import 'package:flutter/material.dart';
import 'package:flutter_app/models/plant.dart';
import 'package:flutter_app/views/plant_card_dialog.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({super.key, required this.plant});

  void _showPlantDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlantCardDialog(plant: plant,);
        /*Dialog(
          //title: Text(plant.name),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                plant.avatarUrl,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 10),
              Text('這是一個關於 ${plant.name} 的詳細信息。'),
              TextButton(
              child: Text('關閉'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ],
          ),
          /*actions: [
            
          ],*/
        );*/
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPlantDetailsDialog(context),    
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: const Color.fromARGB(255, 216, 243, 224),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 植物圖片
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                plant.avatarUrl,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 植物名稱
                  Expanded(
                    child: Center(
                      child: Text(
                        plant.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  // 小按鈕
                  IconButton(
                    icon: const Icon(Icons.info_outline),
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
                    icon: const Icon(
                      Icons.water_drop,
                      size: 16,
                      color: Color.fromARGB(255, 39, 159, 255)
                    ),
                    label: const Text(
                      "澆水", 
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 39, 159, 255)
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 196, 228, 244), 
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      padding: const EdgeInsets.only(left: 7, right: 7),
                    ),
                    onPressed: () {
                      // 按鈕功能待實現
                    },
                  ),
                  // 施肥按鈕
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.local_florist,
                      size: 16,
                      color: Color.fromARGB(255, 97, 178, 121)
                    ),
                    label: const Text(
                      "施肥", 
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 97, 178, 121)
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 196, 229, 202), 
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      padding: const EdgeInsets.only(left: 7, right: 7),
                    ),
                    onPressed: () {
                      // 按鈕功能待實現
                    },
                  ),
                  // 修剪按鈕
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.content_cut,
                      size: 16,
                      color: Color.fromARGB(255, 245, 121, 58)
                    ),
                    label: const Text(
                      "修剪", 
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 245, 121, 58)
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 223, 173), 
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      padding: const EdgeInsets.only(left: 7, right: 7),
                    ),
                    onPressed: () {
                      // 按鈕功能待實現
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}