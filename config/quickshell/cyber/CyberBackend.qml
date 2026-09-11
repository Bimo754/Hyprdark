import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: backendRoot

    property string targetIp: ""
    property var domains: []
    readonly property bool hasTarget: targetIp.length > 0 && targetIp !== "Unset" && targetIp !== "NONE"

    property string vpnIp: ""
    property string vpnInterface: "None"
    readonly property bool vpnConnected: vpnIp.length > 0 && vpnIp !== "Disconnected" && vpnIp !== "None"

    signal actionFeedback(string title, string message)

    // 1. Target Telemetry Reader
    Process {
        id: targetReader
        command: ["python3", "-c", "import os, json; d=os.path.expanduser('~/.local/share/hyprdark'); ip_f=os.path.join(d,'target_ip'); dom_f=os.path.join(d,'target_domains'); ip=open(ip_f).read().strip() if os.path.exists(ip_f) else ''; doms=[l.strip() for l in open(dom_f) if l.strip()] if os.path.exists(dom_f) else []; print(json.dumps({'ip':ip,'domains':doms}))"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let parsed = JSON.parse(data);
                    backendRoot.targetIp = parsed.ip || "";
                    backendRoot.domains = parsed.domains || [];
                } catch(e) {}
            }
        }
    }

    // 2. VPN Telemetry Reader
    Process {
        id: vpnReader
        command: ["python3", "-c", "import subprocess, json, re\nout = ''\niface = 'None'\nip = 'Disconnected'\ntry:\n    res = subprocess.check_output(['ip', '-o', '-4', 'addr', 'show'], text=True)\n    for line in res.splitlines():\n        for dev in ['tun0', 'wg0', 'proton0', 'tap0']:\n            if f' {dev} ' in line:\n                m = re.search(r'inet (\\d+\\.\\d+\\.\\d+\\.\\d+)', line)\n                if m:\n                    ip = m.group(1)\n                    iface = dev\n                    break\nexcept Exception:\n    pass\nprint(json.dumps({'ip': ip, 'interface': iface}))"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    let parsed = JSON.parse(data);
                    backendRoot.vpnIp = parsed.ip || "Disconnected";
                    backendRoot.vpnInterface = parsed.interface || "None";
                } catch(e) {}
            }
        }
    }

    Timer {
        id: telemetryTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            targetReader.running = true;
            vpnReader.running = true;
        }
    }

    function refresh() {
        targetReader.running = true;
        vpnReader.running = true;
    }

    function runCmd(cmd) {
        let p = Qt.createQmlObject('import Quickshell.Io 1.0; Process { command: ["bash", "-c", "' + cmd.replace(/"/g, '\\"') + '"] }', backendRoot);
        p.running = true;
    }

    function copyToClipboard(text) {
        if (!text || text.length === 0) return;
        runCmd("echo -n '" + text + "' | wl-copy");
        actionFeedback("Copied", "Copied to clipboard: " + text);
    }

    function copyTarget() {
        if (hasTarget) {
            copyToClipboard(targetIp);
        } else {
            actionFeedback("Target", "No target IP configured");
        }
    }

    function copyVpn() {
        if (vpnConnected) {
            copyToClipboard(vpnIp);
        } else {
            actionFeedback("VPN", "VPN is currently disconnected");
        }
    }

    function setTarget(input) {
        if (!input || input.trim() === "") return;
        let val = input.trim();
        if (val === "clear" || val === "reset") {
            clearTarget();
            return;
        }
        if (val.startsWith("+")) {
            let dom = val.substring(1).trim();
            runCmd("~/.config/hyprdark/scripts/set-target.sh -a '" + dom + "' 2>/dev/null || ~/Desktop/Github/Hyprdark/scripts/set-target.sh -a '" + dom + "'");
            actionFeedback("Domain Added", dom);
        } else if (val.startsWith("-")) {
            let dom = val.substring(1).trim();
            runCmd("~/.config/hyprdark/scripts/set-target.sh -r '" + dom + "' 2>/dev/null || ~/Desktop/Github/Hyprdark/scripts/set-target.sh -r '" + dom + "'");
            actionFeedback("Domain Removed", dom);
        } else {
            runCmd("~/.config/hyprdark/scripts/set-target.sh '" + val + "' 2>/dev/null || ~/Desktop/Github/Hyprdark/scripts/set-target.sh '" + val + "'");
            actionFeedback("Target Set", val);
        }
        refresh();
    }

    function clearTarget() {
        runCmd("~/.config/hyprdark/scripts/set-target.sh clear 2>/dev/null || ~/Desktop/Github/Hyprdark/scripts/set-target.sh clear");
        actionFeedback("Target", "Target IP and domains cleared");
        refresh();
    }

    function launchHttpServer() {
        runCmd("kitty --title 'Python HTTP Server :8000' bash -c 'echo \"[+] Launching HTTP Server on 0.0.0.0:8000...\"; python3 -m http.server 8000' &");
        actionFeedback("HTTP Server", "Started on port 8000");
    }

    function runNmapScan(scanType) {
        if (!hasTarget) {
            actionFeedback("Scan Error", "Please set an active target IP first!");
            return;
        }
        let target = targetIp;
        let cmd = "";
        let title = "";

        if (scanType === "fast") {
            title = "Nmap Fast: " + target;
            cmd = "echo '[*] Fast Scan on " + target + "...'; sudo nmap -F -sV -T4 " + target + "; echo ''; read -p 'Press Enter to close...'";
        } else if (scanType === "vuln") {
            title = "Nmap Vuln: " + target;
            cmd = "echo '[*] Vuln Script Scan on " + target + "...'; sudo nmap --script vuln -Pn " + target + "; echo ''; read -p 'Press Enter to close...'";
        } else {
            title = "Nmap Standard: " + target;
            cmd = "echo '[*] Standard Scan on " + target + "...'; sudo nmap -sC -sV -Pn " + target + "; echo ''; read -p 'Press Enter to close...'";
        }

        runCmd("kitty --title '" + title + "' bash -c \"" + cmd + "\" &");
        actionFeedback("Nmap Scan", "Launched scan for " + target);
    }

    function launchGuiTool(tool) {
        if (tool === "burpsuite") {
            runCmd("burpsuite >/dev/null 2>&1 &");
            actionFeedback("Arsenal", "Launching Burp Suite");
        } else if (tool === "wireshark") {
            runCmd("wireshark >/dev/null 2>&1 &");
            actionFeedback("Arsenal", "Launching Wireshark");
        } else if (tool === "msfconsole") {
            runCmd("kitty --title 'Metasploit Framework' bash -c 'msfconsole' &");
            actionFeedback("Arsenal", "Launching Metasploit");
        }
    }

    function toggleScratchpad() {
        runCmd("hyprctl dispatch togglespecialworkspace scratchpad");
    }

    function lockWorkstation() {
        runCmd("hyprlock");
    }

    function switchWallpaper() {
        runCmd("~/.config/hyprdark/scripts/wallpaper-ctl.sh --next 2>/dev/null || ~/Desktop/Github/Hyprdark/scripts/wallpaper-ctl.sh --next");
        actionFeedback("Wallpaper", "Rotated wallpaper");
    }

    function openNetworkStatus() {
        let msg = "LAN: " + (backendRoot.targetIp || "None") + "\\nVPN (" + backendRoot.vpnInterface + "): " + (backendRoot.vpnIp || "Disconnected");
        runCmd("notify-send 'Network Status' '" + msg + "' -u normal");
        actionFeedback("Network Status", "LAN & VPN status dispatched");
    }
}
