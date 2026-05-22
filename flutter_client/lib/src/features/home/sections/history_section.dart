import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_box.dart';
import '../../../shared/widgets/app_panel.dart';
import '../../../theme/app_colors.dart';
import '../helpers/home_actions.dart';
import '../widgets/home_hero_banner.dart';
import '../widgets/home_section_scroll.dart';

class HistorySection extends StatelessWidget {
  const HistorySection({super.key});
  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryController>();
    return HomeSectionScroll(
      onRefresh: () => context.read<HistoryController>().load(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeroBanner(
            title: 'Historial',
            subtitle:
                'Cada escucha ayuda a trazar el comportamiento musical y alimentar recomendaciones.',
          ),
          const SizedBox(height: 20),
          if (history.error != null) AppErrorBox(message: history.error!),
          if (history.loading)
            LinearProgressIndicator(
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(AppColors.purple),
            )
          else if (history.entries.isEmpty)
            const AppEmptyState(
              message: 'No hay reproducciones registradas todavia.',
            )
          else
            ...history.entries.map(
              (entry) => AppPanel(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.purple.withValues(alpha: 0.18),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: AppColors.purple,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    entry.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${entry.artist} • ${entry.genre} • ${entry.playedSeconds}s • ${entry.completionRate.toStringAsFixed(1)}%',
                    style: TextStyle(color: AppColors.textMid, fontSize: 12),
                  ),
                  trailing: Text(
                    formatDate(entry.startedAt),
                    style: TextStyle(color: AppColors.textMid, fontSize: 11),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── RecommendationsSection ───────────────────────────────────────────────────
