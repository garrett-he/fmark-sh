display_cmd_help() {
    echo "usage: fmark stat [--dbfile=DBFILE] [--help]"
    echo "Show the statistical information of bookmarks"
    echo
    echo "  --dbfile=DBFILE    bookmark database file"
    echo "  --help             display help message and exit"
}

fmark_init "$@"

bookmarks=`fmark_query_db "SELECT COUNT(*) FROM moz_bookmarks WHERE type = 1"`
keywords=`fmark_query_db "SELECT COUNT(*) FROM moz_keywords"`
filesize=`ls -l "$profiledir/places.sqlite" | cut -f5 -d\ `

echo "bookmarks: $bookmarks"
echo "keywords: $keywords"
echo "size: $filesize"
