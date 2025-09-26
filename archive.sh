#!/bin/bash

# Logging function that outputs to both terminal and archive.log
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local log_entry="$level: [$timestamp] $message"
    
    echo "$log_entry"
    echo "$log_entry" >> archive.log
}

# help section
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $0 [OPTIONS] [SOURCE_DIR] [TARGET_DIR]"
    echo ""
    echo "Creates a compressed .tar.gz archive with automatic timestamping"
    echo ""
    echo "MODES:"
    echo "  With arguments:    $0 SOURCE_DIR TARGET_DIR"
    echo "  With config file:  $0 (uses archive.conf)"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "EXAMPLES:"
    echo "  $0 /home/user/documents /backups"
    echo "  $0 ./src ./archives"
    echo "  $0  (uses paths from archive.conf)"
    echo ""
    echo "CONFIG FILE:"
    echo "  Edit 'archive.conf' to set default SOURCE_DIR and TARGET_DIR"
    exit 0
fi

# Log start of execution
log_message "INFO" "archive script started"

# Configuration file handling
CONFIG_FILE="archive.conf"

# Check if we should use config file or command line arguments
if [ $# -eq 0 ]; then
    # No arguments provided - try to use config file
    if [ -f "$CONFIG_FILE" ]; then
        log_message "INFO" "No arguments provided, loading configuration from $CONFIG_FILE"
        source "$CONFIG_FILE"
        SRC="$SOURCE_DIR"
        DST="$TARGET_DIR"
    else
        log_message "ERROR" "No arguments provided and no config file ($CONFIG_FILE) found. Use -h for help."
        exit 1
    fi
elif [ $# -eq 2 ]; then
    # Two arguments provided - use command line arguments
    log_message "INFO" "Using command line arguments"
    SRC="$1"
    DST="$2"
else
    # Wrong number of arguments
    log_message "ERROR" "Incorrect number of arguments. Use -h or --help for usage."
    exit 1
fi

# Source directory validation
if [ ! -d "$SRC" ]; then
    log_message "ERROR" "Source directory ($SRC) does not exist or is not readable. Exiting."
    exit 1
fi

# Target directory validation - create if it doesn't exist
if [ ! -d "$DST" ]; then
    mkdir -p "$DST" || {
        log_message "ERROR" "Target directory ($DST) does not exist or could not be created. Exiting."
        exit 1
    }
fi

# create timestamped compressed backup
TS=$(date +"%Y%m%d_%H%M%S")
TARGET_FILE="$DST/backup_${TS}.tar.gz"

# Log confirmation of backup action
log_message "INFO" "Backing up from $SRC to $TARGET_FILE"

# Create compressed archive using tar
if tar -czf "$TARGET_FILE" -C "$SRC" . 2>/dev/null; then
    log_message "INFO" "Backup completed successfully"
else
    log_message "ERROR" "Backup failed during compression"
    exit 1
fi
