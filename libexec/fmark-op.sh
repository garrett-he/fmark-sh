display_cmd_help() {
    echo "usage: fmark op [--dbfile=DBFILE] [--help]"
    echo "Optimize bookmark database"
    echo
    echo "  --dbfile=DBFILE    bookmark database file"
    echo "  --help             show help message and exit"
}

fmark_init "$@"

if pgrep firefox > /dev/null; then
    echo "error: close firefox before optimizing" >&2
    exit 1
else
    sql="VACUUM"
    fmark_query_db "${sql}" "-bail"
fi
