import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../domain/entities/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(note.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(note.body),
          Text('Diperbarui: ${formatTimestamp(note.updatedAt)}'),
          Chip(
            avatar: Icon(
              note.dirty ? Icons.schedule : Icons.cloud_done,
              size: 16,
            ),
            label: Text(note.dirty ? 'Belum tersinkron' : 'Tersinkron'),
          ),
        ],
      ),
      onTap: onOpen,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit catatan',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Hapus catatan',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    ),
  );
}
