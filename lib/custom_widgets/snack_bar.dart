import 'package:get/get.dart';
import 'package:flutter/material.dart';

enum SnackbarType {
  networkError,
  success,
  failure,
}

class CustomSnackbar {
  static final Color _networkErrorColor = Colors.blue.shade600; // Dark Blue
  static final Color _successColor = Colors.greenAccent.shade400; // Dark Green
  static const Color _failureColor = Colors.red; // Dark Red

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.networkError:
        return Icons.signal_wifi_off;
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.failure:
        return Icons.error;
    }
  }

  static Color _getColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.networkError:
        return _networkErrorColor;
      case SnackbarType.success:
        return _successColor;
      case SnackbarType.failure:
        return _failureColor;
    }
  }

  static String _getTitle(SnackbarType type) {
    switch (type) {
      case SnackbarType.networkError:
        return 'Network Error';
      case SnackbarType.success:
        return 'Success';
      case SnackbarType.failure:
        return 'Error';
    }
  }

  static void showSnackbar({
    required SnackbarType type,
    required String message,
  }) {
    Get.snackbar(
      _getTitle(type),
      message,
      icon: Icon(_getIcon(type), color: _getColor(type)),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.grey.shade800,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 1500),
      margin: const EdgeInsets.all(12),
    );
  }
}
