import 'package:flutter/material.dart';
import '../domain/filter_notes.dart';
import '../domain/note.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // Data dummy simulasi (pada arsitektur penuh disediakan oleh repository/provider)
  final List<Note> _allNotes = const [
    Note(
      id: '1',
      title: 'Belajar Flutter Clean Architecture',
      body: 'Hari ini belajar memisahkan layer presentation, domain, dan data.',
    ),
    Note(
      id: '2',
      title: 'Catatan Rapat Mingguan',
      body: 'Membahas progres sprint dan implementasi AI-assisted development.',
    ),
    Note(
      id: '3',
      title: 'Dart Pure Function',
      body: 'Fungsi murni tanpa side effect untuk mempermudah unit testing.',
    ),
    Note(
      id: '4',
      title: 'Belanja Bulanan',
      body: 'Beras, telur, sabun, dan kopi.',
    ),
    Note(
      id: '5',
      title: 'Olahraga Pagi',
      body: 'Lari santai 5km keliling komplek perumahan.',
    ),
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredNotes = filterNotes(_allNotes, _searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes Search (AI)'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: filteredNotes.isEmpty
                ? _buildEmptyState()
                : _buildNotesList(filteredNotes),
          ),
        ],
      ),
    );
  }

  /// Komponen input pencarian
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: const InputDecoration(
          labelText: 'Cari judul catatan...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  /// Komponen Empty State saat hasil pencarian tidak ditemukan
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Catatan tidak ditemukan',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Komponen daftar catatan
  Widget _buildNotesList(List<Note> notes) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(note.id),
          ),
          title: Text(note.title),
          subtitle: Text(note.body),
        );
      },
    );
  }
}
