import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/models/plant.dart';
import 'package:flutter_app/models/wiki.dart';
import 'package:flutter_app/repositories/plant_repo.dart';

class WikiRepository {
  final PlantRepository _plantRepository = PlantRepository();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<List<Wiki>> streamAllWiki() {
    return _plantRepository.streamAllPlants().map((plantList) {
      return plantList.map((plant) {
        return Wiki(
          imageUrl: plant.imageUrl,
          name:
              plant.species, // Assuming plant.species is the name of the plant
          description: plant.description,
        );
      }).toList();
    });
  }

  Future<Wiki?> getWikiByName(String name) async {
    try {
      // Convert the stream to a list
      List<Wiki> wikiList = await streamAllWiki().first;
      // Find the wiki with the matching name
      return wikiList.firstWhere((wiki) => wiki.name == name/*, orElse: () => null*/);
    } catch (e) {
      // Handle any errors that might occur
      print("Error getting wiki by name: $e");
      return null;
    }
  }
}

/*final List<Wiki> wikiList = [
    Wiki(
      name: 'Snake Plant (Sansevieria)',
      imageUrl: 'images/Snake_Plant.jpg',
      description:
          '        室內放一盆虎尾蘭盆栽的好處很多，因為虎尾蘭可以「有效去除甲醛」及「吸收室內 80% 以上的有害氣體」，有一個「空氣清淨機」的稱號呢，沒想到這麼強的植物也是多肉植物吧！\n        虎尾蘭（Sansevieria）大致上可分成兩種：軟葉型與硬葉型。軟葉型虎尾蘭起源於：熱帶與亞熱帶地區，屬於熱帶植物，特徵：寬、長、呈帶狀。硬葉型虎尾蘭生長於乾旱氣候，也是沙漠植物（多肉植物），特徵：厚、硬、短，過往植物學分類上虎尾蘭是龍舌蘭科虎尾蘭屬的植物，而最新的植物科學研究表示，虎尾蘭該被分進天門冬科龍血樹屬之中，意味著虎尾蘭將不再自成一屬了，不過這不一定會影響到園藝世界裡的俗名稱呼，應該還會延續使用虎尾蘭這個名字許多年。虎尾蘭為多年生植物，原生品種超過 70 種，葉片形狀有柱狀與片狀，柱狀的大多原產於非洲，片狀的大多原生於斯里蘭卡與印度，也分高種與矮種，高種植株高度超過 1 公尺，可適應全日照到較陰的環境裡，通常來說矮種的比高種的更耐曬。\n        虎尾蘭喜歡溫暖的環境，行光合作用的方式為：景天酸代謝。適合放置在 16 度- 30 度的溫度下生長，低於 8 度會休眠，並會產生寒凍害，不過在台灣的我們不用太擔心這一點囉！若是你的虎尾蘭種植在南面陽台等陽光照射到的地方，他的葉片顏色會比較翠綠，生長速度快，也比較有機會開花。若是陽光比較不夠的地方，例如北面陽台、臥室、客廳，那顏色偏深綠且生長速度慢。\n        虎尾蘭的栽培土質需要疏鬆，具透氣性的介質，滿喜歡砂質土的，如上面提到的虎尾蘭對生長環境的適應性很強，很好照顧，不過如果想要給他最舒服的居住環境的話，可以使用多肉植物專用土加一些腐植土，多肉專用土由多種疏水性好、保水性高的石頭組合而成，兼具營養及疏水性。\n',
    ),
    Wiki(
      name: '黃金葛',
      imageUrl: 'images/Pothos.png',
      description:
          '        黃金葛，生長超快、超好養，蟲害也不怕，絕對是盆栽新手的最佳選擇！黃金葛到底有多好照顧呢？其實只要您有去過花市，肯定聽過攤商老闆說「黃金葛隨便種隨便活」！所以不管是公共場所、餐廳、民宿、飯店、百貨公司、車站、機場，還是一般住家或辦公室，都能看到黃金葛的身影。 最特別的是，黃金葛可是大家最熟悉的空氣淨化植物哦！如果有人問，廁所或浴室裡最容易種的植物是什麼？當然非「黃金葛」莫屬啦！\n        澆水頻率要視氣候及環境調整：\n                天氣冷或濕度高的時候：每 2~3 天 1 次。\n                天氣熱或濕度低的時候：每週 1 次。\n        黃金葛及其相似品種，均可依據個人喜好不定期針對外觀做適度修剪；修剪時建議使用恰當的工具, 不要用拉拔或硬扯的方式處理，避免造成撕裂傷或傷口過大。\n        黃金葛老化的葉片會自然脫水、最後乾枯，種植於室內建議要幫助植株移除這類沒有繼續生長的部位，並定期修剪明顯發黃或枯掉的老葉，可以看到就剪掉，以幫助盆栽的養份重新均勻分配給健康或新生的葉片。\n        如果黃金葛生病了，很常是因為細菌性感染（如腐敗病、葉斑病），若即時處理，會很快看到黃金葛恢復生氣；但若發現黃金葛植株莖部已整枝感染發黑，就要記得深入檢查根部是否有腐爛、甚至發臭的情形，若有，就要像我們受傷時清理傷口一樣，儘可能清除受感染部位，必要時以清水仔細沖洗掉腐敗物質，接下來，還要暫停澆水並觀察病態是否獲得控制、不再蔓延。\n',
    ),
    Wiki(
      name: '吊蘭',
      imageUrl: 'images/spider_plant.jpg',
      description:
          '        吊蘭（Chlorophytum comosum），以其獨特的綠白相間葉片和強大的空氣淨化能力而受到許多人的喜愛。這種植物不僅美觀，而且易於照料，非常適合作為室內植物。本文將提供一個全面的指南，幫助您在室內養出健康、茂盛的吊蘭。\n        吊蘭屬於百合科，是一種多年生草本植物。它們原產於非洲南部，能夠忍受較低光照條件和不規則的澆水，使其成為室內環境的理想選擇。\n        市場上有許多不同品種的吊蘭，包括傳統的綠葉吊蘭和斑點吊蘭等。每個品種的葉片圖案和顏色都略有不同，可以根據個人喜好和裝飾風格選擇合適的品種。\n        吊蘭喜歡肥沃、排水良好的土壤。使用通用的盆栽土壤混合物，並適量添加蛭石或珍珠岩來改善土壤的透氣性和排水性。確保盆栽底部有排水孔。\n        吊蘭能夠適應從低光到明亮的光照條件，但最佳生長環境是明亮且無直射陽光的地方。在室內種植時，選擇接受間接陽光的地方，如靠近窗戶的位置。\n        吊蘭不喜歡過度澆水。保持土壤的輕微濕潤，並在每次澆水前確保土壤表層已經乾燥。過多的水分會導致根部腐爛。此外，吊蘭喜歡較高的空氣濕度，可以通過噴霧或放置加濕器來增加周圍環境的濕度。\n        在生長季節，每月施用一次液態全能肥料，以支持吊蘭的生長。冬季時減少施肥，因為這是植物生長較慢的時期。\n        定期修剪可以促進吊蘭的健康生長，並保持其整潔的外觀。去除枯萎或受損的葉片，並修剪過長的莖條，以維持植物的形狀。\n        吊蘭相對抗病蟲害，但仍需定期檢查是否有蟲害或疾病。在發現問題時，及時使用適合的殺蟲劑或殺菌劑。\n',
    ),
  ];

  Wiki? getWikiByName(String name) {
    try {
      return wikiList.firstWhere((wiki) => wiki.name == name);
    } catch (e) {
      return null;
    }
  }*/