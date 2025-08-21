import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class ConnectivityService extends GetxService {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Rx<ConnectivityResult> _connectionStatus = Rx<ConnectivityResult>(ConnectivityResult.none);

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    if (result.isEmpty) {
      _connectionStatus.value = ConnectivityResult.none;
    } else {
      _connectionStatus.value = result.first;
    }

    if (_connectionStatus.value == ConnectivityResult.none) {
      if (!(Get.isDialogOpen ?? false)) {
        Get.dialog(
          AlertDialog(
            title: const Text(
              'No Internet Connection',
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/new404animation.json', width: 150, height: 150),
                const SizedBox(height: 16),
                const Text('Please check your internet connection.'),
              ],
            ),
          ),
          barrierDismissible: false,
        );
      }
    } else {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}