import 'dart:math';
import 'package:tuple/tuple.dart';
import 'package:meta/meta.dart';

/// Input parameters for the SPA algorithm.
class SPAParams {
  /// Creates input parameters for the SPA algorithm.
  SPAParams({
    required this.time,
    double? timeZone,
    double? second,
    this.deltaUtl = 0,
    this.deltaT = 0,
    required this.longitude,
    required this.latitude,
    this.elevation = 0,
    this.pressure = 1013,
    this.temperature = 15,
    this.slope = 0,
    this.azmRotation = 0,
    this.atmosRefract = 0.5667,
  }) : timeZone = timeZone ?? time.timeZoneOffset.inHours.toDouble(),
       second = second ?? time.second +
         time.millisecond / 1000 +
         time.microsecond / 1000000;

  /// Initializer list style construction.
  ///
  /// Argument order: year, month, day, hour, minute, second, deltaUtl, deltaT,
  /// timeZone, longitude, latitude, elevation, pressure, temperature, slope,
  /// azmRotation, atmosRefract.
  SPAParams.list(List<num> list) :
    time = DateTime.utc(
      list.isEmpty ? 0 : list[0].toInt(),
      list.length < 2 ? 0 : list[1].toInt(),
      list.length < 3 ? 0 : list[2].toInt(),
      list.length < 4 ? 0 : list[3].toInt(),
      list.length < 5 ? 0 : list[4].toInt(),
    ),
    second = list.length < 6 ? 0 : list[5].toDouble(),
    deltaUtl = list.length < 7 ? 0 : list[6].toDouble(),
    deltaT = list.length < 8 ? 0 : list[7].toDouble(),
    timeZone = list.length < 9 ? 0 : list[8].toDouble(),
    longitude = list.length < 10 ? 0 : list[9].toDouble(),
    latitude = list.length < 11 ? 0 : list[10].toDouble(),
    elevation = list.length < 12 ? 0 : list[11].toDouble(),
    pressure = list.length < 13 ? 0 : list[12].toDouble(),
    temperature = list.length < 14 ? 0 : list[13].toDouble(),
    slope = list.length < 15 ? 0 : list[14].toDouble(),
    azmRotation = list.length < 16 ? 0 : list[15].toDouble(),
    atmosRefract = list.length < 17 ? 0 : list[16].toDouble();

  /// Observer time
  ///
  /// Must be within -2000 to 6000 years.
  DateTime time;

  /// Overrides seconds / millis / micros in [time].
  ///
  /// Must be within 0 to 60 seconds.
  double second;

  /// Overrides the timezone provided in [time].
  ///
  /// Must be within -18 to 18 hours.
  double timeZone;

  /// Fractional second difference between UTC and UT.
  ///
  /// Used to adjust UTC for earth's irregular rotation rate and is derived
  /// from observation only and is reported in this bulletin:
  /// http://maia.usno.navy.mil/ser7/ser7.dat, where deltaUtl = DUT1
  ///
  /// Must be between -1 to 1 second.
  double deltaUtl;

  /// Difference between earth rotation time and terrestrial time.
  ///
  /// It is derived from observation only and is reported in this
  /// bulletin: http://maia.usno.navy.mil/ser7/ser7.dat,
  /// where deltaT = 32.184 + (TAI-UTC) - DUT1
  ///
  /// Must be between -8000 to 8000 seconds.
  double deltaT;

  /// Observer longitude in degrees.
  ///
  /// Must be within -180 to 180 degrees.
  double longitude;

  /// Observer latitude in degrees.
  ///
  /// Must be within -90 to 90 degrees.
  double latitude;

  /// Observer elevation in meters.
  ///
  /// Must be above -6500000 meters.
  double elevation;

  /// Average pressure in millibars.
  ///
  /// Must be between 0 to 5000 millibars.
  double pressure;

  /// Average temperature in degrees Celsius.
  ///
  /// Must be between -273 and 6000 degrees Celsius.
  double temperature;

  /// Surface slope from the horizontal plane in degrees.
  ///
  /// Must be between -360 to 360.
  double slope;

  /// Surface azimuth rotation in degrees.
  ///
  /// Measured from south to projection surface normal on horizontal plane,
  /// negative east.
  ///
  /// Must be between -360 to 360 degrees.
  double azmRotation;

  /// Atmospheric refraction at sunrise and sunset in degrees.
  ///
  /// Must be between -5 to 5 degrees.
  double atmosRefract;
}

/// Intermediate values for the SPA algorithm.
class SPAIntermediate {
  /// Julian day
  double? jd;
  /// Julian century
  double? jc;

  /// Julian ephemeris day
  double? jde;
  /// Julian ephemeris century
  double? jce;
  /// Julian ephemeris millennium
  double? jme;

  /// Earth heliocentric longitude in degrees
  double? l;
  /// Earth heliocentric latitude in degrees
  double? b;
  /// Earth radius vector in AU
  double? r;

  /// Geocentric longitude in degrees
  double? theta;
  /// Geocentric latitude in degrees
  double? beta;

  /// (
  ///   Mean elongation (moon-sun) in degrees,
  ///   Mean anomaly (sun) in degrees,
  ///   Mean anomaly (moon) in degrees,
  ///   Argument latitude (moon) in degrees,
  ///   Ascending longitude (moon) in degrees,
  /// )
  Tuple5<double, double, double, double, double>? x;

  /// Nutation longitude in degrees
  double? delPsi;
  /// Nutation obliquity in degrees
  double? delEps;
  /// Ecliptic mean obliquity in arc seconds
  double? epsilon0;
  /// Ecliptic t rue obliquity in degrees
  double? epsilon;

  /// Aberration correction in degrees
  double? delTau;
  /// Apparent sun longitude in degrees
  double? lamda;
  /// Greenwich mean sidereal time in degrees
  double? nu0;
  /// Greenwich sidereal time in degrees
  double? nu;

  /// Geocentric sun right ascension in degrees
  double? alpha;
  /// Geocentric sun declination in degrees
  double? delta;

  /// Observer hour angle in degrees
  double? h;
  /// Sun equatorial horizontal parallax in degrees
  double? xi;
  /// Sun right ascension parallax in degrees
  double? delAlpha;
  /// Topocentric sun declination in degrees
  double? delPrime;
  /// Topocentric sun right ascension in degrees
  double? alphaPrime;
  /// Topocentric local hour angle in degrees
  double? hPrime;

  /// Topocentric elevation angle uncorrected in degrees
  double? e0;
  /// Atmospheric refraction correction in degrees
  double? delE;
  /// Topocentric elevation angle corrected in degrees
  double? e;

  /// Equation of time in minutes
  double? eot;
  /// Sunrise hour angle in degrees
  double? srha;
  /// Sunset hour angle in degrees
  double? ssha;
  /// Sun transit altitude in degrees
  double? sta;
}

/// Output values for the SPA algorithm.
class SPAOutput {
  /// Topocentric zenith angle in degrees
  late double zenith;

  /// Topocentric azimuth angle, westward from south (for astronomers).
  late double azimuthAstro;

  /// Topocentric azimuth angle, eastward from south
  /// (for navigators and solar radiation)
  late double azimuth;

  /// Surface incidence angle in degrees
  double? incidence;

  /// Local sun transit time in hours
  double? sunTransit;

  /// Local sunrise time (+/- 30 seconds) in hours
  double? sunrise;

  /// Local sunset time (+/- 30 seconds) in hours
  double? sunset;
}

double _sunRadius = 0.26667;

const _lterms = <List<Tuple3<double, double, double>>>[
  [
    Tuple3(175347046.0, 0, 0),
    Tuple3(3341656.0, 4.6692568, 6283.07585),
    Tuple3(34894.0, 4.6261, 12566.1517),
    Tuple3(3497.0, 2.7441, 5753.3849),
    Tuple3(3418.0, 2.8289, 3.5231),
    Tuple3(3136.0, 3.6277, 77713.7715),
    Tuple3(2676.0, 4.4181, 7860.4194),
    Tuple3(2343.0, 6.1352, 3930.2097),
    Tuple3(1324.0, 0.7425, 11506.7698),
    Tuple3(1273.0, 2.0371, 529.691),
    Tuple3(1199.0, 1.1096, 1577.3435),
    Tuple3(990, 5.233, 5884.927),
    Tuple3(902, 2.045, 26.298),
    Tuple3(857, 3.508, 398.149),
    Tuple3(780, 1.179, 5223.694),
    Tuple3(753, 2.533, 5507.553),
    Tuple3(505, 4.583, 18849.228),
    Tuple3(492, 4.205, 775.523),
    Tuple3(357, 2.92, 0.067),
    Tuple3(317, 5.849, 11790.629),
    Tuple3(284, 1.899, 796.298),
    Tuple3(271, 0.315, 10977.079),
    Tuple3(243, 0.345, 5486.778),
    Tuple3(206, 4.806, 2544.314),
    Tuple3(205, 1.869, 5573.143),
    Tuple3(202, 2.458, 6069.777),
    Tuple3(156, 0.833, 213.299),
    Tuple3(132, 3.411, 2942.463),
    Tuple3(126, 1.083, 20.775),
    Tuple3(115, 0.645, 0.98),
    Tuple3(103, 0.636, 4694.003),
    Tuple3(102, 0.976, 15720.839),
    Tuple3(102, 4.267, 7.114),
    Tuple3(99, 6.21, 2146.17),
    Tuple3(98, 0.68, 155.42),
    Tuple3(86, 5.98, 161000.69),
    Tuple3(85, 1.3, 6275.96),
    Tuple3(85, 3.67, 71430.7),
    Tuple3(80, 1.81, 17260.15),
    Tuple3(79, 3.04, 12036.46),
    Tuple3(75, 1.76, 5088.63),
    Tuple3(74, 3.5, 3154.69),
    Tuple3(74, 4.68, 801.82),
    Tuple3(70, 0.83, 9437.76),
    Tuple3(62, 3.98, 8827.39),
    Tuple3(61, 1.82, 7084.9),
    Tuple3(57, 2.78, 6286.6),
    Tuple3(56, 4.39, 14143.5),
    Tuple3(56, 3.47, 6279.55),
    Tuple3(52, 0.19, 12139.55),
    Tuple3(52, 1.33, 1748.02),
    Tuple3(51, 0.28, 5856.48),
    Tuple3(49, 0.49, 1194.45),
    Tuple3(41, 5.37, 8429.24),
    Tuple3(41, 2.4, 19651.05),
    Tuple3(39, 6.17, 10447.39),
    Tuple3(37, 6.04, 10213.29),
    Tuple3(37, 2.57, 1059.38),
    Tuple3(36, 1.71, 2352.87),
    Tuple3(36, 1.78, 6812.77),
    Tuple3(33, 0.59, 17789.85),
    Tuple3(30, 0.44, 83996.85),
    Tuple3(30, 2.74, 1349.87),
    Tuple3(25, 3.16, 4690.48)
  ],
  [
    Tuple3(628331966747.0, 0, 0),
    Tuple3(206059.0, 2.678235, 6283.07585),
    Tuple3(4303.0, 2.6351, 12566.1517),
    Tuple3(425.0, 1.59, 3.523),
    Tuple3(119.0, 5.796, 26.298),
    Tuple3(109.0, 2.966, 1577.344),
    Tuple3(93, 2.59, 18849.23),
    Tuple3(72, 1.14, 529.69),
    Tuple3(68, 1.87, 398.15),
    Tuple3(67, 4.41, 5507.55),
    Tuple3(59, 2.89, 5223.69),
    Tuple3(56, 2.17, 155.42),
    Tuple3(45, 0.4, 796.3),
    Tuple3(36, 0.47, 775.52),
    Tuple3(29, 2.65, 7.11),
    Tuple3(21, 5.34, 0.98),
    Tuple3(19, 1.85, 5486.78),
    Tuple3(19, 4.97, 213.3),
    Tuple3(17, 2.99, 6275.96),
    Tuple3(16, 0.03, 2544.31),
    Tuple3(16, 1.43, 2146.17),
    Tuple3(15, 1.21, 10977.08),
    Tuple3(12, 2.83, 1748.02),
    Tuple3(12, 3.26, 5088.63),
    Tuple3(12, 5.27, 1194.45),
    Tuple3(12, 2.08, 4694),
    Tuple3(11, 0.77, 553.57),
    Tuple3(10, 1.3, 6286.6),
    Tuple3(10, 4.24, 1349.87),
    Tuple3(9, 2.7, 242.73),
    Tuple3(9, 5.64, 951.72),
    Tuple3(8, 5.3, 2352.87),
    Tuple3(6, 2.65, 9437.76),
    Tuple3(6, 4.67, 4690.48)
  ],
  [
    Tuple3(52919.0, 0, 0),
    Tuple3(8720.0, 1.0721, 6283.0758),
    Tuple3(309.0, 0.867, 12566.152),
    Tuple3(27, 0.05, 3.52),
    Tuple3(16, 5.19, 26.3),
    Tuple3(16, 3.68, 155.42),
    Tuple3(10, 0.76, 18849.23),
    Tuple3(9, 2.06, 77713.77),
    Tuple3(7, 0.83, 775.52),
    Tuple3(5, 4.66, 1577.34),
    Tuple3(4, 1.03, 7.11),
    Tuple3(4, 3.44, 5573.14),
    Tuple3(3, 5.14, 796.3),
    Tuple3(3, 6.05, 5507.55),
    Tuple3(3, 1.19, 242.73),
    Tuple3(3, 6.12, 529.69),
    Tuple3(3, 0.31, 398.15),
    Tuple3(3, 2.28, 553.57),
    Tuple3(2, 4.38, 5223.69),
    Tuple3(2, 3.75, 0.98)
  ],
  [
    Tuple3(289.0, 5.844, 6283.076),
    Tuple3(35, 0, 0),
    Tuple3(17, 5.49, 12566.15),
    Tuple3(3, 5.2, 155.42),
    Tuple3(1, 4.72, 3.52),
    Tuple3(1, 5.3, 18849.23),
    Tuple3(1, 5.97, 242.73)
  ],
  [
    Tuple3(114.0, 3.142, 0),
    Tuple3(8, 4.13, 6283.08),
    Tuple3(1, 3.84, 12566.15)
  ],
  [
    Tuple3(1, 3.14, 0)
  ]
];

const _bterms = <List<Tuple3<double, double, double>>>[
  [
    Tuple3(280.0, 3.199, 84334.662),
    Tuple3(102.0, 5.422, 5507.553),
    Tuple3(80, 3.88, 5223.69),
    Tuple3(44, 3.7, 2352.87),
    Tuple3(32, 4, 1577.34)
  ],
  [
    Tuple3(9, 3.9, 5507.55),
    Tuple3(6, 1.73, 5223.69)
  ],
];

const _rterms = <List<Tuple3<double, double, double>>>[
  [
    Tuple3(100013989.0, 0, 0),
    Tuple3(1670700.0, 3.0984635, 6283.07585),
    Tuple3(13956.0, 3.05525, 12566.1517),
    Tuple3(3084.0, 5.1985, 77713.7715),
    Tuple3(1628.0, 1.1739, 5753.3849),
    Tuple3(1576.0, 2.8469, 7860.4194),
    Tuple3(925.0, 5.453, 11506.77),
    Tuple3(542.0, 4.564, 3930.21),
    Tuple3(472.0, 3.661, 5884.927),
    Tuple3(346.0, 0.964, 5507.553),
    Tuple3(329.0, 5.9, 5223.694),
    Tuple3(307.0, 0.299, 5573.143),
    Tuple3(243.0, 4.273, 11790.629),
    Tuple3(212.0, 5.847, 1577.344),
    Tuple3(186.0, 5.022, 10977.079),
    Tuple3(175.0, 3.012, 18849.228),
    Tuple3(110.0, 5.055, 5486.778),
    Tuple3(98, 0.89, 6069.78),
    Tuple3(86, 5.69, 15720.84),
    Tuple3(86, 1.27, 161000.69),
    Tuple3(65, 0.27, 17260.15),
    Tuple3(63, 0.92, 529.69),
    Tuple3(57, 2.01, 83996.85),
    Tuple3(56, 5.24, 71430.7),
    Tuple3(49, 3.25, 2544.31),
    Tuple3(47, 2.58, 775.52),
    Tuple3(45, 5.54, 9437.76),
    Tuple3(43, 6.01, 6275.96),
    Tuple3(39, 5.36, 4694),
    Tuple3(38, 2.39, 8827.39),
    Tuple3(37, 0.83, 19651.05),
    Tuple3(37, 4.9, 12139.55),
    Tuple3(36, 1.67, 12036.46),
    Tuple3(35, 1.84, 2942.46),
    Tuple3(33, 0.24, 7084.9),
    Tuple3(32, 0.18, 5088.63),
    Tuple3(32, 1.78, 398.15),
    Tuple3(28, 1.21, 6286.6),
    Tuple3(28, 1.9, 6279.55),
    Tuple3(26, 4.59, 10447.39)
  ],
  [
    Tuple3(103019.0, 1.10749, 6283.07585),
    Tuple3(1721.0, 1.0644, 12566.1517),
    Tuple3(702.0, 3.142, 0),
    Tuple3(32, 1.02, 18849.23),
    Tuple3(31, 2.84, 5507.55),
    Tuple3(25, 1.32, 5223.69),
    Tuple3(18, 1.42, 1577.34),
    Tuple3(10, 5.91, 10977.08),
    Tuple3(9, 1.42, 6275.96),
    Tuple3(9, 0.27, 5486.78)
  ],
  [
    Tuple3(4359.0, 5.7846, 6283.0758),
    Tuple3(124.0, 5.579, 12566.152),
    Tuple3(12, 3.14, 0),
    Tuple3(9, 3.63, 77713.77),
    Tuple3(6, 1.87, 5573.14),
    Tuple3(3, 5.47, 18849.23)
  ],
  [
    Tuple3(145.0, 4.273, 6283.076),
    Tuple3(7, 3.92, 12566.15)
  ],
  [
    Tuple3(4, 2.56, 6283.08)
  ]
];

const _yterms = <Tuple5<double, double, double, double, double>>[
  Tuple5(0, 0, 0, 0, 1),
  Tuple5(-2, 0, 0, 2, 2),
  Tuple5(0, 0, 0, 2, 2),
  Tuple5(0, 0, 0, 0, 2),
  Tuple5(0, 1, 0, 0, 0),
  Tuple5(0, 0, 1, 0, 0),
  Tuple5(-2, 1, 0, 2, 2),
  Tuple5(0, 0, 0, 2, 1),
  Tuple5(0, 0, 1, 2, 2),
  Tuple5(-2, -1, 0, 2, 2),
  Tuple5(-2, 0, 1, 0, 0),
  Tuple5(-2, 0, 0, 2, 1),
  Tuple5(0, 0, -1, 2, 2),
  Tuple5(2, 0, 0, 0, 0),
  Tuple5(0, 0, 1, 0, 1),
  Tuple5(2, 0, -1, 2, 2),
  Tuple5(0, 0, -1, 0, 1),
  Tuple5(0, 0, 1, 2, 1),
  Tuple5(-2, 0, 2, 0, 0),
  Tuple5(0, 0, -2, 2, 1),
  Tuple5(2, 0, 0, 2, 2),
  Tuple5(0, 0, 2, 2, 2),
  Tuple5(0, 0, 2, 0, 0),
  Tuple5(-2, 0, 1, 2, 2),
  Tuple5(0, 0, 0, 2, 0),
  Tuple5(-2, 0, 0, 2, 0),
  Tuple5(0, 0, -1, 2, 1),
  Tuple5(0, 2, 0, 0, 0),
  Tuple5(2, 0, -1, 0, 1),
  Tuple5(-2, 2, 0, 2, 2),
  Tuple5(0, 1, 0, 0, 1),
  Tuple5(-2, 0, 1, 0, 1),
  Tuple5(0, -1, 0, 0, 1),
  Tuple5(0, 0, 2, -2, 0),
  Tuple5(2, 0, -1, 2, 1),
  Tuple5(2, 0, 1, 2, 2),
  Tuple5(0, 1, 0, 2, 2),
  Tuple5(-2, 1, 1, 0, 0),
  Tuple5(0, -1, 0, 2, 2),
  Tuple5(2, 0, 0, 2, 1),
  Tuple5(2, 0, 1, 0, 0),
  Tuple5(-2, 0, 2, 2, 2),
  Tuple5(-2, 0, 1, 2, 1),
  Tuple5(2, 0, -2, 0, 1),
  Tuple5(2, 0, 0, 0, 1),
  Tuple5(0, -1, 1, 0, 0),
  Tuple5(-2, -1, 0, 2, 1),
  Tuple5(-2, 0, 0, 0, 1),
  Tuple5(0, 0, 2, 2, 1),
  Tuple5(-2, 0, 2, 0, 1),
  Tuple5(-2, 1, 0, 2, 1),
  Tuple5(0, 0, 1, -2, 0),
  Tuple5(-1, 0, 1, 0, 0),
  Tuple5(-2, 1, 0, 0, 0),
  Tuple5(1, 0, 0, 0, 0),
  Tuple5(0, 0, 1, 2, 0),
  Tuple5(0, 0, -2, 2, 2),
  Tuple5(-1, -1, 1, 0, 0),
  Tuple5(0, 1, 1, 0, 0),
  Tuple5(0, -1, 1, 2, 2),
  Tuple5(2, -1, -1, 2, 2),
  Tuple5(0, 0, 3, 2, 2),
  Tuple5(2, -1, 0, 2, 2),
];

const _peTerms = <Tuple4<double, double, double, double>>[
  Tuple4(-171996, -174.2, 92025, 8.9),
  Tuple4(-13187, -1.6, 5736, -3.1),
  Tuple4(-2274, -0.2, 977, -0.5),
  Tuple4(2062, 0.2, -895, 0.5),
  Tuple4(1426, -3.4, 54, -0.1),
  Tuple4(712, 0.1, -7, 0),
  Tuple4(-517, 1.2, 224, -0.6),
  Tuple4(-386, -0.4, 200, 0),
  Tuple4(-301, 0, 129, -0.1),
  Tuple4(217, -0.5, -95, 0.3),
  Tuple4(-158, 0, 0, 0),
  Tuple4(129, 0.1, -70, 0),
  Tuple4(123, 0, -53, 0),
  Tuple4(63, 0, 0, 0),
  Tuple4(63, 0.1, -33, 0),
  Tuple4(-59, 0, 26, 0),
  Tuple4(-58, -0.1, 32, 0),
  Tuple4(-51, 0, 27, 0),
  Tuple4(48, 0, 0, 0),
  Tuple4(46, 0, -24, 0),
  Tuple4(-38, 0, 16, 0),
  Tuple4(-31, 0, 13, 0),
  Tuple4(29, 0, 0, 0),
  Tuple4(29, 0, -12, 0),
  Tuple4(26, 0, 0, 0),
  Tuple4(-22, 0, 0, 0),
  Tuple4(21, 0, -10, 0),
  Tuple4(17, -0.1, 0, 0),
  Tuple4(16, 0, -8, 0),
  Tuple4(-16, 0.1, 7, 0),
  Tuple4(-15, 0, 9, 0),
  Tuple4(-13, 0, 7, 0),
  Tuple4(-12, 0, 6, 0),
  Tuple4(11, 0, 0, 0),
  Tuple4(-10, 0, 5, 0),
  Tuple4(-8, 0, 3, 0),
  Tuple4(7, 0, -3, 0),
  Tuple4(-7, 0, 0, 0),
  Tuple4(-7, 0, 3, 0),
  Tuple4(-7, 0, 3, 0),
  Tuple4(6, 0, 0, 0),
  Tuple4(6, 0, -3, 0),
  Tuple4(6, 0, -3, 0),
  Tuple4(-6, 0, 3, 0),
  Tuple4(-6, 0, 3, 0),
  Tuple4(5, 0, 0, 0),
  Tuple4(-5, 0, 3, 0),
  Tuple4(-5, 0, 3, 0),
  Tuple4(-5, 0, 3, 0),
  Tuple4(4, 0, 0, 0),
  Tuple4(4, 0, 0, 0),
  Tuple4(4, 0, 0, 0),
  Tuple4(-4, 0, 0, 0),
  Tuple4(-4, 0, 0, 0),
  Tuple4(-4, 0, 0, 0),
  Tuple4(3, 0, 0, 0),
  Tuple4(-3, 0, 0, 0),
  Tuple4(-3, 0, 0, 0),
  Tuple4(-3, 0, 0, 0),
  Tuple4(-3, 0, 0, 0),
  Tuple4(-3, 0, 0, 0),
  Tuple4(-3, 0, 0, 0),
  Tuple4(-3, 0, 0, 0),
];

double _r2d(double rad) => (180 / pi) * rad;
double _d2r(double deg) => (pi / 180) * deg;

double _limitDeg(double deg) {
  deg /= 360;
  deg = 360 * (deg - deg.floor());
  if (deg < 0) deg += 360;
  return deg;
}

double _limitDeg180pm(double deg) {
  deg /= 360.0;
  deg = 360 * (deg - deg.floor());
  if (deg < -180) deg += 360;
  if (deg > 180) deg -= 360;
  return deg;
}

double _limitDeg180(double deg) {
  deg /= 180;
  deg = 180 * (deg - deg.floor());
  if (deg < 0) deg += 180;
  return deg;
}

double _limitZero2One(double value) {
  value -= value.floor();
  if (value < 0) value += 1;
  return value;
}

double _limitMinutes(double minutes) {
  if (minutes < -20) minutes += 1440;
  if (minutes > 20) minutes += 1440;
  return minutes;
}

double _dayFrac2LocalHr(double dayFrac, double timezone) =>
  24 * _limitZero2One(dayFrac + timezone / 24);

double _thirdOrderPolynomial(double a, double b, double c, double d, double x) =>
  ((a * x + b) * x + c) * x + d;

double _julianDay(DateTime time, double second, double timeZone, double dut1) {
  final dayDec = time.day +
    (time.hour - timeZone + (time.minute + (second + dut1) / 60) / 60) / 24;

  int month = time.month;
  int year = time.year;

  if (month < 3) {
    month += 12;
    year--;
  }

  double julianDay =
    (365.25 * (year + 4716.0)).floor() +
    (30.6001 * (month + 1)).floor() + dayDec - 1524.5;

  if (julianDay > 2299160) {
    final a = year ~/ 100;
    julianDay += 2 - a + a ~/ 4;
  }

  return julianDay;
}

double _julianCentury(double jd) => (jd - 2451545) / 36525;
double _julianEphemerisDay(double jd, double deltaT) => jd + deltaT / 86400;
double _julianEphemerisCentury(double jde) => (jde - 2451545) / 36525;
double _julianEphemerisMillenium(double jce) => jce / 10;

double _earthPeriodicTermSum(
  List<Tuple3<double, double, double>> terms, double jme
) =>
  terms.fold(0, (s, e) => s + e.item1 * cos(e.item2 + e.item3 * jme));

double _earthHeliocentricLongitude(double jme) {
  var sum = 0.0;
  for (int i = 0; i < _lterms.length; i++) {
    sum += _earthPeriodicTermSum(_lterms[i], jme) * pow(jme, i);
  }
  return _limitDeg(_r2d(sum / 1e8));
}

double _earthHeliocentricLatitude(double jme) {
  var sum = 0.0;
  for (int i = 0; i < _bterms.length; i++) {
    sum += _earthPeriodicTermSum(_bterms[i], jme) * pow(jme, i);
  }
  return _r2d(sum / 1e8);
}

double _earthRadiusVector(double jme) {
  var sum = 0.0;
  for (int i = 0; i < _rterms.length; i++) {
    sum += _earthPeriodicTermSum(_rterms[i], jme) * pow(jme, i);
  }
  return sum / 1e8;
}

double _geocentricLongitude(double l) {
  l += 180;
  if (l >= 360) l -= 360;
  return l;
}

double _geocentricLatitude(double b) => -b;

double _meanElongationMoonSun(double jce) =>
  _thirdOrderPolynomial(1 / 189474, -0.0019142, 445267.11148, 297.85036, jce);

double _meanAnomalySun(double jce) =>
  _thirdOrderPolynomial(-1 / 300000.0, -0.0001603, 35999.05034, 357.52772, jce);

double _meanAnomalyMoon(double jce) =>
  _thirdOrderPolynomial(1 / 56250.0, 0.0086972, 477198.867398, 134.96298, jce);

double _argumentLatitudeMoon(double jce) =>
  _thirdOrderPolynomial(1 / 327270.0, -0.0036825, 483202.017538, 93.27191, jce);

double _ascendingLongitudeMoon(double jce) =>
  _thirdOrderPolynomial(1 / 450000.0, 0.0020708, -1934.136261, 125.04452, jce);

double _xyTermSummation(int i, Tuple5<double, double, double, double, double> x) =>
  x.item1 * _yterms[i].item1 +
  x.item2 * _yterms[i].item2 +
  x.item3 * _yterms[i].item3 +
  x.item4 * _yterms[i].item4 +
  x.item5 * _yterms[i].item5;

Tuple2<double, double> _nutationLongAndObliquity(double jce, Tuple5<double, double, double, double, double> x) {
  var sumPsi = 0.0;
  var sumEps = 0.0;

  for (int i = 0; i < _yterms.length; i++) {
    final rad = _d2r(_xyTermSummation(i, x));
    final pe = _peTerms[i];
    sumPsi += (pe.item1 + jce * pe.item2) * sin(rad);
    sumEps += (pe.item3 + jce * pe.item4) * cos(rad);
  }

  return Tuple2(sumPsi / 36000000, sumEps / 36000000);
}

double _eclipticMeanObliquity(double jme) {
  final u = jme / 10;
  return 84381.448 + u * (-4680.93 + u * (-1.55 + u * (1999.25 + u * (-51.38 +
    u * (-249.67 + u * (-39.05 + u * (7.12 + u *
      (27.87 + u * (5.79 + u * 2.45))
    )))
  ))));
}

double _eclipticTrueObliquity(double deltaEps, double eps) =>
  deltaEps + eps / 3600;

double _aberrationCorrection(double r) => -20.4898 / (3600 * r);

double _apparentSunLongitude(double theta, double deltaPsi, double deltaTau) =>
  theta + deltaPsi + deltaTau;

double _greenwichMeanSiderealTime(double jd, double jc) => _limitDeg(
  280.46061837 + 360.98564736629 * (jd - 2451545.0) +
  jc * jc * (0.000387933 - jc / 38710000.0)
);

double _greenwichSiderealTime(double nu0, double deltaPsi, double eps) =>
  nu0 + deltaPsi * cos(_d2r(eps));

double _geocentricRightAscention(double lambda, double eps, double beta) {
  final lambdaRad = _d2r(lambda);
  final epsRad = _d2r(eps);
  return _limitDeg(_r2d(atan2(sin(lambdaRad) * cos(epsRad) -
    tan(_d2r(beta)) * sin(epsRad), cos(lambdaRad)
  )));
}

double _geocentricDeclination(double beta, double eps, double lambda) {
  final betaRad = _d2r(beta);
  final epsRad = _d2r(eps);
  return _r2d(asin(sin(betaRad) * cos(epsRad) +
    cos(betaRad) * sin(epsRad) * sin(_d2r(lambda))
  ));
}

double _observerHourAngle(double nu, double longitude, double alphaDeg) =>
  _limitDeg(nu + longitude - alphaDeg);

double _sunEquatorialHorizontalParallax(double r) => 8.794 / (3600 * r);

Tuple2<double, double> _rightAscentionParallax(
  double latitude, double elevation, double xi, double h, double delta
) {
  final latRad = _d2r(latitude);
  final xiRad = _d2r(xi);
  final hRad = _d2r(h);
  final deltaRad = _d2r(delta);
  final u = atan(0.99664719 * tan(latRad));
  final y = 0.99664719 * sin(u) + elevation * sin(latRad) / 6378140;
  final x = cos(u) + elevation * cos(latRad) / 6378140;

  final dtAlphaRad = atan2(-x * sin(xiRad) * sin(hRad),
    cos(deltaRad) - x * sin(xiRad) * cos(hRad)
  );

  return Tuple2(
    _r2d(dtAlphaRad),
    _r2d(atan2((sin(deltaRad) - y * sin(xiRad)) * cos(dtAlphaRad),
      cos(deltaRad) - x * sin(xiRad) * cos(hRad)
    )),
  );
}

double _topocentricElevationAngle(
  double latitude, double dtPrime, double hPrime
) {
  final latRad = _d2r(latitude);
  final dtPrimeRad = _d2r(dtPrime);
  return _r2d(asin(sin(latRad) * sin(dtPrimeRad) +
    cos(latRad) * cos(dtPrimeRad) * cos(_d2r(hPrime))
  ));
}

double _atmosphericRefractionCorrection(
  double pressure, double temperature, double atmosRefract, double e0
) {
  if (e0 < -(_sunRadius + atmosRefract)) return 0;
  return (pressure / 1010) * (283 / (273 + temperature)) *
    1.02 / (60 * tan(_d2r(e0 + 10.3 / (e0 + 5.11))));
}

double _topocentricElevationAngle2(double e0, double deltaE) => e0 + deltaE;
double _topocentricZenithAngle(double e) => 90 - e;

double _topocentricAzimuthAngleAstro(
  double hPrime, double latitude, double dtPrime
) {
  final hPrimeRad = _d2r(hPrime);
  final latRad = _d2r(latitude);
  return _limitDeg(_r2d(atan2(sin(hPrimeRad),
    cos(hPrimeRad) * sin(latRad) - tan(_d2r(dtPrime)) * cos(latRad)
  )));
}

double _topocentricAzimuthAngle(double azimuthAstro) =>
  _limitDeg(azimuthAstro + 180);

double _surfaceIncidenceAngle(
  double zenith, double azimuthAstro, double azmRotation, double slope,
) {
  final zenithRad = _d2r(zenith);
  final slopeRad = _d2r(slope);

  return _r2d(acos(cos(zenithRad) * cos(slopeRad) +
    sin(slopeRad) * sin(zenithRad) * cos(_d2r(azimuthAstro - azmRotation))
  ));
}

double _sunMeanLongitude(double jme) =>
  _limitDeg(280.4664567 + jme * (360007.6982779 + jme * (0.03032028 + jme *
    (1 / 49931.0 + jme * (-1 / 15300 + jme * (-1 / 2000000))))));

double _eot(double m, double alpha, double delPsi, double epsilon) =>
  _limitMinutes(4 * (m - 0.0057183 - alpha + delPsi * cos(_d2r(epsilon))));

double _approxSunTransitionTime(double alphaZero, double longitude, double nu) =>
  (alphaZero - longitude - nu) / 360;

double _sunHourAngleAtRiseSet(double latitude, double dtZero, double h0Prime) {
  var h0 = -99999.0;
  final latitudeRad = _d2r(latitude);
  final dtZeroRad = _d2r(dtZero);
  final argument = (sin(_d2r(h0Prime)) - sin(latitudeRad) * sin(dtZeroRad)) /
    (cos(latitudeRad) * cos(dtZeroRad));
  if (argument.abs() <= 1) h0 = _limitDeg180(_r2d(acos(argument)));
  return h0;
}

double _sunRiseAndSet(
  double mRts, double hRts, double dtPrime, double latitude,
  double hPrime, double h0Prime, int sun) =>
    mRts + (hRts -  h0Prime) /
    (360 * cos(_d2r(dtPrime)) * cos(_d2r(latitude)) * sin(_d2r(hPrime)));

double _rtsAlphaDeltaPrime(Tuple3<double, double, double> ad, double n) {
  var a = ad.item2 - ad.item1;
  var b = ad.item3 - ad.item2;

  if (a.abs() >= 2) a = _limitZero2One(a);
  if (b.abs() >= 2) b = _limitZero2One(b);

  return ad.item2 + n * (a + b + (b - a) * n) / 2;
}

double _rtsSunAltitude(double latitude, double deltaPrime, double hPrime) {
  final latitudeRad = _d2r(latitude);
  final dtPrimeRad = _d2r(deltaPrime);
  return _r2d(asin(sin(latitudeRad) * sin(dtPrimeRad) +
    cos(latitudeRad) * cos(dtPrimeRad) * cos(_d2r(hPrime)))
  );
}

void _calculateGeoSun(
  SPAParams params, SPAIntermediate it, double jd, double deltaT
) {
  it.jc = _julianCentury(jd);

  it.jde = _julianEphemerisDay(jd, deltaT);
  it.jce = _julianEphemerisCentury(it.jde!);
  it.jme = _julianEphemerisMillenium(it.jce!);

  it.l = _earthHeliocentricLongitude(it.jme!);
  it.b = _earthHeliocentricLatitude(it.jme!);
  it.r = _earthRadiusVector(it.jme!);

  it.theta = _geocentricLongitude(it.l!);
  it.beta = _geocentricLatitude(it.b!);

  it.x = Tuple5(
    _meanElongationMoonSun(it.jce!),
    _meanAnomalySun(it.jce!),
    _meanAnomalyMoon(it.jce!),
    _argumentLatitudeMoon(it.jce!),
    _ascendingLongitudeMoon(it.jce!),
  );

  final dl = _nutationLongAndObliquity(it.jce!, it.x!);
  it.delPsi = dl.item1;
  it.delEps = dl.item2;

  it.epsilon0 = _eclipticMeanObliquity(it.jme!);
  it.epsilon = _eclipticTrueObliquity(it.delEps!, it.epsilon0!);

  it.delTau = _aberrationCorrection(it.r!);
  it.lamda = _apparentSunLongitude(it.theta!, it.delPsi!, it.delTau!);
  it.nu0 = _greenwichMeanSiderealTime(jd, it.jc!);
  it.nu = _greenwichSiderealTime(it.nu0!, it.delPsi!, it.epsilon!);

  it.alpha = _geocentricRightAscention(it.lamda!, it.epsilon!, it.beta!);
  it.delta = _geocentricDeclination(it.beta!, it.epsilon!, it.lamda!);
}

void _calculateEotAndSunRiseTransitSet(
  SPAOutput out, SPAParams params, SPAIntermediate it
) {
  final m = _sunMeanLongitude(it.jme!);
  it.eot = _eot(m, it.alpha!, it.delPsi!, it.epsilon!);

  final sunIt = SPAIntermediate();
  var sunJd = _julianDay(DateTime.utc(
    params.time.year, params.time.month, params.time.day
  ), 0, 0, 0);
  _calculateGeoSun(params, sunIt, sunJd--, 0);
  final nu = sunIt.nu!;

  _calculateGeoSun(params, sunIt, sunJd++, 0);
  final nd = Tuple2(sunIt.alpha!, sunIt.delta!);
  _calculateGeoSun(params, sunIt, sunJd++, 0);
  final zd = Tuple2(sunIt.alpha!, sunIt.delta!);
  _calculateGeoSun(params, sunIt, sunJd++, 0);
  final pd = Tuple2(sunIt.alpha!, sunIt.delta!);

  final alpha = Tuple3(nd.item1, zd.item1, pd.item1);
  final delta = Tuple3(nd.item2, zd.item2, pd.item2);

  final mRtsTransit = _approxSunTransitionTime(alpha.item2, params.longitude, nu);
  final h0Prime = -(_sunRadius + params.atmosRefract);
  final h0 = _sunHourAngleAtRiseSet(params.latitude, delta.item2, h0Prime);

  if (h0 < 0) {
    it.srha = it.ssha = it.sta = out.sunTransit = out.sunrise = out.sunset =
      -99999;
    return;
  }

  final h0Dfrac = h0 / 360;
  final mRts = Tuple3(
    _limitZero2One(mRtsTransit),
    _limitZero2One(mRtsTransit - h0Dfrac),
    _limitZero2One(mRtsTransit + h0Dfrac),
  );

  Tuple5<double, double, double, double, double> calcpr(double m) {
    final nuRts = nu + 360.985647 * m;
    final n = m + params.deltaT / 86400;
    final alphaPrime = _rtsAlphaDeltaPrime(alpha, n);
    final deltaPrime = _rtsAlphaDeltaPrime(delta, n);
    final hPrime = _limitDeg180pm(nuRts + params.longitude - alphaPrime);
    final hRts = _rtsSunAltitude(params.latitude, deltaPrime, hPrime);
    return Tuple5(nuRts, alphaPrime, deltaPrime, hPrime, hRts);
  }

  final prTrans = calcpr(mRts.item1);
  final prRise = calcpr(mRts.item2);
  final prSet = calcpr(mRts.item3);

  it.srha = prRise.item4;
  it.ssha = prSet.item4;
  it.sta = prTrans.item5;

  final timezone = params.timeZone;

  out.sunTransit = _dayFrac2LocalHr(mRts.item1 - prTrans.item4 / 360, timezone);

  out.sunrise = _dayFrac2LocalHr(_sunRiseAndSet(
    mRts.item2, prRise.item5, prRise.item3,
    params.latitude, prRise.item4, h0Prime, 1,
  ), timezone);

  out.sunset = _dayFrac2LocalHr(_sunRiseAndSet(
    mRts.item3, prSet.item5, prSet.item3,
    params.latitude, prSet.item4, h0Prime, 1,
  ), timezone);
}

/// Calculate sun position information with the specified parameters.
SPAOutput spaCalculate(SPAParams params, {
  /// Intermediate values to write to.
  SPAIntermediate? intermediate,

  /// Whether or not to calculate the incidence angle. (defaults to true)
  bool incidence = true,

  /// Whether or not to calculate the sun rise / transit / set.
  /// (defaults to true)
  bool sun = true,

  /// Whether or not to enable assertions on the input parameters, if this is
  /// turned off there are no guarantees on accuracy. This has no effect if
  /// assertions are already turned off by the platform (e.g. Flutter's release
  /// mode).
  bool safe = true,
}) {
  final out = SPAOutput();
  final it = intermediate ??= SPAIntermediate();

  if (safe) {
    assert(params.time.year >= -2000 && params.time.year <= 6000);
    assert(params.pressure >= 0 && params.pressure <= 5000);
    assert(params.temperature > -273 && params.temperature <= 6000);
    assert(params.deltaUtl > -1 && params.deltaUtl < 1);
    assert(params.longitude.abs() <= 180);
    assert(params.latitude.abs() <= 180);
    assert(params.atmosRefract <= 5);
    assert(params.elevation >= -6500000);
    assert(!incidence || params.slope <= 360);
    assert(!incidence || params.azmRotation <= 360);
  }

  it.jd = _julianDay(
    params.time, params.second, params.timeZone, params.deltaUtl
  );
  _calculateGeoSun(params, it, it.jd!, params.deltaT);

  it.h = _observerHourAngle(it.nu!, params.longitude, it.alpha!);
  it.xi  = _sunEquatorialHorizontalParallax(it.r!);

  final rap = _rightAscentionParallax(
    params.latitude, params.elevation, it.xi!, it.h!, it.delta!
  );
  it.delAlpha = rap.item1;
  it.delPrime = rap.item2;

  it.alphaPrime = it.alpha! + it.delAlpha!;
  it.hPrime = it.h! - it.delAlpha!;

  it.e0 = _topocentricElevationAngle(params.latitude, it.delPrime!, it.hPrime!);
  it.delE = _atmosphericRefractionCorrection(
    params.pressure, params.temperature, params.atmosRefract, it.e0!
  );

  it.e = _topocentricElevationAngle2(it.e0!, it.delE!);

  out.zenith = _topocentricZenithAngle(it.e!);
  out.azimuthAstro = _topocentricAzimuthAngleAstro(
    it.hPrime!, params.latitude, it.delPrime!
  );

  out.azimuth = _topocentricAzimuthAngle(out.azimuthAstro);

  if (incidence) {
    out.incidence = _surfaceIncidenceAngle(
      out.zenith, out.azimuthAstro, params.azmRotation, params.slope
    );
  }

  if (sun) {
    _calculateEotAndSunRiseTransitSet(out, params, it);
  }

  return out;
}