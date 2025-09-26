# help section
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: options"
    echo " Makes target_dir/backup_YYYYMMDD_HHMMSS and puts the copy of contents there."
    exit 0
fi

# check number of arguments 
if [ $# -ne 2 ]; then
    echo "Incorrect number of arguments. Use -h or --help for usage."
    exit 1
fi

# assign arguments to variables and validate directories
SRC="$1"
DST="$2"

if [ ! -d "$SRC" ]; then
  echo "Error: The source directory was not found: $SRC" >&2
  echo "Use -h or --help for usage."
  exit 1
fi
if [ ! -d "$DST" ]; then
  echo "Error: The target directory was not found: $DST" >&2
  echo "Use -h or --help for usage."
  exit 1
fi
