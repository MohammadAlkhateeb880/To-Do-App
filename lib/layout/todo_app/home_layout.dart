import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:intl/intl.dart'; // for Date Formatting
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/todo_app/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/todo_app/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/todo_app/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  // 1. Create Database
  // 2. Create Table
  // 3. Open Database
  // 4. Insert Into Database
  // 5. Update In Database
  // 6. Delete From Database
  // 7. get from Database

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
          listener: (BuildContext context, AppStates state) {
        if (state is AppInsertDatabaseState) {
          Navigator.pop(context);
        }
      }, builder: (BuildContext context, AppStates state) {
        AppCubit cubit = AppCubit.get(context);
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(cubit.titles[cubit.currentIndex]),
          ),
          body: Conditional.single(
              context: context,
              conditionBuilder: (context) =>
                  state is! AppGetDatabaseLoadingState,
              widgetBuilder: (context) => cubit.screen[cubit.currentIndex],
              fallbackBuilder: (context) =>
                  Center(child: CircularProgressIndicator())),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (cubit.isBottomSheetShown) {
                if (formKey.currentState.validate()) {
                  cubit.insertToDatabase(
                    title: titleController.text,
                    date: dateController.text,
                    time: timeController.text,
                  );
                }
              } else {
                scaffoldKey.currentState
                    .showBottomSheet(
                        (context) => Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(20.0),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    defaultFormField(
                                        controller: titleController,
                                        type: TextInputType.text,
                                        validate: (String value) {
                                          if (value.isEmpty) {
                                            return 'Title Must Not Be Empty!';
                                          }
                                          return null;
                                        },
                                        label: 'Task Title',
                                        prefix: Icons.title),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    defaultFormField(
                                        controller: timeController,
                                        type: TextInputType.text,
                                        onTap: () {
                                          showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          ).then((value) {
                                            timeController.text = value
                                                .format(context)
                                                .toString();
                                            print(value.format(context));
                                          });
                                        },
                                        validate: (String value) {
                                          if (value.isEmpty) {
                                            return 'Time Must Not Be Empty!';
                                          }
                                          return null;
                                        },
                                        label: 'Task Time',
                                        prefix: Icons.watch_later_outlined),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    defaultFormField(
                                        controller: dateController,
                                        type: TextInputType.text,
                                        onTap: () {
                                          showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate:
                                                DateTime.parse('2080-12-30'),
                                          ).then((value) {
                                            dateController.text =
                                                DateFormat.yMMMd()
                                                    .format(value);
                                          });
                                        },
                                        validate: (String value) {
                                          if (value.isEmpty) {
                                            return 'Date Must Not Be Empty!';
                                          }
                                          return null;
                                        },
                                        label: 'Task Date',
                                        prefix: Icons.calendar_today_outlined),
                                  ],
                                ),
                              ),
                            ),
                        elevation: 15.0)
                    .closed
                    .then((value) {
                  cubit.changeBottomSheetState(isShow: false, icon: Icons.edit);
                });
                cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
              }
            },
            child: Icon(cubit.fabIcon),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: cubit.currentIndex,
            onTap: (index) {
              cubit.changeIndex(index);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.menu),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline),
                label: 'Done',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.archive_rounded),
                label: 'Archived',
              ),
            ],
          ),
        );
      }),
    );
  }
}
