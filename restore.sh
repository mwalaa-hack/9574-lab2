#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 dir malicious_dir"
    exit 1
fi



dir="$1"
malicious_dir="$2"



if [ ! -d "$dir" ]; then
    echo "Error: directory '$dir' does not exist."
    exit 1
fi

if [ ! -d "$malicious_dir" ]; then
    echo "Error: malicious directory '$malicious_dir' does not exist."
    exit 1
fi

while true
do
    files=("$malicious_dir"/*)

    if [ ! -e "${files[0]}" ]; then
        echo "No malicious files to review."
        exit 0
    fi

    echo "Malicious files:"

    for i in "${!files[@]}"
    do
        filename=$(basename "${files[$i]}")
        echo "$((i + 1)). $filename"
    done

    echo -n "Choose a file by number (or press Ctrl+C to exit): "
    read choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#files[@]}" ]; then
        echo "Invalid choice."
        continue
    fi

    selected_file="${files[$((choice - 1))]}"
    filename=$(basename "$selected_file")





    echo
    echo "Selected: $filename"
    echo "1. Restore this file"
    echo "2. Permanently delete this file"
    echo "3. Leave this file as-is and return to the list"
    echo -n "Choose an option: "
    read option

    if [ "$option" -eq 1 ]; then
        mv "$selected_file" "$dir/$filename"
        echo "Restored $filename to $dir."

    elif [ "$option" -eq 2 ]; then
        rm "$selected_file"
        echo "$filename permanently deleted."

    elif [ "$option" -eq 3 ]; then
        continue

    else
        echo "Invalid option."
    fi
done