import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taskaty/controllers/task_controller.dart';
import 'package:taskaty/models/task.dart';
import 'package:taskaty/services/notification_services.dart';
import 'package:taskaty/services/theme_services.dart';
import 'package:taskaty/ui/size_config.dart';
import 'package:taskaty/ui/theme.dart';
import 'package:taskaty/ui/widgets/button.dart';
import 'package:taskaty/ui/widgets/input_field.dart';
import 'package:taskaty/ui/widgets/task_tile.dart';

import 'add_task_page.dart';
import 'notification_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotifyHelper notifyHelper;
  final TaskController _taskController = Get.put(TaskController());
  DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    notifyHelper = NotifyHelper();
    notifyHelper.requestIOSPermissions();
    notifyHelper.initializeNotification();
    _taskController.getTask();
    return Scaffold(
      backgroundColor: Get.isDarkMode ? darkGreyClr : Colors.white,
      appBar: _appbar(),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          const SizedBox(height: 9),
          _showTask(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Get.isDarkMode ? darkGreyClr : Colors.white,
          color: primaryClr,
          animationDuration: Duration(milliseconds: 400),
          items: [
            IconButton(
              onPressed: () {
                Get.to(HomePage());
              },
              icon: Icon(Icons.home, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                notifyHelper.cancelAllNotification();
                _taskController.deleteAllTask();
                //Get.to(HomePage());
                print('All Tasks deleted');
              },
              icon: const Icon(Icons.cleaning_services_outlined,
                  color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                Get.to(HomePage());
              },
              icon: Icon(Icons.chat, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                Get.to(HomePage());
              },
              icon: Icon(Icons.help, color: Colors.white),
            ),
          ]),
    );
  }

  AppBar _appbar() {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          ThemeServices().switchTheme();
        },
        icon: Icon(
            Get.isDarkMode
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_round_outlined,
            size: 24,
            color: Colors.white),
      ),
      elevation: 0,
      backgroundColor: primaryClr,
      title: Center(
        child: Text(
          "taskaty",
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white),
        ),
      ),
      actions: [
        /*IconButton(
          onPressed: () {
            notifyHelper.cancelAllNotification();
            _taskController.deleteAllTask;
          },
          icon: const Icon(Icons.cleaning_services_outlined,
              size: 24, color: Colors.white),
        ),*/
        const SizedBox(
          width: 25,
        ),
        const CircleAvatar(
          backgroundImage: const AssetImage('images/person.jpeg'),
          radius: 20,
        ),
        const SizedBox(
          width: 20,
        )
      ],
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 10, top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: TextStyle(
                  color: Get.isDarkMode ? Colors.white : darkGreyClr,
                  fontSize: 15,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                "Today",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                ),
              )
            ],
          ),
          MyButton(
            label: '+ Add Task',
            onTap: () async {
              await Get.to(() => const AddTaskPage());
              // _taskController.getTasks();
            },
          ),
        ],
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 10),
      child: DatePicker(
        _selectedDate,
        width: 70,
        height: 80,
        initialSelectedDate: _selectedDate,
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        onDateChange: (newDate) {
          setState(() {
            //_selectedDate = newDate;
          });
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _taskController.getTask();
  }

  _showTask() {
    return Expanded(child: Obx(
      () {
        if (_taskController.tasklist.isEmpty) {
          return noTaskMes();
        } else {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              scrollDirection: SizeConfig.orientation == Orientation.landscape
                  ? Axis.horizontal
                  : Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                var task = _taskController.tasklist[index];

                if (task.repeat == 'Daily' ||
                    task.date == DateFormat.yMd().format(_selectedDate) ||
                    (task.repeat == 'Weekly' &&
                        _selectedDate
                                    .difference(
                                        DateFormat.yMd().parse(task.date!))
                                    .inDays %
                                7 ==
                            0) ||
                    (task.repeat == 'Monthly' &&
                        DateFormat.yMd().parse(task.date!).day ==
                            _selectedDate.day)) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(seconds: 2),
                    child: SlideAnimation(
                      horizontalOffset: 300,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () {
                            _showBottomSheet(context, task);
                          },
                          child: TaskTile(task),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container(height: 50, width: 40);
                }
              },
              itemCount: _taskController.tasklist.length,
            ),
          );
        }
      },
    ));

    /* child: Obx(()),*/
  }

  noTaskMes() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(seconds: 5),
          child: RefreshIndicator(
            backgroundColor: Get.isDarkMode ? Colors.white : darkGreyClr,
            color: primaryClr,
            onRefresh: () => _onRefresh(),
            child: SingleChildScrollView(
              child: Wrap(
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  SvgPicture.asset(
                    'images/task.svg',
                    height: 90,
                    width: 70,
                    color: Colors.blueGrey.withOpacity(0.2),
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 20)
                      : const SizedBox(width: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Text(
                      'You don\'t have any task\'s yet ! \n Add a new task\'s to show day\'s productive',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  _buildBottomSheet({
    required String label,
    required Function() onTop,
    required Color color,
    bool isClosed = false,
  }) {
    return GestureDetector(
      onTap: onTop,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 30,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClosed
                ? Get.isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[300]!
                : color,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClosed ? Colors.transparent : color,
        ),
        child: Center(
          child: Text(
            label,
            style: isClosed
                ? GoogleFonts.lato(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Get.isDarkMode ? Colors.white : Colors.black,
                    ),
                  )
                : GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 4),
          width: SizeConfig.screenWidth,
          height: (SizeConfig.orientation == Orientation.landscape)
              ? (task.isCompleted == 1
                  ? SizeConfig.screenHeight * 0.6
                  : SizeConfig.screenHeight * 0.8)
              : (task.isCompleted == 1
                  ? SizeConfig.screenHeight * 0.30
                  : SizeConfig.screenHeight * 0.39),
          color: Get.isDarkMode ? darkHeaderClr : Colors.white,
          child: Column(
            children: [
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection:
                      SizeConfig.orientation == Orientation.landscape
                          ? Axis.horizontal
                          : Axis.vertical,
                  child: Container(
                    height: 40,
                    width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Get.isDarkMode
                            ? Colors.grey[600]
                            : Colors.grey[300]),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              task.isCompleted == 1
                  ? Container()
                  : _buildBottomSheet(
                      label: 'Task Completed',
                      onTop: () {
                        notifyHelper.cancelNotification(task);
                        _taskController.markTaskCompleted(task.id!);
                        Get.back();
                      },
                      color: primaryClr),
              const SizedBox(height: 3),
              _buildBottomSheet(
                label: 'Share',
                onTop: () {
                  onPressed:
                  _share(context, task);
                },
                color: Colors.green.withOpacity(0.5),
              ),
              const SizedBox(height: 3),
              _buildBottomSheet(
                label: 'Delete',
                onTop: () {
                  notifyHelper.cancelNotification(task);
                  _taskController.deleteTask(task);
                  Get.back();
                },
                color: Colors.red.withOpacity(0.4),
              ),
              const SizedBox(height: 3),
              _buildBottomSheet(
                label: 'Cancel',
                onTop: () {
                  Get.back();
                },
                color: Color.fromARGB(239, 112, 110, 110),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _share(BuildContext context, Task task) {
  String? message = '${task}';
  Share.share(message);
}
