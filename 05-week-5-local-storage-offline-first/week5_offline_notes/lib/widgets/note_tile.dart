import 'package:flutter/material.dart';
import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(note.body.isEmpty ? '-' : note.body),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            note.dirty ? Icons.cloud_upload : Icons.cloud_done,
            color: note.dirty ? Colors.orange : Colors.green,
            size: 20,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}