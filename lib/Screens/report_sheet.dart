import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';
import 'package:do_an/Theme/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:do_an/Models/report_model.dart';
import 'package:do_an/Stores/report_store.dart';
import 'package:do_an/Stores/auth_store.dart';
import 'package:do_an/Services/location_service.dart';

class IncidentType {
  final IconData icon;
  final String label;
  final Color color;
  const IncidentType(
      {required this.icon, required this.label, required this.color});
}

class ReportSheet extends StatefulWidget {
  const ReportSheet({super.key});

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  int _selected = -1;
  bool _isSubmitting = false;
  bool _isLoadingLocation = true;

  LatLng _selectedLocation = const LatLng(10.7769, 106.6953);

  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  static const List<IncidentType> _types = [
    IncidentType(
        icon: Icons.edit_road,
        label: 'Ổ gà/Hỏng đường',
        color: AppTheme.trafficRed),
    IncidentType(
        icon: Icons.delete_outline_rounded,
        label: 'Rác thải',
        color: AppTheme.trafficGreen),
    IncidentType(
        icon: Icons.lightbulb_outline,
        label: 'Đèn đường',
        color: AppTheme.trafficYellow),
    IncidentType(
        icon: Icons.water_drop_outlined,
        label: 'Cống/Ngập',
        color: AppTheme.trafficBlue),
    IncidentType(
        icon: Icons.electric_bolt_outlined,
        label: 'Điện/Cáp',
        color: AppTheme.trafficOrange),
    IncidentType(
        icon: Icons.more_horiz_rounded,
        label: 'Khác',
        color: AppTheme.trafficPurple),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final location = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _selectedLocation = LatLng(location.latitude, location.longitude);
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) setState(() => _images.add(photo));
    } catch (e) {
      debugPrint('Lỗi camera: $e');
    }
  }

  // --- HÀM MỚI THÊM: CHỌN NGUỒN ẢNH ---
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading:
                    const Icon(Icons.camera_alt_rounded, color: Colors.blue),
                title: const Text('Chụp ảnh trực tiếp'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePicture(); // Gọi lại hàm chụp ảnh cũ của bạn
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: Colors.green),
                title: const Text('Chọn ảnh từ thư viện'),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    // Mở thư viện cho chọn nhiều ảnh
                    final List<XFile> pickedFiles =
                        await _picker.pickMultiImage(imageQuality: 80);
                    if (pickedFiles.isNotEmpty) {
                      setState(() => _images.addAll(pickedFiles));
                    }
                  } catch (e) {
                    debugPrint('Lỗi chọn ảnh: $e');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) => setState(() => _images.removeAt(index));

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => _LocationPickerScreen(
          initialLocation: _selectedLocation,
        ),
      ),
    );
    if (result != null) {
      setState(() => _selectedLocation = result);
    }
  }

  Future<void> _submitReport() async {
    if (_selected < 0) return;
    setState(() => _isSubmitting = true);

    final type = _types[_selected];
    final userId = AuthStore().currentUser?.id ?? '';

    final report = ReportModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      typeLabel: type.label,
      typeIcon: type.icon,
      typeColor: type.color,
      description: _descriptionController.text.trim(),
      imagePaths: _images.map((x) => x.path).toList(),
      createdAt: DateTime.now(),
      location: _selectedLocation,
    );

    await ReportStore().addReport(report);
    await AuthStore().addPoints(10);

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Báo cáo "${type.label}" đã được gửi! +10 điểm'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppTheme.radiusSheet)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 16),
            const Text('Báo cáo sự cố đô thị', style: AppTheme.sheetTitle),
            const SizedBox(height: 20),
            _buildGrid(),
            const SizedBox(height: 16),
            _buildLocationRow(),
            const SizedBox(height: 16),
            if (_images.isNotEmpty) ...[
              _buildImagePreviewList(),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Mô tả chi tiết sự cố...',
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildAddCameraButton(),
              ],
            ),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow() {
    return GestureDetector(
      onTap: _openLocationPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded,
                color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: _isLoadingLocation
                  ? Row(children: [
                      const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                      Text('Đang lấy vị trí...',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 13)),
                    ])
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vị trí báo cáo',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor)),
                        const SizedBox(height: 2),
                        Text(
                          '${_selectedLocation.latitude.toStringAsFixed(5)}, '
                          '${_selectedLocation.longitude.toStringAsFixed(5)}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_location_alt_rounded,
                      size: 14, color: AppTheme.primaryColor),
                  SizedBox(width: 4),
                  Text('Chỉnh',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreviewList() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (context, index) => Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 10, top: 8),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(_images[index].path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 2,
              top: 0,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCameraButton() => InkWell(
        onTap: () => _showImageSourceActionSheet(context),
        child: Container(
          height: 65,
          width: 65,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor, width: 1.5),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_rounded,
                  color: AppTheme.primaryColor, size: 20),
              SizedBox(height: 4),
              Text('Thêm',
                  style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );

  Widget _buildHandle() => Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
          color: Colors.grey[300], borderRadius: BorderRadius.circular(2)));

  Widget _buildGrid() => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2),
        itemCount: _types.length,
        itemBuilder: (_, i) => _IncidentCard(
            type: _types[i],
            isSelected: _selected == i,
            onTap: () => setState(() => _selected = i)),
      );

  Widget _buildSubmitButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (_selected >= 0 && !_isSubmitting && !_isLoadingLocation)
              ? _submitReport
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('GỬI BÁO CÁO & NHẬN ĐIỂM',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ),
      );
}

class _LocationPickerScreen extends StatefulWidget {
  final LatLng initialLocation;
  const _LocationPickerScreen({required this.initialLocation});

  @override
  State<_LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<_LocationPickerScreen> {
  late LatLng _pickedLocation;
  gmaps.GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vị trí sự cố',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, _pickedLocation),
            icon: const Icon(Icons.check_rounded, color: AppTheme.primaryColor),
            label: const Text('Xác nhận',
                style: TextStyle(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Stack(
        children: [
          gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(
              target: gmaps.LatLng(
                _pickedLocation.latitude,
                _pickedLocation.longitude,
              ),
              zoom: 16,
            ),
            onMapCreated: (c) => _mapController = c,
            onCameraMove: (position) {
              _pickedLocation = LatLng(
                position.target.latitude,
                position.target.longitude,
              );
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_rounded,
                    color: AppTheme.primaryColor, size: 48),
                SizedBox(height: 48),
              ],
            ),
          ),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kéo bản đồ để đặt ghim vào đúng vị trí sự cố',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppTheme.primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_pickedLocation.latitude.toStringAsFixed(6)}, '
                      '${_pickedLocation.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, _pickedLocation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Chọn',
                        style: TextStyle(fontWeight: FontWeight.w700)),
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

class _IncidentCard extends StatelessWidget {
  final IncidentType type;
  final bool isSelected;
  final VoidCallback onTap;
  const _IncidentCard(
      {required this.type, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? type.color.withOpacity(0.15) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? type.color : Colors.grey[200]!,
              width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon,
                color: isSelected ? type.color : Colors.grey[600], size: 24),
            const SizedBox(height: 4),
            Text(type.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isSelected ? type.color : Colors.grey[700],
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
