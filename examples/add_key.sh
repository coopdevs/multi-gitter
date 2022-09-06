#!/bin/bash

# Title: Add a pub key if it doesn't exist
# Usage: multi-gitter run add_key.sh ~/.ssh/key.pub
# Path must be absolute. The key will be copied into repository's pub_keys folder.

FILE=$1
DIR="pub_keys/"
KEY=$DIR$(basename "$1")
USER=$(basename "$FILE" .pub)
NEW_SYSADMIN="
---
system_administrators:
  - name: $USER
    ssh_key: '{{ inventory_dir }}/../pub_keys/$USER.pub'
    state: present
"

if [ ! -d "$DIR" ]; then
   echo "Destination dir is not present in repository"
   exit 2
fi

if [ ! -f "$FILE" ]; then
    echo "File $FILE not found"
    ls
    exit 1
fi

ssh-keygen -l -f "$FILE" 1>&2 > /dev/null
valid=$?

if [[ ! $valid ]]; then
    echo "Not valid ssh-key"
    exit 1
fi

echo "Valid key"
cp "$FILE" "$KEY"

## Add user and key to the inventory file

INVENTORY=$(ls inventory/host_vars/**/*.yml)

for YAML in $INVENTORY; do
  DIR=$(dirname "$YAML")
  echo "$YAML"
  if [[ "$DIR" =~ .*"local"$ || "$YAML" == *"secrets.yml" ]]; then     
    continue
  fi
  NAMES=$(yq "[.system_administrators.[].name] | @csv" < "$YAML")
  for NAME in $NAMES; do
    IFS=,
    if [[ "$NAME" == "$USER" ]]; then
      echo "User $USER already present in $YAML"
      exit 2
    else
    echo "Adding user $USER to $YAML"
    echo "$NEW_SYSADMIN" > new_sysadmin.yml
    yq eval-all 'select(fileIndex == 0) *+ select(fileIndex == 1)' new_sysadmin.yml "$YAML" >> tmp.yml
    #yq '. *= load("new_sysadmin.yml")' "$YAML"
    rm new_sysadmin.yml "$YAML"
    mv tmp.yml "$YAML"
    cat "$YAML"
    #yq -i ".system_administrators += [$NEW_SYSADMIN]" "$YAML"
    fi
   done
done
