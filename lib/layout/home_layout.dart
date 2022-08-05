import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/components/widget/widget.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is AppInsertDatabaseStates) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingStates,
              builder: (context) => cubit.screen[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            appBar: AppBar(
              title: Text(cubit.title[cubit.currentIndex]),
            ),
//FloatingActionButton
////////////////////////////////////////////////           
            floatingActionButton: FloatingActionButton(
              child: Icon(cubit.fabIcon),
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState.validate()) {
                    cubit.insertDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text);
                  }
                } else {
//  showBottomSheet  
///////////////////////////////////////////////               
                  scaffoldKey.currentState.showBottomSheet(
                        (context) => Container(
                          padding: EdgeInsets.all(20),
                          color: Colors.white,
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
//DefaultFormField Title                                    
/////////////////////////////////////////////////////////////////////////////
                                defaultFormField(
                               
                                  controller: titleController,
                                  type: TextInputType.text,
                                  label: 'Task title',
                                  prifix: Icons.title,
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return 'title must not be empty';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 15,
                                ),
//DefaultFormField Time
///////////////////////////////////////////////////////////////////////////////                                  
                                defaultFormField(
                                    controller: timeController,
                                    type: TextInputType.datetime,
                                    label: 'Task time',
                                    prifix: Icons.watch_later_outlined,
                                    validate: (String value) {
                                      if (value.isEmpty) {
                                        return 'time must not be empty';
                                      }
                                      return null;
                                    },
                                    onTap: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then((value) {
                                        timeController.text =
                                            value.format(context).toString();
                                        print(value.format(context));
                                      });
                                    }),
                                SizedBox(
                                  height: 15,
                                ),
 //DefaultFormField Date
 ///////////////////////////////////////////////////////////////////////////////                                 
                                defaultFormField(
                                  controller: dateController,
                                  type: TextInputType.datetime,
                                  label: 'Task date',
                                  prifix: Icons.calendar_today_outlined,
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return 'date must not be empty';
                                    }
                                    return null;
                                  },
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2022-06-03'),
                                    ).then((value) {
                                      print(DateFormat.yMMMd().format(value));
                                      dateController.text =
                                          DateFormat.yMMMd().format(value);
                                    }).catchError((error) {
                                      print(error);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        elevation: 15,
                      ) // End Show Bottom Sheet/////////////////////////////////////////////////
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetStata(
                      isShow: false,
                      icon: Icons.edit,
                    );
                  });

                  cubit.changeBottomSheetStata(
                    isShow: true,
                    icon: Icons.add,
                  );
                }
              },
            ),
//  BottomNavigationBar        
// ///////////////////////////////////////////////////////////////////////////////        
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);

                print(index);
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Task'),
                BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_rounded), label: 'Archive'),
              ],
            ),
          );
        },
      ),
    );
  }
}
