import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/currency_service.dart';

class CurrencyProvider with ChangeNotifier {
  String _baseCurrency = 'USD';
  String _targetCurrency = 'EUR';
  double _amount = 1.0;
  double _convertedAmount = 0.0;
  bool _isLoading = false;
  Map<String, double> _rates = {};
  Map<DateTime, double> _historicalRates = {};
  List<String> _favorites = [];
  final SharedPreferences _prefs;

  CurrencyProvider(this._prefs) {
    _loadFavorites();
    fetchRates();
  }

  // Getters
  String get baseCurrency => _baseCurrency;
  String get targetCurrency => _targetCurrency;
  double get amount => _amount;
  double get convertedAmount => _convertedAmount;
  bool get isLoading => _isLoading;
  Map<String, double> get rates => _rates;
  Map<DateTime, double> get historicalRates => _historicalRates;
  List<String> get favorites => _favorites;

  // Setters
  set baseCurrency(String value) {
    if (_baseCurrency != value) {
      _baseCurrency = value;
      fetchRates();
      notifyListeners();
    }
  }

  set targetCurrency(String value) {
    if (_targetCurrency != value) {
      _targetCurrency = value;
      _convert();
      _fetchHistoricalRates();
      notifyListeners();
    }
  }

  // Set the amount and trigger conversion
  set amount(double value) {
    if (_amount != value) {
      _amount = value;
      _convert();
    }
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    _favorites = _prefs.getStringList('favorites') ?? [];
    notifyListeners();
  }

  // Toggle favorite status of current currency pair
  Future<void> toggleFavorite() async {
    final pair = '$_baseCurrency-$_targetCurrency';
    if (_favorites.contains(pair)) {
      _favorites.remove(pair);
    } else {
      _favorites.add(pair);
    }
    await _prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }

  // Check if current pair is in favorites
  bool isFavorite() {
    return _favorites.contains('$_baseCurrency-$_targetCurrency');
  }

  // Swap base and target currencies
  void swapCurrencies() {
    final temp = _baseCurrency;
    _baseCurrency = _targetCurrency;
    _targetCurrency = temp;
    fetchRates();
  }

  // Fetch latest exchange rates
  Future<void> fetchRates() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rates = await CurrencyService.getLatestRates(_baseCurrency);
      _convert();
      await _fetchHistoricalRates();
    } catch (e) {
      debugPrint('Error fetching rates: $e');
      // If there's an error, set default rates to avoid null
      _rates = {_baseCurrency: 1.0};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Convert the amount from base to target currency
  void _convert() {
    if (_rates.isEmpty) {
      _convertedAmount = 0.0;
      notifyListeners();
      return;
    }

    try {
      if (_baseCurrency == _targetCurrency) {
        // Same currency, no conversion needed
        _convertedAmount = _amount.toDouble();
      } else {
        // Get rates from the API response
        final baseRate = _rates[_baseCurrency] ?? 1.0;
        final targetRate = _rates[_targetCurrency] ?? 0.0;
        
        if (baseRate == 0) {
          _convertedAmount = 0.0;
        } else {
          // Convert using the formula: (amount / baseRate) * targetRate
          _convertedAmount = (_amount / baseRate) * targetRate;
        }
      }

      // Handle potential division by zero or invalid rates
      if (_convertedAmount.isNaN || _convertedAmount.isInfinite) {
        _convertedAmount = 0.0;
      } else {
        // Format to 6 decimal places for display
        _convertedAmount = double.parse(_convertedAmount.toStringAsFixed(6));
      }
    } catch (e) {
      debugPrint('Conversion error: $e');
      _convertedAmount = 0.0;
    }

    notifyListeners();
  }


  // Fetch historical rates for the chart
  Future<void> _fetchHistoricalRates() async {
    try {
      final historicalRates = await CurrencyService.getHistoricalRates(
        _baseCurrency,
        _targetCurrency,
      );
      _historicalRates = Map<DateTime, double>.from(historicalRates);
    } catch (e) {
      debugPrint('Error fetching historical rates: $e');
    }
    notifyListeners();
  }
}
