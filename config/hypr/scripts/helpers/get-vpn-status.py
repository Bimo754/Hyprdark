#!/usr/bin/env python3
"""
Hyprdark Telemetry Helper - VPN Status
Detects active VPN network interfaces (tun, wg, tap, ppp, tailscale, nord, proton)
and returns interface names and IPv4 addresses as JSON.
"""

import json
import os
import re
import subprocess
import sys

def get_vpn_status():
    vpns = []
    try:
        out = subprocess.check_output(["ip", "-o", "-4", "addr", "show"], text=True)
        for line in out.splitlines():
            parts = line.split()
            if len(parts) >= 4:
                iface = parts[1]
                if re.match(r"^(tun|wg|tap|ppp|tailscale|nord|proton)", iface):
                    ip_addr = parts[3].split("/")[0]
                    vpns.append({"iface": iface, "ip": ip_addr})
        vpns.sort(key=lambda x: x["iface"])
    except Exception:
        pass

    if not vpns:
        fallback_file = os.path.expanduser("~/.local/share/hyprdark/vpn_ip")
        if os.path.exists(fallback_file):
            try:
                with open(fallback_file, "r", encoding="utf-8") as f:
                    content = f.read().strip()
                if content and content != "Off":
                    try:
                        parsed = json.loads(content)
                        if isinstance(parsed, list):
                            vpns = parsed
                    except Exception:
                        for idx, line in enumerate(content.splitlines()):
                            line = line.strip()
                            if line and line != "Off":
                                if ":" in line:
                                    pts = line.split(":", 1)
                                    vpns.append({"iface": pts[0].strip(), "ip": pts[1].strip()})
                                else:
                                    vpns.append({"iface": f"tun{idx}", "ip": line})
            except Exception:
                pass

    return vpns

if __name__ == "__main__":
    print(json.dumps(get_vpn_status()))
