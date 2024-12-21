import 'package:flutter/material.dart';
import 'db/db_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  _loadTodos() async {
    final todos = await _databaseHelper.getAllTodos();
    setState(() {
      _todos = todos;
    });
  }

  _showTodoDialog([int? id, String task = '', bool isCompleted = false]) {
    final _taskController = TextEditingController(text: task);
    bool _isCompleted = isCompleted;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(id == null ? 'Tambah Tugas' : 'Edit Tugas'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _taskController,
                    decoration: InputDecoration(labelText: 'Tugas'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Sudah Selesai?'),
                      Switch(
                        value: _isCompleted,
                        onChanged: (value) {
                          setState(() {
                            _isCompleted = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    String task = _taskController.text.trim();
                    if (task.isNotEmpty) {
                      if (id == null) {
                        // Tambah tugas baru
                        await _databaseHelper.addTodo(task, _isCompleted ? 1 : 0);
                      } else {
                        // Perbarui tugas yang ada
                        await _databaseHelper.updateTodo(
                            id, task, _isCompleted ? 1 : 0);
                      }
                      _loadTodos();
                      Navigator.of(context).pop();
                    } else {
                      // Tampilkan pesan jika input kosong
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tugas tidak boleh kosong!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Tugas'),
          content: Text('Apakah Anda yakin ingin menghapus tugas ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await _databaseHelper.deleteTodo(id);
                _loadTodos();
                Navigator.of(context).pop();
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('To-Do List'),
      backgroundColor: Colors.green,
    ),
    body: _todos.isEmpty
        ? Center(child: Text('Belum ada tugas'))
        : ListView.builder(
            itemCount: _todos.length,
            itemBuilder: (context, index) {
              var todo = _todos[index];
              bool isCompleted = todo['isCompleted'] == 1; // Periksa status

              return Card(
                color: isCompleted ? Colors.green : Colors.white, // Ubah background
                child: ListTile(
                  title: Text(
                    todo['task'],
                    style: TextStyle(
                      color: isCompleted ? Colors.white : Colors.black, // Warna teks
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(todo['id']),
                  ),
                  onTap: () {
                    _showTodoDialog(
                      todo['id'],
                      todo['task'],
                      isCompleted,
                    );
                  },
                ),
              );
            },
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _showTodoDialog(),
      child: Icon(Icons.add),
      backgroundColor: Colors.green,
    ),
  );
}

}
