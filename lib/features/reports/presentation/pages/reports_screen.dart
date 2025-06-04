import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/pages/generate_tab.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/pages/history_tab.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ReportsBloc>().add(LoadReports());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Generate Report', icon: Icon(Icons.add_chart)),
            Tab(text: 'Reports History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
           GenerateReportTab(),
           ReportsHistoryTab(),
        ],
      ),
    );
  }
}
