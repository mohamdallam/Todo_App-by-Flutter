import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/bottom_nav_bar/archive_task.dart';
import 'package:todo_app/modules/bottom_nav_bar/done_task.dart';
import 'package:todo_app/modules/bottom_nav_bar/new_task.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

// To Be More Easily When use this Cubit It Many Place
  static AppCubit get(context) => BlocProvider.of(context);

// BottonNavigationBar
////////////////////////////////////////////////////////////////
  int currentIndex = 0;
  List<Widget> screen = [
    NewTask(),
    DoneTask(),
    ArchiveTask(),
  ];

  List<String> title = [
    'Task',
    'Done',
    'Archive',
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

//////////////////////////////////////////////////////////////
  Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archiveTasks = [];

// createDatabase
////////////////////////////////////////////////////////////////
  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, time TEXT, date TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error when creating table ${error.toString()}');
        });
      },
      onOpen: (database) {
        print('database opened');

        getDataFormDatabase(database);
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }
// insertDatabase
////////////////////////////////////////////////////////////////
  insertDatabase({
    @required String title,
    @required String time,
    @required String date,
  }) async {
    await database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, time, date, status) VALUES("$title", "$time", "$date", "new")')
          .then((value) {
        print('${value} insert success');
        emit(AppInsertDatabaseStates());
        getDataFormDatabase(database);
      }).catchError((error) {
        print('error when insert new record${error.toString()}');
      });
      return null;
    });
  }

// getDataFormDatabase
////////////////////////////////////////////////////////////////
  void getDataFormDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archiveTasks = [];
    emit(AppGetDatabaseLoadingStates());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new')
          newTasks.add(element);
        else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archiveTasks.add(element);
      });
      emit(AppGetDatabaseStates());
    });
  }

// updateData
////////////////////////////////////////////////////////////////
  void updateData({
    @required String status,
    @required int id,
  }) async {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value) {
      getDataFormDatabase(database);
      emit(AppUpdateDatabaseStates());
    });
  }
// deleteData
////////////////////////////////////////////////////////////////
  void deleteData({
    @required int id,
  }) async {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFormDatabase(database);
      emit(AppDeleteDatabaseStates());
    });
  }

// BottomSheet
////////////////////////////////////////////////////////////////
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetStata({
    @required bool isShow,
    @required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetStates());
  }

  

}
