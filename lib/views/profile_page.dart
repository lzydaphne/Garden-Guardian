import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/views/navigation_bar.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<Map<String, String>> items = [
    {
      'title': 'Notes for seeding',
      'content': 'Essential information and tips to ensure successful seed planting and ...',
      'date': '2024/4/13'
    },
    {
      'title': 'Being a gardener',
      'content': 'A hands-on experience that involves nurturing plants from seed to maturity ...',
      'date': '2024/3/23'
    },
    {
      'title': 'Manual for this app',
      'content': 'A comprehensive guide that can be adapted to practically any app, helping users ...',
      'date': '2024/1/21'
    },
    {
      'title': 'Hydration Hero',
      'content': 'Achieve the title of Hydration Hero by watering your plants a total of 1000 times.',
      'date': '2024/1/21'
    },
  ];

  void _addItem(String title, String content) {
    setState(() {
      items.add({
        'title': title,
        'content': content,
        'date': DateTime.now().toString().split(' ')[0],
      });
    });
    Navigator.of(context).pop();
  }

  void _showAddItemDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('新增事項'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: '標題'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: '內容'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                _addItem(titleController.text, contentController.text);
              },
              child: Text('增加'),
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
        title: const Text('Profile', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: const Color.fromARGB(255, 93, 176, 117),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Logout', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 120,
                        color: const Color.fromARGB(255, 93, 176, 117),
                      ),
                      Container(
                        height: 40, 
                        decoration: BoxDecoration(color: Colors.white),),
                    ],
                  ),
                  const Positioned(
                    top: 20,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage('images/user.png'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
              Container(height: 10, decoration: BoxDecoration(color: Colors.white),),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white),
                child:const Column(children: [
                  Text('Victoria Robertson', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  Text('LVL. 5', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],)
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  child: ListView.separated(
                    padding: EdgeInsets.only(top: 16, left: 48, right: 48),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(items[index]['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(items[index]['content']!),
                        trailing: Text(items[index]['date']!, style: TextStyle(color: Colors.grey)),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(color: Colors.grey);
                    },
                  ),
                ),
              ),
              const NavigationBottomBar(),
            ],
          ),
          Positioned(
            bottom: 80.0, 
            right: 16.0,
            child: FloatingActionButton(
              shape: CircleBorder(eccentricity: 1.0),
              elevation: 5,
              onPressed: _showAddItemDialog,
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: const Color.fromARGB(255, 93, 176, 117),
            ),
          ),
        ],
      ),
    );
  }
}
