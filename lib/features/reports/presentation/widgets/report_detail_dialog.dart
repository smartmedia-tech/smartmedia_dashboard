import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';
import '../../domain/entities/report.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // For web download

class ReportDetailDialog extends StatelessWidget {
  final Report report;
  final Color primaryColor = const Color(0xFF1565C0);
  final Color secondaryColor = const Color(0xFF42A5F5);
  final Color accentColor = const Color(0xFFE3F2FD);
  final Color textColor = const Color(0xFF333333);
  final Color lightTextColor = const Color(0xFF666666);

  const ReportDetailDialog({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              _buildTabBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('01', 'STORE LIST'),
                      const SizedBox(height: 16),
                      if (report.stores.isEmpty) 
                        _buildEmptyState('No stores available for this campaign')
                      else
                        ..._buildStoreSections(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('02', 'GEOTAGGED IMAGES'),
                      const SizedBox(height: 16),
                      _buildImageGallery(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('03', 'SUMMARY'),
                      const SizedBox(height: 16),
                      _buildSummaryMetrics(),
                      const SizedBox(height: 32),
                      _buildThankYou(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: accentColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          _buildTabButton('STORE LIST', 0),
          _buildTabButton('GEOTAGGED IMAGES', 1),
          _buildTabButton('SUMMARY', 2),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.share, color: primaryColor),
              tooltip: 'Export as PDF',
              onPressed: () => _generateAndSharePdf(),
            ),
          ),
        ],
      ),
    );
  }

  // Load custom font for Unicode support
  Future<pw.Font> _loadFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      // Fallback to a default font if custom font fails
      return pw.Font.helvetica();
    }
  }

  Future<pw.Font> _loadBoldFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      // Fallback to a default font if custom font fails
      return pw.Font.helveticaBold();
    }
  }

  Future<void> _generateAndSharePdf() async {
    try {
      // Load fonts
      final regularFont = await _loadFont();
      final boldFont = await _loadBoldFont();

      // Create PDF document
      final pdf = pw.Document();

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // PDF Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 20),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 2, color: PdfColors.blue),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CAMPAIGN REPORT',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            font: boldFont,
                            color: PdfColors.blue,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          report.campaign.name,
                          style: pw.TextStyle(
                            fontSize: 18,
                            font: regularFont,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Generated: ${DateTime.now().toString().split('.')[0]}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        font: regularFont,
                        color: PdfColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Store List Section
              pw.Text(
                '01 - STORE LIST',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                  color: PdfColors.blue,
                ),
              ),
              pw.SizedBox(height: 15),
              
              // Stores
              ...report.stores.map((store) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      store.name,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        font: boldFont,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Site #${store.siteNumber} • ${store.region}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: regularFont,
                        color: PdfColors.grey,
                      ),
                    ),
                    if (store.tills.isNotEmpty) ...[
                      pw.SizedBox(height: 12),
                      pw.Text(
                        'Tills (${store.tills.length})',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          font: boldFont,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      ...store.tills.map((till) => pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
                        child: pw.Text(
                          'Till ${till.number} - ${till.isOccupied ? "Occupied" : "Available"}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            font: regularFont,
                          ),
                        ),
                      )),
                    ],
                  ],
                ),
              )),
              
              pw.SizedBox(height: 30),
              
              // Summary Section
              pw.Text(
                '03 - SUMMARY',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                  color: PdfColors.blue,
                ),
              ),
              pw.SizedBox(height: 15),
              
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    _buildPdfMetricRow('Total Stores', report.metrics.totalStores.toString(), regularFont),
                    pw.SizedBox(height: 8),
                    _buildPdfMetricRow('Total Tills', report.metrics.totalTills.toString(), regularFont),
                    pw.SizedBox(height: 8),
                    _buildPdfMetricRow('Occupied Tills', report.metrics.occupiedTills.toString(), regularFont),
                    pw.SizedBox(height: 8),
                    _buildPdfMetricRow('Occupancy Rate', '${report.metrics.occupancyRate.toStringAsFixed(1)}%', regularFont),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 40),
              
              // Thank you section
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'THANK YOU',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        font: boldFont,
                        color: PdfColors.blue,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'For using our campaign management system',
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: regularFont,
                        color: PdfColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Generate and save PDF
      final Uint8List bytes = await pdf.save();
      final filename = '${report.campaign.name}_report_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        // Web-specific download
        _downloadFileWeb(bytes, filename);
      } else {
        // Mobile/Desktop sharing
        await _sharePdfMobile(bytes, filename);
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      // Handle error appropriately - maybe show a snackbar
    }
  }

  // Web download function
  void _downloadFileWeb(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  // Mobile sharing function
  Future<void> _sharePdfMobile(Uint8List bytes, String filename) async {
    try {
      await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (e) {
      // Fallback: Save to device storage
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: filename,
      );
    }
  }

  pw.Widget _buildPdfMetricRow(String label, String value, pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 12, font: font),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            font: font,
            color: PdfColors.blue,
          ),
        ),
      ],
    );
  }

  // Rest of your existing methods remain the same...
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'SM',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CAMPAIGN REPORT',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.campaign.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    return Container(
      width: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: index == 0 ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title,
          style: TextStyle(
            color: index == 0 ? primaryColor : lightTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String number, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStoreSections() {
    return report.stores.map((store) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Site #${store.siteNumber} • ${store.region}',
                        style: TextStyle(
                          fontSize: 13,
                          color: lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (store.imageUrl != null)
                  _buildResponsiveImage(store.imageUrl!),
              ],
            ),
            const SizedBox(height: 16),
            if (store.tills.isNotEmpty) ...[
              Text(
                'Tills (${store.tills.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: store.tills.map((till) => _buildTillItem(till)).toList(),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  Widget _buildResponsiveImage(String url) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < 600 ? 60.0 : 80.0;
        return Container(
          width: size,
          height: size,
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              url,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTillItem(Till till) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Till ${till.number}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: till.isOccupied ? Colors.orange.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: till.isOccupied ? Colors.orange : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    till.isOccupied ? 'Occupied' : 'Available',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: till.isOccupied ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            if (till.imageUrl != null || till.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (till.imageUrl != null)
                      _buildImageThumbnail(till.imageUrl!),
                    ...till.imageUrls.map((url) => _buildImageThumbnail(url)).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String url) {
    return Container(
      width: 100,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.broken_image, color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final allImages = <String>[];
    
    for (final store in report.stores) {
      if (store.imageUrl != null) allImages.add(store.imageUrl!);
      for (final till in store.tills) {
        if (till.imageUrl != null) allImages.add(till.imageUrl!);
        allImages.addAll(till.imageUrls);
      }
    }
    
    if (allImages.isEmpty) {
      return _buildEmptyState('No geotagged images available');
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: allImages.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(context, allImages[index]),
          child: _buildImageThumbnail(allImages[index]),
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryMetrics() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildMetricRow('Total Stores', report.metrics.totalStores),
          const Divider(height: 20, color: Colors.grey),
          _buildMetricRow('Total Tills', report.metrics.totalTills),
          const Divider(height: 20, color: Colors.grey),
          _buildMetricRow('Occupied Tills', report.metrics.occupiedTills),
          const Divider(height: 20, color: Colors.grey),
          _buildMetricRow('Occupancy Rate', report.metrics.occupancyRate,
              isPercentage: true),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, dynamic value, {bool isPercentage = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: lightTextColor,
            ),
          ),
        ),
        Text(
          isPercentage 
              ? '${value.toStringAsFixed(1)}%' 
              : value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildThankYou() {
    return Column(
      children: [
        const Divider(height: 40, color: Colors.grey),
        Text(
          'THANK YOU',
          style: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'For using our campaign management system',
          style: TextStyle(
            color: lightTextColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: lightTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}