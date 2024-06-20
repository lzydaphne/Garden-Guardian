import 'package:flutter/material.dart';
import 'package:flutter_app/models/plant.dart';

class PlantCardDialog extends StatelessWidget {
  final Plant plant;

  PlantCardDialog({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  plant.imageUrl,
                  height: 350,
                  width: 400/*double.infinity*/,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: Icon(Icons.highlight_off),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () {
                    // 相機功能待實現
                  },
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(Icons.book_outlined),
                  onPressed: () {
                    // 書本功能待實現
                  },
                ),
              ),
            ],
          ),
          Container(
            width: 400,
            height: 230,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(15),
                bottomLeft: Radius.circular(15)
                ),
              color: Color.fromARGB(255, 216, 243, 224)),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plant.nickName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      //const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 216, 243, 224),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              '123',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                            SizedBox(width: 4),
                            
                            IconButton(
                              icon: Icon(Icons.info, size: 16),
                              onPressed: () {
                                // i 按鈕功能待實現
                              },
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: const Icon(Icons.border_color_rounded),
                        onPressed: () {
                          // 書寫按鈕功能待實現
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  buildInfoRow('入住時間', /*plant.moveInDate*/'123', context),
                  SizedBox(height: 8),
                  buildInfoRow('最近澆水', /*plant.lastWateredDate*/'123', context),
                  SizedBox(height: 8),
                  buildInfoRow('最近施肥', /*plant.lastFertilizedDate*/'123', context),
                  SizedBox(height: 8),
                  buildInfoRow('最近修剪', /*plant.lastPrunedDate*/'123', context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String date, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 120,
          height: 30,
          decoration: const BoxDecoration(
              //border: Border.all(color: Colors.green),
              color: const Color.fromARGB(255, 93, 176, 117),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w100),
          ),
        ),
        Expanded(
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
            ),
            child: Row(
              children: [
                Text(date),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  onPressed: () {
                    // 彈出月曆選擇日期
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    ).then((pickedDate) {
                      if (pickedDate != null) {
                        // 更新日期顯示
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}