import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:panorama/panorama.dart';
import 'package:http/http.dart' as http;

class PanoramaViewPage extends StatefulWidget {
  final List<VrModel> vrData;

  const PanoramaViewPage({super.key, required this.vrData});

  @override
  State<PanoramaViewPage> createState() => _PanoramaViewPageState();
}

class _PanoramaViewPageState extends State<PanoramaViewPage> {
  VrModel? _currentScene;
  bool _isImageLoading = true;
  ImageProvider? _currentImageProvider;
  double _downloadProgress = 0.0;
  int _downloadedBytes = 0;
  int _totalBytes = 0;

  @override
  void initState() {
    super.initState();
    if (widget.vrData.isNotEmpty) {
      _currentScene = widget.vrData.first;
      _preloadImage();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _preloadImage() async {
    if (_currentScene == null) return;

    setState(() {
      _isImageLoading = true;
      _downloadProgress = 0.0;
      _downloadedBytes = 0;
      _totalBytes = 0;
    });

    try {
      final url = ApiConstants.imageURL + _currentScene!.imageUrl;
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();

      _totalBytes = response.contentLength ?? 0;
      final List<int> bytes = [];

      response.stream.listen(
        (List<int> chunk) {
          bytes.addAll(chunk);
          _downloadedBytes += chunk.length;

          if (mounted) {
            setState(() {
              _downloadProgress = _totalBytes > 0 ? _downloadedBytes / _totalBytes : 0.0;
            });
          }
        },
        onDone: () async {
          if (mounted) {
            // Create image provider from downloaded bytes
            _currentImageProvider = MemoryImage(Uint8List.fromList(bytes));

            // Wait 2 seconds after image is loaded before hiding loading
            await Future.delayed(const Duration(seconds: 2));

            if (mounted) {
              setState(() {
                _isImageLoading = false;
              });
            }
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isImageLoading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImageLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void _navigateToScene(String sceneName) async {
    final targetScene = widget.vrData.firstWhereOrNull(
      (scene) => scene.title == sceneName,
    );

    if (targetScene != null && targetScene.id != _currentScene?.id) {
      // Change scene and show loading
      if (mounted) {
        setState(() {
          _currentScene = targetScene;
          _isImageLoading = true;
        });
        _preloadImage();
      }
    }
  }

  List<Hotspot> _buildHotspots() {
    final List<Hotspot> hotspots = [];
    if (_currentScene == null) return hotspots;

    final List<Map<String, dynamic>> potentialHotspots = [
      {'title': _currentScene!.title0, 'lat': _currentScene!.lat0, 'long': _currentScene!.long0},
      {'title': _currentScene!.title1, 'lat': _currentScene!.lat1, 'long': _currentScene!.long1},
      {'title': _currentScene!.title2, 'lat': _currentScene!.lat2, 'long': _currentScene!.long2},
      {'title': _currentScene!.title3, 'lat': _currentScene!.lat3, 'long': _currentScene!.long3},
      {'title': _currentScene!.title4, 'lat': _currentScene!.lat4, 'long': _currentScene!.long4},
      {'title': _currentScene!.title5, 'lat': _currentScene!.lat5, 'long': _currentScene!.long5},
    ];

    for (var spot in potentialHotspots) {
      final String? title = spot['title'];
      final double? latitude = spot['lat'];
      final double? longitude = spot['long'];

      if (title != null && title.isNotEmpty && latitude != null && longitude != null) {
        hotspots.add(
          Hotspot(
            latitude: latitude,
            longitude: longitude,
            width: 120.0,
            height: 130.0,
            widget: HotspotButton(
              text: title,
              onPressed: () => _navigateToScene(title),
            ),
          ),
        );
      }
    }
    return hotspots;
  }

  @override
  Widget build(BuildContext context) {
    if (_currentScene == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'panorama_no_data'.tr,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _currentScene!.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          splashRadius: 24,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.2),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Panorama(
            animSpeed: 0.0,
            zoom: 0.5,
            minZoom: 0.5,
            maxZoom: 3.0,
            sensitivity: 2.0,
            sensorControl: SensorControl.None,
            hotspots: _buildHotspots(),
            child: Image(
              image: _currentImageProvider ??
                  CachedNetworkImageProvider(
                    ApiConstants.imageURL + _currentScene!.imageUrl,
                  ),
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    'panorama_image_load_error'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
          if (_isImageLoading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _downloadProgress > 0 ? _downloadProgress : null,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _totalBytes > 0 ? '${(_downloadedBytes / 1024 / 1024).toStringAsFixed(2)} MB / ${(_totalBytes / 1024 / 1024).toStringAsFixed(2)} MB' : 'panorama_loading'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_downloadProgress > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HotspotButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const HotspotButton({super.key, required this.text, required this.onPressed});

  @override
  State<HotspotButton> createState() => _HotspotButtonState();
}

class _HotspotButtonState extends State<HotspotButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the ripple effect (opacity only)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated pulse rings (opacity only, no size change to parent)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 60 + (_pulseAnimation.value * 30),
                      height: 60 + (_pulseAnimation.value * 30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6 * (1 - _pulseAnimation.value)),
                          width: 2,
                        ),
                      ),
                    );
                  },
                ),
                // Main button (fixed size, no animation)
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.meeting_room,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            constraints: const BoxConstraints(maxWidth: 100),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
