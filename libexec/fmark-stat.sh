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
