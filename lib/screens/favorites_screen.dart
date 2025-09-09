import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../services/currency_service.dart';
import 'converter_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Pairs'),
      ),
      body: Consumer<CurrencyProvider>(
        builder: (context, provider, _) {
          if (provider.favorites.isEmpty) {
            return const Center(
              child: Text('No favorite currency pairs yet.'),
            );
          }

          return ListView.builder(
            itemCount: provider.favorites.length,
            itemBuilder: (context, index) {
              final pair = provider.favorites[index];
              final parts = pair.split('-');
              if (parts.length != 2) return const SizedBox.shrink();
              
              final fromCurrency = parts[0];
              final toCurrency = parts[1];
              
              return ListTile(
                leading: const Icon(Icons.currency_exchange),
                title: Text('$fromCurrency → $toCurrency'),
                subtitle: Text(
                  '${CurrencyService.getCurrencyName(fromCurrency)} to ${CurrencyService.getCurrencyName(toCurrency)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeFavorite(provider, pair),
                ),
                onTap: () {
                  provider.baseCurrency = fromCurrency;
                  provider.targetCurrency = toCurrency;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConverterScreen(),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _removeFavorite(CurrencyProvider provider, String pair) {
    provider.favorites.remove(pair);
    provider.toggleFavorite(); // This will update the SharedPreferences
  }
}
