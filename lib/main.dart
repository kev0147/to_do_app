import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(tabs: [
              Tab(
                text: 'ToDo',
              ),
              Tab(
                text: 'finance',
              ),
              Tab(
                text: 'note',
              )
            ]),
          ),
          body: TabBarView(
            children: [
              ToDo(
                storage: Storage(),
              ),
              Finance(
                storage: Storage(),
              ),
              ThinkPad(
                storage: Storage(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Storage {
  List<Task> sortTask(List<Task> taskList) {
    taskList.sort(((a, b) => a.deadline.compareTo(b.deadline)));
    return taskList;
  }

  List<Routine> sortRoutine(List<Routine> routineList) {
    routineList.sort(((a, b) => a.task.deadline.compareTo(b.task.deadline)));
    return routineList;
  }

  List<Note> sortNote(List<Note> noteList) {
    noteList.sort(((a, b) => a.date.compareTo(b.date)));
    return noteList;
  }

  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('EEEE, MMMM d ');
    return formatter.format(dateTime);
  }

  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('EEEE, MMMM d,  hh:mm');
    return formatter.format(dateTime);
  }

  Routine getRoutineOfTask(List<Routine> routineList, Task task) {
    Routine? routine = routineList
        .singleWhere((element) => element.task.taskId == task.taskId);
    return routine;
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<List<File>> getAllTaskFiles() async {
    final path = await _localPath;
    final directory = Directory('$path/daily_tasks');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final List<FileSystemEntity> entities = await directory.list().toList();
    final List<File> files = entities.whereType<File>().toList();

    return files;
  }

  Future<File> getTaskFile(String taskId) async {
    final path = await _localPath;
    return File('$path/daily_tasks/task_$taskId.txt');
  }

  Future<List<Task>> getAllTask() async {
    List<Task> tasksList = [];
    List<File> taskFiles = await getAllTaskFiles();
    for (var file in taskFiles) {
      tasksList.add(Task.fromJson(jsonDecode(await file.readAsString())));
    }
    return tasksList;
  }

  Future<Task> readTask(String taskId) async {
    try {
      final file = await getTaskFile(taskId);

      // Read the file
      final contents = await file.readAsString();
      final contentsJson = jsonDecode(contents);
      final contentsTask = Task.fromJson(contentsJson);
      return contentsTask;
    } catch (e) {
      // If encountering an error, return 0
      return Task('', DateTime.now(), DateTime.now());
    }
  }

  Future<Task> addDailyTask(Task task) async {
    final file = await getTaskFile(task.taskId);

    // Write the file
    final taskJson = jsonEncode(task.toJson());
    file.writeAsString(taskJson);
    return task;
  }

  Future<File> writeTask(Task task) async {
    final file = await getTaskFile(task.taskId);

    // Write the file
    final taskJson = jsonEncode(task);
    return file.writeAsString(taskJson);
  }

  void deleteTask(Task task) async {
    final file = await getTaskFile(task.taskId);
    file.delete();
  }

  Future<File> get _soldeFile async {
    final path = await _localPath;
    return File('$path/solde.txt');
  }

  Future<int> readSolde() async {
    try {
      final file = await _soldeFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeSolde(int counter) async {
    final file = await _soldeFile;
    return file.writeAsString('$counter');
  }

  List<Transaction> sortTransaction(List<Transaction> transactionList) {
    transactionList.sort(((a, b) => a.date.compareTo(b.date)));
    return transactionList;
  }

  Future<File> getTransactionsFile(String transactionId) async {
    final path = await _localPath;
    return File('$path/transactions/transaction_$transactionId.txt');
  }

  Future<List<File>> getAllTransactionsFiles() async {
    final path = await _localPath;
    final directory = Directory('$path/transactions');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final List<FileSystemEntity> entities = await directory.list().toList();
    final List<File> files = entities.whereType<File>().toList();

    return files;
  }

  Future<List<Transaction>> getAllTransactions() async {
    List<Transaction> transactionsList = [];
    List<File> transactionsFiles = await getAllTransactionsFiles();
    for (var file in transactionsFiles) {
      transactionsList
          .add(Transaction.fromJson(jsonDecode(await file.readAsString())));
    }
    return transactionsList;
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    final file = await getTransactionsFile(transaction.transactionId);

    // Write the file
    final transactionJson = jsonEncode(transaction.toJson());
    file.writeAsString(transactionJson);
    return transaction;
  }

  Future<File> writetransaction(Transaction transaction) async {
    final file = await getTransactionsFile(transaction.transactionId);

    // Write the file
    final transactionJson = jsonEncode(transaction);
    return file.writeAsString(transactionJson);
  }

  void deleteTransaction(Transaction transaction) async {
    final file = await getTransactionsFile(transaction.transactionId);
    file.delete();
  }

  Future<File> getNoteFile(String noteId) async {
    final path = await _localPath;
    return File('${path}/notes/note_${noteId}');
  }

  Future<List<File>> getAllNotesFile() async {
    final path = await _localPath;
    final directory = Directory('${path}/notes');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final List<FileSystemEntity> entities = await directory.list().toList();
    final List<File> files = entities.whereType<File>().toList();
    return files;
  }

  Future<List<Note>> getAllNotes() async {
    List<Note> notesList = [];
    List<File> notesFiles = await getAllNotesFile();
    for (var file in notesFiles) {
      notesList.add(Note.fromJson(jsonDecode(await file.readAsString())));
    }
    return notesList;
  }

  Future<Note> readNote(String noteId) async {
    final file = await getNoteFile(noteId);
    final jsonNote = file.readAsString();
    return Note.fromJson(jsonDecode(await jsonNote));
  }

  Future<Note> addNote(Note note) async {
    final file = await getNoteFile(note.noteId);

    // Write the file
    final noteJson = jsonEncode(note.toJson());
    file.writeAsString(noteJson);
    return note;
  }

  Future<Routine> addRoutine(Routine task) async {
    final file = await getTaskFile(task.routineId);

    // Write the file
    final taskJson = jsonEncode(task.toJson());
    file.writeAsString(taskJson);
    return task;
  }

  Future<Note> writeNote(Note note) async {
    final file = await getNoteFile(note.noteId);
    final jsonNote = jsonEncode(note);
    file.writeAsString(jsonNote);
    return note;
  }

  Future<Note> deleteNote(Note note) async {
    final file = await getNoteFile(note.noteId);
    file.delete();
    return note;
  }

  Future<File> getRoutineFile(String routineId) async {
    final path = await _localPath;
    return File('${path}/routines/routine_${routineId}');
  }

  Future<List<File>> getAllRoutinesFile() async {
    final path = await _localPath;
    final directory = Directory('${path}/routines');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final List<FileSystemEntity> entities = await directory.list().toList();
    final List<File> files = entities.whereType<File>().toList();
    return files;
  }

  Future<List<Routine>> getAllRoutines() async {
    List<Routine> routinesList = [];
    List<File> routinesFiles = await getAllTransactionsFiles();
    for (var file in routinesFiles) {
      routinesList.add(Routine.fromJson(jsonDecode(await file.readAsString())));
    }
    return routinesList;
  }

  Future<Routine> readRoutine(String routineId) async {
    final file = await getRoutineFile(routineId);
    final jsonRoutine = file.readAsString();
    return Routine.fromJson(jsonDecode(await jsonRoutine));
  }

  Future<Routine> writeRoutine(Routine routine) async {
    final file = await getRoutineFile(routine.routineId);
    final jsonRoutine = jsonEncode(routine);
    file.writeAsString(jsonRoutine);
    return routine;
  }

  Future<Routine> deleteRoutine(Routine routine) async {
    final file = await getRoutineFile(routine.routineId);
    file.delete();
    return routine;
  }
}

enum TransactionType {
  cashIn,
  cashOut,
}

class Transaction {
  TransactionType type;
  String reason;
  int amount;
  String transactionId;
  DateTime date;

  Transaction(this.amount, this.reason, this.type, this.date)
      : transactionId = Uuid().v4();

  addTransaction() async {
    int solde = await Storage().readSolde();
    if (type == TransactionType.cashIn) {
      solde += amount;
    } else {
      solde -= amount;
    }
    Storage().writeSolde(solde);
  }

  Transaction.fromJson(Map<String, dynamic> json)
      : type = TransactionType.values
            .firstWhere((e) => e.toString().split('.').last == json['type']),
        transactionId = json['transactionId'],
        date = DateTime.parse(json['date'] as String),
        amount = json['amount'] as int,
        reason = json['reason'] as String;

  Map<String, dynamic> toJson() => {
        'type': type.toString().split('.').last,
        'transactionId': transactionId,
        'amount': amount,
        'reason': reason,
        'date': date.toString()
      };
}

class Note {
  Note(title, this.note, detail, date)
      : date = date == null ? DateTime.now() : date,
        title = title == null ? '' : title,
        detail = detail == null ? '' : detail,
        noteId = Uuid().v4();
  String title;
  String note;
  DateTime date;
  String detail;
  String noteId;

  Note.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        note = json['note'],
        detail = json['detail'],
        noteId = json['noteId'],
        date = DateTime.parse(json['date'] as String);

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date.toString(),
        'note': note,
        'detail': detail,
        'noteId': noteId,
      };
}

class Routine {
  Routine(this.task, startDate, endDate)
      : routineId = Uuid().v4(),
        startDate = startDate == null ? DateTime.now() : startDate,
        endDate = endDate.isBefore(startDate!.add(Duration(days: 30)))
            ? startDate.add(Duration(minutes: 30))
            : endDate;

  Task task;
  DateTime? startDate;
  DateTime? endDate;
  String routineId;

  Routine.fromJson(Map<String, dynamic> json)
      : task = Task.fromJson(json['task']),
        startDate = DateTime.parse(json['startDate'] as String),
        endDate = DateTime.parse(json['endDate'] as String),
        routineId = json['routineId'] as String;

  Map<String, dynamic> toJson() => {
        'task': task,
        'startDate': startDate.toString(),
        'endDate': endDate.toString(),
        'routineId': routineId,
      };
}

class Task {
  Task(this.taskName, this.startedTime, DateTime deadline)
      : deadline = deadline.isBefore(startedTime.add(Duration(minutes: 30)))
            ? startedTime.add(Duration(minutes: 30))
            : deadline,
        taskId = Uuid().v4();

  Task.fromJson(Map<String, dynamic> json)
      : taskName = json['taskName'],
        startedTime = DateTime.parse(json['startedTime'] as String),
        deadline = DateTime.parse(json['deadline'] as String),
        done = json['done'],
        taskId = json['taskId'] as String;

  String taskName;
  DateTime startedTime;
  DateTime deadline;
  String taskId;
  bool done = false;

  void markAsDone() {
    done = true;
  }

  Map<String, dynamic> toJson() => {
        'taskName': taskName,
        'startedTime': startedTime.toString(),
        'deadline': deadline.toString(),
        'taskId': taskId,
        'done': done,
      };
}

class ToDo extends StatefulWidget {
  Storage storage;
  ToDo({required this.storage});
  @override
  _ToDoState createState() => _ToDoState();
}

class _ToDoState extends State<ToDo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(tabs: [
              Tab(
                text: 'Task',
              ),
              Tab(
                text: 'Routine',
              )
            ]),
          ),
          body: TabBarView(
            children: [
              TaskPage(storage: Storage()),
              Card(),
            ],
          ),
        ),
      ),
    );
  }
}

class RoutinePage extends StatefulWidget {
  final Storage storage;

  const RoutinePage({super.key, required this.storage});
  @override
  State<StatefulWidget> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<TaskPage> {
  List<Routine> myDailyTasks = [];

  @override
  void initState() {
    super.initState();
    widget.storage.getAllRoutines().then(
      (value) {
        setState(() {
          myDailyTasks = value;
          widget.storage.sortRoutine(myDailyTasks);
        });
      },
    );
  }

  void _addTask(Task task) {
    setState(() {
      Storage().addDailyTask(task);
      Routine routine = Routine(task, null, null);
      myDailyTasks.add(routine);
      Storage().addRoutine(routine);
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      var routine = widget.storage.getRoutineOfTask(myDailyTasks, task);
      widget.storage.deleteRoutine(routine);
    });
  }

  void _updateTask(Task task) {
    setState(() {
      task.deadline =
          task.deadline.isBefore(task.startedTime.add(Duration(minutes: 30)))
              ? task.startedTime.add(Duration(minutes: 30))
              : task.deadline;
      widget.storage.writeTask(task);
    });
  }

  void _markAsDone(Task task) {
    setState(() {
      task.done = true;
      widget.storage.writeTask(task);
    });
  }

  Color _getTileColor(Task task) {
    if (task.done) {
      return Colors.green; // Green if done
    } else if (DateTime.now().isAfter(task.deadline)) {
      return Colors.red; // Red if deadline is over
    } else {
      return Colors.blue; // Blue otherwise
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily tasks'),
      ),
      body: ListView.builder(
        itemCount: myDailyTasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: _getTileColor(myDailyTasks[index].task),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return TaskForm(
                      task: myDailyTasks[index].task,
                      onAddTask: _markAsDone,
                      onDeleteTask: _deleteTask,
                      onUpdateTask: _updateTask);
                },
              );
            },
            title: Text(myDailyTasks[index].task.taskName),
            subtitle: Column(
              children: [
                Text(
                    'created on ${Storage().formatDateTime(myDailyTasks[index].task.startedTime)}'),
                Text(
                    'to do before ${Storage().formatDateTime(myDailyTasks[index].task.deadline)}')
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TaskForm(
                task: null,
                onAddTask: _addTask,
              );
            },
          );
        },
      ),
    );
  }
}

class TaskPage extends StatefulWidget {
  final Storage storage;

  const TaskPage({super.key, required this.storage});
  @override
  State<StatefulWidget> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> myDailyTasks = [];

  @override
  void initState() {
    super.initState();
    widget.storage.getAllTask().then(
      (value) {
        setState(() {
          myDailyTasks = value;
          widget.storage.sortTask(myDailyTasks);
        });
      },
    );
  }

  void _addTask(Task task) {
    setState(() {
      myDailyTasks.add(task);
      Storage().addDailyTask(task);
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      Storage().deleteTask(task);
    });
  }

  void _updateTask(Task task) {
    setState(() {
      task.deadline =
          task.deadline.isBefore(task.startedTime.add(Duration(minutes: 30)))
              ? task.startedTime.add(Duration(minutes: 30))
              : task.deadline;
      widget.storage.writeTask(task);
    });
  }

  void _markAsDone(Task task) {
    setState(() {
      task.done = true;
      widget.storage.writeTask(task);
    });
  }

  Color _getTileColor(Task task) {
    if (task.done) {
      return Colors.green; // Green if done
    } else if (DateTime.now().isAfter(task.deadline)) {
      return Colors.red; // Red if deadline is over
    } else {
      return Colors.blue; // Blue otherwise
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily tasks'),
      ),
      body: ListView.builder(
        itemCount: myDailyTasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: _getTileColor(myDailyTasks[index]),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return TaskForm(
                      task: myDailyTasks[index],
                      onAddTask: _markAsDone,
                      onDeleteTask: _deleteTask,
                      onUpdateTask: _updateTask);
                },
              );
            },
            title: Text(myDailyTasks[index].taskName),
            subtitle: Column(
              children: [
                Text(
                    'created on ${Storage().formatDateTime(myDailyTasks[index].startedTime)}'),
                Text(
                    'to do before ${Storage().formatDateTime(myDailyTasks[index].deadline)}')
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TaskForm(
                task: null,
                onAddTask: _addTask,
              );
            },
          );
        },
      ),
    );
  }
}

class TaskForm extends StatefulWidget {
  bool creatingTask;
  Task task;
  ValueChanged<Task>? onAddTask;
  ValueChanged<Task>? onUpdateTask;
  ValueChanged<Task>? onDeleteTask;
  TaskForm({this.onAddTask, this.onDeleteTask, this.onUpdateTask, Task? task})
      : creatingTask = task == null ? true : false,
        this.task =
            task != null ? task : Task('', DateTime.now(), DateTime.now());

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  void _onStartedDateSelected(DateTime selectedDate) {
    setState(() {
      widget.task.startedTime = selectedDate;
    });
  }

  void _onDeadlineDateSelected(DateTime selectedDate) {
    setState(() {
      widget.task.deadline = selectedDate;
    });
  }

  void _onDeadlineTimeSelected(TimeOfDay selectedTime) {
    setState(() {
      widget.task.deadline = DateTime(
          widget.task.deadline.year,
          widget.task.deadline.month,
          widget.task.deadline.day,
          selectedTime.hour,
          selectedTime.minute);
    });
  }

  void _onStartTimeSelected(TimeOfDay selectedTime) {
    setState(() {
      widget.task.startedTime = DateTime(
          widget.task.startedTime.year,
          widget.task.startedTime.month,
          widget.task.startedTime.day,
          selectedTime.hour,
          selectedTime.minute);
    });
  }

  final taskNameController = TextEditingController();

  DateTime setDateTimeWithTimeOfDay(DateTime dateTime, TimeOfDay timeOfDay) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }

  Widget createTask() {
    if (widget.creatingTask) {
      return FloatingActionButton(
        onPressed: () {
          widget.task.taskName = taskNameController.text;
          widget.onAddTask!(widget.task);

          Navigator.of(context).pop();
        },
        child: const Icon(Icons.add),
      );
    }
    return Container();
  }

  Widget markAsDone() {
    if (!widget.creatingTask) {
      return FloatingActionButton(
        onPressed: () {
          widget.onAddTask!(widget.task);
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.done),
      );
    }
    return Container();
  }

  Widget updateTask() {
    if (!widget.creatingTask) {
      return FloatingActionButton(
        onPressed: () {
          widget.task.taskName = taskNameController.text.isEmpty
              ? widget.task.taskName
              : taskNameController.text;
          widget.onUpdateTask!(widget.task);
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.edit),
      );
    }
    return Container();
  }

  Widget deleteTask() {
    if (!widget.creatingTask) {
      return FloatingActionButton(
        onPressed: () {
          widget.task.taskName = taskNameController.text;
          widget.onDeleteTask!(widget.task);
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.delete),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    // Fill this out in the next step.
    PickDate pickStartDate = PickDate(
      onDateSelected: _onStartedDateSelected,
      labelText: 'start date',
      dateToChose: widget.task.startedTime,
    );
    PickDate pickDeadlineDate = PickDate(
      onDateSelected: _onDeadlineDateSelected,
      labelText: 'deadline date',
      dateToChose: widget.task.deadline,
    );
    PickTime pickStartTime = PickTime(
      onTimeSelected: _onStartTimeSelected,
      labelText: 'start time',
      timeToChose: TimeOfDay(
          hour: widget.task.startedTime.hour,
          minute: widget.task.startedTime.minute),
    );
    PickTime pickDeadlineTime = PickTime(
        onTimeSelected: _onDeadlineTimeSelected,
        labelText: 'deadline time',
        timeToChose: TimeOfDay(
            hour: widget.task.deadline.hour,
            minute: widget.task.deadline.minute));
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Return'),
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Task name',
                  hintText: widget.task.taskName),
              controller: taskNameController,
            ),
            pickStartDate,
            pickStartTime,
            pickDeadlineDate,
            pickDeadlineTime,
            Row(
              children: [
                markAsDone(),
                updateTask(),
                deleteTask(),
              ],
            ),
            createTask()
          ],
        ),
      ),
    );
  }
}

class PickTime extends StatefulWidget {
  PickTime(
      {required this.onTimeSelected,
      required this.labelText,
      required this.timeToChose});
  final ValueChanged<TimeOfDay> onTimeSelected;
  final String labelText;
  TimeOfDay timeToChose;

  @override
  _PickTimeState createState() => _PickTimeState();
}

class _PickTimeState extends State<PickTime> {
  TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateInputTime(widget.timeToChose);
  }

  void _updateInputTime(TimeOfDay selectedTime) {
    timeController.text = Storage().formatTimeOfDay(selectedTime);
  }

  void _showTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    ).then((value) {
      setState(() {
        _updateInputTime(value!);
      });
      widget.onTimeSelected(value!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: _showTimePicker,
      controller: timeController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: widget.labelText,
      ),
      readOnly: true,
    );
  }
}

class PickDate extends StatefulWidget {
  PickDate(
      {required this.onDateSelected,
      required this.labelText,
      required this.dateToChose});

  DateTime? dateToChose = DateTime.now();
  final String labelText;
  final ValueChanged<DateTime> onDateSelected;
  @override
  _PickDateState createState() => _PickDateState();
}

class _PickDateState extends State<PickDate> {
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateDateText();
  }

  void _updateDateText() {
    _dateController.text = Storage().formatDate(widget.dateToChose!);
  }

  void _showStartDateTimePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 90)),
    ).then((value) {
      if (value != null) {
        setState(() {
          widget.dateToChose = value;
          _updateDateText();
          print(widget.dateToChose.toString());
        });
        widget.onDateSelected(value);
        print(widget.dateToChose.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _dateController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: widget.labelText,
      ),
      readOnly: true,
      onTap: () {
        _showStartDateTimePicker(context);
      },
    );
  }
}

class Finance extends StatefulWidget {
  Storage storage;
  Finance({required this.storage});
  @override
  _FinanceState createState() => _FinanceState();
}

class _FinanceState extends State<Finance> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(tabs: [
              Tab(
                text: 'transactions',
              ),
              Tab(
                text: 'finance',
              )
            ]),
          ),
          body: TabBarView(
            children: [
              Transactions(widget.storage),
              Card(),
            ],
          ),
        ),
      ),
    );
  }
}

class Transactions extends StatefulWidget {
  int? solde;
  Storage storage;
  Transactions(this.storage);
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  List<Transaction> transactions = [];

  setSolde(List<Transaction> transactions) {
    int solde = 0;
    for (var element in transactions) {
      if (element.type == TransactionType.cashIn) {
        solde += element.amount;
      } else {
        solde -= element.amount;
      }
    }
    widget.solde = solde;
  }

  updateTransactionsList() {
    widget.storage.getAllTransactions().then(
      (value) {
        setState(() {
          transactions = value;
          widget.storage.sortTransaction(transactions);
          setSolde(value);
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    updateTransactionsList();
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
      setSolde(transactions);
      widget.storage.addTransaction(transaction);
    });
  }

  void _updateTransaction(Transaction transaction) {
    setState(() {
      widget.storage.writetransaction(transaction);
      updateTransactionsList();
    });
  }

  void _deleteTransaction(Transaction transaction) {
    setState(() {
      widget.storage.deleteTransaction(transaction);
      updateTransactionsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.solde.toString()),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return TransactionForm(
                    transaction: transactions[index],
                    onUpdateTransaction: _updateTransaction,
                    onDeleteTransaction: _deleteTransaction,
                  );
                },
              );
            },
            title: Text(transactions[index].type.name),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(transactions[index].amount.toString()),
                Text(transactions[index].reason),
                Text(Storage().formatDateTime(transactions[index].date))
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return TransactionForm(
                transaction: null,
                onAddTransaction: _addTransaction,
              );
            },
          );
        },
      ),
    );
  }
}

class TransactionForm extends StatefulWidget {
  bool creatingTransaction;
  Transaction transaction;
  ValueChanged<Transaction>? onAddTransaction;
  ValueChanged<Transaction>? onUpdateTransaction;
  ValueChanged<Transaction>? onDeleteTransaction;
  TransactionForm(
      {this.onAddTransaction,
      this.onUpdateTransaction,
      this.onDeleteTransaction,
      Transaction? transaction})
      : creatingTransaction = transaction == null ? true : false,
        this.transaction = transaction != null
            ? transaction
            : Transaction(0, '', TransactionType.cashIn, DateTime.now());

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  void _onDateSelected(DateTime selectedDate) {
    setState(() {
      widget.transaction.date = selectedDate;
    });
  }

  Widget createTransaction() {
    if (widget.creatingTransaction) {
      return FloatingActionButton(
        onPressed: () {
          widget.transaction.amount = int.parse(_amountController.text);
          widget.transaction.reason = _reasonController.text;
          widget.onAddTransaction!(widget.transaction);

          Navigator.of(context).pop();
        },
        child: const Icon(Icons.add),
      );
    }
    return Container();
  }

  Widget updateTransaction() {
    if (!widget.creatingTransaction) {
      return FloatingActionButton(
        onPressed: () {
          widget.transaction.amount = int.parse(_amountController.text);
          widget.transaction.reason = _reasonController.text;
          widget.onUpdateTransaction!(widget.transaction);
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.edit),
      );
    }
    return Container();
  }


  Widget deleteTransaction() {
    if (!widget.creatingTransaction) {
      return FloatingActionButton(
        onPressed: () {
          widget.onDeleteTransaction!(widget.transaction);
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.delete),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    PickDate pickDate = PickDate(
      onDateSelected: _onDateSelected,
      labelText: 'date',
      dateToChose: widget.transaction.date,
    );

    DropdownButton<TransactionType> transactionType =
        DropdownButton<TransactionType>(
      value: widget.transaction.type,
      onChanged: (TransactionType? newValue) {
        setState(() {
          if (newValue != null) {
            widget.transaction.type = newValue;
          }
        });
      },
      items: TransactionType.values.map((TransactionType type) {
        return DropdownMenuItem<TransactionType>(
          value: type,
          child: Text(type.toString().split('.').last),
        );
      }).toList(),
    );

    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Return'),
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'amount',
                hintText: widget.transaction.amount.toString(),
              ),
              keyboardType: TextInputType.number,
              controller: _amountController,
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'reason',
                hintText: widget.transaction.reason,
              ),
              controller: _reasonController,
            ),
            pickDate,
            transactionType,
            Row(
              children: [createTransaction(), updateTransaction(), deleteTransaction()],
            )
          ],
        ),
      ),
    );
  }
}

class ThinkPad extends StatefulWidget {
  Storage storage;
  ThinkPad({required this.storage});
  @override
  _ThinkPadState createState() => _ThinkPadState();
}

class _ThinkPadState extends State<ThinkPad> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    widget.storage.getAllNotes().then(
      (value) {
        setState(() {
          notes = value;
          widget.storage.sortNote(notes);
        });
      },
    );
  }

  void _addNote(Note note) {
    setState(() {
      notes.add(note);
      widget.storage.addNote(note);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                Text(notes[index].title),
                Text(widget.storage.formatDate(notes[index].date)),
                Text(notes[index].note)
              ],
            ),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return NoteForm(
                note: null,
                onAddNote: _addNote,
              );
            },
          );
        },
      ),
    );
  }
}

/*********************************************************************************** */
class NoteForm extends StatefulWidget {
  bool creatingNote;
  Note note;
  ValueChanged<Note>? onAddNote;
  ValueChanged<Note>? onUpdateNote;
  NoteForm({this.onAddNote, this.onUpdateNote, Note? note})
      : creatingNote = note == null ? true : false,
        note = note != null ? note : Note(null, '', null, DateTime.now());

  @override
  _NoteFormState createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  void _onDateSelected(DateTime selectedDate) {
    setState(() {
      widget.note.date = selectedDate;
    });
  }

  Widget createNote() {
    if (widget.creatingNote) {
      return FloatingActionButton(
        onPressed: () {
          widget.note.title = _titleController.text;
          widget.note.note = _noteController.text;
          widget.note.detail = _detailController.text;
          widget.onAddNote!(widget.note);

          Navigator.of(context).pop();
        },
        child: const Icon(Icons.add),
      );
    }
    return Container();
  }

  Widget updateNote() {
    if (!widget.creatingNote) {
      return FloatingActionButton(
        onPressed: () {
          widget.note.title = _titleController.text;
          widget.note.note = _noteController.text;
          widget.note.detail = _detailController.text;
          widget.onUpdateNote!(widget.note);
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.edit),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Return'),
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'title',
                hintText: widget.note.title,
              ),
              controller: _titleController,
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'details',
                hintText: widget.note.detail,
              ),
              controller: _detailController,
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'note',
                hintText: widget.note.note,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              controller: _noteController,
            ),
            Row(
              children: [createNote(), updateNote()],
            )
          ],
        ),
      ),
    );
  }
}
