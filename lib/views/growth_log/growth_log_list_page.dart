import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GrowthLogListPage extends StatelessWidget {
  final String plantID;

  GrowthLogListPage({required this.plantID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Growth Log',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('plants')
            .doc(plantID)
            .collection('growth_logs')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No growth logs found.'));
          }
          final growthLogs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.only(left: 4, right: 4),
            itemCount: growthLogs.length,
            itemBuilder: (context, index) {
              final growthLog = growthLogs[index];
              return ListTile(
                title: Container(
                  child: Column(
                    children: [
                      Image.network(
                        growthLog['imageUrl'],
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Text(growthLog['name']),
                    ],
                  ),
                ),
                subtitle: Text(
                  growthLog['description'].length > 120
                      ? growthLog['description'].substring(0, 120) + '...'
                      : growthLog['description'],
                ),
                onTap: () {
                  // Handle growth log detail page navigation
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(eccentricity: 1.0),
        elevation: 5,
        onPressed: () {
          // Handle add growth log navigation
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 93, 176, 117),
      ),
    );
  }
}
