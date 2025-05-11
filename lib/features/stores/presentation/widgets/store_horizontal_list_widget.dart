import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/core/utils/colors.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/horizontal_avatar_widget.dart';

class HorizontalStoreListWidget extends StatelessWidget {
  final List<Store> store;
  const HorizontalStoreListWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.dividerColorDark.withOpacity(.3)
                : AppColors.cardColor.withOpacity(.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) =>
                StoreCardAvatar(store: store[index]),
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemCount: store.length,
          )),
    );
  }
}
