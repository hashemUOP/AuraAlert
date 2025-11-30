// chat_page.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _Msg {
  final String id;
  String text;
  final bool isUser;
  final bool isImage;
  final String? imagePath;

  _Msg({
    required this.id,
    this.text = '',
    required this.isUser,
    this.isImage = false,
    this.imagePath,
  });
}

class _ChatBotState extends State<ChatBot> {
  final Gemini gemini = Gemini.instance;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_Msg> _messages = [];

  /// id of the currently streaming bot message (if any)
  String? _streamingBotMessageId;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- helpers --------------------------------------------------------------
  String _makeId(String prefix) =>
      '$prefix-${DateTime.now().millisecondsSinceEpoch}-${_messages.length}';

  /// Best-effort extractor for various "part" shapes to avoid compile-time issues.
  String _extractTextFromPart(dynamic p) {
    try {
      if (p == null) return '';
      // If it's already a string
      if (p is String) return p;
      // If it's a Map-like (JSON decoded)
      if (p is Map) {
        return (p['text'] ?? p['content'] ?? p['body'] ?? p['value'] ?? '')
            .toString();
      }
      // Try property access on dynamic object (may throw)
      try {
        final t = (p as dynamic).text;
        if (t != null) return t.toString();
      } catch (_) {}
      try {
        final t = (p as dynamic).content;
        if (t != null) return t.toString();
      } catch (_) {}
      // Fallback
      return p.toString();
    } catch (_) {
      return '';
    }
  }

  void _scrollToTop() {
    // We're using reverse: true and inserting at index 0, so top == newest
    if (!_scrollController.hasClients) return;
    try {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } catch (_) {
      // ignore
    }
  }

  // --- user actions --------------------------------------------------------
  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    final userMsg = _Msg(
      id: _makeId('user'),
      text: text,
      isUser: true,
      isImage: false,
    );

    setState(() => _messages.insert(0, userMsg));
    _scrollToTop();

    _sendToGemini(question: text, imageBytes: null);
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    // Show user's image immediately
    final userImgMsg = _Msg(
      id: _makeId('user-img'),
      isUser: true,
      isImage: true,
      imagePath: picked.path,
    );

    setState(() => _messages.insert(0, userImgMsg));
    _scrollToTop();

    final bytes = await File(picked.path).readAsBytes();
    _sendToGemini(question: "Describe this image", imageBytes: bytes);
  }

  // --- Gemini streaming ----------------------------------------------------
  void _sendToGemini({required String question, Uint8List? imageBytes}) {
    // create or reset bot streaming message
    final botId = _makeId('bot');
    _streamingBotMessageId = botId;

    final botPlaceholder = _Msg(
      id: botId,
      text: '',
      isUser: false,
      isImage: false,
    );

    setState(() => _messages.insert(0, botPlaceholder));
    _scrollToTop();

    // Attempt to stream; be defensive about event shape
    try {
      gemini
          .streamGenerateContent(
        question,
        images: imageBytes != null ? [imageBytes] : null,
      )
          .listen((event) {
        // event may have different shapes. Parse parts defensively.
        final dynamic evt = event;
        final dynamic content = evt?.content ?? evt;
        final parts = (content?.parts ?? content) as dynamic;

        // normalize to iterable
        Iterable<dynamic> iter;
        if (parts is Iterable) {
          iter = parts;
        } else if (parts != null) {
          iter = [parts];
        } else {
          iter = [];
        }

        final chunk = iter.map(_extractTextFromPart).join(' ').trim();

        if (chunk.isEmpty) {
          // nothing meaningful in this tick
          return;
        }

        // append chunk to the currently streaming bot message
        setState(() {
          final idx =
          _messages.indexWhere((m) => m.id == _streamingBotMessageId);
          if (idx >= 0) {
            _messages[idx].text = (_messages[idx].text + ' ' + chunk).trim();
          } else {
            // if placeholder missing, insert a new bot message
            _messages.insert(
              0,
              _Msg(id: _makeId('bot'), text: chunk, isUser: false),
            );
            // update streaming id to newly inserted
            _streamingBotMessageId = _messages.first.id;
          }
        });
        _scrollToTop();
      }, onDone: () {
        // finished streaming: clear streaming id
        _streamingBotMessageId = null;
      }, onError: (err) {
        _streamingBotMessageId = null;
        // update last bot msg with an error note
        setState(() {
          final idx =
          _messages.indexWhere((m) => m.id == _streamingBotMessageId);
          if (idx >= 0) {
            _messages[idx].text =
            '${_messages[idx].text}\n\n[Error while streaming response]';
          } else {
            _messages.insert(
                0,
                _Msg(
                    id: _makeId('bot'),
                    text: '[Error while streaming response]',
                    isUser: false));
          }
        });
      });
    } catch (e) {
      // fallback single response if stream call fails synchronously
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == botId);
        if (idx >= 0) {
          _messages[idx].text = '[Failed to contact Gemini]';
        } else {
          _messages.insert(
              0,
              _Msg(
                  id: _makeId('bot'),
                  text: '[Failed to contact Gemini]',
                  isUser: false));
        }
      });
      _streamingBotMessageId = null;
    }
  }

  // --- UI ------------------------------------------------------------------
  Widget _buildBubble(_Msg m) {
    final isUser = m.isUser;
    final radius = BorderRadius.only(
      topLeft: Radius.circular(isUser ? 12 : 0),
      topRight: Radius.circular(isUser ? 0 : 12),
      bottomLeft: const Radius.circular(12),
      bottomRight: const Radius.circular(12),
    );

    final bgColor = isUser ? Colors.purple.shade300 : Colors.grey.shade300;
    final textColor = isUser ? Colors.white : Colors.black87;

    if (m.isImage && m.imagePath != null) {
      return Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260, maxHeight: 360),
              child: Image.file(
                File(m.imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey.shade200,
                  width: 160,
                  height: 120,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // text bubble
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Text(
          m.text.isEmpty ? (m.isUser ? '' : '...') : m.text,
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AuraAlert's ChatBot", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: Text(
                "Say hi 👋",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return _buildBubble(m);
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.image, color: Colors.purple[400]),
                    onPressed: _sendImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Type a message',
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.purple[400]),
                    onPressed: _sendText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
