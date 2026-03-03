import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

class HiveBoxInit{
  Future<void> initHive() async {
    try {
      Directory? appDocDir;

      if (kIsWeb) {
        await Hive.initFlutter();
        if (kDebugMode) print("✅ Hive initialized for Web");
      } else {
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

          if (!await appDocDir.exists()) {
            await appDocDir.create(recursive: true);
          }
        }

        if (appDocDir == null) {
          throw Exception("Failed to determine app directory.");
        }

        Hive.init(appDocDir.path);
        if (kDebugMode) print("✅ Hive initialized at: ${appDocDir.path}");
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ Hive init failed: $e");
        print(stack);
      }
    }
  }
}