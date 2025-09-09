import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/currency_card.dart';
import '../widgets/conversion_result_card.dart';
import '../widgets/history_chart.dart';
import 'favorites_screen.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({Key? key}) : super(key: key);

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _amountController.text = '1.0';
    // Fetch initial rates after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CurrencyProvider>(context, listen: false);
      provider.fetchRates().catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching rates: $error')),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Currency Converter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: _navigateToFavorites,
            tooltip: 'View Favorites',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider =
                  Provider.of<CurrencyProvider>(context, listen: false);
              provider.fetchRates();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rates updated')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // 🔹 Amount Input
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter amount",
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    final amount = double.tryParse(val) ?? 0.0;
                    Provider.of<CurrencyProvider>(context, listen: false)
                        .amount = amount;
                  }
                },
                onSubmitted: (val) {
                  if (val.isEmpty) {
                    _amountController.text = '0.0';
                    Provider.of<CurrencyProvider>(context, listen: false)
                        .amount = 0.0;
                  }
                },
              ),
              const SizedBox(height: 16),

              // 🔹 Currency Cards + Swap
              Expanded(
                child: Consumer<CurrencyProvider>(
                  builder: (context, provider, _) {
                    return ListView(
                      children: [
                        isPortrait
                            ? _buildPortraitLayout(context, provider)
                            : _buildLandscapeLayout(context, provider),

                        const SizedBox(height: 20),

                        // 🔹 Conversion Result
                        ConversionResultCard(provider: provider),

                        const SizedBox(height: 20),

                        // 🔹 History Chart
                        HistoryChart(
                          historicalRates: provider.historicalRates,
                          baseCurrency: provider.baseCurrency,
                          targetCurrency: provider.targetCurrency,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Portrait Layout
  Widget _buildPortraitLayout(
      BuildContext context, CurrencyProvider provider) {
    return Column(
      children: [
        // Base Currency Card with Favorite Toggle
        CurrencyCard(
          isBaseCurrency: true,
          isActive: true,
          showFavoriteButton: true,
        ),
        
        // Swap Button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: IconButton.filledTonal(
            onPressed: () {
              provider.swapCurrencies();
              _amountController.text = provider.amount.toString();
            },
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            icon: const Icon(Icons.swap_vert_rounded, size: 28),
          ),
        ),
        
        // Target Currency Card
        CurrencyCard(
          isBaseCurrency: false,
          isActive: false,
        ),
      ],
    );
  }

  // 🔹 Landscape Layout
  Widget _buildLandscapeLayout(
      BuildContext context, CurrencyProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Base Currency Card
        Expanded(
          child: CurrencyCard(
            isBaseCurrency: true,
            isActive: true,
          ),
        ),
        
        // Swap Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
          child: IconButton.filledTonal(
            onPressed: () {
              provider.swapCurrencies();
              _amountController.text = provider.amount.toString();
            },
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            icon: const Icon(Icons.swap_horiz_rounded, size: 28),
          ),
        ),
        
        // Target Currency Card
        Expanded(
          child: CurrencyCard(
            isBaseCurrency: false,
            isActive: false,
          ),
        ),
      ],
    );
  }

}
