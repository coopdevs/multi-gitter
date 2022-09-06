#!/bin/bash

# Title: Add a pub key if it doesn't exist
# Usage: multi-gitter run add_key.sh ~/.ssh/key.pub
# Path must be absolute. The key will be copied into repository's pub_keys folder.

FILE=$1
DIR="pub_keys/"
KEY=$DIR$(basename "$1")

if [ ! -d "$DIR" ]; then
   echo "Destination dir is not present in repository"
   exit 2
fi

if [ -f "$KEY" ]; then
    echo "Key is already present"
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
  yq ".system_administrators" < "$YAML"
done
