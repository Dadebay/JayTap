// lib/modules/house_details/controllers/add_house_controller.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/service/add_house_service.dart';
import 'package:jaytap/modules/house_details/views/add_house_view.dart';
import 'package:jaytap/modules/house_details/views/full_screen_map_view.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:latlong2/latlong.dart';

// Goşmaça (Olanaklar) için basit bir model
class Amenity {
  final int id;
  final String name;
  final IconData icon;
  RxBool isSelected;

  Amenity(
      {required this.id,
      required this.name,
      required this.icon,
      bool initialValue = false})
      : isSelected = initialValue.obs;
}

class AddHouseController extends GetxController {
  final AddHouseService _addHouseService = AddHouseService();

  //welayat
  RxList<Village> villages = <Village>[].obs;
  var isLoadingVillages = true.obs;
  RxInt selectedVillageId = 0.obs;
//CAtegory
  RxList<Category> categories = <Category>[].obs;
  var isLoadingCategories = true.obs;
  RxInt selectedCategoryId = 0.obs;
//Subcategory
  RxList<SubCategory> subCategories = <SubCategory>[].obs;
  RxInt selectedSubCategoryId = 0.obs;

  //Subcategory
  RxList<SubCategory> subinCategories = <SubCategory>[].obs;
  RxInt selectedInSubCategoryId = 0.obs;
//Etrap
  RxList<Village> regions = <Village>[].obs;
  var isLoadingRegions = false.obs;
  RxInt selectedRegionId = 0.obs;
  // Specifications
  RxList<Specification> specifications = <Specification>[].obs;
  var isLoadingSpecifications = true.obs;
  RxList<int> selectedSpecificationIds = <int>[].obs;
  // Limits
  RxInt minRoom = 0.obs;
  RxInt maxRoom = 0.obs;
  RxInt minFloor = 0.obs;
  RxInt maxFloor = 0.obs;
  LimitData? limits;

  // Map
  final MapController mapController = MapController();
  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  RxList<Marker> markers = <Marker>[].obs;
  Rx<LatLng?> userLocation = Rx<LatLng?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    _determinePosition();
    _fetchLimits(); // Call to fetch limits
    fetchSpecifications(); // Call to fetch specifications
    fetchRemontOptions(); // Call to fetch remont options
    fetchExtrainforms(); // Call to fetch extrainforms
  }

  Future<void> fetchSpecifications() async {
    try {
      isLoadingSpecifications.value = true;
      final fetchedSpecifications =
          await _addHouseService.fetchSpecifications();
      if (fetchedSpecifications.isNotEmpty) {
        specifications.value = fetchedSpecifications;
        for (var spec in fetchedSpecifications) {
          specificationCounts[spec.id] = 0.obs;
        }
      }
    } finally {
      isLoadingSpecifications.value = false;
    }
  }

  Future<void> fetchRemontOptions() async {
    try {
      isLoadingRemontOptions.value = true;
      final fetchedRemontOptions = await _addHouseService.fetchRemontOptions();
      if (fetchedRemontOptions.isNotEmpty) {
        remontOptions.value = fetchedRemontOptions;
      }
    } finally {
      isLoadingRemontOptions.value = false;
    }
  }

  Future<void> fetchExtrainforms() async {
    try {
      isLoadingExtrainforms.value = true;
      final fetchedExtrainforms = await _addHouseService.fetchExtrainforms();
      if (fetchedExtrainforms.isNotEmpty) {
        extrainforms.value = fetchedExtrainforms;
      }
    } finally {
      isLoadingExtrainforms.value = false;
    }
  }

  Future<void> _fetchLimits() async {
    limits = await _addHouseService.fetchLimits();
    if (limits != null) {
      minRoom.value = limits!.minRoom;
      maxRoom.value = limits!.maxRoom;
      minFloor.value = limits!.minFloor;
      maxFloor.value = limits!.maxFloor;
      print(
          'API Limits: Min Room: ${minRoom.value}, Max Room: ${maxRoom.value}, Min Floor: ${minFloor.value}, Max Floor: ${maxFloor.value}');
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      CustomWidgets.showSnackBar(
          'Error', 'Location services are disabled.', Colors.red);
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CustomWidgets.showSnackBar(
            'Error', 'Location permissions are denied', Colors.red);
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      CustomWidgets.showSnackBar(
          'Error',
          'Location permissions are permanently denied, we cannot request permissions.',
          Colors.red);
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);
      userLocation.value = latLng;
      selectedLocation.value = latLng;
      mapController.move(latLng, 15.0);
      markers.clear();
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: latLng,
          child: Icon(
            IconlyBold.location,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
    } catch (e) {
      CustomWidgets.showSnackBar(
          'Error', 'Could not get current location.', Colors.red);
      print(e);
    }
  }

  void onMapReadyCallback() {
    _determinePosition();
  }

  void openFullScreenMap() {
    Get.to(() => FullScreenMapView(
          initialLocation: userLocation.value,
          onLocationSelected: (latlng) {
            selectedLocation.value = latlng;
            mapController.move(latlng, 15.0);
            markers.clear();
            markers.add(
              Marker(
                width: 80.0,
                height: 80.0,
                point: latlng,
                child: Icon(
                  IconlyBold.location,
                  color: Colors.red,
                  size: 40.0,
                ),
              ),
            );
            Get.back();
          },
          userCurrentLocation: userLocation.value,
        ));
  }

  // DİĞER DEĞİŞKENLER...
  var isEditMode = false.obs;
  var selectedSaleTypeIndex = 0.obs;
  Future<void> fetchInitialData() async {
    try {
      isLoadingVillages.value = true;
      final fetchedVillages = await _addHouseService.fetchVillages();
      if (fetchedVillages.isNotEmpty) {
        villages.value = fetchedVillages;
        selectVillage(villages.first.id);
      }
    } finally {
      isLoadingVillages.value = false;
    }
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;
      final fetchedCategories = await _addHouseService.fetchCategories();
      if (fetchedCategories.isNotEmpty) {
        categories.value = fetchedCategories;
        selectCategory(categories.first.id);
      }
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchRegions(int villageId) async {
    try {
      isLoadingRegions.value = true;
      regions.clear();
      selectedRegionId.value = 0;
      final fetchedRegions = await _addHouseService.fetchRegions(villageId);
      if (fetchedRegions.isNotEmpty) {
        regions.value = fetchedRegions;
        selectRegion(regions.first.id);
      }
    } finally {
      isLoadingRegions.value = false;
    }
  }

  void selectVillage(int villageId) {
    selectedVillageId.value = villageId;
    final selectedName = villages.firstWhere((v) => v.id == villageId).name;
    print('Seçilen şäher: ${selectedName ?? "Ady ýok"}');
    fetchRegions(villageId);
  }

  void selectRegion(int regionId) {
    selectedRegionId.value = regionId;
    final selectedName = regions.firstWhere((v) => v.id == regionId).name;
    print('Seçilen etrap: ${selectedName ?? "Ady ýok"}');
  }

  void selectCategory(int categoryId) {
    selectedCategoryId.value = categoryId;
    final selectedCategory = categories.firstWhere((c) => c.id == categoryId);
    subCategories.value = selectedCategory.subcategory;
    if (subCategories.isNotEmpty) {
      selectSubCategory(subCategories.first.id!);
    } else {
      selectedSubCategoryId.value = 0;
    }
    final selectedName = selectedCategory.name;
    print('Seçilen kategori: ${selectedName ?? "Ady ýok"}');
  }

  void selectSubCategory(int subCategoryId) {
    selectedSubCategoryId.value = subCategoryId;
    final selectedSubCategory =
        subCategories.firstWhere((sc) => sc.id == subCategoryId);
    subinCategories.value = selectedSubCategory.subin ?? [];
    if (subinCategories.isNotEmpty) {
      selectSubIncategory(subinCategories.first.id!);
    } else {
      selectedInSubCategoryId.value = 0;
    }
    final selectedName = selectedSubCategory.name;
    print('Seçilen alt kategori: ${selectedName ?? "Ady ýok"}');
  }

  void selectSubIncategory(int subInCategoryId) {
    selectedInSubCategoryId.value = subInCategoryId;
    final selectedName =
        subinCategories.firstWhere((sic) => sic.id == subInCategoryId).name;
    print('Seçilen alt kategori içi: ${selectedName ?? "Ady ýok"}');
  }

  // Seçimler
  var selectedCityIndex = 0.obs;
  var selectedBuildingFloor = 1.obs;
  var selectedRenovation = Rxn<String>();
  Rxn<int> selectedRenovationId = Rxn<int>();

  // Text Alanları
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  var totalFloorCount = 1.obs;
  final areaController = TextEditingController();
  final priceController = TextEditingController();
  final phoneController = TextEditingController();
  RxMap<int, RxInt> specificationCounts = <int, RxInt>{}.obs;
  // Oda Sayaçları
  var livingRoomCount = 0.obs;
  var guestRoomCount = 0.obs;
  var kitchenCount = 0.obs;
  var salonCount = 0.obs;
  var bathroomCount = 0.obs;
  var totalRoomCount = 1.obs;

  // Resimler
  var images = <XFile>[].obs;
  final ImagePicker _picker = ImagePicker();

  // --- SABİT VERİLER (Normalde Backend'den gelir) ---
  RxList<RemontOption> remontOptions = <RemontOption>[].obs;
  var isLoadingRemontOptions = true.obs;

  // Extrainforms
  RxList<Extrainform> extrainforms = <Extrainform>[].obs;
  var isLoadingExtrainforms = true.obs;

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
  void selectBuildingFloor(int floor) {
    if (maxFloor.value > 0 && floor > maxFloor.value) {
      return;
    }
    if (minFloor.value > 0 && floor < minFloor.value) {
      return;
    }
    selectedBuildingFloor.value = floor;
  }

  void selectRenovation(String? value) => selectedRenovation.value = value;

  // Oda sayısını değiştiren genel fonksiyon
  void changeSpecificationCount(int specificationId, int change) {
    if (specificationCounts.containsKey(specificationId)) {
      final currentCount = specificationCounts[specificationId]!.value;
      if (currentCount + change >= 0) {
        specificationCounts[specificationId]!.value += change;
      }
    }
  }

  // Oda sayısını değiştiren genel fonksiyon
  void changeRoomCount(RxInt counter, int change) {
    if (counter == totalRoomCount) {
      if (maxRoom.value > 0 && counter.value + change > maxRoom.value) {
        return;
      }
      if (minRoom.value > 0 && counter.value + change < minRoom.value) {
        return;
      }
    }
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
            Obx(() {
              if (isLoadingRemontOptions.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (remontOptions.isEmpty) {
                return const Center(
                    child: Text('Remont seçenekleri bulunamadı'));
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: remontOptions.length,
                itemBuilder: (context, index) {
                  final option = remontOptions[index];
                  return Obx(() => RadioListTile<int>(
                        title: Text(option.name),
                        value: option.id,
                        groupValue: selectedRenovationId.value,
                        onChanged: (value) {
                          selectedRenovationId.value = value;
                          selectedRenovation.value = option.name;
                        },
                      ));
                },
              );
            }),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Get.back(), // Modal'ı kapat
                child: const Text('TASSYKLA'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
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
            Obx(() {
              if (isLoadingExtrainforms.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (extrainforms.isEmpty) {
                return const Center(child: Text('Ek bilgiler bulunamadı'));
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: extrainforms.length,
                  itemBuilder: (context, index) {
                    final extrainform = extrainforms[index];
                    return Obx(() => SwitchListTile(
                          title: Text(extrainform.name ?? ''),
                          // secondary: extrainform.img != null ? Image.network(extrainform.img!) : null, // Optional: display image if available
                          value: extrainform.isSelected.value,
                          onChanged: (bool value) {
                            extrainform.isSelected.value = value;
                          },
                        ));
                  },
                ),
              );
            }),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('ÝAP'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
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
        content:
            const Text('Siz hakykatdanam bu bildirişi goşmak isleýärsiňizmi?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Goýbolsun')),
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
            Text('Tassyklanýar...',
                style: TextStyle(
                    color: Colors.white, decoration: TextDecoration.none)),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    List<String> base64Images = [];
    for (XFile imageFile in images) {
      List<int> imageBytes = await imageFile.readAsBytes();
      base64Images.add(base64Encode(imageBytes));
    }

    Map<String, dynamic> payload = {
      "name":
          "${totalRoomCount.value} Otag, ${areaController.text} M2 , etaz ${selectedBuildingFloor.value} / ${totalFloorCount.value}",
      "address":
          "${villages.firstWhere((v) => v.id == selectedVillageId.value, orElse: () => Village(id: 0, nameTm: '')).name ?? ''}, ${regions.firstWhere((r) => r.id == selectedRegionId.value, orElse: () => Village(id: 0, nameTm: '')).name ?? ''}",
      "description": descriptionController.text,
      "village_id": selectedVillageId.value.toString(),
      "totalfloorcount": totalFloorCount.value,
      "floorcount": selectedBuildingFloor.value,
      "room_count": totalRoomCount.value,
      "price": double.tryParse(priceController.text) ?? 0.0,
      "square": double.tryParse(areaController.text) ?? 0.0,
      "created": DateTime.now()
          .toIso8601String()
          .substring(0, 19)
          .replaceAll('T', '-'),
      "lat": selectedLocation.value?.latitude.toString() ?? "0.0",
      "long": selectedLocation.value?.longitude.toString() ?? "0.0",
      "category_id": selectedCategoryId.value,
      "subcategory_id": selectedSubCategoryId.value,
      "region_id": selectedRegionId.value,
      "phone_number": phoneController.text,
      "sphere": [1, 2],
      "remont": selectedRenovationId.value != null
          ? [selectedRenovationId.value!]
          : [],
      "specification": specificationCounts.entries
          .where((entry) => entry.value.value > 0)
          .map((entry) => {"id": entry.key, "count": entry.value.value})
          .toList(),
      "extrainform": extrainforms
          .where((e) => e.isSelected.value)
          .map((e) => e.id)
          .toList(),
      "img": base64Images,
    };

    final bool success = await _addHouseService.createProperty(payload);

    Get.back();

    if (success) {
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text('Üstünlikli amala aşyryldy',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                  'Siziň bildirişiňiz saklanyldy. Moderasiýa edilenden soň, bildiriş saýta ýerleşdiriler.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14)),
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
    } else {
      Get.dialog(
        AlertDialog(
          title: const Text('Hata'),
          content: const Text('Bildiriş iberilende bir ýalňyşlyk ýüze çykdy.'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('ÝAP')),
          ],
        ),
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    areaController.dispose();
    priceController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
