import 'package:flutter/material.dart';
//import 'package:flutter_app/models/growth_log.dart';
import 'package:flutter_app/repositories/growth_log_repo.dart';
import 'package:flutter_app/views/growth_log_detail_page.dart';
import 'package:flutter_app/views/navigation_bar.dart';

class GrowthLogListPage extends StatelessWidget {
  final GrowthLogRepository growthRepository = GrowthLogRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Growth Log', style: TextStyle(fontWeight: FontWeight.w800),),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [Column(
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
                itemCount: growthRepository.GrowthLogList.length,
                itemBuilder: (context, index) {
                  final growthLog = growthRepository.GrowthLogList[index];
                  return ListTile(
                    /*leading: Image.asset(
                      wiki.imageUrl,
                      /*height: 150,
                      width: 150/*double.infinity*/,*/
                      //fit: BoxFit.cover,
                    ),*/
                    title: Container(
                      child: Column(
                        children: [
                          Image.asset(
                            growthLog.imageUrl,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Text(growthLog.name),
                        ],
                    )),
                    subtitle: Text(
                      growthLog.description.length > 120
                          ? growthLog.description.substring(0, 120) + '...'
                          : growthLog.description,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GrowthLogDetailPage(growthLog: growthLog),
                        ),
                      );
                    },
                  );
                },
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
              onPressed: (){},
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: const Color.fromARGB(255, 93, 176, 117),
            ),
          ),
        ]
      ),
    );
  }
}
