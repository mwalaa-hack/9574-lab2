# Simple Antivirus Daemon

## Overview

This project is a simple antivirus daemon written in Bash for Ubuntu Linux. It monitors a directory and checks files for suspicious extensions and keywords. If a file matches one of these checks, it is moved to a quarantine directory.

The project also has a restore tool that lets the user check quarantined files. The user can restore a file if it was flagged by mistake, delete it permanently, or leave it in quarantine.

## Project Structure

```text
9574-lab2/

antivirusd.sh        - Monitors the directory and scans files
restore.sh           - Lists quarantined files and allows the user to restore or delete them
Makefile             - Runs the scripts and creates the quarantine directory
README.md            - Project documentation
test_files/          - Directory monitored by the antivirus
quarantine/          - Stores files identified as malicious
directory-info.last  - Previous directory snapshot
directory-info.new   - Current directory snapshot
antivirus-cron.sh    - Scans the directory once when triggered by cron
cron.log             - Stores the cron scan output and errors
```

The antivirus script creates the two snapshot files. It uses them to compare the directory contents and detect changes.

## Prerequisites

The project requires the following:

- Ubuntu Linux
- Bash
- GNU Make
- Standard Linux command-line utilities used by the scripts

No extra packages or external libraries are needed if these tools are already installed.

To check if Bash and Make are installed, run:

```bash
bash --version
make --version
```

If they are not installed, run these commands:

```bash
sudo apt update
sudo apt install bash make
```

## Configuration

The default settings are in the `Makefile`:

```makefile
DIR = test_files
MALICIOUS_DIR = quarantine
INTERVAL = 5
```

These variables are used for the following:

- `DIR`: The directory that the antivirus monitors.
- `MALICIOUS_DIR`: The directory where flagged files are moved.
- `INTERVAL`: The time in seconds between checks.

The file `antivirusd.sh` also contains the extensions and keywords used to flag files:

```bash
flagged_extensions=("exe" "bat" "vbs" "scr" "ps1")
flagged_keywords=("virus" "trojan" "malware" "worm" "ransomware")
```

A file is flagged if its extension matches one of the listed extensions or if its contents contain one of the listed keywords. The keyword check is case-insensitive.

## Running the Antivirus

First, open the terminal and go to the project directory:

```bash
cd ~/Operating_System_labs/9574-lab2
```

To start the antivirus using the Makefile, run:

```bash
make antivirus
```

The Makefile creates the quarantine directory if it does not already exist and then starts the antivirus script.

By default, the daemon checks the directory every five seconds. It scans the files when it starts and checks again when it detects a change in the directory.

To stop the daemon, press `Ctrl+C`.

The script can also be started directly without using the Makefile:

```bash
./antivirusd.sh test_files quarantine 5
```

In this command, `test_files` is the directory to monitor, `quarantine` is where flagged files are moved, and `5` is the interval between checks in seconds.

## Running the Restore Tool

Before starting the restore tool, make sure the antivirus daemon is not running.

To start the restore tool using the Makefile, run:

```bash
make restore
```

The tool shows the files currently in quarantine and asks the user to choose a file by entering its number.

After selecting a file, the user can choose one of three actions:

1. Restore the file to the monitored directory.
2. Delete the file permanently from quarantine.
3. Leave the file as it is and return to the list.

After a file is restored or deleted, the tool displays a confirmation message.

If there are no files in the quarantine directory, the tool displays:

```text
No malicious files to review.
```

The restore script can also be run directly:

```bash
./restore.sh test_files quarantine
```

To exit the interactive tool, press `Ctrl+C`.

**Important:** Do not run the antivirus daemon and the restore tool at the same time.

## Notes

- Files flagged by the antivirus are moved to the quarantine directory.
- When a file is restored, it is moved back to the monitored directory.
- Permanently deleting a file removes it from quarantine.
- The monitored directory and quarantine directory can be changed by editing the DIR and MALICIOUS_DIR variables in the Makefile, or by providing different arguments when running the scripts directly.

## Bonus 1: Cron Job

### Prerequisites

The cron version requires the following:

- Ubuntu Linux
- Bash
- Cron service
- The `antivirus-cron.sh` script
- A directory to monitor and a quarantine directory

To check if cron is installed, run:

```bash
crontab -l
```

If cron is not installed, run:

```bash
sudo apt update
sudo apt install cron
```

Start the cron service and enable it to start automatically at boot:

```bash
sudo systemctl enable --now cron
```

### Configuring the Cron Job

1. Open the terminal and go to the project directory:

   ```bash
   cd ~/Operating_System_labs/9574-lab2
   ```

2. Make the script executable:

   ```bash
   chmod +x antivirus-cron.sh
   ```

3. Run the script manually to make sure it works:

   ```bash
   ./antivirus-cron.sh test_files quarantine
   ```

4. Get the absolute path of the project directory:

   ```bash
   pwd
   ```

5. Open the user crontab:

   ```bash
   crontab -e
   ```

6. Add the following line. Replace the example paths with the actual absolute paths on your system:

   ```cron
   * * * * * sleep 23; /home/mwalaa/Operating_System_labs/9574-lab2/antivirus-cron.sh /home/mwalaa/Operating_System_labs/9574-lab2/test_files /home/mwalaa/Operating_System_labs/9574-lab2/quarantine >> /home/mwalaa/Operating_System_labs/9574-lab2/cron.log 2>&1
   ```

7. Save the file and check that the entry was added:

   ```bash
   crontab -l
   ```

The cron job runs every minute and waits about 23 seconds before starting the scan. The script checks the monitored directory, moves files that match the flagged extensions or keywords to quarantine, and then exits.

The output and any errors are saved in `cron.log`.

Cron does not support scheduling jobs directly by seconds. The `sleep 23` command delays the scan by approximately 23 seconds after the cron job starts.

To stop the scheduled job, open the crontab again:

```bash
crontab -e
```

Remove the antivirus entry and save the file. Make sure not to remove any other cron entries.

### Running the Scan on the Third Friday of Every Month

To run the scan at 12:31 AM on the third Friday of every month, add the following entry to the crontab:

```cron
31 0 15-21 * * [ "$(date +\%u)" -eq 5 ] && /home/mwalaa/Operating_System_labs/9574-lab2/antivirus-cron.sh /home/mwalaa/Operating_System_labs/9574-lab2/test_files /home/mwalaa/Operating_System_labs/9574-lab2/quarantine
```

Replace the example paths with the actual absolute paths on your system.

The third Friday of every month falls between the 15th and 21st. The command checks whether the current day is Friday (`5`) and runs the scan only if the date is within that range and the day is Friday.