import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/service/add_house_service.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';
import 'package:jaytap/modules/house_details/views/add_house_view.dart'; // Resim seçici için pubspec.yaml'a ekleyin: image_picker: ^1.0.7

// Goşmaça (Olanaklar) için basit bir model
class Amenity {
  final String name;
  final IconData icon;
  RxBool isSelected;

  Amenity({required this.name, required this.icon, bool initialValue = false}) : isSelected = initialValue.obs;
}

class AddHouseController extends GetxController {
  final AddHouseService _addHouseService = AddHouseService();
  RxList<Village> villages = <Village>[].obs;
  var isLoadingVillages = true.obs;
  RxInt selectedVillageId = 0.obs;

  // DİĞER DEĞİŞKENLER...
  var isEditMode = false.obs;
  var selectedSaleTypeIndex = 0.obs;
  Future<void> fetchInitialData() async {
    try {
      isLoadingVillages.value = true;
      final fetchedVillages = await _addHouseService.fetchVillages();
      if (fetchedVillages.isNotEmpty) {
        villages.value = fetchedVillages;
        selectVillage(villages.first.id); // Başlangıçta ilk köyü seçili yap
      }
    } finally {
      isLoadingVillages.value = false;
    }
  }

  void selectVillage(int villageId) {
    print(selectedVillageId.value);
    print(villageId);
    selectedVillageId.value = villageId;
    print(selectedVillageId.value);
    print("______________________________________");
  }

  // Seçimler
  var selectedCityIndex = 0.obs;
  var selectedBuildingFloor = 1.obs;
  var selectedRenovation = Rxn<String>();

  // Text Alanları
  final areaController = TextEditingController();
  final priceController = TextEditingController();
  final phoneController = TextEditingController();

  // Oda Sayaçları
  var livingRoomCount = 0.obs;
  var guestRoomCount = 0.obs;
  var kitchenCount = 0.obs;
  var salonCount = 0.obs;
  var bathroomCount = 0.obs;
  var totalRoomCount = 0.obs;

  // Resimler
  var images = <XFile>[].obs;
  final ImagePicker _picker = ImagePicker();

  // --- SABİT VERİLER (Normalde Backend'den gelir) ---
  final List<String> renovationOptions = ['Ýewro remont', 'Kosmetiçeskiý', 'Dizaýnerskiý', 'Goş. remont', 'Orta', 'Remont etmeli'];
  final List<Amenity> amenities = [
    Amenity(name: 'Wi-Fi', icon: Icons.wifi),
    Amenity(name: 'Kir maşyn', icon: Icons.local_laundry_service),
    Amenity(name: 'Aşhana', icon: Icons.kitchen),
    Amenity(name: 'Holodilnik', icon: Icons.ac_unit),
    // ...Tasarımınızdaki diğer tüm olanakları buraya ekleyin
    Amenity(name: 'Telewizor', icon: Icons.tv),
    Amenity(name: 'Şkaf', icon: Icons.balcony), // Uygun ikon bulunmalı
    Amenity(name: 'Spalny', icon: Icons.bed),
    Amenity(name: 'Basseýn', icon: Icons.pool),
    Amenity(name: 'Lift', icon: Icons.elevator),
  ];

  // --- FONKSİYONLAR ---

  // Bir ilanı düzenlemek için bu fonksiyon çağrılır
  void loadExistingData(dynamic houseData) {
    isEditMode.value = true;
    // houseData'dan gelen verilerle controller'daki tüm state'leri doldur...
    // Örnek:
    // areaController.text = houseData['area'].toString();
    // selectedCityIndex.value = cities.indexOf(houseData['city']);
    // ...
    Get.to(() => AddHouseView()); // Veriler yüklendikten sonra sayfayı aç
  }

  // Şehir, Satış türü, Kat vb. seçim fonksiyonları
  void selectCity(int index) => selectedCityIndex.value = index;
  void selectBuildingFloor(int floor) => selectedBuildingFloor.value = floor;
  void selectRenovation(String? value) => selectedRenovation.value = value;

  // Oda sayısını değiştiren genel fonksiyon
  void changeRoomCount(RxInt counter, int change) {
    if (counter.value + change >= 0) counter.value += change;
  }

  // Resim seçme fonksiyonu
  Future<void> pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      images.addAll(pickedFiles);
    }
  }

  void removeImage(int index) => images.removeAt(index);

  // --- DIALOG ve MODAL GÖSTERME FONKSİYONLARI ---

  // Remont (Tadilat) tipi seçme modal'ını göster
  void showRenovationPicker() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Remont görnüşi', style: Get.textTheme.titleLarge),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: renovationOptions.length,
              itemBuilder: (context, index) {
                final option = renovationOptions[index];
                return Obx(() => RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: selectedRenovation.value,
                      onChanged: (value) {
                        selectRenovation(value);
                      },
                    ));
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Get.back(), // Modal'ı kapat
                child: const Text('TASSYKLA'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Goşmaça (Olanaklar) seçme modal'ını göster
  void showAmenitiesPicker() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Goşmaça', style: Get.textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: amenities.length,
                itemBuilder: (context, index) {
                  final amenity = amenities[index];
                  return Obx(() => SwitchListTile(
                        title: Text(amenity.name),
                        secondary: Icon(amenity.icon),
                        value: amenity.isSelected.value,
                        onChanged: (bool value) {
                          amenity.isSelected.value = value;
                        },
                      ));
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('ÝAP'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // İlan gönderme/güncelleme süreci
  void submitListing() {
    Get.dialog(
      AlertDialog(
        title: const Text('Tassylama'),
        content: const Text('Siz hakykatdanam bu bildirişi goşmak isleýärsiňizmi?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Goýbolsun')),
          FilledButton(
              onPressed: () {
                Get.back(); // Onay dialog'unu kapat
                _processSubmission();
              },
              child: const Text('Hawa')),
        ],
      ),
    );
  }

  Future<void> _processSubmission() async {
    // 1. Yükleniyor dialog'unu göster
    Get.dialog(
      const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Tassyklanýar...', style: TextStyle(color: Colors.white, decoration: TextDecoration.none)),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    // 2. Backend'e gönderme işlemini simüle et
    await Future.delayed(const Duration(seconds: 2));

    // 3. Yükleniyor dialog'unu kapat
    Get.back();

    // 4. Başarı dialog'unu göster
    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text('Üstünlikli amala aşyryldy', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Siziň bildirişiňiz saklanyldy. Moderasiýa edilenden soň, bildiriş saýta ýerleşdiriler.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Başarı dialog'unu kapat
                // Get.offAll(...); // Ana sayfaya yönlendir
              },
              child: const Text('TASSYKLANDY'),
            )
          ],
        ),
      ),
    );
  }

  @override
  void onClose() {
    areaController.dispose();
    priceController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
