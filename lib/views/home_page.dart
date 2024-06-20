import 'package:flutter/material.dart';
import 'package:flutter_app/views/navigation_bar.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final List<String> _todoList = [];

  void _addTodoItem(String item) {
    setState(() {
      _todoList.add(item);
    });
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
        toolbarHeight: 0, // 隱藏預設的 AppBar
      ),
      body: Column(
        children: [
          // 最上方的綠色區域
          Container(
            color: const Color.fromARGB(255, 93, 176, 117),
            padding: EdgeInsets.all(20),
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
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'GUARDIAN',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {},
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
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 中間的區域
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // 增加空間使灰色框框不會蓋到Row
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
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ), 
                    // 灰色框框
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 200,
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        children: [
                          // 左半邊
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '28°C',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('April 13, 2024'),
                                  Text('Taipei'),
                                ],
                              ),
                            ),
                          ),
                          // 中間的白色分隔線
                          Container(
                            width: 1,
                            color: Colors.white,
                          ),
                          // 右半邊
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'To-do list',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onVerticalDragUpdate: (details) {
                                        // 這裡可以根據需要添加自定義行為
                                      },
                                      child: ListView.builder(
                                        itemCount: _todoList.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(_todoList[index]),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.grey,
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
                  backgroundImage:
                      AssetImage('images/user.png'), 
                  radius: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 自定義按鈕佈局
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Column(
                children: [
                  SizedBox(
                    height: 125,
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
                            0
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildButton(
                            '種植挑戰',
                            const Color.fromARGB(255, 216, 243, 224),
                            const Color.fromARGB(255, 112, 187, 134),
                            Icons.hotel_class_rounded,
                            //Icons.local_florist,
                            '已種植8株植物\n最高難度3★',
                            '點擊查看紀錄',
                            0
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
                            0
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
                                  '',
                                  '',
                                  1
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: _buildButton(
                                  '新手指南',
                                  const Color.fromARGB(255, 241, 241, 241),
                                  const Color.fromARGB(255, 120, 120, 120),
                                  Icons.library_books,
                                  '',
                                  '',
                                  1
                                ),
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
          // 最下方的Bar
          //const NavigationBottomBar(),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, Color iconColor, IconData icon,
      String description, String linkText, int type) {
        double? iconSize = 0;
        double? topPadding = 0;
    if (type == 0){
      iconSize = 40;
      topPadding = 12;
    }
    else {
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
      onPressed: () {},
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
                  //Icon(icon, size: 28, color: iconColor),
                  //const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: iconColor),
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
                  children: [
                    const SizedBox(width: 88),
                    Text(
                      linkText,
                      style: TextStyle(
                          fontSize: 10,
                          color: iconColor),
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

