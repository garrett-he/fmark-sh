#!/usr/bin/env bash
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

PRG="$0"

while [ -h "$PRG" ]; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`/"$link"
    fi
done

PRGDIR=`dirname "$PRG"`

[ -z "$FMARK_HOME" ] && FMARK_HOME=`cd "$PRGDIR"/.. > /dev/null; pwd`

source "$FMARK_HOME"/libexec/functions.sh

display_usage() {
    echo "usage: fmark [--help] <command> [<args>]"
    echo
    echo "Available commands:"

    for cmd in `ls -1 "$FMARK_HOME"/libexec/fmark-* 2> /dev/null`; do
        basename $cmd | sed 's/fmark-\(.*\)\.sh/  \1/'
    done
}

while true; do
    case "$1" in
        --help)
            display_usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            break;
            ;;
    esac
done

cmd="$1"

if [ -z $cmd ]; then
    display_usage
    exit 0
fi

if expr "$1" : "-.*" > /dev/null; then
    echo "error: unknown option: $cmd" >&2
    exit 1
fi

if [ ! -r "$FMARK_HOME"/libexec/fmark-$cmd.sh ]; then
    echo "error: '$cmd' is not a fmark command." >&2
    exit 1
fi

shift 1

source "$FMARK_HOME"/libexec/fmark-$cmd.sh $*
