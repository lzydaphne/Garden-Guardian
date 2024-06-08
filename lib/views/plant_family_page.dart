import 'package:flutter/material.dart';
import 'package:flutter_app/views/search_bar.dart';
import 'package:flutter_app/views/plant_card.dart';
//import 'package:flutter_app/models/location.dart';
import 'package:flutter_app/models/plant.dart';
import 'package:flutter_app/repositories/location_repo.dart';
import 'package:flutter_app/repositories/plant_repo.dart';

final ValueNotifier<String> _msg = ValueNotifier('');

class PlantFamilyPage extends StatefulWidget {
  const PlantFamilyPage({Key? key}) : super(key: key);

  @override
  State<PlantFamilyPage> createState() => _PlantFamilyPageState();
}

class _PlantFamilyPageState extends State<PlantFamilyPage> {
  final LocationRepository _locationRepo = LocationRepository();
  final PlantRepository _plantRepo = PlantRepository();

  String searchVal = '';
  String selectedLocation = '';
  int currentPage = 0;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // 初始化地點和植物資料
    _initializeData();
    if (_locationRepo.getLocations().isNotEmpty) {
      selectedLocation = _locationRepo.getLocations().first.name;
    }
  }

  void _initializeData() {
    // 初始化一些範例資料
    _locationRepo.addLocation("後陽台");
    _locationRepo.addLocation("客廳");
    _locationRepo.addLocation("臥房陽台");

    _plantRepo.addPlant("植物1", "後陽台");
    _plantRepo.addPlant("植物2", "後陽台");
    _plantRepo.addPlant("植物3", "客廳");
    _plantRepo.addPlant("植物4", "客廳");
    _plantRepo.addPlant("植物5", "客廳");
    _plantRepo.addPlant("植物6", "客廳");
    _plantRepo.addPlant("植物7", "客廳");
    _plantRepo.addPlant("植物8", "客廳");
    _plantRepo.addPlant("植物9", "客廳");
    _plantRepo.addPlant("植物10", "客廳");
    _plantRepo.addPlant("植物11", "客廳");
    _plantRepo.addPlant("植物12", "客廳");
    _plantRepo.addPlant("植物13", "臥房陽台");
    _plantRepo.addPlant("植物14", "臥房陽台");
    _plantRepo.addPlant("植物15", "臥房陽台");
    _plantRepo.addPlant("植物16", "臥房陽台");
    //_plantRepo.addPlant("植物17", "臥房陽台");
  }

  void _addLocation(String location) {
    setState(() {
      _locationRepo.addLocation(location);
      if (selectedLocation.isEmpty) {
        selectedLocation = location;
      }
    });
  }

  void _showAddLocationDialog() {
    String newLocation = "";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("新增地點"),
          content: TextField(
            onChanged: (value) {
              newLocation = value;
            },
            decoration: const InputDecoration(hintText: "新地點名稱"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () {
                if (newLocation.isNotEmpty) {
                  _addLocation(newLocation);
                }
                Navigator.of(context).pop();
              },
              child: const Text("確定"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 93, 176, 117),
        appBar: _buildAppBar(context),
        body: SizedBox(
          width: double.maxFinite,
          child: Column(
            children: [
              const SizedBox(height: 10),
              SearchAppBar(
                hintLabel: "尋找我的植物",
                onSubmitted: (value) {
                  setState(() {
                    searchVal = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              _buildLocationTabs(),
              _buildPlantGrid(),
              _buildPageIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ..._locationRepo.getLocations().map((location) => Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, top: 8),
                child: ChoiceChip(
                  label: Text(location.name),
                  backgroundColor: const Color.fromARGB(255, 93, 176, 117),
                  selectedColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selectedLocation == location.name? const Color.fromARGB(255, 93, 176, 117) : Colors.white,
                    fontWeight: FontWeight.w600
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      width: 2,
                      color:  selectedLocation == location.name? Colors.transparent : Colors.white,
                      //style: BorderStyle.solid
                    )
                  ),
                  selected: selectedLocation == location.name,
                  onSelected: (bool selected) {
                    setState(() {
                      selectedLocation = location.name;
                      currentPage = 0; // 切換地點時重置頁面
                      _pageController.jumpToPage(0); // 重置PageView到第一頁
                    });
                  },
                ),
              )),
          IconButton(
            icon: const Icon(
              Icons.add_circle, 
              color: Colors.white,
            ),
            onPressed: _showAddLocationDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildPlantGrid() {
  List<Plant> plants = _plantRepo.getPlantsByLocation(selectedLocation);
  int pageCount = (plants.length / 4).ceil();
  bool needsExtraPage = plants.length % 4 == 0;

  return Expanded(
    child: GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          // 向左滑動
          if (currentPage < pageCount) {
            _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          }
        } else if (details.primaryVelocity! > 0) {
          // 向右滑動
          if (currentPage > 0) {
            _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          }
        }
      },
      child: PageView.builder(
        controller: _pageController,
        itemCount: pageCount + (needsExtraPage ? 1 : 0),
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        itemBuilder: (context, pageIndex) {
          if (pageIndex == pageCount && needsExtraPage) {
            // 顯示加號卡片的額外頁面
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: 1, // 只顯示一個加號卡片
              itemBuilder: (context, index) {
                return Card(
                  color: const Color.fromARGB(255, 216, 243, 224),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAddPlantDialog,
                  ),
                );
              },
            );
          } else {
            int startIndex = pageIndex * 4;
            int endIndex = (startIndex + 4).clamp(0, plants.length);
            List<Plant> pagePlants = plants.sublist(startIndex, endIndex);
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: pagePlants.length + (pageIndex == pageCount - 1 && !needsExtraPage ? 1 : 0), // 最後一頁多一個加號卡片
                itemBuilder: (context, index) {
                  if (pageIndex == pageCount - 1 && index == pagePlants.length && !needsExtraPage) {
                    // 最後一頁的加號卡片
                    return Card(
                      color: const Color.fromARGB(255, 216, 243, 224),
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _showAddPlantDialog,
                      ),
                    );
                  } else {
                    return PlantCard(plant: pagePlants[index]);
                    /*return Card(
                      child: Center(child: Text(pagePlants[index].name)),
                    );*/
                  }
                },
              ),
            );
          }
        },
      ),
    ),
  );
}

void _showAddPlantDialog() {
  String newPlantName = "";
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("新增植物"),
        content: TextField(
          onChanged: (value) {
            newPlantName = value;
          },
          decoration: const InputDecoration(hintText: "植物名稱"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () {
              if (newPlantName.isNotEmpty) {
                _addPlant(newPlantName);
              }
              Navigator.of(context).pop();
            },
            child: const Text("確認"),
          ),
        ],
      );
    },
  );
}

void _addPlant(String plantName) {
  setState(() {
    _plantRepo.addPlant(plantName, selectedLocation);
  });
}


  Widget _buildPageIndicator() {
  List<Plant> plants = _plantRepo.getPlantsByLocation(selectedLocation);
  int pageCount = (plants.length / 4).ceil();
  bool needsExtraPage = plants.length % 4 == 0;

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      pageCount + (needsExtraPage ? 1 : 0), // 如果需要額外頁面，則加1
      (index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: currentPage == index ? Colors.white : const Color.fromARGB(255, 216, 243, 224),
        ),
      ),
    ),
  );
}

//PreferredSizeWidget = AppBar
PreferredSizeWidget _buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: const Color.fromARGB(255, 93, 176, 117),
    centerTitle: true,
    title: const Text("我的植物", style: TextStyle(color: Colors.white)),
    actions: [
      IconButton(
        icon: const Icon(Icons.info_outline, color: Colors.white),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        onPressed: () => _msg.value = 'press wiki button.',
      )
    ],
  );
}

}
