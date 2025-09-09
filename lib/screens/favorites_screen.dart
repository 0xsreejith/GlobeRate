import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/currency_provider.dart';
import '../services/currency_service.dart';
import '../models/favorite_pair.dart';

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
          final favoritePairs = provider.favoritePairs;
          
          if (favoritePairs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite pairs yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the star icon in the converter to add favorites',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            itemCount: favoritePairs.length,
            onReorder: (oldIndex, newIndex) {
              provider.reorderFavorites(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final pair = favoritePairs[index];
              
              return _buildFavoriteItem(context, provider, pair, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context,
    CurrencyProvider provider,
    FavoritePair pair,
    int index,
  ) {
    final theme = Theme.of(context);
    
    return Slidable(
      key: ValueKey(pair.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _removeFavorite(provider, pair.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ReorderableDragStartListener(
        key: Key('item_${pair.id}'),
        index: index,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.currency_exchange, size: 28),
            title: Text(
              '${pair.baseCurrency} → ${pair.targetCurrency}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '${CurrencyService.getCurrencyName(pair.baseCurrency)} to ${CurrencyService.getCurrencyName(pair.targetCurrency)}',
              style: theme.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.drag_handle, color: Colors.grey),
            onTap: () async {
              await provider.loadFavoritePair(pair);
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }

  void _removeFavorite(CurrencyProvider provider, String pairId) {
    provider.removeFromFavorites(pairId);
  }
}
