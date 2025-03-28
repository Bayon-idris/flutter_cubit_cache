import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cubit_cache/presentation/pages/home_page.dart';
import 'package:hive_flutter/adapters.dart';

import 'data/models/task_model.dart';
import 'data/repositories/tasks_repository.dart';
import 'data/sources/local_source.dart';
import 'data/sources/remote_source.dart';
import 'presentation/cubits/tasks_cubit.dart';

void main() async {
  final dio = Dio();
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());
  runApp(MyApp(dio: dio));
}

class MyApp extends StatelessWidget {
  final Dio dio;

  const MyApp({super.key, required this.dio});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TaskCubit(
            repository: TaskRepository(
              localSource: TaskLocalSource(),
              remoteSource: TaskRemoteSource(dio),
            ),
          ),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: true,
        home: TasksPage(),
      ),
    );
  }
}
