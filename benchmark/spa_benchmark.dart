import 'package:spa/spa.dart';

void main() {
  // This checksum ensures parts of SPA aren't optimized out.
  int checksum = 0;
  void volatile(double v) {
    checksum = (checksum + v.floor()) % 64;
  }

  double round(int count) {
    var t0 = DateTime.now().microsecondsSinceEpoch;

    for (int i = 0; i < count; i++) {
      var res = spaCalculate(SPAParams(
        time: DateTime.fromMillisecondsSinceEpoch(1562212800000 + (
          86400000 * (i / count)
        ).floor()),
        longitude: -83.0458,
        latitude: 42.3314,
        elevation: 100,
      ));
      
      volatile(res.zenith);
      volatile(res.azimuthAstro);
      volatile(res.azimuth);
      volatile(res.incidence);
      volatile(res.sunTransit);
      volatile(res.sunrise);
      volatile(res.sunset);
    }

    var t1 = DateTime.now().microsecondsSinceEpoch;
    return (t1 - t0) / count;
  }

  round(10000); // Warm up

  var us = round(10000);

  print("Result: ${(1000000 / us).floor()} spa/s | ${us.floor()} μs/spa");
  print("Checksum: $checksum");
}