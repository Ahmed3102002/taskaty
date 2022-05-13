import 'package:get/get.dart';
import 'package:taskaty/db/db_helper.dart';
import 'package:taskaty/models/task.dart';

class TaskController extends GetxController {
  final tasklist = <Task>[].obs;
  Future<int> addTask({Task? task}) {
    return DBHelper.insert(task!);
  }

  Future<void> getTask() async {
    final tasks = await DBHelper.query();
    tasklist.assignAll(tasks
        .map(
          (data) => Task.fromJson(data),
        )
        .toList());
  }

  void deleteTask(Task task) async {
    await DBHelper.delete(task);
    getTask();
  }

  void deleteAllTask() async {
    await DBHelper.deleteAll;
    getTask();
  }

  void markTaskCompleted(int id) async {
    await DBHelper.update(id);
    getTask();
  }
}
