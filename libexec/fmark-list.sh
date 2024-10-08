display_cmd_help() {
    echo "usage: fmark list [--cols=COLS] [--duplicate=COL] [--dbfile=DBFILE]"
    echo "                  [--help]"
    echo "List all bookmarks"
    echo
    echo "  --cols=COLS        columns for displaying"
    echo "  --duplicate=[u|t]  column to be identified for duplicates"
    echo "  --omitone          use with --duplicate, omit the first duplicate"
    echo "  --delimiter=DELIM  DELIM as the column delimiter, a TAB by default"
    echo "  --dbfile=DBFILE    bookmark database file"
    echo "  --help             show help message and exit"
}

fmark_init "$@"

cols=$(echo $(fmark_get_opt "cols" "$@" || echo "U") | tr '[a-z]' '[A-Z]')
delim=$(fmark_get_opt "delimiter" "$@" || echo "\t")
duplicate=$(fmark_get_opt "duplicate" "$@" | tr '[a-z]' '[A-Z]')
from="moz_bookmarks b"

if [ "$duplicate" = "" ]; then
    from="moz_bookmarks b"
else
    case $duplicate in
        U)
            dupcol="fk"
            ;;
        T)
            dupcol="title"
            ;;
        *)
            echo "unrecognized duplicate column: '$duplicate'" >&2
            exit 1
    esac

    from="(SELECT * FROM moz_bookmarks WHERE $dupcol IN\
        (SELECT $dupcol FROM moz_bookmarks WHERE parent NOT IN\
        (SELECT id FROM moz_bookmarks WHERE parent IN\
        (SELECT id FROM moz_bookmarks WHERE guid='tags________'))\
        GROUP BY $dupcol HAVING COUNT(*)>1))"

    if fmark_has_opt "omitone" "$@"; then
        from="(SELECT * FROM $from WHERE id NOT IN (SELECT MIN(id) FROM $from GROUP BY $dupcol))"
    fi

    from="$from AS b"
fi

where="b.type=1 AND \
b.fk NOT IN (SELECT id FROM moz_places WHERE url LIKE 'place:%') \
AND parent NOT IN \
(SELECT id FROM moz_bookmarks WHERE parent IN \
(SELECT id FROM moz_bookmarks WHERE guid='tags________'))"

# i = id
if expr "$cols" : ".*I.*" > /dev/null; then
    cols=$(echo $cols | sed 's/I/ b\.id/')
fi


# u = url
if expr "$cols" : ".*U.*" > /dev/null; then
    cols=$(echo $cols | sed 's/U/ u\.url/')
    join="$join LEFT JOIN moz_places u ON u.id=b.fk"
fi

# t = title
if expr "$cols" : ".*T.*" > /dev/null; then
    cols=$(echo $cols | sed 's/T/ b\.title/')
fi

# a = dateAdded
if expr "$cols" : ".*A.*" > /dev/null; then
    cols=$(echo $cols | sed 's/A/ b\.dateAdded/')
fi

# m = lastModified
if expr "$cols" : ".*M.*" > /dev/null; then
    cols=$(echo $cols | sed 's/M/ b\.lastModified/')
fi

# k = keyword
if expr "$cols" : ".*K.*" > /dev/null; then
    cols=$(echo $cols | sed 's/K/ k\.keyword/')
    join="$join LEFT JOIN \
    (SELECT kk.place_id, kk.keyword FROM moz_places kp, moz_keywords kk WHERE kp.id = kk.place_id) k \
    ON b.fk = k.place_id"
fi

# d = description
if expr "$cols" : ".*D.*" > /dev/null; then
    cols=$(echo $cols | sed 's/D/ d\.content/')
    join="$join LEFT JOIN moz_items_annos d ON d.item_id=b.id"
fi


# c = visit_count
if expr "$cols" : ".*C.*" > /dev/null; then
    cols=$(echo $cols | sed 's/C/ c\.visit_count/')
    join="$join LEFT JOIN moz_places c ON c.id=b.fk"
fi

# l = last_visit_date
if expr "$cols" : ".*L.*" > /dev/null; then
    cols=$(echo $cols | sed 's/L/ l\.last_visit_date/')
    join="$join LEFT JOIN moz_places l ON l.id=b.fk"
fi

# g = tags
if expr "$cols" : ".*G.*" > /dev/null; then
    cols=$(echo $cols | sed 's/G/ g\.tags/')
    join="$join LEFT JOIN\
        (SELECT GROUP_CONCAT(b.title) AS tags, t.fk FROM moz_bookmarks b\
        INNER JOIN (SELECT * FROM moz_bookmarks WHERE parent IN\
        (SELECT id FROM moz_bookmarks WHERE parent IN\
        (SELECT id FROM moz_bookmarks WHERE guid='tags________')))\
        AS t ON b.id=t.parent GROUP BY t.fk) AS g ON g.fk=b.fk AND b.type=1"
fi

select=$(echo $cols | sed 's/^ //;s/ $//;s/ /,/g')

sql="SELECT $select FROM $from $join WHERE $where"

fmark_query_db "$sql" "-line" | while read line; do
    if [ "$line" = "" ]; then
        echo
        continue
    fi

    echo -ne $(echo $line | cut -f2 -d=)"$delim"
done
echo
