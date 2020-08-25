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

bool _isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.parse(s, (e) => null) != null;
}

void _fileActions(FileSystemEntity entity) {
  File entt = entity as File;
  String path = entt.path;
  String filename = path.substring(entt.parent.path.length);
  int extIndex = filename.lastIndexOf(".");
  String ext =
      extIndex != -1 ? filename.substring(extIndex + 1).toUpperCase() : "OTHER";
  if (_isNumeric(ext)) ext = "OTHER";

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
  } catch (FileSystemException) {}
}

void _printResults() {
  if (log) {
    print("-" * 30 + "\n\tLOG");
    print("-" * 30 + "\n" + dolumnify(columns));
    print("-" * 30);
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
      print(parser.usage);
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
    print("Exception Caught.");
    print(parser.usage);

    return -1;
  }

  if (results.rest.length > 0) {
    print("Unknown argument(s) passed!");
    return -1;
  }

  FileSystemEntity.isFile(results['location']).then((bool isFile) {
    if (isFile) {
      _fileActions(File(results['location']));
      _printResults();

      return 0;
    }
  });

  FileSystemEntity.isDirectory(results['location']).then((bool isDir) {
    if (isDir) {
      Directory(results['location'])
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
