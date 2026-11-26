import 'dart:async';

import 'package:flutter/material.dart';

import '../ai/ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatScreen extends StatefulWidget {
  final AiService? aiService;

  const ChatScreen({super.key, this.aiService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final AiService _aiService;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isStreaming = false;
  String? _currentApiKey;

  final List<String> _quickPrompts = [
    'Jadwal kuliah hari Senin?',
    'Info pengisian KRS semester ini',
    'Lokasi perpustakaan kampus',
    'Syarat beasiswa prestasi',
  ];

  @override
  void initState() {
    super.initState();
    _aiService = widget.aiService ?? AiService();
    _loadApiKey();

    // Pesan sapaan ramah dari AI saat pertama kali masuk
    _messages.add(
      ChatMessage(
        text: 'Halo! Saya Asisten AI Kampus. Ada yang bisa saya bantu terkait jadwal, KRS, beasiswa, atau pengumuman kampus hari ini?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _loadApiKey() async {
    final key = await _aiService.getApiKey();
    if (mounted) {
      setState(() {
        _currentApiKey = key;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Pengecekan privasi sebelum mengirim data ke AI API (Zero-Leakage Policy)
  bool _containsSensitiveData(String text) {
    // Deteksi sederhana pola NIK (16 digit), nomor HP (10-13 digit), atau kata kunci kredensial
    final nikRegex = RegExp(r'\b\d{16}\b');
    final phoneRegex = RegExp(r'\b(08|628)\d{8,11}\b');
    final passwordRegex = RegExp(
      r'(password|pin|rekening)\s*[:=]\s*\S+',
      caseSensitive: false,
    );

    return nikRegex.hasMatch(text) ||
        phoneRegex.hasMatch(text) ||
        passwordRegex.hasMatch(text);
  }

  Future<void> _handleSubmitted(String text) async {
    final query = text.trim();
    if (query.isEmpty || _isLoading || _isStreaming) return;

    // Filter Privasi & Keamanan (Sesuai panduan Jobsheet)
    if (_containsSensitiveData(query)) {
      _showPrivacyWarningDialog();
      return;
    }

    _textController.clear();
    setState(() {
      _messages.add(
        ChatMessage(text: query, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Mendengarkan streaming response untuk efek mengetik real-time
      setState(() {
        _isLoading = false;
        _isStreaming = true;
        _messages.add(
          ChatMessage(text: '', isUser: false, timestamp: DateTime.now()),
        );
      });

      await for (final chunk in _aiService.askStream(query)) {
        if (!mounted) break;
        setState(() {
          _messages[_messages.length - 1] = ChatMessage(
            text: chunk,
            isUser: false,
            timestamp: DateTime.now(),
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        _showFallbackDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isStreaming = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _showPrivacyWarningDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.security, color: Colors.orange, size: 48),
        title: const Text('Peringatan Privasi'),
        content: const Text(
          'Pesan Anda terdeteksi memuat informasi sensitif (seperti NIK, nomor HP, atau password). '
          'Sesuai kebijakan keamanan, dilarang mengirim data pribadi ke layanan AI pihak ketiga.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showFallbackDialog(String errorDetail) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.cloud_off, color: Colors.redAccent, size: 48),
        title: const Text('Layanan AI Sibuk'),
        content: const Text('Coba lagi nanti atau gunakan mode offline.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Jalankan fallback offline
              final fallbackAnswer = _aiService.ask(
                _messages.last.text,
                allowOfflineFallback: true,
              );
              fallbackAnswer.then((ans) {
                if (mounted) {
                  setState(() {
                    _messages.add(
                      ChatMessage(
                        text: '[Mode Offline]: $ans',
                        isUser: false,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                  _scrollToBottom();
                }
              });
            },
            child: const Text('Gunakan Offline'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController(text: _currentApiKey ?? '');
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.key, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('Pengaturan AI API Key'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan Google Gemini API Key Anda. Kunci ini disimpan secara terenkripsi menggunakan FlutterSecureStorage.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _aiService.deleteApiKey();
              if (mounted) {
                setState(() => _currentApiKey = null);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('API Key dihapus. Mode offline aktif.'),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
          FilledButton(
            onPressed: () async {
              final newKey = controller.text.trim();
              if (newKey.isNotEmpty) {
                await _aiService.saveApiKey(newKey);
                if (mounted) {
                  setState(() => _currentApiKey = newKey);
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('API Key berhasil disimpan dengan aman!'),
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  /// Demonstrasi integrasi OCR (Optical Character Recognition)
  Future<void> _handleOcrDemo() async {
    setState(() => _isLoading = true);
    final ocrText = await _aiService.recognizeText('ktm_sample.png');
    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(
            Icons.document_scanner,
            color: Colors.blue,
            size: 48,
          ),
          title: const Text('Hasil Ekstraksi OCR'),
          content: Text(ocrText),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _handleSubmitted(
                  'Tolong periksa status aktif dari hasil OCR KTM ini.',
                );
              },
              child: const Text('Tanyakan ke AI'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }

  /// Demonstrasi integrasi Speech-to-Text
  Future<void> _handleSttDemo() async {
    setState(() => _isLoading = true);
    final spokenText = await _aiService.speechToText('voice_input.m4a');
    setState(() => _isLoading = false);

    _textController.text = spokenText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asisten AI Kampus',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _currentApiKey != null && _currentApiKey!.isNotEmpty
                  ? 'Gemini 1.5 Flash • Online'
                  : 'Mode Cerdas Offline Aktif',
              style: TextStyle(
                fontSize: 12,
                color: _currentApiKey != null && _currentApiKey!.isNotEmpty
                    ? Colors.greenAccent
                    : Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_outlined),
            tooltip: 'Atur API Key',
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Quick Prompt Suggestions
          _buildQuickPromptsBar(theme),

          // Area Riwayat Pesan
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Indikator Loading saat menunggu respon
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Asisten AI sedang berpikir...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),

          // Input Bar & Action Tools
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildQuickPromptsBar(ThemeData theme) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _quickPrompts.length,
        itemBuilder: (context, index) {
          final prompt = _quickPrompts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(prompt, style: const TextStyle(fontSize: 12)),
              avatar: const Icon(Icons.bolt, size: 16, color: Colors.amber),
              onPressed: () => _handleSubmitted(prompt),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isUser)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.smart_toy, size: 14, color: Colors.blueAccent),
                    SizedBox(width: 4),
                    Text(
                      'AI Campus',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              message.text.isEmpty && _isStreaming ? '...' : message.text,
              style: TextStyle(
                color: isUser
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontSize: 14.5,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.document_scanner_outlined),
              tooltip: 'Simulasi OCR Dokumen/KTM',
              onPressed: _handleOcrDemo,
            ),
            IconButton(
              icon: const Icon(Icons.mic_none_outlined),
              tooltip: 'Simulasi Speech-to-Text',
              onPressed: _handleSttDemo,
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Tanyakan sesuatu tentang kampus...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                onSubmitted: _handleSubmitted,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              color: theme.colorScheme.primary,
              tooltip: 'Kirim',
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ],
        ),
      ),
    );
  }
}
