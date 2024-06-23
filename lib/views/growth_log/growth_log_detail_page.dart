import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_app/models/growth_log.dart';

class GrowthLogDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> growthLog;

  GrowthLogDetailPage({required this.growthLog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Growth Log'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
                child:  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          growthLog['name'],
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            ),
                        ),
                        const SizedBox(height: 16),
                        Image.network(
                          growthLog['imageUrl'],
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),
                        Text(growthLog['description']),
                      ],
                    ),
                  ),
                  
              ),
          ),
          //const NavBar(),
        ],
      ),
    );
  }
}
