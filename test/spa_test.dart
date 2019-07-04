@Timeout(const Duration(seconds: 1000))

import 'dart:convert';
import 'dart:io';

import 'package:spa/src/spa.dart';
import 'package:test/test.dart';

bool doubleEq(double a, double b) =>
  (a - b).abs() < 0.000001;

Future<bool> testCsv(String fileName) async {
  var file = File(fileName);
  if (!await file.exists()) return false;

  test(fileName, () async {
    bool first = true;

    int lineNum = 0;

    await for (var line in
      LineSplitter().bind(Utf8Decoder().bind(file.openRead()))
    ) {
      lineNum++;

      if (first) { // Skip column names
        first = false;
        continue;
      }

      var row = line.split(",");
      var params = SPAParams.list(row.map((e) => num.parse(e)).toList());

      var itm = SPAIntermediate();
      var output = spaCalculate(params, intermediate: itm);

      void check(double res, int idx) {
        if (!doubleEq(res, double.parse(row[idx]))) {
          throw TestFailure(
            "Test failed at line $lineNum\n"
              "Row $idx: expected ${row[idx]} but got $res"
          );
        }
      }

      check(output.zenith, 17);
      check(output.azimuthAstro, 18);
      check(output.azimuth, 19);
      check(output.incidence, 20);
      check(output.sunTransit, 21);
      check(output.sunrise, 22);
      check(output.sunset, 23);
    }
  });

  return true;
}

Future main() async {
  if (!await testCsv("test/dataset.csv")) {
    await testCsv("test/dataset_small.csv");
  }
}
