import 'package:flutter/material.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/repositories/todo_repository.dart';
import 'package:todo_list/widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController taskController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> tasks = [];

  Todo? deletedTodo;
  int? deletedTodoPos;

  String? errorText;

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: taskController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Color(0xff00d7f3),
                        )),
                        labelText: 'Adicione uma tarefa',
                        hintText: 'Ex. Estudar Flutter',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff00d7f3)),
                        ),
                        labelStyle: TextStyle(
                          color: Color(0xff00d7f3),
                        ),
                        errorText: errorText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String text = taskController.text;

                      if (text.isEmpty) {
                        setState(() {
                          errorText = 'O título não pode ser vazio';
                        });
                        return;
                      }

                      setState(() {
                        Todo newTodo = Todo(
                          title: text,
                          dateTime: DateTime.now(),
                        );
                        tasks.add(newTodo);
                        errorText = null;
                      });
                      taskController.clear();
                      todoRepository.saveTodoList(tasks);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff00d7f3),
                      padding: EdgeInsets.all(15),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 30,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (Todo task in tasks)
                      TodoListItem(
                        task: task,
                        onDelete: onDelete,
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Você possui ${tasks.length} tarefas pendentes',
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: showDeleteTodoConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff00d7f3),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                        )),
                    child: Text('Limpar Tudo'),
                  ),
                ],
              )
            ],
          ),
        ),
      )),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = tasks.indexOf(todo);

    setState(() {
      tasks.remove(todo);
    });
    todoRepository.saveTodoList(tasks);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Tarefa ${todo.title} foi removida com sucesso!!',
        style: TextStyle(color: Color(0xff060708)),
      ),
      backgroundColor: Colors.white,
      action: SnackBarAction(
        label: 'Desfazer',
        textColor: const Color(0xff00d7f3),
        onPressed: () {
          setState(() {
            tasks.insert(deletedTodoPos!, deletedTodo!);
          });
          todoRepository.saveTodoList(tasks);
        },
      ),
      duration: const Duration(seconds: 5),
    ));
  }

  void showDeleteTodoConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar tudo?'),
        content: Text('Você tem certeza que deseja apagar todos as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Color(0xff00f7f3),
            ),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deletedAllTodos();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Limpar tudo'),
          )
        ],
      ),
    );
  }

  void deletedAllTodos() {
    setState(() {
      tasks.clear();
    });
    todoRepository.saveTodoList(tasks);
  }
}
