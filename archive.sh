#!/bin/bash

# Logging function that outputs to both terminal and archive.log
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local log_entry="$level: [$timestamp] $message"
    
    # Display the message to the user's terminal for immediate feedback
    echo "$log_entry"
    # Append the same message to our persistent log file for historical tracking
    echo "$log_entry" >> archive.log
}

# Parse command line flags
DRY_RUN=false

# Check for flags first
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "Usage: $0 [OPTIONS] [SOURCE_DIR] [TARGET_DIR]"
            echo "Creates a compressed .tar.gz archive that has automatic timestamping"
            echo "MODES:"
            echo "  With arguments:    $0 SOURCE_DIR TARGET_DIR"
            echo "  With config file:  $0 (uses archive.conf)"

            echo "OPTIONS:"
            echo "  -h, --help    Show this help message"
            echo "  -d, --dry-run   Show what would be backed up without actually backing up"
            echo ""
            echo "EXAMPLES:"
            echo "  $0 /home/user/documents /backups"
            echo "  $0 --dry-run ./src ./archives"
            echo "  $0 -d  (dry-run using archive.conf)"
            echo ""
            echo "EXCLUSIONS:"
            echo "Create '.bassignore' file to exclude patterns like .gitignore does"
            echo "CONFIG FILE:"
            echo " Edit 'archive.conf' to set default SOURCE_DIR and TARGET_DIR"
            exit 0
            ;;
        -d|--dry-run)
            # Enable dry-run mode: show what would happen without actually creating backups
            # This is useful for testing and previewing backup operations before committing to them
            DRY_RUN=true
            shift  # Remove this argument from the argument list and continue processing
            ;;
        -*)
            # Handle any unrecognized flags or options with proper error reporting
            # This ensures users get feedback when they mistype command options
            log_message "ERROR" "Unknown option: $1"
            exit 1
            ;;
        *)
            # Exit the flag processing loop when we encounter non-flag arguments
            # This allows us to process positional arguments (source/target directories) separately
            break
            ;;
    esac
done

# Initialize script execution with comprehensive logging for audit trail and debugging purposes
# This marks the official start of the backup process and begins our log file tracking
log_message "INFO" "archive script started"

# Special logging for dry-run mode to ensure users understand they're in simulation mode
# This prevents confusion about whether actual backups are being created or just simulated
if [ "$DRY_RUN" = true ]; then
    log_message "INFO" "Dry-run enabled. Simulating backup"
fi

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

# Build tar exclusion options from .bassignore if it exists
TAR_EXCLUDE_OPTS=""
BASSIGNORE_FILE=".bassignore"

if [ -f "$BASSIGNORE_FILE" ]; then
    log_message "INFO" "Found exclusion file: $BASSIGNORE_FILE"
    while IFS= read -r pattern || [ -n "$pattern" ]; do
        # Skip empty lines and comments
        if [[ ! "$pattern" =~ ^[[:space:]]*# ]] && [[ -n "$pattern" ]]; then
            pattern=$(echo "$pattern" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [[ -n "$pattern" ]]; then
                TAR_EXCLUDE_OPTS="$TAR_EXCLUDE_OPTS --exclude=$pattern"
            fi
        fi
    done < "$BASSIGNORE_FILE"
fi

# Dry-run mode: show what would be included
if [ "$DRY_RUN" = true ]; then
    log_message "INFO" "Dry-run mode: Files that would be included in backup:"
    if [ -n "$TAR_EXCLUDE_OPTS" ]; then
        eval "tar -czf /dev/null -C '$SRC' $TAR_EXCLUDE_OPTS --verbose . 2>/dev/null" || true
    else
        tar -czf /dev/null -C "$SRC" --verbose . 2>/dev/null || true
    fi
    log_message "INFO" "Dry-run completed. No actual backup was created"
    exit 0
fi

# Create compressed archive using tar with exclusions
if [ -n "$TAR_EXCLUDE_OPTS" ]; then
    if eval "tar -czf '$TARGET_FILE' -C '$SRC' $TAR_EXCLUDE_OPTS . 2>/dev/null"; then
        log_message "INFO" "Backup completed successfully"
    else
        log_message "ERROR" "Backup failed during compression"
        exit 1
    fi
else
    if tar -czf "$TARGET_FILE" -C "$SRC" . 2>/dev/null; then
        log_message "INFO" "Backup completed successfully"
    else
        log_message "ERROR" "Backup failed during compression"
        exit 1
    fi
fi
