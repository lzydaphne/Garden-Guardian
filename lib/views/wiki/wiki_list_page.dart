import 'package:flutter/material.dart';
import 'package:flutter_app/repositories/wiki_repo.dart';
import 'package:flutter_app/views/wiki/wiki_detail_page.dart';
import 'package:flutter_app/views/wiki/search_bar_wiki.dart';
import 'package:flutter_app/models/wiki.dart';

class WikiListPage extends StatefulWidget {
  @override
  State<WikiListPage> createState() => _WikiListPageState();
}

class _WikiListPageState extends State<WikiListPage> {
  final WikiRepository wikiRepository = WikiRepository();

  String searchVal = '';

  List<Wiki> searchResults = [];

  void _searchWikis(String query) {
    setState(() {
      searchVal = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'wiki',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 8, left: 24, right: 24, bottom: 8),
            child: SearchAppBarWiki(
              hintLabel: "Search",
              onSubmitted: (value) {
                setState(() {
                  searchVal = value;
                });
                _searchWikis(value);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Wiki>>(
              stream: wikiRepository.streamAllWiki(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                } else {
                  final allWikis = snapshot.data!;
                  List<Wiki> filteredWikis = searchVal.isEmpty
                      ? allWikis
                      : allWikis
                          .where((Wiki) => Wiki.name!
                              .toLowerCase()
                              .startsWith(searchVal.toLowerCase()))
                          .toList();
                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    itemCount: filteredWikis.length,
                    itemBuilder: (context, index) {
                      final wiki = filteredWikis[index];
                      return ListTile(
                        title: Column(
                          children: [
                            Image.network(
                              wiki.imageUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Text(wiki.name),
                          ],
                        ),
                        subtitle: Text(
                          wiki.description.length > 120
                              ? '${wiki.description.substring(0, 120)}...'
                              : wiki.description,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WikiDetailPage(wiki: wiki),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
