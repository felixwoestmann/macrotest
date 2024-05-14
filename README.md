Playing around with the new Dart macros language feature.
Building heavily on https://github.com/millsteed/macros and https://www.reddit.com/r/FlutterDev/comments/1bru0ch/testing_dart_macros/.

This code implements a data class, similar to Freezed. 
Generating:
    - a constructor with named parameters
    - a copyWith method
    - a toString method
    - a == operator
    - a hashCode method
    - a toJson method
    - a fromJson method

If you want to run it you should have Flutter 3.22.0 installed and use the `--enable-experiment=macros` flag.

Executable Dart code is in `/bin`