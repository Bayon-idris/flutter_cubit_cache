import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task_model.dart';
import '../cubits/tasks_cubit.dart';
import '../cubits/tasks_state.dart';
import '../widgets/task_item.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks")),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            return ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                return TaskItem(task: state.tasks[index]);
              },
            );
          } else if (state is TaskError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text("Aucune tâche disponible"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<TaskCubit>().addTask(
                Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: "Nouvelle tâche",
                    description: "Description de la tâche",
                    createdAt: DateTime.now().toString()),
              );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
