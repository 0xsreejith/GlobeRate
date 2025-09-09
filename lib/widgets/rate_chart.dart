import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/currency_provider.dart';

class RateChart extends StatelessWidget {
  final String baseCurrency;
  final String targetCurrency;
  final Map<DateTime, double> historicalRates;
  
  const RateChart({
    super.key,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.historicalRates,
  });

  @override
  Widget build(BuildContext context) {
    if (historicalRates.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = historicalRates.entries
        .map((entry) => FlSpot(
              entry.key.millisecondsSinceEpoch.toDouble(),
              entry.value,
            ))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    if (spots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$baseCurrency/$targetCurrency (7 days)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: _calculateInterval(spots),
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: spots.first.x,
                  maxX: spots.last.x,
                  minY: _getMinY(spots),
                  maxY: _getMaxY(spots),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMinY(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    double min = spots.first.y;
    for (var spot in spots) {
      if (spot.y < min) min = spot.y;
    }
    return min * 0.99; // Add a small margin
  }

  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 1;
    double max = spots.first.y;
    for (var spot in spots) {
      if (spot.y > max) max = spot.y;
    }
    return max * 1.01; // Add a small margin
  }

  double _calculateInterval(List<FlSpot> spots) {
    if (spots.length < 2) return 1;
    
    final minY = _getMinY(spots);
    final maxY = _getMaxY(spots);
    final range = maxY - minY;
    
    if (range <= 0) return 1;
    
    // Try to have about 5 lines on the chart
    final rawInterval = range / 5;
    
    // Round to nearest 0.1, 0.2, 0.5, 1, 2, 5, 10, etc.
    final magnitude = (rawInterval == 0) ? 1 : pow(10, (log(rawInterval) / log(10)).floor()).toDouble();
    var normalized = rawInterval / magnitude;
    
    if (normalized > 0.5) {
      normalized = 1.0;
    } else if (normalized > 0.2) {
      normalized = 0.5;
    } else if (normalized > 0.1) {
      normalized = 0.2;
    } else {
      normalized = 0.1;
    }
    
    return normalized * magnitude;
  }
}
