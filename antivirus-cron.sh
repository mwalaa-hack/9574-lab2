#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 dir malicious_dir"
    exit 1
fi



dir="$1"
malicious_dir="$2"
whitelist="$dir/../whitelist.txt"



if [ ! -d "$dir" ]; then
    echo "Error: directory '$dir' does not exist."
    exit 1
fi

if [ ! -d "$malicious_dir" ]; then
    mkdir -p "$malicious_dir"
fi


flagged_extensions=("exe" "bat" "vbs" "scr" "ps1")
flagged_keywords=("virus" "trojan" "malware" "worm" "ransomware")


for file in "$dir"/*
do
    if [ ! -f "$file" ]; then
        continue
    fi

    filename=$(basename "$file")
    if [ -f "$whitelist" ] && grep -Fxq "$filename" "$whitelist"; then
        continue
    fi
    extension="${filename##*.}"

    for flagged in "${flagged_extensions[@]}"
    do
        if [ "$extension" = "$flagged" ]; then
            cp "$file" "$malicious_dir/$filename"
            rm "$file"
            echo "$filename is malicious and it is DELETED"
            continue 2
        fi
    done

    for keyword in "${flagged_keywords[@]}"
    do
        if grep -qi "$keyword" "$file"; then
            cp "$file" "$malicious_dir/$filename"
            rm "$file"
            echo "$filename is malicious and it is DELETED"
            break
        fi
    done
done
