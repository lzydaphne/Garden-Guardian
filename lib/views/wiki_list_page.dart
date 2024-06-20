import 'package:flutter/material.dart';
import 'package:flutter_app/repositories/wiki_repo.dart';
import 'package:flutter_app/views/wiki/wiki_detail_page.dart';

class WikiListPage extends StatelessWidget {
  final WikiRepository wikiRepository = WikiRepository();

  WikiListPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('wiki', style: TextStyle(fontWeight: FontWeight.w800),),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 24, right: 24, bottom: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 4, right: 4),
              itemCount: wikiRepository.wikiList.length,
              itemBuilder: (context, index) {
                final wiki = wikiRepository.wikiList[index];
                return ListTile(
                  title: Container(
                    child: Column(
                      children: [
                        Image.asset(
                          wiki.imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Text(wiki.name),
                      ],
                  )),
                  subtitle: Text(
                    wiki.description.length > 120
                        ? wiki.description.substring(0, 120) + '...'
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
            ),
          ),
        ],
      ),
    );
  }
}
