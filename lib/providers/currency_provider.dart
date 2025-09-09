import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/currency_service.dart';
import '../models/favorite_pair.dart';

class CurrencyProvider with ChangeNotifier {
  String _baseCurrency = 'USD';
  String _targetCurrency = 'EUR';
  double _amount = 1.0;
  double _convertedAmount = 0.0;
  bool _isLoading = false;
  Map<String, double> _rates = {};
  Map<DateTime, double> _historicalRates = {};
  List<FavoritePair> _favoritePairs = [];
  final SharedPreferences _prefs;
  static const String _favoritesKey = 'favorite_currency_pairs';

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
  List<FavoritePair> get favoritePairs => List.unmodifiable(_favoritePairs);

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
    final favoritesJson = _prefs.getStringList(_favoritesKey) ?? [];
    _favoritePairs = favoritesJson
        .map((json) => FavoritePair.fromJson(jsonDecode(json)))
        .toList();
    _sortFavorites();
    notifyListeners();
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final favoritesJson = _favoritePairs
        .map((pair) => jsonEncode(pair.toJson()))
        .toList();
    await _prefs.setStringList(_favoritesKey, favoritesJson);
  }

  // Sort favorites by sortOrder
  void _sortFavorites() {
    _favoritePairs.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  // Toggle favorite status of current currency pair
  Future<void> toggleFavorite() async {
    final existingIndex = _favoritePairs.indexWhere((pair) => 
      pair.baseCurrency == _baseCurrency && 
      pair.targetCurrency == _targetCurrency);
    
    if (existingIndex >= 0) {
      await removeFromFavorites(_favoritePairs[existingIndex].id);
    } else {
      await addToFavorites();
    }
    notifyListeners();  // Add this to ensure UI updates
  }

  // Add current currency pair to favorites
  Future<void> addToFavorites() async {
    final newPair = FavoritePair(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      baseCurrency: _baseCurrency,
      targetCurrency: _targetCurrency,
      createdAt: DateTime.now(),
      sortOrder: _favoritePairs.length,
    );
    
    if (!_favoritePairs.any((pair) => 
        pair.baseCurrency == _baseCurrency && 
        pair.targetCurrency == _targetCurrency)) {
      _favoritePairs.add(newPair);
      await _saveFavorites();
      notifyListeners();
    }
  }

  // Remove currency pair from favorites
  Future<void> removeFromFavorites(String id) async {
    _favoritePairs.removeWhere((pair) => pair.id == id);
    await _saveFavorites();
    notifyListeners();
  }

  // Check if current pair is in favorites
  bool get isFavorite {
    return _favoritePairs.any((pair) => 
        pair.baseCurrency == _baseCurrency && 
        pair.targetCurrency == _targetCurrency);
  }
  
  // Reorder favorites
  Future<void> reorderFavorites(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final FavoritePair pair = _favoritePairs.removeAt(oldIndex);
    _favoritePairs.insert(newIndex, pair);
    
    // Update sortOrder for all items
    for (int i = 0; i < _favoritePairs.length; i++) {
      _favoritePairs[i] = _favoritePairs[i].copyWith(sortOrder: i);
    }
    
    await _saveFavorites();
    notifyListeners();
  }
  
  // Load a favorite pair
  Future<void> loadFavoritePair(FavoritePair pair) async {
    _baseCurrency = pair.baseCurrency;
    _targetCurrency = pair.targetCurrency;
    await fetchRates();
    fetchRates();
    notifyListeners();
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
