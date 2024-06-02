import 'package:flutter/material.dart';
import 'package:flutter_app/models/plant.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({Key? key, required this.plant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 植物圖片
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              plant.avatarUrl ?? 'https://via.placeholder.com/150',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 植物名稱
                Expanded(
                  child: Center(
                    child: Text(
                      plant.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                // 小按鈕
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    // 按鈕功能待實現
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 澆水按鈕
                ElevatedButton.icon(
                  icon: Icon(Icons.water_drop),
                  label: Text("澆水"),
                  onPressed: () {
                    // 按鈕功能待實現
                  },
                ),
                // 施肥按鈕
                ElevatedButton.icon(
                  icon: Icon(Icons.local_florist),
                  label: Text("施肥"),
                  onPressed: () {
                    // 按鈕功能待實現
                  },
                ),
                // 修剪按鈕
                ElevatedButton.icon(
                  icon: Icon(Icons.content_cut),
                  label: Text("修剪"),
                  onPressed: () {
                    // 按鈕功能待實現
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}