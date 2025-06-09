import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';
import '../../domain/entities/report.dart'; 
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; 
import 'package:http/http.dart' as http; 

class ReportDetailDialog extends StatefulWidget {
  final Report report;
  final Color primaryColor = const Color(0xFF1565C0);
  final Color secondaryColor = const Color(0xFF42A5F5);
  final Color accentColor = const Color(0xFFE3F2FD);
  final Color textColor = const Color(0xFF333333);
  final Color lightTextColor = const Color(0xFF666666);

  const ReportDetailDialog({super.key, required this.report});

  @override
  State<ReportDetailDialog> createState() => _ReportDetailDialogState();
}

class _ReportDetailDialogState extends State<ReportDetailDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper function to fetch image bytes from URL
  Future<Uint8List?> _getImageBytesFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      debugPrint('Failed to load image from $url: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error fetching image from $url: $e');
      return null;
    }
  }

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
                child: TabBarView(
                  // Use TabBarView to switch content
                  controller: _tabController,
                  children: [
                    _buildStoreListTab(),
                    _buildGeotaggedImagesTab(),
                    _buildSummaryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreListTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('01', 'STORE LIST'),
          const SizedBox(height: 16),
          if (widget.report.stores.isEmpty)
            _buildEmptyState('No stores available for this campaign')
          else
            ..._buildStoreSections(),
        ],
      ),
    );
  }

  Widget _buildGeotaggedImagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('02', 'GEOTAGGED IMAGES'),
          const SizedBox(height: 16),
          _buildImageGallery(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('03', 'SUMMARY'),
          const SizedBox(height: 16),
          _buildSummaryMetrics(),
          const SizedBox(height: 32),
          _buildThankYou(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: widget.accentColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _tabController,
              labelColor: widget.primaryColor,
              unselectedLabelColor: widget.lightTextColor,
              indicatorColor: widget.primaryColor,
              tabs: const [
                Tab(text: 'STORES'),
                Tab(text: 'IMAGES'),
                Tab(text: 'SUMMARY'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.picture_as_pdf, color: widget.primaryColor),
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
      final fontData =
          await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      debugPrint('Error loading NotoSans-Regular.ttf: $e');
      return pw.Font.helvetica();
    }
  }

  Future<pw.Font> _loadBoldFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      debugPrint('Error loading NotoSans-Bold.ttf: $e');
      return pw.Font.helveticaBold();
    }
  }

  Future<void> _generateAndSharePdf() async {
    try {
      final regularFont = await _loadFont();
      final boldFont = await _loadBoldFont();

      final pdf = pw.Document();

      // Collect all images with their metadata for PDF
      final List<Map<String, dynamic>> allPdfImagesData = [];
      for (final store in widget.report.stores) {
        if (store.imageUrl != null && store.imageUrl!.isNotEmpty) {
          allPdfImagesData.add({
            'url': store.imageUrl!,
            'caption': '${store.name} - Storefront',
            'timestamp': '', // Store images might not have timestamps
          });
        }
        for (final till in store.tills) {
          for (final tillImage in till.images ?? []) {
            // Use null-aware operator
            allPdfImagesData.add({
              'url': tillImage.imageUrl,
              'caption': '${store.name} - Till ${till.number}',
              'timestamp': _formatDateTime(tillImage.timestamp),
            });
          }
        }
      }

      // Prepare image widgets for PDF by downloading bytes
      final List<pw.Widget> pdfImageWidgets = [];
      for (final imgData in allPdfImagesData) {
        final imageUrl = imgData['url'] as String;
        final caption = imgData['caption'] as String;
        final timestamp = imgData['timestamp'] as String;

        final Uint8List? imageBytes = await _getImageBytesFromUrl(imageUrl);
        if (imageBytes != null) {
          pdfImageWidgets.add(
            pw.Column(
              children: [
                pw.Expanded(
                  child: pw.Image(pw.MemoryImage(
                      imageBytes)), // Use pw.Image with pw.MemoryImage
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  caption,
                  style: pw.TextStyle(fontSize: 8, font: regularFont),
                  textAlign: pw.TextAlign.center,
                ),
                if (timestamp.isNotEmpty)
                  pw.Text(
                    timestamp,
                    style: pw.TextStyle(
                      fontSize: 7,
                      font: regularFont,
                      color: PdfColors.grey,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
              ],
            ),
          );
        } else {
          // Add a placeholder or an error message in the PDF for failed images
          pdfImageWidgets.add(
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Text('Image failed to load: $caption',
                  style: pw.TextStyle(
                      fontSize: 8, font: regularFont, color: PdfColors.red)),
            ),
          );
        }
      }

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
                          widget.report.campaign.name,
                          style: pw.TextStyle(
                            fontSize: 18,
                            font: regularFont,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      'Generated: ${_formatDateTime(widget.report.generatedAt)}',
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
              if (widget.report.stores.isEmpty)
                pw.Text('No stores available for this campaign',
                    style: pw.TextStyle(font: regularFont))
              else
                ...widget.report.stores.map((store) => pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 20),
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(8)),
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
                                  padding: const pw.EdgeInsets.only(
                                      left: 16, bottom: 4),
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

              // Geotagged Images Section
              pw.Text(
                '02 - GEOTAGGED IMAGES',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                  color: PdfColors.blue,
                ),
              ),
              pw.SizedBox(height: 15),
              if (pdfImageWidgets.isEmpty) // Check the prepared list
                pw.Text('No geotagged images available.',
                    style: pw.TextStyle(font: regularFont))
              else
                pw.GridView(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: pdfImageWidgets, // Use the prepared list of widgets
                ),

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
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    _buildPdfMetricRow(
                        'Total Stores',
                        widget.report.metrics.totalStores.toString(),
                        regularFont),
                    pw.SizedBox(height: 8),
                    _buildPdfMetricRow(
                        'Total Tills',
                        widget.report.metrics.totalTills.toString(),
                        regularFont),
                    pw.SizedBox(height: 8),
                    _buildPdfMetricRow(
                        'Occupied Tills',
                        widget.report.metrics.occupiedTills.toString(),
                        regularFont),
                    pw.SizedBox(height: 8),
                    _buildPdfMetricRow(
                        'Occupancy Rate',
                        '${widget.report.metrics.occupancyRate.toStringAsFixed(1)}%',
                        regularFont),
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

      final Uint8List bytes = await pdf.save();
      final filename =
          '${widget.report.campaign.name}_report_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        _downloadFileWeb(bytes, filename);
      } else {
        await _sharePdfMobile(bytes, filename);
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

  Future<void> _sharePdfMobile(Uint8List bytes, String filename) async {
    try {
      await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (e) {
      debugPrint('Error sharing PDF on mobile: $e');
      // Fallback to saving if sharing fails
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: widget.primaryColor,
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
                  color: widget.primaryColor,
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
                  widget.report.campaign.name,
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

  Widget _buildSectionTitle(String number, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: widget.primaryColor,
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
            color: widget.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStoreSections() {
    return widget.report.stores.map((store) {
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
                          color: widget.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Site #${store.siteNumber} • ${store.region}',
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (store.imageUrl != null && store.imageUrl!.isNotEmpty)
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
                  color: widget.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    store.tills.map((till) => _buildTillItem(till)).toList(),
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
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(Icons.broken_image, color: Colors.grey.shade400),
              ),
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
                    color: widget.textColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: till.isOccupied
                        ? Colors.orange.shade50
                        : Colors.green.shade50,
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
            if (till.images?.isNotEmpty == true) ...[
              // Null-safe check
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: till.images!
                      .map((img) => _buildImageThumbnail(img.imageUrl))
                      .toList(),
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
    // Structure to hold image data with associated store/till info
    final List<Map<String, dynamic>> allImagesWithMetadata = [];

    for (final store in widget.report.stores) {
      if (store.imageUrl != null && store.imageUrl!.isNotEmpty) {
        allImagesWithMetadata.add({
          'url': store.imageUrl!,
          'storeName': store.name,
          'tillNumber': null, // Store image, no till number
          'timestamp': null, // Store image, no specific timestamp
        });
      }
      for (final till in store.tills) {
        for (final tillImage in till.images ?? []) {
          // Use null-aware operator
          allImagesWithMetadata.add({
            'url': tillImage.imageUrl,
            'storeName': store.name,
            'tillNumber': till.number,
            'timestamp': tillImage.timestamp,
          });
        }
      }
    }

    if (allImagesWithMetadata.isEmpty) {
      return _buildEmptyState('No geotagged images available.');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Changed to 2 for better readability of metadata
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8, // Adjusted for more content below image
      ),
      itemCount: allImagesWithMetadata.length,
      itemBuilder: (context, index) {
        final imgData = allImagesWithMetadata[index];
        final imageUrl = imgData['url'] as String;
        final storeName = imgData['storeName'] as String;
        final tillNumber = imgData['tillNumber'] as int?;
        final timestamp = imgData['timestamp'] as DateTime?;

        return GestureDetector(
          onTap: () => _showFullScreenImage(context, imageUrl),
          child: _buildImageCard(
            imageUrl,
            storeName,
            tillNumber,
            timestamp,
          ),
        );
      },
    );
  }

  Widget _buildImageCard(
      String imageUrl, String storeName, int? tillNumber, DateTime? timestamp) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.broken_image,
                      color: Colors.grey.shade400, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: widget.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tillNumber != null)
                  Text(
                    'Till: $tillNumber',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.lightTextColor,
                    ),
                  ),
                if (timestamp != null)
                  Text(
                    _formatDateTime(timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 100,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetrics() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.accentColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildMetricRow('Total Stores', widget.report.metrics.totalStores),
          const Divider(height: 20, color: Colors.grey),
          _buildMetricRow('Total Tills', widget.report.metrics.totalTills),
          const Divider(height: 20, color: Colors.grey),
          _buildMetricRow(
              'Occupied Tills', widget.report.metrics.occupiedTills),
          const Divider(height: 20, color: Colors.grey),
          _buildMetricRow('Occupancy Rate', widget.report.metrics.occupancyRate,
              isPercentage: true),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, dynamic value,
      {bool isPercentage = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.lightTextColor,
            ),
          ),
        ),
        Text(
          isPercentage ? '${value.toStringAsFixed(1)}%' : value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.primaryColor,
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
            color: widget.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'For using our campaign management system',
          style: TextStyle(
            color: widget.lightTextColor,
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
                color: widget.lightTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
