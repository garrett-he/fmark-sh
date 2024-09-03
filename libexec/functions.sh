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

fmark_has_opt() {
    local opt
    local name="$1"
    shift 1

    for opt in "$@"; do
        if [ "$opt" == "--" ]; then
            return 1
        fi

        if expr "$opt" : "--$name" > /dev/null; then
            return 0
        fi
    done

    return 1
}

fmark_get_opt() {
    local opt
    local value

    local name="$1"
    shift

    for opt in "$@"; do
        if [ "$opt" = "--" ]; then
            return 1
        fi

        if value=$(expr "$opt" : "--$name=\(.*\)"); then
            echo "$value"
            return 0
        fi
    done

    return 1
}

fmark_ostype() {
    if uname | grep -i linux > /dev/null; then
        echo linux
    elif uname | grep -i darwin > /dev/null; then
        echo darwin
    elif uname | grep -i cygwin > /dev/null; then
        echo cygwin
    fi
}
