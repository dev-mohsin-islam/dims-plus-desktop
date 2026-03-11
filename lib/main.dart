import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'controller/auth_ctrl.dart';
import 'controller/theme_ctrl.dart';
import 'database/hive_box_init.dart';
import 'database/hive_box_model_register.dart';
import 'database/hive_box_open.dart';
import 'database/hive_box_copy.dart';
import 'screen/app_theme.dart';
import 'screen/login_screen.dart';
import 'screen/main_screen.dart';
import 'utilities/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool initialLoginStatus = false;
  try {
    await HiveBoxInit().initHive();
    await AdapterRegister().registerAdapters();
    
    final sharedPref = SharedPref();
    initialLoginStatus = await sharedPref.getLoginStatus();

    // According to requirement: If user is already logged in, do not copy.
    if (!initialLoginStatus) {
      await HiveBoxCopy().copyHiveBoxes();
    }
    
    await HiveBoxOpen.instance.hiveBoxOpen();
  } catch (e) {
    debugPrint('Error initializing app: $e');
  }

  // Initialize essential global controllers once at startup
  Get.put(ThemeCtrl());
  final authCtrl = Get.put(AuthCtrl());
  authCtrl.isLoggedIn.value = initialLoginStatus;

  runApp(const DimsApp());
}

class DimsApp extends StatelessWidget {
  const DimsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeCtrl>();

    // We avoid wrapping GetMaterialApp in Obx directly as it can cause 
    // Inspector issues during full app rebuilds. Instead, we use Obx 
    // for theme property extraction.
    return Obx(() {
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
    final authCtrl = Get.find<AuthCtrl>();
    return Obx(() {
      // Smallest possible reactive scope
      final loggedIn = authCtrl.isLoggedIn.value;
      return loggedIn ? const MainScreen() : const LoginScreen();
    });
  }
}
