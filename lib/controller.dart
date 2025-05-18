import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stated_management/database.dart';
import 'package:stated_management/model.dart';

class AlertController extends GetxController {
  final alerts = <Alert>[].obs;
  final nameController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final remainingTimes = <int, String>{}.obs; // Map to store timer values
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    loadAlerts();
    startTimer();
  }

  Future<void> loadAlerts() async {
    final loadedAlerts = await DatabaseHelper.instance.getAlerts();
    alerts.assignAll(loadedAlerts);
    updateTimers();
  }

  Future<void> saveAlert() async {
    if (formKey.currentState!.validate()) {
      final alert = Alert(
        name: nameController.text,
        startTime: startTimeController.text,
        endTime: endTimeController.text,
      );
      await DatabaseHelper.instance.insertAlert(alert);
      nameController.clear();
      startTimeController.clear();
      endTimeController.clear();
      await loadAlerts();
      Get.snackbar(
        'Success',
        'Alert saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteAlert(int id) async {
    await DatabaseHelper.instance.deleteAlert(id);
    remainingTimes.remove(id);
    await loadAlerts();
    Get.snackbar(
      'Success',
      'Alert deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTimers();
    });
  }

  void updateTimers() {
    final now = DateTime.now();
    for (var alert in alerts) {
      if (alert.id == null) continue;
      try {
        final endTimeParts = alert.endTime.split(':');
        final endHour = int.parse(endTimeParts[0]);
        final endMinute = int.parse(endTimeParts[1]);
        final endDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          endHour,
          endMinute,
        );

        if (endDateTime.isBefore(now)) {
          remainingTimes[alert.id!] = 'Expired';
        } else {
          final difference = endDateTime.difference(now);
          final hours = difference.inHours;
          final minutes = difference.inMinutes % 60;
          final seconds = difference.inSeconds % 60;
          remainingTimes[alert.id!] =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        }
      } catch (e) {
        remainingTimes[alert.id!] = 'Invalid';
      }
    }
  }

  Future<void> pickTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final formattedTime = picked.format(context);
      controller.text = formattedTime; // Formats as HH:mm
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    nameController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.onClose();
  }
}
