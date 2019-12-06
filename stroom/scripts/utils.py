"""
Functions used in several other files
"""
from os import fdopen, remove
from shutil import move
from tempfile import mkstemp
import fileinput
import json
import re
import subprocess


def get_inventory():
    out = subprocess.Popen(
        ['ansible-inventory', '--list'],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout, stderr = out.communicate()
    # inventory = json.loads(stdout) python 3.6 only
    inventory = json.loads(stdout.decode("utf-8"))
    return inventory


def get_service_fqdn(inventory):
    # We'll use the first services host as the fqdn. YMMV.
    if "stroom_services_stack" in inventory.keys():
        host_line = inventory["stroom_services_stack"]["hosts"][0]
    else:
        host_line = inventory["stroom_core_stack"]["hosts"][0]

    if '@' in host_line:
        fqdn = host_line.split('@')[1]
    else:
        fqdn = host_line

    return fqdn


def get_db_fqdn(inventory):
    # We'll use the first database host as the fqdn. YMMV.
    if "stroom_dbs_stack" in inventory.keys():
        host_line = inventory["stroom_dbs_stack"]["hosts"][0]
    else:
        host_line = inventory["database"]["hosts"][0]

    if '@' in host_line:
        fqdn = host_line.split('@')[1]
    else:
        fqdn = host_line

    return fqdn


def remove_line_from_file(path, line_contents):
    with open(path, "r") as f:
        lines = f.readlines()
    with open(path, "w") as f:
        for line in lines:
            if line_contents not in line:
                f.write(line)


def replace_line(file_path, substring_to_find, new_line):
    temp_file, temp_file_path = mkstemp()
    with fdopen(temp_file,'w') as new_file:
        with open(file_path) as old_file:
            for line in old_file:
                if substring_to_find in line:
                    new_file.write(new_line)
                else:
                    new_file.write(line)

    remove(file_path)
    move(temp_file_path, file_path)

def regex_replace(file_path, regex_match, regex_replacement):
    for line in fileinput.input(file_path, inplace=1):
        new_line = re.sub(regex_match, regex_replacement, line)
        new_line = new_line.strip("\n")
        # print to the file not stdout
        print(new_line)

