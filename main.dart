import "dart:io";
import "package:args/args.dart";
import 'package:dolumns/dolumns.dart';

ArgParser _initParser() {
  var _parser = ArgParser(allowTrailingOptions: false);
  _parser.addOption("file", abbr: 'f', defaultsTo: '.');
  _parser.addOption("mode", abbr: 'm', allowed: ['log', 'stat', 'both']);
  _parser.addFlag("recurse", abbr: 'r', negatable: false);

  return _parser;
}

int main(List<String> args) {
  var parser = _initParser();
  bool log = false;
  bool stats = false;
  var directory;
  int lines = 0;
  int length = 0;
  bool recursive;

  var results;
  try {
    results = parser.parse(args);

    recursive = results['recurse'];
    directory = Directory(results['file']).absolute;

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

  var columns = [
    ["Path", "Lines", "Length(Bytes)"],
  ];

  var statsArr = {};

  directory
      .list(recursive: recursive, followLinks: true)
      .listen((FileSystemEntity entity) {
    if (entity.statSync().type == FileSystemEntityType.file) {
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
          print("Skipped: ${entt.path}");
        }
      }
    }
  }).onDone(() {
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
          (value / lines * 100).toString() +
              "(" +
              value.toString() +
              " / " +
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
  });

  return 0;
}
