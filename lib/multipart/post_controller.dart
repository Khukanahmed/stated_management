import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:stated_management/network/network_caller.dart';
import 'package:flutter/material.dart';

class PostController extends GetxController {
  RxBool isLoading = false.obs;

  Future<void> uploadPost({
    required String title,
    required String description,
    required File imageFile,
  }) async {
    isLoading.value = true;

    try {
      final response = await NetworkCaller().request(
        method: RequestMethod.MULTIPART,
        url: 'https://yourapi.com/upload',
        isAuth: true,
        body: {'title': title, 'description': description},
        files: {'image': imageFile},
      );

      if (response != null) {
        if (kDebugMode) {
          print("Upload success: $response");
        }
        Get.snackbar(
          "Success",
          "Post uploaded successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Something went wrong",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      Get.snackbar(
        "Exception",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
