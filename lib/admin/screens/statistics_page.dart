import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api.dart';

const Color bgColor = Color(0xFFF2EDE6);
const Color secColor = Color(0xFFC9B29B);
const Color thirdColor = Color(0xFF9C6B3F);
const Color darkColor = Color(0xFF4A2C24);
const Color veryDarkColor = Color(0xFF2D1B15);

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});
  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int totalUsers = 0;
  int totalPosts = 0;
  List<Map<String, dynamic>> userStats = [];
  List<Map<String, dynamic>> postStats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => isLoading = true);
    final overview = await ApiService.adminGetOverview();
    final users = await ApiService.adminGetUserStats();
    final posts = await ApiService.adminGetPostStats();
    setState(() {
      totalUsers = overview['total_users'] ?? 0;
      totalPosts = overview['total_posts'] ?? 0;
      userStats = users;
      postStats = posts;
      isLoading = false;
    });
  }

  String _formatDay(String raw) {
    // "2026-04-24" → "24/04"
    final parts = raw.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: veryDarkColor),
        ),
        title: const Text(
          "Statistics",
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: veryDarkColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: veryDarkColor),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: darkColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  statCard("Total Users", totalUsers.toString(), Icons.group),
                  const SizedBox(height: 12),
                  statCard("Total Posts", totalPosts.toString(), Icons.article),
                  const SizedBox(height: 24),
                  sectionTitle("Users Overview"),
                  const SizedBox(height: 12),
                  userStats.isEmpty
                      ? const Center(child: Text('No user data available'))
                      : _buildLineChart(),
                  const SizedBox(height: 24),
                  sectionTitle("Posts Overview"),
                  const SizedBox(height: 12),
                  postStats.isEmpty
                      ? const Center(child: Text('No post data available'))
                      : _buildBarChart(),
                ],
              ),
            ),
    );
  }

  Widget statCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: thirdColor,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: veryDarkColor,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  color: veryDarkColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: veryDarkColor,
      ),
    ),
  );

  Widget _buildLineChart() {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black12),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < userStats.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatDay(userStats[index]['month'] ?? ''),
                        style: const TextStyle(fontSize: 9),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: thirdColor,
              barWidth: 3,
              spots: List.generate(
                userStats.length,
                (index) => FlSpot(
                  index.toDouble(),
                  (userStats[index]['count'] ?? 0).toDouble(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black12),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < postStats.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatDay(postStats[index]['month'] ?? ''),
                        style: const TextStyle(fontSize: 9),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: List.generate(
            postStats.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (postStats[index]['count'] ?? 0).toDouble(),
                  color: thirdColor,
                  width: 14,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
