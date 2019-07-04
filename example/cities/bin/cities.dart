import 'package:spa/spa.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';

void printCity(
  String name, String timezone, double latitude, double longitude
) {
  var location = getLocation(timezone);
  var tz = location.currentTimeZone.offset / 3600000;
  var time = TZDateTime.now(location);

  var sp = spaCalculate(SPAParams(
    time: time,
    latitude: latitude,
    longitude: longitude,
  ));

  String fmtHHMM(int hours, int mins) =>
    "${hours.toString().padLeft(2)}:${mins.toString().padLeft(2, "0")}";

  String fmtDeg(double deg) =>
    "${deg.toStringAsFixed(2).padLeft(6)}°";

  print(
    "${name.padRight(13)} | "
    "${fmtHHMM(time.hour, time.minute)} | "
    "Zenith: ${fmtDeg(sp.zenith)} | "
    "Sunrise: ${fmtHHMM(sp.sunrise.floor(), (sp.sunrise * 60).floor() % 60)} | "
    "Transit: ${fmtHHMM(sp.sunTransit.floor(), (sp.sunset * 60).floor() % 60)} | "
    "Sunset: ${fmtHHMM(sp.sunset.floor(), (sp.sunset * 60).floor() % 60)}"
  );
}

void main() async {
  await initializeTimeZone();

  printCity("Anchorage", "America/Anchorage", 61.2181, -149.9003);
  printCity("Mountain View", "America/Los_Angeles", 37.3861, -122.0839);
  printCity("Detroit", "America/Detroit", 42.3314, -83.0458);
  printCity("New York City", "America/New_York", 40.7128, -74.006);
  printCity("Reykjavik", "Atlantic/Reykjavik", 64.9631, -19.0208);
  printCity("Frankfurt", "Europe/Berlin", 50.1109, 8.6821);
  printCity("Moscow", "Europe/Moscow", 55.7558, 37.6173);
  printCity("New Delhi", "Asia/Kolkata", 28.6139, 77.2090);
  printCity("Hong Kong", "Asia/Hong_Kong", 22.3193, 114.1694);
  printCity("Tokyo", "Asia/Tokyo", 35.6804, 139.7690);
  printCity("Melbourne", "Australia/Melbourne", -37.8136, 144.9631);
}