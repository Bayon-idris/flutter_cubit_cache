import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cubit_cache/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/sources/remote_source.dart';
import 'presentation/cubits/tasks_cubit.dart';
import 'presentation/pages/home_page.dart';
import 'data/repositories/tasks_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskCubit>(
          create: (context) => TaskCubit(
              repository: TaskRepository(remoteSource: TaskRemoteSource(Dio())))
            ..fetchTasks(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TasksPage(),
      ),
    );
  }
}
