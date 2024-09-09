# Copyright (C) 2017 Garrett HE <garrett.he@hotmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

display_cmd_usage() {
    echo "usage: fmark list [--cols=COLS] [--duplicate=COL] [--dbfile=DBFILE]"
    echo "                  [--help]"
    echo "List all bookmarks"
    echo
    echo "  --cols=COLS        columns for displaying"
    echo "  --delimiter=DELIM  DELIM as the column delimiter, a TAB by default"
    echo "  --dbfile=DBFILE    bookmark database file"
    echo "  --help             show help message and exit"
}

fmark_init "$@"

cols=$(echo $(fmark_get_opt "cols" "$@" || echo "U") | tr '[a-z]' '[A-Z]')
delim=$(fmark_get_opt "delimiter" "$@" || echo "\t")
from="moz_bookmarks b"

where="b.type=1 AND \
b.fk NOT IN (SELECT id FROM moz_places WHERE url LIKE 'place:%')"


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
