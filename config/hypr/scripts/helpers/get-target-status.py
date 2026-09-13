#!/usr/bin/env python3
"""
Hyprdark Telemetry Helper - Target Status
Returns active target IP and associated domains as JSON.
"""

import json
import os
import sys

def get_target_status():
    data_dir = os.path.expanduser("~/.local/share/hyprdark")
    ip_file = os.path.join(data_dir, "target_ip")
    domains_file = os.path.join(data_dir, "target_domains")

    target_ip = ""
    domains = []

    if os.path.exists(ip_file):
        try:
            with open(ip_file, "r", encoding="utf-8") as f:
                target_ip = f.read().strip()
        except OSError:
            pass

    if os.path.exists(domains_file):
        try:
            with open(domains_file, "r", encoding="utf-8") as f:
                domains = [line.strip() for line in f if line.strip()]
        except OSError:
            pass

    return {
        "ip": target_ip,
        "domains": domains
    }

if __name__ == "__main__":
    print(json.dumps(get_target_status()))
