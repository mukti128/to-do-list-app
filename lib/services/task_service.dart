import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list/model/task_model.dart';

class TaskService {
  final CollectionReference taskRef = FirebaseFirestore.instance.collection(
    'tasks',
  );

  Future<void> addTask(TaskModel task) async {
    await taskRef.add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    await taskRef.doc(task.id).update(task.toMap());
  }

  Future<void> softDeleteTask(String id) async {
    await taskRef.doc(id).update({'isDeleted': true});
  }

  Stream<List<TaskModel>> getTask() {
    return taskRef
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromFireStore(doc)).toList(),
        );
  }
}
