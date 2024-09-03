{pkgs}: {
  channel = "stable-23.11";
  packages = [
    pkgs.nodePackages.firebase-tools
    pkgs.jdk17
    pkgs.unzip
    pkgs.sdkmanager
  ];
    # Sets environment variables in the workspace
  env = {};
  idx.extensions = [
 "Dart-Code.dart-code"
 "Dart-Code.flutter"
 ];
  idx.previews = {
    previews = {
      android = {
        command = [
          "flutter"
          "run"
          "--machine"
          "-d"
          "android"
          "-d"
          "emulator-5554"
        ];
        manager = "flutter";
      };
    };
  };
}