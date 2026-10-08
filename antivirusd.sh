#!/bin/bash

# Functions

scan_directory()
{
    for file in "$dir"/*
    do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            extension="${filename##*.}"

            for flagged in "${flagged_extensions[@]}"
            do
                if [ "$extension" = "$flagged" ]; then
                    echo "$filename is malicious and it is DELETED"
                    cp "$file" "$malicious_dir/$filename"
                    rm "$file"
                    continue 2
                fi
            done

            for keyword in "${flagged_keywords[@]}"
            do
                if grep -qi "$keyword" "$file"; then
                    echo "$filename is malicious and it is DELETED"
                    cp "$file" "$malicious_dir/$filename"
                    rm "$file"
                    break
                fi
            done
        fi
    done
}




# Code

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 dir malicious_dir interval-secs"
    exit 1
fi




dir="$1"
malicious_dir="$2"
interval="$3"
flagged_extensions=("exe" "bat" "vbs" "scr" "ps1")
flagged_keywords=("virus" "trojan" "malware" "worm" "ransomware")




if [ ! -d "$dir" ]; then
    echo "Error: directory '$dir' does not exist."
    exit 1
fi

if [ ! -d "$malicious_dir" ]; then
    mkdir -p "$malicious_dir"
fi

echo "Monitoring: $dir"
echo "Quarantine: $malicious_dir"
echo "Interval: $interval seconds"

if [ ! -f "directory-info.last" ]; then
    echo "First run: directory has not been scanned yet."
    scan_directory
    ls -l "$dir" > directory-info.last
    echo "Initial directory snapshot created."
fi




while true
do
    sleep "$interval"

    ls -l "$dir" > directory-info.new

    if cmp -s directory-info.last directory-info.new
    then
        echo "No change detected."
    else
        echo "Change detected."
        scan_directory
        cp directory-info.new directory-info.last
    fi
done