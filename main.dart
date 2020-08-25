import "dart:io";
import "package:args/args.dart";
import 'package:dolumns/dolumns.dart';

int lines = 0;
int length = 0;
bool log = false;
bool stats = false;
var fsEntity;
var statsArr = {};
var columns = [
  ["Path", "Lines", "Length(Bytes)"],
];

ArgParser _initParser() {
  var _parser = ArgParser(allowTrailingOptions: false);
  _parser.addOption("location",
      abbr: 'l', defaultsTo: '.', help: "The location/file to scan.");
  _parser.addOption(
    "mode",
    abbr: 'm',
    allowed: ['log', 'stat', 'both'],
    help: "The mode to use.",
    allowedHelp: {
      'log': 'prints out log',
      'stat': 'prints out type statistics',
      'both': 'prints out both log and statistics'
    },
  );
  // todo: add exclude
  // _parser.addMultiOption("exclude", abbr: 'e');
  _parser.addFlag("recurse",
      abbr: 'r',
      negatable: false,
      help: "Whether to recursively scan child directories.");
  _parser.addFlag("help",
      abbr: 'h', negatable: false, help: "Prints out this text.");

  return _parser;
}

void _fileActions(FileSystemEntity entity) {
  File entt = entity as File;
  String path = entt.path;
  String ext = path.substring(path.lastIndexOf(".") + 1).toUpperCase();

  try {
    int _lines = entt.readAsLinesSync().length;
    int bytes = entt.lengthSync();
    if (stats) {
      if (statsArr.containsKey(ext)) {
        statsArr[ext] += _lines;
      } else
        statsArr[ext] = _lines;
    }
    if (log) {
      columns.add([path, _lines.toString(), bytes.toString()]);
    }
    lines += _lines;
    length += bytes;
  } catch (FileSystemException) {
    if (log) {
      //print("Skipped: ${entt.path}");
    }
  }
}

void _printResults() {
  if (log) {
    stdout.write("-" * 30 + "\n\tLOG");
    stdout.write("-" * 30 + "\n" + dolumnify(columns));
    stdout.write("-" * 30);
  }

  var statCol = [
    ["Type", "Lines", "Percentage(Lines)"]
  ];

  if (stats) {
    statsArr.forEach((key, value) {
      statCol.add([
        key.toString(),
        value.toString(),
        (value / lines * 100).toStringAsFixed(3) +
            "(" +
            value.toString() +
            "/" +
            lines.toString() +
            ")"
      ]);
    });
    print("-" * 30 + "\n\tSTATS");
    print("-" * 30 + "\n" + dolumnify(statCol));
    print("-" * 30);
  }
  print("-" * 30 + "\n\tRESULTS");
  print("-" * 30 +
      "\nTotal Lines: $lines\nTotal Length(Bytes): $length\n" +
      "-" * 30);
}

int main(List<String> args) {
  var parser = _initParser();

  bool recursive;

  var results;
  try {
    results = parser.parse(args);

    if (results['help']) {
      stdout.write(parser.usage);
      return 0;
    }

    recursive = results['recurse'];

    switch (results['mode']) {
      case 'log':
        log = true;
        break;
      case 'stat':
        stats = true;
        break;
      case 'both':
        log = true;
        stats = true;
        break;
      default:
        break;
    }
  } catch (FormatException) {
    stderr.write("Exception Caught.");
    stderr.write(parser.usage);

    return -1;
  }

  if (results.rest.length > 0) {
    stderr.write("Unknown argument(s) passed!");
    return -1;
  }

  FileSystemEntity.isFile(results['dir']).then((bool isFile) {
    if (isFile) {
      _fileActions(File(results['dir']));
      _printResults();

      return 0;
    }
  });

  FileSystemEntity.isDirectory(results['dir']).then((bool isDir) {
    if (isDir) {
      Directory(results['dir'])
          .list(recursive: recursive, followLinks: true)
          .listen((FileSystemEntity entity) {
        if (entity.statSync().type == FileSystemEntityType.file) {
          _fileActions(entity);
        }
      }).onDone(() {
        _printResults();
      });
    }
  });

  return 0;
}
