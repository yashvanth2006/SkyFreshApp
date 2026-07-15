import 'package:flutter/material.dart';
import 'package:skyfresh/theme.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  String _goal = 'Weight gain';
  final _question = TextEditingController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage('Hi! Ask me about fruit, freshness, storage, or nutrition.', false),
  ];

  final Map<String, List<String>> _recommendations = const {
    'Weight gain': ['Banana', 'Mango', 'Avocado', 'Dates'],
    'Weight loss': ['Apple', 'Watermelon', 'Guava', 'Berries'],
    'Skin care': ['Orange', 'Papaya', 'Pomegranate', 'Kiwi'],
    'Energy & immunity': ['Orange', 'Banana', 'Pomegranate', 'Mango'],
  };

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  void _ask() {
    final question = _question.text.trim();
    if (question.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(question, true));
      _messages.add(_ChatMessage(_answerFor(question), false));
      _question.clear();
    });
  }

  String _answerFor(String question) {
    final q = question.toLowerCase();
    if (q.contains('store') || q.contains('keep') || q.contains('fresh')) {
      return 'Keep berries and cut fruit refrigerated in a covered container. Whole bananas and mangoes ripen best at room temperature; refrigerate once ripe.';
    }
    if (q.contains('weight') || q.contains('diet')) {
      return 'For a filling, balanced snack, pair fruit with protein or nuts. Choose water-rich fruit for lighter meals and banana or mango when you need more energy.';
    }
    if (q.contains('skin') || q.contains('glow')) {
      return 'Vitamin-C-rich fruits such as orange, kiwi, papaya and pomegranate support a healthy diet for skin. Hydration and an overall balanced diet matter too.';
    }
    if (q.contains('diabetes') || q.contains('sugar')) {
      return 'Fruit can fit many eating plans, but portions and personal medical advice matter. Choose whole fruit over juice and check with your clinician for tailored guidance.';
    }
    return 'Whole fruit is a great source of fibre and micronutrients. Tell me your goal or ask about a specific fruit and I’ll help with a practical suggestion.';
  }

  @override
  Widget build(BuildContext context) {
    final fruits = _recommendations[_goal]!;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(children: const [
                Icon(Icons.auto_awesome_rounded, color: AppTheme.primary),
                SizedBox(width: 10),
                Text('SKYfresh AI', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textMain)),
              ]),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Find fruits for your goal', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textMain)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _goal,
                  decoration: const InputDecoration(labelText: 'Your goal', border: OutlineInputBorder()),
                  items: _recommendations.keys.map((goal) => DropdownMenuItem(value: goal, child: Text(goal))).toList(),
                  onChanged: (value) => setState(() => _goal = value!),
                ),
                const SizedBox(height: 12),
                Text('Try: ${fruits.join(' • ')}', style: const TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.w700)),
              ]),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Align(alignment: Alignment.centerLeft, child: Text('Fruit helper', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppTheme.textMain))),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (_, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(color: message.isUser ? AppTheme.primary : AppTheme.surface, borderRadius: BorderRadius.circular(16)),
                      child: Text(message.text, style: TextStyle(color: message.isUser ? Colors.white : AppTheme.textMain, height: 1.35)),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(children: [
                Expanded(child: TextField(controller: _question, onSubmitted: (_) => _ask(), decoration: const InputDecoration(hintText: 'Ask about a fruit...', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                IconButton(onPressed: _ask, icon: const Icon(Icons.send_rounded), color: AppTheme.primary),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage(this.text, this.isUser);
}
