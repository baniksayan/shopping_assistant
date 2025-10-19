import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

/// Helper widget to build platform-specific UI
class PlatformWidget extends StatelessWidget {
  final Widget Function(BuildContext context) androidBuilder;
  final Widget Function(BuildContext context) iosBuilder;

  const PlatformWidget({
    super.key,
    required this.androidBuilder,
    required this.iosBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return iosBuilder(context);
    }
    return androidBuilder(context);
  }
}

/// Platform-specific button
class PlatformButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final bool isLoading;

  const PlatformButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.primaryColor;

    if (Platform.isIOS) {
      return CupertinoButton(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(vertical: 14),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );
  }
}

/// Platform-specific alert dialog
class PlatformAlertDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String? cancelText,
    String? confirmText,
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            if (cancelText != null)
              CupertinoDialogAction(
                child: Text(cancelText),
                onPressed: () => Navigator.pop(context, false),
              ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(confirmText ?? 'OK'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );
    }

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          if (cancelText != null)
            TextButton(
              child: Text(cancelText),
              onPressed: () => Navigator.pop(context, false),
            ),
          TextButton(
            child: Text(confirmText ?? 'OK'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}
