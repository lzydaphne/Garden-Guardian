import 'package:flutter/material.dart';
import 'package:flutter_app/models/wiki.dart';
import 'package:flutter_app/views/navigation_bar.dart';

class WikiDetailPage extends StatelessWidget {
  final Wiki wiki;

  WikiDetailPage({required this.wiki});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('wiki'),
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
                          wiki.name,
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            ),
                        ),
                        const SizedBox(height: 16),
                        Image.asset(
                          wiki.imageUrl,
                          height: 150,
                          width: 250/*double.infinity*/,
                          //fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),
                        Text(wiki.description),
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
