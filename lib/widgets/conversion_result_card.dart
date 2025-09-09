import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../services/currency_service.dart';

class ConversionResultCard extends StatelessWidget {
  final CurrencyProvider provider;

  const ConversionResultCard({
    super.key,
    required this.provider,
  });

  // Format number based on its value
  String _formatNumber(double value) {
    if (value >= 1) return value.toStringAsFixed(2);
    if (value >= 0.01) return value.toStringAsFixed(4);
    return value.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBaseUSD = provider.baseCurrency == 'USD';
    final rate = provider.rates[provider.targetCurrency] ?? 0;
    final inverseRate = rate != 0 ? 1 / rate : 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conversion Result',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => provider.fetchRates(),
                  tooltip: 'Refresh rates',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Main conversion
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '${_formatNumber(provider.amount)} ${provider.baseCurrency}',
                    style: theme.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.arrow_forward, size: 20),
                ),
                Expanded(
                  child: Text(
                    '${_formatNumber(provider.convertedAmount)} ${provider.targetCurrency}',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Rate display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 ${provider.baseCurrency} = ${_formatNumber(rate.toDouble())} ${provider.targetCurrency}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '1 ${provider.targetCurrency} = ${_formatNumber(inverseRate.toDouble())} ${provider.baseCurrency}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
