import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/currency_provider.dart';
import '../services/currency_service.dart';

class CurrencyCard extends StatelessWidget {
  final bool isBaseCurrency;
  final bool isActive;
  final bool showFavoriteButton;

  const CurrencyCard({
    Key? key,
    required this.isBaseCurrency,
    this.isActive = false,
    this.showFavoriteButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<CurrencyProvider>(
      builder: (context, provider, _) {
        final currencyCode = isBaseCurrency
            ? provider.baseCurrency
            : provider.targetCurrency;
        final amount = isBaseCurrency
            ? provider.amount
            : provider.convertedAmount;
        final currencyName = CurrencyService.getCurrencyName(currencyCode);
        final formatter = NumberFormat.currency(
          symbol: '',
          decimalDigits: 2,
        );

        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: isActive ? theme.colorScheme.primary.withOpacity(0.05) : theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive 
                      ? theme.colorScheme.primary.withOpacity(0.3) 
                      : theme.dividerColor.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  if (isActive)
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _showCurrencyPicker(context, isBaseCurrency, provider),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Flag and Currency Code
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getFlagEmoji(currencyCode),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currencyCode,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Currency Name and Amount
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formatter.format(amount),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Dropdown Icon
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 28,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (showFavoriteButton && isBaseCurrency)
              Positioned(
                top: 8,
                right: 24,
                child: Consumer<CurrencyProvider>(
                  builder: (context, provider, _) {
                    return IconButton(
                      icon: Icon(
                        provider.isFavorite ? Icons.star : Icons.star_border,
                        color: provider.isFavorite 
                            ? theme.colorScheme.secondary 
                            : theme.iconTheme.color?.withOpacity(0.7),
                        size: 28,
                      ),
                      onPressed: () => provider.toggleFavorite(),
                      tooltip: provider.isFavorite 
                          ? 'Remove from favorites' 
                          : 'Add to favorites',
                    );
                  },
                ),
              ),
          ],
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
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select Currency',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search currency...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),
            
            // Currency List
            Expanded(
              child: ListView.builder(
                itemCount: CurrencyService.availableCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = CurrencyService.availableCurrencies[index];
                  final isSelected = currency == currentCurrency;
                  
                  return ListTile(
                    onTap: () {
                      if (isBaseCurrency) {
                        provider.baseCurrency = currency;
                      } else {
                        provider.targetCurrency = currency;
                      }
                      Navigator.of(context).pop();
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getFlagEmoji(currency),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(
                      currency,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      CurrencyService.getCurrencyName(currency),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFlagEmoji(String currencyCode) {
    // Map of currency codes to flag emojis
    final Map<String, String> currencyToFlag = {
      'USD': '🇺🇸',
      'EUR': '🇪🇺',
      'GBP': '🇬🇧',
      'JPY': '🇯🇵',
      'AUD': '🇦🇺',
      'CAD': '🇨🇦',
      'CHF': '🇨🇭',
      'CNY': '🇨🇳',
      'INR': '🇮🇳',
      'SGD': '🇸🇬',
      'NZD': '🇳🇿',
      'KRW': '🇰🇷',
      'BRL': '🇧🇷',
      'RUB': '🇷🇺',
      'ZAR': '🇿🇦',
      'MXN': '🇲🇽',
      'TRY': '🇹🇷',
      'AED': '🇦🇪',
      'SAR': '🇸🇦',
      'THB': '🇹🇭',
    };

    // Return the flag if found, otherwise use a generic currency symbol
    return currencyToFlag[currencyCode] ?? '💱';
  }
}
