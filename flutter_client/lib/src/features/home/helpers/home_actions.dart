import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controllers/controllers.dart';
import '../../../models/domain_models.dart';

String formatDate(DateTime? value) {
  if (value == null) return '-';
  return DateFormat('yyyy-MM-dd HH:mm').format(value.toLocal());
}

Future<void> showSnack(BuildContext context, String message) async {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> playSong(
  BuildContext context,
  Song song, {
  String source = 'catalog',
}) async {
  await context.read<PlayerController>().playSong(song, source: source);
  if (!context.mounted) return;
  await context.read<HistoryController>().load();
}
