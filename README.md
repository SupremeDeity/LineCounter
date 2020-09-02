### Line Counter

Line Counter is a simple program written in dart that can be used to count lines of files in directory.

## Usage

If you are using the dart sdk:

```bash
$ cd <program_directoy>
$ dart main.dart
```

If you are using the executable:

```bash
$ linecounter.exe
```

This gives a overview of total lines and length in bytes of the current directory.

The program accepts several arguments:

```bash
-i, --ignore        Glob pattern to ignore files.
-l, --location      The location/file to scan.
                    (defaults to ".")
-m, --mode          The mode to use.

          [both]    prints out both log and statistics
          [log]     prints out log
          [stat]    prints out type statistics

-r, --recurse       Whether to recursively scan child directories.
```

You can use --help argument to print this help text.

## Example

```bash
<<<<<<< HEAD
> dart main.dart -m both -i **.yaml,**.md -r
=======
$ dart main.dart --mode=both
>>>>>>> 80e15910be092f428c5f1419458ffcb785ec881d

------------------------------
        LOG
------------------------------
Path                                    Lines  Length(Bytes)
.\.dart_tool\package_config.json        103    3297
.\.git\COMMIT_EDITMSG                   1      56
.\.git\config                           13     310
.\.git\description                      1      73
.\.git\FETCH_HEAD                       3      331
.\.git\HEAD                             1      23
.\.git\info\exclude                     6      240
.\.git\logs\HEAD                        9      1666
.\.git\logs\refs\heads\master           8      1498
.\.git\logs\refs\remotes\origin\master  6      961
.\.git\ORIG_HEAD                        1      41
.\.git\refs\heads\master                1      41
.\.git\refs\remotes\origin\master       1      41
.\.git\refs\tags\v1.0                   1      41
.\.git\refs\tags\v1.1                   1      41
.\.gitignore                            1      5
.\.packages                             17     1566
.\.vscode\launch.json                   14     375
.\main.dart                             172    4325
.\pubspec.lock                          110    2429
------------------------------
------------------------------
        STATS
------------------------------
Type       Lines  Percentage(Lines)
JSON       117    24.894(117/470)
OTHER      53     11.277(53/470)
GITIGNORE  1      0.213(1/470)
PACKAGES   17     3.617(17/470)
DART       172    36.596(172/470)
LOCK       110    23.404(110/470)
------------------------------
------------------------------
        RESULTS
------------------------------
Total Lines: 470
Total Length(Bytes): 17360
------------------------------
```
