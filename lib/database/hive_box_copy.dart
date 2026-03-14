import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../utilities/shared_preferences.dart';

class HiveBoxCopy {
  static const List<String> _boxes = [
    'brand',
    'company',
    'generic',
    'indication',
    'indicationgenericindex',
    'occupation',
    'pregnancycategory',
    'speciality',
    'systemicclass',
    'therapeuticclass',
    'therapeuticclassgenericindex',
  ];

  Future<void> copyHiveBoxes() async {
    try {
      final sharedPref = SharedPref();
      bool isLoggedIn = await sharedPref.getLoginStatus();

      // According to requirement: If user is already logged in, do not copy.
      if (isLoggedIn) {
        if (kDebugMode) print("⏭️ User already logged in, skipping Hive box copy.");
        return;
      }

      Directory? appDocDir;
      if (kIsWeb) {
        // Copying files manually to Web storage is not standard this way.
        // Usually handled by Hive.initFlutter() and openBox.
        return;
      }

      if (Platform.isAndroid || Platform.isIOS) {
        appDocDir = await getApplicationDocumentsDirectory();
      } else if (Platform.isWindows) {
        String customDirectoryName = "dimsdb";
        if (await Directory("C:\\").exists()) {
          appDocDir = Directory("C:\\$customDirectoryName");
        } else if (await Directory("D:").exists()) {
          appDocDir = Directory("D:\\$customDirectoryName");
        } else {
          appDocDir = Directory("${Platform.environment['APPDATA']}\\$customDirectoryName");
        }
      }

      if (appDocDir == null) return;

      if (!await appDocDir.exists()) {
        await appDocDir.create(recursive: true);
      }

      for (String boxName in _boxes) {
        final String fileName = "$boxName.hive";
        final File targetFile = File("${appDocDir.path}/$fileName");

        if (kDebugMode) print("📦 Copying $fileName to ${appDocDir.path} (Overwriting if exists)...");
        try {
          final ByteData data = await rootBundle.load("assets/hive_boxes/$fileName");
          final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          
          // writeAsBytes will create the file if it doesn't exist, 
          // and overwrite it if it does.
          await targetFile.writeAsBytes(bytes, flush: true);
          if (kDebugMode) print("✅ Successfully copied/replaced $fileName");
        } catch (e) {
          if (kDebugMode) print("❌ Error copying $fileName: $e");
        }
      }
    } catch (e) {
      if (kDebugMode) print("❌ HiveBoxCopy failed: $e");
    }
  }
}
