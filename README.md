# AutoBass - Automatic Backup System

**Version 1.0** | A professional bash script for automated file archiving with compression, exclusions, and dry-run capabilities.

AutoBass creates timestamped, compressed backups of your important files and directories. It supports flexible configuration options, pattern-based exclusions, and simulation modes to help you manage your backup workflow efficiently and safely.

## Features

- 🗜️ **Compression**: Creates space-efficient `.tar.gz` archives
- 📝 **Smart Logging**: Dual output to terminal and persistent log file
- ⚙️ **Configuration File**: Set default paths for automated workflows
- 🚫 **Exclusions**: Skip files using `.bassignore` patterns (like `.gitignore`)
- 🔍 **Dry-Run Mode**: Preview backups before creating them
- 🏷️ **Timestamping**: Automatic unique naming with date/time stamps

## Installation

### Prerequisites
- Unix-like operating system (macOS, Linux, etc.)
- Bash shell (version 4.0 or later)
- `tar` command (usually pre-installed)
- Basic terminal knowledge

### Download and Setup

1. **Download the script:**
   ```bash
   # Clone the repository
   git clone https://github.com/mbazal/autobass.git
   cd autobass
   ```

2. **Make the script executable:**
   ```bash
   chmod +x archive.sh
   ```

3. **Optional - Add to your PATH for global access:**
   ```bash
   # Copy to a directory in your PATH
   sudo cp archive.sh /usr/local/bin/autobass
   ```

## Usage

AutoBass supports multiple operation modes for maximum flexibility:

### Basic Usage (Command Line Arguments)

```bash
./archive.sh SOURCE_DIRECTORY TARGET_DIRECTORY
```

**Examples:**
```bash
# Backup documents to external drive
./archive.sh /home/user/documents /media/backup

# Backup project to safe storage
./archive.sh ./my-project ./backups

# Backup with full paths
./archive.sh /Users/john/Desktop /Users/john/SafeStorage
```

### Configuration File Mode

For frequent backups, use the configuration file for convenience:

1. **Edit `archive.conf`** with your default paths:
   ```bash
   # Example configuration
   SOURCE_DIR="/home/user/important-files"
   TARGET_DIR="/home/user/backups"
   ```

2. **Run without arguments:**
   ```bash
   ./archive.sh
   ```

### Dry-Run Mode (Preview)

Test your backup before creating it:

```bash
# Preview with command line arguments
./archive.sh --dry-run /path/to/source /path/to/target

# Preview using config file
./archive.sh -d

# Short form dry-run
./archive.sh -d ./documents ./backup-test
```

### Help and Options

```bash
./archive.sh --help    # Show detailed usage information
./archive.sh -h        # Short help flag
```

## Configuration

### Configuration File (`archive.conf`)

Create and customize `archive.conf` for default backup locations:

```bash
# AutoBass Configuration File
# Set your preferred default directories

# Source directory to backup from
SOURCE_DIR="/home/user/documents"

# Target directory to store backups
TARGET_DIR="/media/external-drive/backups"
```

**Benefits:**
- No need to specify paths each time
- Perfect for automated scripts and cron jobs
- Easy to change default locations

### Exclusion File (`.bassignore`)

Create `.bassignore` to exclude unwanted files and directories:

```bash
# AutoBass Exclusion Patterns
# One pattern per line, supports wildcards

# Temporary files
*.tmp
*.temp
*~

# Log files  
*.log
logs/

# Cache directories
cache/
.cache/
node_modules/

# OS files
.DS_Store
Thumbs.db

# Development files
.git/
.svn/
```

**Pattern Examples:**
- `*.log` - Excludes all `.log` files
- `tmp/` - Excludes `tmp` directory and all contents
- `.cache/` - Excludes hidden cache directories
- `*~` - Excludes backup files ending with `~`

### Output Format

Backups are created with automatic timestamping:
```
backup_YYYYMMDD_HHMMSS.tar.gz
```

**Examples:**
- `backup_20250926_143022.tar.gz`
- `backup_20250926_091545.tar.gz`

## Logging

AutoBass provides comprehensive logging for audit trails and troubleshooting:

### Terminal Output
- Real-time progress updates
- Success/error notifications  
- Dry-run preview results

### Log File (`archive.log`)
- Persistent record of all operations
- Timestamped entries for each action
- Error tracking and debugging information

### Sample Log Output
```
INFO: [2025-09-26 14:30:22] archive script started
INFO: [2025-09-26 14:30:22] Using command line arguments  
INFO: [2025-09-26 14:30:22] Found exclusion file: .bassignore
INFO: [2025-09-26 14:30:22] Backing up from ./documents to ./backups/backup_20250926_143022.tar.gz
INFO: [2025-09-26 14:30:23] Backup completed successfully
```

## Examples

### Daily Document Backup
```bash
# Setup configuration once
echo 'SOURCE_DIR="/home/user/documents"' > archive.conf
echo 'TARGET_DIR="/media/backup-drive"' >> archive.conf

# Daily backup (can be automated with cron)
./archive.sh
```

### Project Backup with Preview
```bash
# First, see what would be included
./archive.sh --dry-run ./my-project ./project-backups

# If satisfied, create the actual backup
./archive.sh ./my-project ./project-backups
```

### Selective Backup with Exclusions
```bash
# Create exclusion file
cat > .bassignore << EOF
*.log
node_modules/
.git/
*.tmp
EOF

# Run backup (automatically excludes matched patterns)
./archive.sh ./web-project ./backups
```

## Troubleshooting

### Common Issues

**"Source directory not found"**
- Verify the source path exists and is readable
- Check for typos in directory paths
- Ensure you have read permissions

**"Target directory could not be created"**  
- Check write permissions on target location
- Verify parent directory exists
- Ensure sufficient disk space

**"Backup failed during compression"**
- Check available disk space in target location
- Verify tar command is available
- Check source directory permissions

### Getting Help

1. **Check the help output:**
   ```bash
   ./archive.sh --help
   ```

2. **Review the log file:**
   ```bash
   cat archive.log
   ```

3. **Test with dry-run:**
   ```bash
   ./archive.sh --dry-run [source] [target]
   ```

## License

This project is open source. See the repository for license details.

## Contributing

Contributions welcome! Please feel free to submit issues and enhancement requests on GitHub.

---

**AutoBass v1.0** - Professional backup automation for everyone.