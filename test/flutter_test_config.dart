import 'dart:async';
import 'package:aquawild/src/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global test configuration executed before any test file runs under `flutter test`.
/// Enforces system font fallback to prevent GoogleFonts from initiating network requests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  AppTheme.useSystemFonts = true;
  await testMain();
}
