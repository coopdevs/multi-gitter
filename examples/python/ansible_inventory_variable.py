#!/usr/bin/env python3

# Title: Python script to add or change a variable in an Ansible inventory file

import yaml


def change_inventory_var(var_name: str, var_value: str | int | list | bool, create: bool = False,
                         inventory_file: str = './inventory/group_vars/all.yml'):
    """
    Change a key-value entry in the inventory file (or create it if it doesn't exist)
    @param var_name: The name of the variable
    @param var_value: The value of the variable.
    @param create: Create the key if it doesn't exist already in file (default: False)
    @param inventory_file: The path to the inventory vars file (Default: ./inventory/group_vars/all.yml)
    """
    with open(inventory_file, 'r') as file:
        content = yaml.safe_load(file)
        keys = content.keys()
        if var_name not in keys and not create:
            print(var_name + " not found")
            exit(0)
        content[var_name] = var_value
        print("New value for variable: " +
              var_name + ": " + var_value)
    with open(inventory_file, 'w') as file:
        yaml.safe_dump(content, file)


# Changing a simple key-value entry
change_inventory_var('demo_data', 'True')

# Adding a new secret
change_inventory_var('new_exporter_secret', 'ENCRYPTEDSTRING', True, './inventory/group_vars/secrets.yml')
