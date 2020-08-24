### Line Counter

Line Counter is a simple program written in dart that can be used to count lines of files in directory.

## Usage

If you are using the dart sdk:
```bash
cd <program_directoy>
dart main.dart
```

If you are using the executable:
```bash
linecounter.exe
```

This gives a overview of total lines and length in bytes of the current directory. 

The program accepts several arguments:
```bash
-d, --dir        The directory to scan.
                 (defaults to ".")
-m, --mode           log: prints out log
                     stat: prints out type statistics
                     both: prints out both log and statistics
                 [log, stat, both]
-r, --recurse    Whether to recursively scan child directories.
```

You can use --help argument to print this help text.

## Example
```bash
> dart main.dart --mode=both

------------------------------
        LOG
------------------------------
Path                      Lines  Length(Bytes)
<Location>.\.packages     4      261
<Location>.\main.dart     146    3636
<Location>.\pubspec.lock  19     419
<Location>.\pubspec.yaml  6      104
------------------------------
------------------------------
        STATS
------------------------------
Type      Lines  Percentage(Lines)
PACKAGES  4      2.286(4/175)
DART      146    83.429(146/175)
LOCK      19     10.857(19/175)
YAML      6      3.429(6/175)
------------------------------
------------------------------
        RESULTS
------------------------------
Total Lines: 175
Total Length(Bytes): 4420
------------------------------
```
