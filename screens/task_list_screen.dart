import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task_model.dart';
import '../database/task_database.dart';
import '../models/list_model.dart';
import '../database/list_database.dart';
import '../dialogs/add_task_dialog.dart';
import '../dialogs/add_list_dialog.dart';
import '../dialogs/edit_list_dialog.dart';
import '../dialogs/add_more_tasks_dialog.dart'; // Add this import
import '../widgets/task_tile.dart';
import 'dart:math'; // Import to use random functions

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskDatabase _taskDatabase = TaskDatabase();
  final ListDatabase _listDatabase = ListDatabase();
  List<TaskList> _lists = [];
  Map<int, List<Task>> _tasksByList = {};

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    final lists = await _listDatabase.getLists();
    setState(() {
      _lists = lists;
      _tasksByList.clear();
      for (var list in lists) {
        _loadTasksForList(list.id!);
      }
    });
  }

  Future<void> _loadTasksForList(int listId) async {
    final tasks = await _taskDatabase.getTasks(listId);
    setState(() {
      _tasksByList[listId] = tasks;
    });
  }

  Future<void> _addList() async {
    final title = await showAddListDialog(context);
    if (title != null && title.isNotEmpty) {
      final list = TaskList(title: title);
      await _listDatabase.insertList(list);
      _loadLists();  // Reload lists to get the new list ID

      // Immediately prompt for adding items to the list after adding the list
      bool addMore = true;
      while (addMore) {
        final taskTitle = await showAddTaskDialog(context);
        if (taskTitle != null && taskTitle.isNotEmpty) {
          // Ensure you have the latest list ID
          final listId = (await _listDatabase.getLists()).last.id!;
          final task = Task(title: taskTitle, isCompleted: false, listId: listId);
          await _taskDatabase.insertTask(task);
          _loadTasksForList(listId);
        }
        addMore = await showAddMoreTasksConfirmationDialog(context);
      }
    }
  }

  Future<void> _editList(TaskList list) async {
    final title = await showEditListDialog(context, list.title);
    if (title != null && title.isNotEmpty) {
      final updatedList = TaskList(
        id: list.id,
        title: title,
      );
      await _listDatabase.updateList(updatedList);
      _loadLists();
    }
  }

  Future<void> _addTask(int listId) async {
    final title = await showAddTaskDialog(context);
    if (title != null && title.isNotEmpty) {
      final task = Task(title: title, isCompleted: false, listId: listId);
      await _taskDatabase.insertTask(task);
      _loadTasksForList(listId);
      bool addMore = await showAddMoreTasksConfirmationDialog(context);
      while (addMore) {
        final newTaskTitle = await showAddTaskDialog(context);
        if (newTaskTitle != null && newTaskTitle.isNotEmpty) {
          final newTask = Task(title: newTaskTitle, isCompleted: false, listId: listId);
          await _taskDatabase.insertTask(newTask);
          _loadTasksForList(listId);
        }
        addMore = await showAddMoreTasksConfirmationDialog(context);
      }
    }
  }

  Future<void> _editTask(Task task) async {
    final title = await showAddTaskDialog(context, initialTitle: task.title);
    if (title != null && title.isNotEmpty) {
      final updatedTask = Task(
        id: task.id,
        title: title,
        isCompleted: task.isCompleted,
        listId: task.listId,
      );
      await _taskDatabase.updateTask(updatedTask);
      _loadTasksForList(task.listId);
    }
  }

  Future<void> _deleteTask(int id, int listId) async {
    await _taskDatabase.deleteTask(id);
    _loadTasksForList(listId);
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      isCompleted: !task.isCompleted,
      listId: task.listId,
    );
    await _taskDatabase.updateTask(updatedTask);
    _loadTasksForList(task.listId);
  }

  List<Widget> _buildDecorativeItems() {
    final random = Random();
    final colors = [
      Color(0xFFE9F5DB),
      Color(0xFFCFE1B9),
      Color(0xFFB5C99A),
      Color(0xFF97A97C),
      Color(0xFF8786A),
      Color(0xFF718355)
    ];

    return List.generate(8, (index) {
      final position = Offset(
        random.nextDouble() * MediaQuery.of(context).size.width,
        random.nextDouble() * MediaQuery.of(context).size.height,
      );
      final size = random.nextInt(45) + 20.0;
      final color = colors[random.nextInt(colors.length)].withOpacity(0.6);
      return Positioned(
        top: position.dy,
        left: position.dx,
        child: Icon(
          random.nextBool() ? Icons.star : Icons.circle,
          color: color,
          size: size,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do Lists', style: GoogleFonts.raleway()),
        backgroundColor: Color(0xFFCFE1B9),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE9F5DB), Color(0xFFCFE1B9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ..._buildDecorativeItems(), // Add decorative items here
          ListView(
            children: [
              for (var list in _lists) ...[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFB2BE9E).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          list.title,
                          style: GoogleFonts.raleway(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF718355),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => _addTask(list.id!),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  await _editList(list);
                                } else if (value == 'delete') {
                                  await _listDatabase.deleteList(list.id!);
                                  _loadLists();
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('Edit List'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete List'),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      ),
                      ...(_tasksByList[list.id] ?? [])
                          .where((task) => !task.isCompleted)
                          .map((task) => TaskTile(
                        task: task,
                        onToggle: () async => await _toggleTaskCompletion(task),
                        onDelete: () async => await _deleteTask(task.id!, list.id!),
                        onEdit: () async => await _editTask(task),
                      )),
                      ...(_tasksByList[list.id] ?? [])
                          .where((task) => task.isCompleted)
                          .map((task) => TaskTile(
                        task: task,
                        onToggle: () async => await _toggleTaskCompletion(task),
                        onDelete: () async => await _deleteTask(task.id!, list.id!),
                        onEdit: () async => await _editTask(task),
                      )),
                      if (_tasksByList[list.id]?.every((task) => task.isCompleted) ?? false)
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Yay! All tasks of the list are completed!',
                            style: GoogleFonts.raleway(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF718355),
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addList,
        backgroundColor: Color(0xFF718355),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
