import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/currency_card.dart';
import '../widgets/conversion_result_card.dart';
import '../widgets/history_chart.dart';
import '../services/currency_service.dart';

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
        GestureDetector(
          onTap: () {
            _showCurrencyPicker(context, true, provider);
          },
          child: const CurrencyCard(isBaseCurrency: true),
        ),
        const SizedBox(height: 16),
        IconButton(
          onPressed: () {
            provider.swapCurrencies();
            _amountController.text = provider.amount.toString();
          },
          icon: const Icon(Icons.swap_vert),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            _showCurrencyPicker(context, false, provider);
          },
          child: const CurrencyCard(isBaseCurrency: false),
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
        Expanded(
          child: GestureDetector(
            onTap: () {
              _showCurrencyPicker(context, true, provider);
            },
            child: const CurrencyCard(isBaseCurrency: true),
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
          child: FloatingActionButton.small(
            onPressed: () {
              provider.swapCurrencies();
              _amountController.text = provider.amount.toString();
            },
            child: const Icon(Icons.swap_horiz),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _showCurrencyPicker(context, false, provider);
            },
            child: const CurrencyCard(isBaseCurrency: false),
          ),
        ),
      ],
    );
  }

  // 🔹 Currency Picker Dialog
  void _showCurrencyPicker(
      BuildContext context, bool isBase, CurrencyProvider provider) {
    final currentCurrency = isBase ? provider.baseCurrency : provider.targetCurrency;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Text(
              isBase ? 'Select Base Currency' : 'Select Target Currency',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search currency...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // Search functionality can be implemented here
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<CurrencyProvider>(
                builder: (context, provider, _) {
                  final currencies = CurrencyService.availableCurrencies;
                  return ListView.builder(
                    itemCount: currencies.length,
                    itemBuilder: (context, index) {
                      final currency = currencies[index];
                      final isSelected = currency == currentCurrency;
                      
                      return ListTile(
                        title: Text(currency),
                        trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                        onTap: () {
                          if (isBase) {
                            provider.baseCurrency = currency;
                          } else {
                            provider.targetCurrency = currency;
                          }
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
