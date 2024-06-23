import 'package:flutter/material.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:flutter_app/views/wiki/wiki_list_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/models/todo.dart';
import 'package:flutter_app/repositories/todo_repo.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TodoRepository _todoRepository = TodoRepository();
  final List<Todo> _todoList = [];
  Map<DateTime, int> heatMapDatasets = {
    DateTime(2024, 5, 6): 8,
    DateTime(2024, 5, 7): 7,
    DateTime(2024, 6, 8): 10,
    DateTime(2024, 6, 22): 13,
    DateTime(2024, 6, 12): 10,
    DateTime(2024, 5, 20): 10,
    DateTime(2024, 5, 30): 6,
  };

  @override
  void initState() {
    super.initState();
    _todoRepository.streamAllTodos().listen((todos) {
      setState(() {
        _todoList.clear();
        _todoList.addAll(todos);
      });
    });
  }

  void _updateTodoItem(Todo item) async {
    try {
      await _todoRepository
          .updateTodoItem(item.id, {'isCompleted': !item.isCompleted});
      setState(() {
        item.isCompleted = !item.isCompleted;
      });
    } catch (e) {
      print('Error updating todo item: $e');
    }
  }

  void _addTodoItem(String item) async {
    Todo newItem = Todo(
      id: '',
      title: item,
      isCompleted: false,
    );
    await _todoRepository.addTodoItem(newItem);
    Navigator.of(context).pop();
  }

  void _showAddTodoDialog() {
    final TextEditingController _textFieldController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('新增事項'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "輸入事項:"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('新增'),
              onPressed: () {
                _addTodoItem(_textFieldController.text);
              },
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
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 93, 176, 117),
            padding: EdgeInsets.only(left: 20, bottom: 20, top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'v0.0.1',
                      style: TextStyle(color: Colors.white),
                    ),
                    const Column(
                      children: [
                        Text(
                          'GARDEN',
                          style: TextStyle(
                              fontFamily: 'JuliusSansOne', fontSize: 12),
                        ),
                        Text(
                          'GUARDIAN',
                          style: TextStyle(
                              fontFamily: 'JuliusSansOne', fontSize: 15),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        context.go('/profile');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Good morning, Victoria.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        '南瓜通常被認為是蔬菜，但它與其他葫蘆瓜一樣，切開後會發現內裡有大量種子，其實它們都是水果家族的一員！',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WikiListPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 35,
                      child: Row(
                        children: [
                          const SizedBox(width: 80),
                          const Text(
                            'Victoria',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 35),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Lv.5',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.notifications_none),
                            onPressed: () {
                              context.go('/profile');
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 280,
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 12,
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '28°C  ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      Icon(
                                        Icons.wb_sunny,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'June 21, 2024',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 129, 129, 129),
                                        ),
                                      ),
                                      Text(
                                        ' | Hsinchu',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 129, 129, 129),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: HeatMap(
                                        scrollable: true,
                                        datasets: heatMapDatasets,
                                        colorsets: const {
                                          1: Colors.red,
                                          3: Colors.orange,
                                          7: Colors.green,
                                          5: Colors.yellow,
                                          9: Colors.blue,
                                          11: Colors.indigo,
                                          13: Colors.purple,
                                        },
                                        startDate: DateTime.now()
                                            .subtract(Duration(days: 60)),
                                        endDate: DateTime.now(),
                                        onClick: (value) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text(value.toString())),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            color: Colors.white,
                          ),
                          Expanded(
                            flex: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 20.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'To-do list',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(144, 0, 0, 0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      padding: EdgeInsets.all(0),
                                      itemCount: _todoList.length,
                                      itemBuilder: (context, index) {
                                        final todo = _todoList[index];
                                        return ListTile(
                                          contentPadding:
                                              EdgeInsets.only(left: 12),
                                          minVerticalPadding: 0,
                                          leading: Checkbox(
                                            side: BorderSide(
                                              color:
                                                  Color.fromARGB(144, 0, 0, 0),
                                            ),
                                            shape: CircleBorder(),
                                            value: todo.isCompleted,
                                            onChanged: (bool? value) {
                                              if (value != null) {
                                                _updateTodoItem(todo);
                                              }
                                            },
                                          ),
                                          title: Text(
                                            todo.title,
                                            style: TextStyle(
                                              color:
                                                  Color.fromARGB(144, 0, 0, 0),
                                              fontSize: 14,
                                              decoration: todo.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.add_circle_rounded,
                                        color: Color.fromARGB(96, 0, 0, 0),
                                        size: 20,
                                      ),
                                      onPressed: _showAddTodoDialog,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 15,
                left: 15,
                child: CircleAvatar(
                  backgroundImage: AssetImage('images/user.png'),
                  radius: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Column(
                children: [
                  Expanded(
                    //height: 125,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildButton(
                            '飲水紀錄',
                            const Color.fromARGB(255, 196, 228, 244),
                            const Color.fromARGB(255, 49, 163, 254),
                            Icons.local_drink,
                            '目標2000ml\n已連續達成6日',
                            '點擊查看紀錄',
                            0,
                            () {
                              context.go('/goal');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildButton(
                            '種植挑戰',
                            const Color.fromARGB(255, 216, 243, 224),
                            const Color.fromARGB(255, 112, 187, 134),
                            Icons.hotel_class_rounded,
                            '已種植8株植物\n最高難度3★',
                            '點擊查看紀錄',
                            0,
                            () {
                              context.go('/goal');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildButton(
                            '帳號維護',
                            const Color.fromARGB(255, 255, 225, 197),
                            const Color.fromARGB(255, 255, 149, 52),
                            Icons.account_circle,
                            '編輯用戶資訊\n設定使用偏好',
                            '',
                            0,
                            () {
                              context.go('/profile');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Expanded(
                                child: _buildButton(
                                    '植物百科',
                                    const Color.fromARGB(255, 148, 223, 170),
                                    Colors.white,
                                    Icons.book,
                                    '科普百科\n植物照顧指南',
                                    '',
                                    0, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WikiListPage(),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text,
    Color color,
    Color iconColor,
    IconData icon,
    String description,
    String linkText,
    int type,
    VoidCallback onPressed,
  ) {
    double? iconSize = 0;
    double? topPadding = 0;
    if (type == 0) {
      iconSize = 40;
      topPadding = 12;
    } else {
      iconSize = 24;
      topPadding = 7;
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.only(left: 20, top: topPadding),
      ),
      onPressed: onPressed,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 10,
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50, top: 10.0, bottom: 9.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 120, 120, 120),
                    ),
                  ),
                ],
                if (linkText.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Text(
                          linkText,
                          style: TextStyle(fontSize: 10, color: iconColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
