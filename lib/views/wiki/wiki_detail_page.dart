import 'package:flutter/material.dart';
import 'package:flutter_app/models/wiki.dart';

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
              child: Padding(
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
                    Image.network(
                      wiki.imageUrl,
                      height: 150,
                      width: 250,
                    ),
                    const SizedBox(height: 16),
                    Text(wiki.description),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
