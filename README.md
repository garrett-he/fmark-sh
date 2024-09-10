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

## Get Started

Here is an example to delete duplicated bookmarks.
(This is the main purpose I program this tool for :)

Firstly, let's see the statistics information with command `fmark stat`:

```sh
$ fmark stat
bookmarks: 9356
keywords: 0
size: 20971520
```

OK, there are lots of bookmarks (9356) and duplicates.

Next, delete the duplicates:

```sh
$ fmark list --cols=I --duplicate=U --omitone | fmark rm
```

With this combined commands, fmark lists all the bookmark IDs
`fmark list --cols=I` which are duplicated with URLs `--duplicate=U`, but
omit the first one `--omitone` (for deletion purpose, remaining the first
bookmark of each duplicate set), then use a pipeline to pass the ID list to
`fmark rm` to delete the other duplicates.

Now let's see the statistics again:

```sh
$ fmark stat
bookmarks: 4919
keywords: 0
size: 20971520
```

As you see, 4437 duplicates are removed!

After deletion, the size of bookmark database is still 20 MiB, let's try to
optimize it:

```sh
$ fmark op
```

Statistics again:

```sh
$ fmark op
bookmarks: 4919
keywords: 0
size: 9633792
```

See, the size is reduced to 9 MiB.

## Commands

The following options are available for all commands:

*--dbfile=DBFILE*

Specifies the path of database file, or else fmark will read the path from
configuration file.

*--help*

Shows the help message of this command and exit.

### op

Optimizes bookmark database,
see [more details][4].

```bash
$ fmark op [--dbfile=DBFILE] [--help]
```

### list

Lists bookmarks in Mozilla Firefox.

```bash
$ fmark list [--cols=COLS] [--delimiter=DELM] [--dbfile=DBFILE] [--help]
```

*--cols=COLS*

Flags represent bookmark columns to be listed. The flags can be:

- i = ID
- u = URL
- t = Title
- a = Date Added
- m = Last Modified
- k = Keyword
- d = Description
- c = Visit Count
- l = Last Visit Date
- g = Tags

*--delimiter=DELIM*

Use DELIM as the field delimiter, a TAB by default. If you'd like to use
some speicial character like "$" or "&", which have some particular
functionalities, you have to escape them.

*--duplicate=COL*

If specified, fmark only lists bookmarks duplicated with COL:

- u = URL
- t = Title

*--omitone*

Use this option ONLY with *--duplicate*, to omit the first duplicate.

### rm

Removes bookmarks by identifiers.

```bash
$ fmark rm [ID [...]] [--help]
```

If no identifiers specified with arguments, this read the identifiers from
STDIN(0).

Example:

```bash
$ fmark list --duplicate=u --cols=i --omitone | fmark rm
```

This command remains one bookmarks from each duplicated groups,
and removes others.

### stat

Displays the statistics of bookmarks.

```bash
$ fmark stat [--dbfile=DBFILE] [--help]
```

### test

Tests connection and HTTP status of bookmarks.

Notice: This command only reads URLs from STDIN, you can generate a list
by `fmark list` command.

```bash
$ fmark test [--max-time=SECONDS] [--threads=NUM] [--help]
```

*--max-time=SECONDS*

Maximum time in seconds operation to take, defaults to be 5

*--threads=NUM*

Number of multiple requests to make, defaults to be 10

Example:

```bash
$ fmark list --cols=u | fmark test
[200] http://www.gnu.org
[200] http://www.yahoo.com
[ERR] http://www.youtube.com       // I'm in China, so you know why
```

## License

Copyright (C) 2023 Garrett HE <garrett.he@hotmail.com>

The GNU General Public License (GPL) version 3, see [COPYING](./COPYING).

[1]: https://www.mozilla.org
[2]: http://www.cygwin.com
[3]: http://www.sqlite.org
[4]: http://www.sqlite.org/lang_vacuum.html
