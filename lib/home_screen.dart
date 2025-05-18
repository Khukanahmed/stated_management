import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stated_management/controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AlertController controller = Get.put(AlertController());

    return Scaffold(
      appBar: AppBar(title: const Text('Aleat'), backgroundColor: Colors.amber),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Form(
              key: controller.formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(
                      hintText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller.startTimeController,
                    decoration: const InputDecoration(
                      hintText: 'Start Time',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      await controller.pickTime(
                        context,
                        controller.startTimeController,
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a start time';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: controller.endTimeController,
                    decoration: const InputDecoration(
                      hintText: 'End Time',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () async {
                      await controller.pickTime(
                        context,
                        controller.endTimeController,
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an end time';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: const RoundedRectangleBorder(),
                      ),
                      onPressed: controller.saveAlert,
                      child: const Text("SAVE"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.alerts.length,
                  itemBuilder: (context, index) {
                    final alert = controller.alerts[index];
                    return Card(
                      child: ListTile(
                        title: Text(alert.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start: ${alert.startTime} - End: ${alert.endTime}',
                            ),
                            Obx(
                              () => Text(
                                'Remaining: ${controller.remainingTimes[alert.id] ?? "Calculating..."}',
                                style: TextStyle(
                                  color:
                                      controller.remainingTimes[alert.id] ==
                                              'Expired'
                                          ? Colors.red
                                          : Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => controller.deleteAlert(alert.id!),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
