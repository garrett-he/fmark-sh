display_cmd_help() {
    echo "usage: fmark rm [--help] [ID1 [ID2...]]"
    echo "Remove Mozilla Firefox bookmarks"
    echo
    echo "  --help             display help message and exit"
}

fmark_init "$@"

fmark_rm_bookmark() {
    sql="DELETE FROM moz_bookmarks WHERE id=$1"
    fmark_query_db "$sql" "-bail"
}

if [ $# -gt 0 ]; then
    for id in "$@"; do
        fmark_rm_bookmark $id
    done
else
    while read -u 0 id; do
        fmark_rm_bookmark $id
    done
fi