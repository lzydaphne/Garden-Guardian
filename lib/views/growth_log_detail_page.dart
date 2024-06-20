import 'package:flutter/material.dart';
import 'package:flutter_app/models/growth_log.dart';
import 'package:flutter_app/views/navigation_bar.dart';

class GrowthLogDetailPage extends StatelessWidget {
  final GrowthLog growthLog;

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
                          growthLog.name,
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            ),
                        ),
                        const SizedBox(height: 16),
                        Image.asset(
                          growthLog.imageUrl,
                          height: 150,
                          width: 250/*double.infinity*/,
                          //fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),
                        Text(growthLog.description),
                      ],
                    ),
                  ),
                  
              ),
          ),
          const NavigationBottomBar(),
        ],
      ),
    );
  }
}
