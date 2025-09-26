#!/bin/bash

# archive.sh - A script to archive/backup directories with timestamps
# Author: GitHub Copilot
# Version: 1.0

# Function to display usage/help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS] SOURCE_DIR TARGET_DIR

Archive/backup files from SOURCE_DIR to TARGET_DIR with a timestamped folder.

ARGUMENTS:
    SOURCE_DIR    Directory to archive/backup
    TARGET_DIR    Directory where the timestamped backup folder will be created

OPTIONS:
    -h, --help    Show this help message and exit

EXAMPLES:
    $0 /home/user/documents /backups
    $0 ./src ./archives

DESCRIPTION:
    This script creates a timestamped folder (e.g., backup_20250925_143022) 
    in the target directory and copies all files from the source directory 
    using rsync for efficient transfer.

EOF
}

# Function to validate directory exists
validate_source_dir() {
    if [[ ! -d "$1" ]]; then
        echo "Error: Source directory '$1' does not exist or is not accessible." >&2
        exit 1
    fi
}

# Function to create target directory if it doesn't exist
ensure_target_dir() {
    if [[ ! -d "$1" ]]; then
        echo "Creating target directory: $1"
        mkdir -p "$1" || {
            echo "Error: Failed to create target directory '$1'" >&2
            exit 1
        }
    fi
}

# Function to generate timestamp
generate_timestamp() {
    date +"%Y%m%d_%H%M%S"
}

# Function to perform the archive operation
archive_files() {
    local source_dir="$1"
    local target_dir="$2"
    local timestamp="$3"
    local backup_folder="${target_dir}/backup_${timestamp}"
    
    echo "Creating backup folder: $backup_folder"
    mkdir -p "$backup_folder" || {
        echo "Error: Failed to create backup folder '$backup_folder'" >&2
        exit 1
    }
    
    echo "Archiving files from '$source_dir' to '$backup_folder'..."
    
    # Use rsync for efficient copying with progress
    if command -v rsync >/dev/null 2>&1; then
        rsync -av --progress "$source_dir/" "$backup_folder/" || {
            echo "Error: Failed to copy files using rsync" >&2
            exit 1
        }
    else
        # Fallback to cp if rsync is not available
        echo "rsync not found, using cp instead..."
        cp -r "$source_dir"/* "$backup_folder"/ 2>/dev/null || {
            echo "Error: Failed to copy files using cp" >&2
            exit 1
        }
    fi
    
    echo "Archive completed successfully!"
    echo "Backup location: $backup_folder"
}

# Main script logic
main() {
    # Parse command line arguments
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        "")
            echo "Error: Missing required arguments." >&2
            echo "Use '$0 --help' for usage information." >&2
            exit 1
            ;;
    esac
    
    # Check if we have exactly 2 arguments (after parsing options)
    if [[ $# -ne 2 ]]; then
        echo "Error: Expected exactly 2 arguments, got $#." >&2
        echo "Use '$0 --help' for usage information." >&2
        exit 1
    fi
    
    local source_dir="$1"
    local target_dir="$2"
    
    # Validate inputs
    validate_source_dir "$source_dir"
    ensure_target_dir "$target_dir"
    
    # Generate timestamp and perform archive
    local timestamp
    timestamp=$(generate_timestamp)
    
    echo "Starting archive operation..."
    echo "Source: $source_dir"
    echo "Target: $target_dir"
    echo "Timestamp: $timestamp"
    echo "----------------------------------------"
    
    archive_files "$source_dir" "$target_dir" "$timestamp"
}

# Run main function with all arguments
main "$@"