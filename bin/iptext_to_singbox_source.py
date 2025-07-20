#!/bin/env python

"""
This script is used to convert ip in plain text format to singbox source format
usage: iptext_to_singbox_source.py <input_file> <output_file>
"""

import json
import sys

ips = []
input_file, ouput_file = sys.argv[1], sys.argv[2]
with open(input_file, "r") as f:
    for ip in f.readlines():
        ip = ip.strip()
        if ip and "#" not in ip and ":" not in ip:
            ips.append(ip)

output_dict = {"version": 2, "rules": [{"ip_cidr": ips}]}

with open(ouput_file, "w") as f:
    json.dump(output_dict, f, indent=4)
