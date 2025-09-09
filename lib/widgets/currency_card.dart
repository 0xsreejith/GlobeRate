import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../services/currency_service.dart';

class CurrencyCard extends StatelessWidget {
  final bool isBaseCurrency;

  const CurrencyCard({
    Key? key,
    required this.isBaseCurrency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, provider, _) {
        final currencyCode = isBaseCurrency
            ? provider.baseCurrency
            : provider.targetCurrency;
        final amount = isBaseCurrency
            ? provider.amount
            : provider.convertedAmount;
        final currencyName = CurrencyService.getCurrencyName(currencyCode);

        return Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: InkWell(
            onTap: () => _showCurrencyPicker(context, isBaseCurrency, provider),
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Text(
                      _getFlagEmoji(currencyCode),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currencyCode,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          currencyName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amount.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCurrencyPicker(
    BuildContext context,
    bool isBaseCurrency,
    CurrencyProvider provider,
  ) {
    final currentCurrency = isBaseCurrency
        ? provider.baseCurrency
        : provider.targetCurrency;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select ${isBaseCurrency ? 'Base' : 'Target'} Currency'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: CurrencyService.availableCurrencies.length,
            itemBuilder: (context, index) {
              final currency = CurrencyService.availableCurrencies[index];
              return ListTile(
                title: Text(currency),
                subtitle: Text(CurrencyService.getCurrencyName(currency)),
                trailing: currency == currentCurrency 
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () {
                  if (isBaseCurrency) {
                    provider.baseCurrency = currency;
                  } else {
                    provider.targetCurrency = currency;
                  }
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _getFlagEmoji(String currencyCode) {
    // This is a simplified version - you might want to use a package for better flag support
    final flagOffset = 0x1F1E6 - 'A'.codeUnitAt(0);
    try {
      final firstChar = currencyCode.codeUnitAt(0) - 'A'.codeUnitAt(0) + flagOffset;
      final secondChar = currencyCode.codeUnitAt(1) - 'A'.codeUnitAt(0) + flagOffset;
      return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
    } catch (e) {
      return '🌐'; // Fallback emoji
    }
  }
}
