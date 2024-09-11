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
