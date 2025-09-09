# 🌍 GlobeRate - Currency Converter

A beautiful and intuitive currency converter app built with Flutter. Convert between different currencies with real-time exchange rates and view historical trends.

## ✨ Features

- 💱 Real-time currency conversion
- 📊 Historical exchange rate charts
- 🌐 Supports 150+ world currencies
- ⚡ Fast and lightweight
- 🎨 Modern Material Design 3 UI
- 🔄 Swap currencies with a single tap
- 📱 Responsive layout for all screen sizes



## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- An internet connection for fetching exchange rates

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/0xsreejith/GlobeRate.git
   cd GlobeRate
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## 🛠️ Built With

- [Flutter](https://flutter.dev/) - Beautiful native apps in record time
- [Provider](https://pub.dev/packages/provider) - State management
- [http](https://pub.dev/packages/http) - For making API requests
- [fl_chart](https://pub.dev/packages/fl_chart) - For beautiful charts
- [intl](https://pub.dev/packages/intl) - For number and date formatting
- [shared_preferences](https://pub.dev/packages/shared_preferences) - For local storage
- [currency_picker](https://pub.dev/packages/currency_picker) - For currency selection

## 📁 Project Structure

```
lib/
├── main.dart          # App entry point
├── models/           # Data models
├── providers/        # State management
│   └── currency_provider.dart
├── screens/          # App screens
│   └── converter_screen.dart
├── services/         # API and business logic
│   └── currency_service.dart
└── widgets/          # Reusable widgets
    ├── currency_card.dart
    ├── conversion_result_card.dart
    └── history_chart.dart
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Exchange rates provided by [ExchangeRate-API](https://www.exchangerate-api.com/)
- Icons by [Material Icons](https://fonts.google.com/icons)
- Built with ❤️ using Flutter

---

<div align="center">
  Made with Flutter 💙 | Give it a ⭐ if you like it!
</div>

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
