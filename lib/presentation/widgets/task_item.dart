import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task_model.dart';
import '../cubits/tasks_cubit.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(task.description),
        leading: Text("#${task.id}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => context.read<TaskCubit>().deleteTask(task.id),
        ),
      ),
    );
  }
}
