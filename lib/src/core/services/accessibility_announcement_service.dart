import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Accessible Screen Reader Announcement Service.
///
/// Dispatches live auditory status messages to assistive technologies
/// (TalkBack on Android, VoiceOver on iOS/macOS, Windows Narrator, and Orca on Linux)
/// in full compliance with WCAG 2.2 AA Success Criterion 4.1.3 (Status Messages).
class AccessibilityAnnouncementService {
  AccessibilityAnnouncementService._();

  /// Announces [message] to active screen readers.
  /// Gracefully catches exceptions in headless test harnesses.
  static void announce(
    String message, {
    TextDirection textDirection = TextDirection.ltr,
  }) {
    try {
      final views = WidgetsBinding.instance.platformDispatcher.views;
      if (views.isNotEmpty) {
        SemanticsService.sendAnnouncement(
          views.first,
          message,
          textDirection,
        );
      } else {
        // Fallback for older semantics dispatch
        // ignore: deprecated_member_use
        SemanticsService.announce(message, textDirection);
      }
    } catch (_) {
      // Headless tests or unattached semantics trees fail gracefully
    }
  }
}
