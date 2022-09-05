#!/bin/bash

# Title: Add a pub key if it doesn't exist
# Usage: multi-gitter run add_key.sh ~/.ssh/key.pub
# Path must be absolute. The key will be copied into repository's pub_keys folder.

FILE=$1
DIR="pub_keys/"
KEY=$DIR$(basename $1)
echo $KEY
if [ ! -d "$DIR" ]; then
   echo "Destination dir is not present in repository"
   exit 1
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

ssh-keygen -l -f $FILE 1>&2 > /dev/null
valid=$?

if [ ! $valid] ]; then
    echo "Not valid ssh-key"
    exit 1
fi

echo "Valid key"
cp $FILE $KEY
