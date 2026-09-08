#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <ctype.h>

static ssize_t (*real_send)(int sockfd, const void *buf, size_t len, int flags) = NULL;
static ssize_t (*real_write)(int fd, const void *buf, size_t count) = NULL;

__attribute__((constructor))
static void init(void) {
    real_send = dlsym(RTLD_NEXT, "send");
    real_write = dlsym(RTLD_NEXT, "write");
}

static char* rewrite_hypr_cmd(const char *buf, size_t len, size_t *new_len) {
    if (!buf || len < 8) return NULL;

    const char *p = buf;
    // Skip optional leading "dispatch "
    if (len >= 9 && strncmp(p, "dispatch ", 9) == 0) {
        p += 9;
    }

    int is_focus = 0;
    int is_move = 0;
    int is_silent = 0;

    if (strncmp(p, "workspace ", 10) == 0) {
        p += 10;
        is_focus = 1;
    } else if (strncmp(p, "focusworkspaceoncurrentmonitor ", 31) == 0) {
        p += 31;
        is_focus = 1;
    } else if (strncmp(p, "movetoworkspace ", 16) == 0) {
        p += 16;
        is_move = 1;
    } else if (strncmp(p, "movetoworkspacesilent ", 22) == 0) {
        p += 22;
        is_move = 1;
        is_silent = 1;
    }

    if (is_focus || is_move) {
        while (*p == ' ') p++;
        char ws[64] = {0};
        int i = 0;
        while (*p && *p != '\n' && *p != '\r' && *p != ' ' && i < 63) {
            ws[i++] = *p++;
        }
        ws[i] = '\0';

        char *out = malloc(384);
        if (!out) return NULL;

        // Strip "name:" prefix if present
        const char *ws_clean = ws;
        if (strncmp(ws_clean, "name:", 5) == 0) {
            ws_clean += 5;
        }

        // Determine if target is integer or string
        int is_num = 1;
        for (const char *c = ws_clean; *c; c++) {
            if (!isdigit((unsigned char)*c)) {
                is_num = 0;
                break;
            }
        }

        if (is_focus) {
            if (is_num && *ws_clean) {
                snprintf(out, 384, "dispatch hl.dsp.focus({ workspace = %s })\n", ws_clean);
            } else {
                snprintf(out, 384, "dispatch hl.dsp.focus({ workspace = \"%s\" })\n", ws_clean);
            }
        } else if (is_move) {
            if (is_num && *ws_clean) {
                if (is_silent) {
                    snprintf(out, 384, "dispatch hl.dsp.window.move({ workspace = %s, silent = true })\n", ws_clean);
                } else {
                    snprintf(out, 384, "dispatch hl.dsp.window.move({ workspace = %s })\n", ws_clean);
                }
            } else {
                if (is_silent) {
                    snprintf(out, 384, "dispatch hl.dsp.window.move({ workspace = \"%s\", silent = true })\n", ws_clean);
                } else {
                    snprintf(out, 384, "dispatch hl.dsp.window.move({ workspace = \"%s\" })\n", ws_clean);
                }
            }
        }

        *new_len = strlen(out);
        return out;
    }

    return NULL;
}

ssize_t send(int sockfd, const void *buf, size_t len, int flags) {
    if (!real_send) real_send = dlsym(RTLD_NEXT, "send");
    size_t new_len = 0;
    char *new_cmd = rewrite_hypr_cmd((const char*)buf, len, &new_len);
    if (new_cmd) {
        ssize_t res = real_send(sockfd, new_cmd, new_len, flags);
        free(new_cmd);
        return (res > 0) ? len : res;
    }
    return real_send(sockfd, buf, len, flags);
}

ssize_t write(int fd, const void *buf, size_t count) {
    if (!real_write) real_write = dlsym(RTLD_NEXT, "write");
    size_t new_len = 0;
    char *new_cmd = rewrite_hypr_cmd((const char*)buf, count, &new_len);
    if (new_cmd) {
        ssize_t res = real_write(fd, new_cmd, new_len);
        free(new_cmd);
        return (res > 0) ? count : res;
    }
    return real_write(fd, buf, count);
}
