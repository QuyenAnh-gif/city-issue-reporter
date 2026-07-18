import 'package:flutter/material.dart';
import 'package:do_an/Theme/theme.dart'; // Đảm bảo đường dẫn này đúng
import 'package:do_an/Screens/report_sheet.dart';

class ReportButton extends StatelessWidget {
  const ReportButton({super.key});

  void _showReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ReportSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
    
      onTap: () => _showReportSheet(context), 
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColorLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.6),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.report_problem_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}