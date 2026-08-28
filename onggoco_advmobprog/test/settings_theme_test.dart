import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:onggoco_advmobprog/providers/theme_provider.dart';
import 'package:onggoco_advmobprog/screens/settings_screen.dart';

void main() {
  testWidgets('shows light mode text when theme is light', (tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: themeProvider,
        child: ScreenUtilInit(
          designSize: const Size(412, 715),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      ),
    );

    expect(themeProvider.isDark, isFalse);
    expect(find.text('Light Mode'), findsOneWidget);
    expect(find.text('Enable or disable light theme'), findsOneWidget);
  });
}
