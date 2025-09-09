import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CurrencyService {
  static const String _baseUrl = 'api.frankfurter.app';
  static const Map<String, String> _currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'INR': 'Indian Rupee',
    'SGD': 'Singapore Dollar',
    'NZD': 'New Zealand Dollar',
    'KRW': 'South Korean Won',
    'BRL': 'Brazilian Real',
    'ZAR': 'South African Rand',
    'RUB': 'Russian Ruble',
  };

  static List<String> get availableCurrencies => _currencyNames.keys.toList();
  
  static String getCurrencyName(String code) => _currencyNames[code] ?? code;

  static Future<Map<String, double>> getLatestRates(String baseCurrency) async {
    try {
      final uri = Uri.https(_baseUrl, '/latest', {'from': baseCurrency});
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Convert num values to double explicitly
        final rates = <String, double>{};
        (data['rates'] as Map<String, dynamic>).forEach((key, value) {
          rates[key] = value.toDouble();
        });
        // Add base currency with rate 1.0
        rates[baseCurrency] = 1.0;
        return rates;
      }
      throw Exception('Failed to load exchange rates');
    } catch (e) {
      debugPrint('Error fetching rates: $e');
      rethrow;
    }
  }

  static Future<Map<DateTime, double>> getHistoricalRates(
    String fromCurrency,
    String toCurrency, {
    int days = 7,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final Map<DateTime, double> historicalRates = {};

    try {
      for (int i = 0; i <= days; i++) {
        final date = startDate.add(Duration(days: i));
        final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        
        final uri = Uri.https(
          _baseUrl,
          '/$formattedDate',
          {
            'from': fromCurrency,
            'to': toCurrency,
          },
        );

        final response = await http.get(uri);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final rate = (data['rates'] as Map<String, dynamic>)[toCurrency];
          if (rate != null) {
            historicalRates[date] = rate is int ? rate.toDouble() : rate;
          }
        }
        
        // Add a small delay to avoid hitting rate limits
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return historicalRates;
    } catch (e) {
      debugPrint('Error fetching historical rates: $e');
      return {};
    }
  }
}
