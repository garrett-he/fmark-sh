# fmark

[README in English](./README.md)

**fmark** 是个 [Mozilla Firefox][1] 的命令行管理工具集。

## 系统需求

### Bash

如果你正在运行的是 \*nix 系统，如 Linux 或 Mac OS X，很可能你已经安装好 Bash
了。Windows 原生并不支持，但是你可以试着用 [Cygwin][2] 安装 Bash。

### Firefox 3 及以后版本

从版本 3 开始，Mozilla Firefox 将书签保存到了用户目录下一个名为
`places.sqlite` 的文件中。

### SQLite 命令行工具

需要 `sqlite3` 命令行工具对书签数据库执行查询语句，详情见
[SQLite 官方网站][3]。

## 开始使用

这里是一个删除重复书签的例子。
(这也是一开始我写这个工具的目的 :)


首先，我们用命令 `fmark stat` 来看看书签的统计信息。

```sh
$ fmark stat
bookmarks: 9356
keywords: 0
size: 20971520
```

书签数量很大 (9356)，而且很多是重复的。

下一步，删除这些重复书签。

```sh
$ fmark list --cols=I --duplicate=U --omitone | fmark rm
```

在这个命令组合中，fmark 首先列出所有 URL `--duplicated=U` 重复的书签 ID
`fmark list --cols=I`，并且忽略每组重复书签的第一条 `--omitone` (目的是为了接
下来的删除，因为每组重复书签要保留一个)。然后用管道把重复书签的 ID 给
`fmark rm` 命令，执行删除动作。

再来看看统计：

```sh
$ fmark stat
bookmarks: 4919
keywords: 0
size: 20971520
```

如你所见，4437 个重复书签被删除了！

删除书签后，数据库大小仍然是 20 MiB，现在我们试着优化一下数据库。

```sh
$ fmark op
```

再统计一下：

```sh
$ fmark op
bookmarks: 4919
keywords: 0
size: 9633792
```

大小已经变成 9 MiB 了。

## 命令

下面的参数对大多数的命令都有效：

*--dbfile=DBFILE*

指定数据库文件的路径，否则 fmark 从配置文件中读取这个值。

*--help*

显示帮助信息并退出。

### stat

显示书签统计信息。

```bash
$ fmark stat [--dbfile=DBFILE] [--help]
```

### op

优化书签数据库，见 [更多详情][4].

```bash
$ fmark op [--dbfile=DBFILE] [--help]
```

### list

列出书签信息。

```bash
$ fmark list [--cols=COLS] [--duplicate=COL] [--delimiter=DELM] [--omitone] [--dbfile=DBFILE] [--help]
```

*--cols=COLS*

指定书签列表的列信息，可以是：

- i = ID
- u = URL
- t = 标题
- a = 添加日期
- m = 最后更新日期
- k = 关键字
- d = 描述
- c = 访问次数
- l = 最后访问日期
- g = 标签

*--duplicate=COL*

如果指定了，fmark 只会列出该参数指定列重复的书签。

- u = URL
- t = 标题

*--delimiter=DELIM*

DELIM 指定列表分隔符，默认为制表符，而一些有特殊功能的字符如 "$" 或 "&" 则需
要转义。

*--omitone*

仅当你使用了 *--duplicate* 参数时再使用该参数，以去除每组重复书签的第一个。

### test

测试书签的 HTTP 连接状态。

注：该命令是从 STDIN(0) 中读取 URL 的，你可以用 `fmark list` 命令生成 URL 列表。

```bash
$ fmark test [--max-time=SECONDS] [--threads=NUM] [--help]
```

*--max-time=SECONDS*

每个连接的超时时间，默认 5 秒。

*--threads=NUM*

测试并发数，默认 10

例子：

```bash
$ fmark list --cols=u | fmark test
[200] http://www.gnu.org
[200] http://www.yahoo.com
[ERR] http://www.youtube.com       // 中国人都懂的
```

### rm

删除 ID 指定的书签

```bash
$ fmark rm [ID [...]] [--help]
```

如果没有 ID 参数，该命令从 STDIN(0) 里读取列表。

例子：

```bash
$ fmark list --duplicate=u --cols=i --omitone | fmark rm
```

该命令会删除重复的书签，每组重复书签只保留一个。

## License

Copyright (C) 2023 Garrett HE <garrett.he@hotmail.com>

The GNU General Public License (GPL) version 3, see [COPYING](./COPYING).

[1]: https://www.mozilla.org
[2]: http://www.cygwin.com
[3]: http://www.sqlite.org
[4]: http://www.sqlite.org/lang_vacuum.html
