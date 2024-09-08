# fmark

**fmark** is a suite of command-line tools to manage bookmarks for
[Mozilla Firefox][1].

## Requirements

### Bash

If you are running \*nix systems like Linux and Mac OS X, no worries probably
you already have Bash installed. Windows is not natively supported, however
you can try to install Bash with [Cygwin][2].

### Firefox 3 or later

Starting in version 3, Mozilla Firefox stores bookmarks in a database
file named `places.sqlite` in the profile directory. fmark need this file
to operate on.

### SQLite command-line tool

`sqlite3` command-line tool is required to run queries on the bookmark
database. See more details at [SQLite official website][3].

## Commands

The following options are available for all commands:

*--dbfile=DBFILE*

Specifies the path of database file, or else fmark will read the path from
configuration file.

*--help*

Shows the help message of this command and exit.

## License

Copyright (C) 2023 Garrett HE <garrett.he@hotmail.com>

The GNU General Public License (GPL) version 3, see [COPYING](./COPYING).

[1]: https://www.mozilla.org
[2]: http://www.cygwin.com
[3]: http://www.sqlite.org
