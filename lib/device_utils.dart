// device_utils.dart
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/material.dart';

class DeviceUtils {

  static bool isIpad(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return MediaQuery.of(context).size.width > 600.0;
    }
    return false;
  }
}
