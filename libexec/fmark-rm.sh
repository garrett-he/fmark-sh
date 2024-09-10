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