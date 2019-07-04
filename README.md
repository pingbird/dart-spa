# Solar Positioning Algorithm - Calculate the position of the sun at arbitrary coordinates.

## About
This is a Dart implementation of the Solar Positioning Algorithm (SPA) by Ibrahim Reda and Afshin Andreas which is used by the U.S. government for radiology and energy purposes.
See the paper here: https://www.nrel.gov/docs/fy08osti/34302.pdf

Given an observers coordinates and DateTime it can calculate the position of the sun and other information such as when the sun rises and sets.

## Installation

Add the package to your `pubspec.yaml`:
```yaml
dependencies:
  spa: ^1.0.0
```

## Example

For a better example, see https://github.com/PixelToast/dart-spa/tree/master/example/cities

```dart
main() {
  var output = spaCalculate(SPAParams(
    time: DateTime(2019, 7, 2, 22),
    longitude: -83.045753,
    latitude: 42.331429,
    elevation: 191,
  ));

  print("zenith: ${output.zenith}");
  print("azimuth_astro: ${output.azimuthAstro}");
  print("azimuth: ${output.azimuth}");
  print("incidence: ${output.incidence}");
  print("suntransit: ${output.sunTransit}");
  print("sunrise: ${output.sunrise}");
  print("sunset: ${output.sunset}");
}
```
```
zenith: 97.83236091904035
azimuth_astro: 131.18876481734603
azimuth: 311.18876481734605
incidence: 97.83236091904035
suntransit: 13.604235957046416
sunrise: 5.994654066296624
sunset: 21.21272791301299
```

## Documentation

Documentation can be found at https://pub.dev/documentation/spa/latest/

## Accuracy

Guaranteed accuracy of +/- 0.0003 degrees.

This library is tested against the [C implementation by NREL](https://midcdmz.nrel.gov/spa/) using 1,000,000 random inputs, see [test/spa_test.dart](https://github.com/PixelToast/dart-spa/blob/master/test/spa_test.dart) for more information.

## Performance

Benchmarks are done using [benchmark/spa_benchmark.dart](https://github.com/PixelToast/dart-spa/blob/master/benchmark/spa_benchmark.dart).

On my desktop with a Ryzen 5 1600 @ 3.2Ghz I get:
```
         [vm] Result: 16529 spa/s |  60 μs/spa
        [DDC] Result:  8077 spa/s | 123 μs/spa
[dart2js -O4] Result: 25316 spa/s |  39 μs/spa
```

On an LG K10 with a Snapdragon 410 @ 1.2Ghz I get:
```
Result: 1149 spa/s | 869 μs/spa
```