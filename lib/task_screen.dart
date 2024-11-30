import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Map<String, dynamic>> tasks = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // Inicializar notificações
    var androidInitialize = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(
        android: androidInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Função para adicionar uma tarefa
  void _addTask(String title, String description, DateTime dateTime) {
    setState(() {
      tasks.add({
        'title': title,
        'description': description,
        'dateTime': dateTime,
        'isCompleted': false,
        'category': 'Sem categoria',
      });
    });

    // Agendar notificação
    _scheduleNotification(dateTime, title);
  }

  // Função para editar uma tarefa
  void _editTask(int index, String title, String description) {
    setState(() {
      tasks[index]['title'] = title;
      tasks[index]['description'] = description;
    });
  }

  // Função para excluir uma tarefa
  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  // Função para marcar a tarefa como concluída
  void _toggleTaskCompletion(int index) {
    setState(() {
      tasks[index]['isCompleted'] = !tasks[index]['isCompleted'];
    });
  }

  // Função para agendar a notificação
  Future<void> _scheduleNotification(DateTime dateTime, String title) async {
    var androidDetails = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.high,
      priority: Priority.high,
    );
    var platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Lembrete: $title',
      'Sua tarefa está vencendo!',
      dateTime,
      platformDetails,
    );
  }

  // Modal para Adicionar/Editar Tarefa
  void _showTaskModal({int? index}) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDateTime = DateTime.now();

    if (index != null) {
      titleController.text = tasks[index]['title'];
      descriptionController.text = tasks[index]['description'];
      selectedDateTime = tasks[index]['dateTime'];
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Descrição'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDateTime) {
                    setState(() {
                      selectedDateTime = picked;
                    });
                  }
                },
                child: Text('Selecionar Data'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty) {
                    if (index == null) {
                      _addTask(
                        titleController.text,
                        descriptionController.text,
                        selectedDateTime,
                      );
                    } else {
                      _editTask(
                        index,
                        titleController.text,
                        descriptionController.text,
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(index == null ? 'Adicionar' : 'Salvar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciamento de Tarefas'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showTaskModal(),
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(child: Text('Nenhuma tarefa adicionada.'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(
                    task['title'],
                    style: TextStyle(
                        decoration: task['isCompleted']
                            ? TextDecoration.lineThrough
                            : null),
                  ),
                  subtitle: Text(task['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          task['isCompleted']
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task['isCompleted'] ? Colors.green : Colors.grey,
                        ),
                        onPressed: () => _toggleTaskCompletion(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showTaskModal(index: index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(index),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
