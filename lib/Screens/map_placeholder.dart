import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:do_an/Stores/report_store.dart';
import 'package:do_an/Models/report_model.dart';
import 'package:do_an/Services/location_service.dart';

const String _kGoogleApiKey = 'AIzaSyAs9EkWptYFe53e9z2_d3sB_4-ZdnB56-w';

class MapPlaceholder extends StatefulWidget {
  final bool isHeatmapMode;

  const MapPlaceholder({super.key, this.isHeatmapMode = false});

  @override
  State<MapPlaceholder> createState() => _MapPlaceholderState();
}

class _MapPlaceholderState extends State<MapPlaceholder> {
  GoogleMapController? _mapController;
  final _store = ReportStore();
  final Map<MarkerId, Marker> _markers = {};
  final Set<Circle> _circles = {};

  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _loadLocationThenBuildMap();
  }

  @override
  void didUpdateWidget(covariant MapPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isHeatmapMode != widget.isHeatmapMode) {
      _buildMapLayers();
    }
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadLocationThenBuildMap() async {
    final location = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() => _currentLocation = location);
    }
  }

  void _onStoreChanged() {
    if (_mapController != null) _buildMapLayers();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _buildMapLayers();
  }

  void _buildMapLayers() {
    final newMarkers = <MarkerId, Marker>{};
    final newCircles = <Circle>{};

    if (widget.isHeatmapMode) {
      int circleIdCounter = 0;
      for (final report in _store.activeReports) {
        newCircles.add(
          Circle(
            circleId: CircleId('heatmap_outer_$circleIdCounter'),
            center: LatLng(report.location.latitude, report.location.longitude),
            radius: 80,
            fillColor: Colors.red.withOpacity(0.12),
            strokeWidth: 0,
          ),
        );
        newCircles.add(
          Circle(
            circleId: CircleId('heatmap_inner_$circleIdCounter'),
            center: LatLng(report.location.latitude, report.location.longitude),
            radius: 35,
            fillColor: Colors.orange.withOpacity(0.25),
            strokeWidth: 0,
          ),
        );
        circleIdCounter++;
      }
    } else {
      for (final report in _store.activeReports) {
        final markerId = MarkerId(report.id);
        newMarkers[markerId] = Marker(
          markerId: markerId,
          position: LatLng(report.location.latitude, report.location.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              _colorToHue(report.typeColor)),
          infoWindow: InfoWindow(title: report.typeLabel),
          onTap: () => _showReportPopup(report),
        );
      }
    }

    setState(() {
      _markers
        ..clear()
        ..addAll(newMarkers);
      _circles
        ..clear()
        ..addAll(newCircles);
    });
  }

  double _colorToHue(Color color) => HSVColor.fromColor(color).hue;

  void _showReportPopup(ReportModel report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ReportPopup(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentLocation == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang lấy vị trí...', style: TextStyle(fontSize: 14)),
          ],
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        zoom: 16,
      ),
      onMapCreated: _onMapCreated,
      markers: Set<Marker>.of(_markers.values),
      circles: _circles,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      mapType: MapType.normal,
    );
  }
}

class _ReportPopup extends StatefulWidget {
  final ReportModel report;
  const _ReportPopup({required this.report});

  @override
  State<_ReportPopup> createState() => _ReportPopupState();
}

class _ReportPopupState extends State<_ReportPopup> {
  String? _address;
  bool _loadingAddress = true;

  @override
  void initState() {
    super.didUpdateWidget(widget);
    _fetchAddressFromGoogle();
  }

  Future<void> _fetchAddressFromGoogle() async {
    final lat = widget.report.location.latitude;
    final lng = widget.report.location.longitude;

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$lat,$lng'
      '&language=vi'
      '&result_type=street_address|route|sublocality'
      '&key=$_kGoogleApiKey',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;
          if (results.isNotEmpty) {
            setState(() {
              _address = results[0]['formatted_address'] as String?;
              _loadingAddress = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Google Geocoding error: $e');
    }

    setState(() {
      _address =
          '${widget.report.location.latitude.toStringAsFixed(5)}, ${widget.report.location.longitude.toStringAsFixed(5)}';
      _loadingAddress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: report.typeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(report.typeIcon, color: report.typeColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.typeLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(_formatTime(report.createdAt),
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              _StatusChip(status: report.status),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 18, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: _loadingAddress
                    ? Row(children: [
                        const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 8),
                        Text('Đang tải địa chỉ...',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 13)),
                      ])
                    : Text(_address ?? '',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87, height: 1.4)),
              ),
            ],
          ),
          if (report.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes_rounded,
                    size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(report.description,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54, height: 1.4)),
                ),
              ],
            ),
          ],
          if (report.imagePaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: report.imagePaths.length,
                itemBuilder: (_, i) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(File(report.imagePaths[i])),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'resolved' => ('Đã xử lý', Colors.green),
      _ => ('Đang xảy ra', Colors.orange),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
