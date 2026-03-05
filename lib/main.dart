import 'package:dims_desktop/controller/company_ctrl.dart';
import 'package:dims_desktop/screen/app_theme.dart';
import 'package:dims_desktop/screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'controller/app_controller.dart';
import 'controller/data_get_and_sync_ctrl.dart';
import 'database/hive_box_init.dart';
import 'database/hive_box_model_register.dart';
import 'database/hive_box_open.dart';
import 'models/brand/drug_brand_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/data_get_and_sync_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controller/theme_ctrl.dart';
import 'screen/main_screen.dart';
import 'screen/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await HiveBoxInit().initHive();
    await AdapterRegister().registerAdapters();
    await HiveBoxOpen.instance.hiveBoxOpen();
  } catch (e) {
    print('Error initializing Hive: $e');
  }

  runApp(const DimsApp());
}

class DimsApp extends StatelessWidget {
  const DimsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize ThemeCtrl before app starts
    Get.put(ThemeCtrl());

    return Obx(() {
      final themeCtrl = Get.put(ThemeCtrl());
      final theme = themeCtrl.currentTheme;

      return GetMaterialApp(
        title: 'DIMS - Drug Information Management System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: theme.isDark ? Brightness.dark : Brightness.light,
          scaffoldBackgroundColor: theme.bg,
          colorScheme: ColorScheme(
            brightness: theme.isDark ? Brightness.dark : Brightness.light,
            primary: theme.accent,
            onPrimary: theme.isDark ? Colors.white : Colors.black,
            secondary: theme.accent.withOpacity(0.7),
            onSecondary: theme.isDark ? Colors.white : Colors.black,
            error: AppTheme.accentRed,
            onError: Colors.white,
            surface: theme.surface,
            onSurface: theme.textPrimary,
          ),
          fontFamily: 'SF Pro Display',
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(theme.divider),
            thickness: WidgetStateProperty.all(4),
            radius: const Radius.circular(4),
          ),
          textTheme: TextTheme(
            displayLarge: TextStyle(
              fontSize: 24 * themeCtrl.fontSizeScale,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
              letterSpacing: -0.5,
            ),
            displayMedium: TextStyle(
              fontSize: 18 * themeCtrl.fontSizeScale,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
              letterSpacing: -0.3,
            ),
            displaySmall: TextStyle(
              fontSize: 14 * themeCtrl.fontSizeScale,
              fontWeight: FontWeight.w600,
              color: theme.textPrimary,
            ),
            bodyLarge: TextStyle(
              fontSize: 13 * themeCtrl.fontSizeScale,
              fontWeight: FontWeight.w400,
              color: theme.textPrimary,
            ),
            bodyMedium: TextStyle(
              fontSize: 13 * themeCtrl.fontSizeScale,
              fontWeight: FontWeight.w400,
              color: theme.textSecondary,
            ),
            labelSmall: TextStyle(
              fontSize: 11 * themeCtrl.fontSizeScale,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        home: const _AppRoot(),
      );
    });
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}