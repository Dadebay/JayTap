import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class FullScreenMapController extends GetxController {
  final mapController = MapController();
  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  RxDouble currentZoom = 15.0.obs; // Varsayılan zoom 15 olarak ayarlandı
  RxBool isLoadingLocation = false.obs;
  final Rx<LatLng?> userLocation = Rx(null);
  bool isMapReady = false;

  final Function(LatLng) onLocationSelectedCallback;
  final LatLng? initialLocation;
  final LatLng? userCurrentLocation;

  Rx<LatLng> currentPosition = LatLng(37.9601, 58.3261).obs;

  FullScreenMapController({
    required this.onLocationSelectedCallback,
    this.initialLocation,
    this.userCurrentLocation,
  });

  @override
  void onInit() {
    super.onInit();
    selectedLocation.value = initialLocation;
    if (userCurrentLocation != null) {
      userLocation.value = userCurrentLocation;
    }
  }

  @override
  void onReady() {
    super.onReady();
    isMapReady = true; // Harita hazır olduğunda bu true olacak
    // Otomatik konum aramasını kaldırdık
    print("Sayfa yüklendi, otomatik konum araması yapılmadı.");
    if (userLocation.value != null && isMapReady) {
      mapController.move(userLocation.value!, currentZoom.value);
    }
  }

  Future<void> findAndMoveToCurrentUserLocation() async {
    isLoadingLocation.value = true;
    try {
      await _determinePositionAndMove(moveToPosition: true);
      if (userLocation.value != null && isMapReady) {
        print(
            "Harita hareket ettiriliyor: Lat=${userLocation.value!.latitude}, Long=${userLocation.value!.longitude}");
        mapController.move(
            userLocation.value!, currentZoom.value); // Doğrudan hareket
        Future.delayed(const Duration(milliseconds: 100), () {
          mapController.move(userLocation.value!,
              currentZoom.value); // Küçük bir gecikme ile tekrar
        });
      }
    } catch (e) {
      print("Konum alma hatası: $e");
      Get.snackbar('Hata', 'Konum alınamadı: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<bool> _handleLocationPermission() async {
    print("Konum izni kontrol ediliyor...");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("GPS servisi durumu: $serviceEnabled");
    if (!serviceEnabled) {
      print("GPS kapalı. Servis durumu: $serviceEnabled");
      Get.dialog(
        AlertDialog(
          title: const Text('GPS Kapalı'),
          content: const Text('Lütfen konum servislerini etkinleştirin.'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Get.back(),
            ),
            TextButton(
              child: const Text('Ayarlar'),
              onPressed: () {
                Geolocator.openLocationSettings();
                Get.back();
              },
            ),
          ],
        ),
      );
      return false;
    }

    var status = await Permission.locationWhenInUse.status;
    print("İzin durumu: $status");
    if (status.isDenied) {
      print("Konum izni reddedildi, izin isteniyor...");
      status = await Permission.locationWhenInUse.request();
      print("İzin isteği sonucu: $status");
      if (status.isDenied) {
        print("İzin reddedildi. Durum: $status");
        Get.snackbar('İzin Hatası', 'Konum izni gerekli.');
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      print("İzin kalıcı olarak reddedildi. Durum: $status");
      Get.snackbar(
        'İzin Hatası',
        'Konum izni kalıcı olarak reddedildi, ayarlar üzerinden etkinleştirin.',
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: const Text('Ayarlar'),
        ),
      );
      return false;
    }

    print("Konum izni alındı. Durum: $status");
    return true;
  }

  Future<void> _determinePositionAndMove({required bool moveToPosition}) async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    Position? position;
    try {
      print("Cihazın ağ durumu kontrol ediliyor...");
      var connectivityResult = await (Connectivity().checkConnectivity());
      bool isConnected = connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi;
      print(
          "Ağ bağlantısı durumu (connectivity_plus): $isConnected, Durum: $connectivityResult");
      print("Yüksek doğrulukla konum alınıyor...");
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 15), // Zaman aşımını artırdık
      );
    } catch (e) {
      print("Yüksek doğruluk hatası: $e");
      try {
        print("Orta doğrulukla konum alınıyor...");
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
      } catch (e) {
        print("Orta doğruluk hatası: $e");
        try {
          print("Düşük doğrulukla konum alınıyor...");
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
        } catch (e) {
          print("Düşük doğruluk hatası: $e");
          Get.snackbar('Hata',
              'Konum alınamadı: $e. GPS veya internet bağlantısını kontrol edin.');
          return;
        }
      }
    }

    if (position != null) {
      final newLocation = LatLng(position.latitude, position.longitude);
      userLocation.value = newLocation;
      currentPosition.value = newLocation;
      print(
          "Konum bulundu: Lat=${position.latitude}, Long=${position.longitude}, Doğruluk: ${position.accuracy}");
      if (moveToPosition && isMapReady) {
        Future.delayed(const Duration(milliseconds: 300), () {
          // Gecikmeyi artırdık
          mapController.move(userLocation.value!, currentZoom.value);
        });
      }
    } else {
      print("Konum alınamadı, null döndü.");
      Get.snackbar('Hata', 'Konum alınamadı. Cihaz ayarlarını kontrol edin.');
    }
  }

  void onMapTap(TapPosition tapPosition, LatLng latLng) {
    selectedLocation.value = latLng;
    print('Seçilen Konum: Lat: ${latLng.latitude}, Long: ${latLng.longitude}');
    _showConfirmationBottomSheet(latLng);
  }

  void _showConfirmationBottomSheet(LatLng selectedLatLng) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'select_location'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    child: Text(
                      'no'.tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onLocationSelectedCallback(selectedLatLng);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    child: Text(
                      'yes'.tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
