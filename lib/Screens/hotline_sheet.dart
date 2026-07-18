import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Hotline {
  final String name;
  final String number;
  final IconData icon;
  final Color color;

  Hotline(
      {required this.name,
      required this.number,
      required this.icon,
      required this.color});
}

class HotlineSheet extends StatelessWidget {
  HotlineSheet({super.key});

  final List<Hotline> _hotlines = [
    Hotline(
        name: 'Cảnh sát Phản ứng nhanh',
        number: '0902222222',
        icon: Icons.local_police_rounded,
        color: Colors.blue),
    Hotline(
        name: 'Cứu hỏa / Cháy nổ',
        number: '0281234567',
        icon: Icons.fire_truck_rounded,
        color: Colors.red),
    Hotline(
        name: 'Cấp cứu Y tế',
        number: '0191234567',
        icon: Icons.medical_services_rounded,
        color: Colors.green),
    Hotline(
        name: 'Công ty Điện lực TP.HCM',
        number: '1900545454',
        icon: Icons.electric_bolt_rounded,
        color: Colors.orange),
    Hotline(
        name: 'Công ty Cấp thoát nước',
        number: '19001010',
        icon: Icons.water_drop_rounded,
        color: Colors.cyan),
    Hotline(
        name: 'Công ty Xử lý rác thải',
        number: '19001234',
        icon: Icons.delete_rounded,
        color: Colors.brown),
    Hotline(
        name: 'Phòng Liên lạc CSGT',
        number: '19001567',
        icon: Icons.traffic_rounded,
        color: Colors.purple),
  ];

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Không thể mở trình gọi điện trên thiết bị này')),
          );
        }
      }
    } catch (e) {
      debugPrint('Lỗi gọi điện: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text('Đường dây nóng hỗ trợ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Chỉ gọi trong các trường hợp thật sự khẩn cấp',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _hotlines.length,
            itemBuilder: (context, index) {
              final hotline = _hotlines[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hotline.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(hotline.icon, color: hotline.color),
                ),
                title: Text(hotline.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(hotline.number,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54)),
                trailing: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(context, hotline.number),
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Gọi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hotline.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
