import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/ai_transaction_suggestion.dart';
import 'package:crowzy_finance/data/models/chat_message.dart';
import 'package:crowzy_finance/data/models/passive_insight.dart';
import 'package:crowzy_finance/features/ai_analyzer/providers/ai_analyzer_provider.dart';
import 'package:crowzy_finance/features/ai_analyzer/providers/chat_qa_provider.dart';
import 'package:crowzy_finance/features/ai_analyzer/providers/passive_insight_provider.dart';
import 'package:crowzy_finance/features/ai_analyzer/ui/ai_analyzer_screen.dart';
import 'package:crowzy_finance/features/ai_analyzer/ui/widgets/chat_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

ChatQaState _initialChat = const ChatQaState();
PassiveInsight? _insight;
final List<String> _classified = [];
final List<String> _parsed = [];

class _FakeChat extends ChatQa {
  @override
  ChatQaState build() => _initialChat;

  @override
  Future<CorrectionOutcome> classifyAndMatch(String text) async {
    _classified.add(text);
    return const CorrectionOutcome.notCorrection();
  }

  @override
  Future<void> answerQuestion() async => appendAssistantMessage('Here is your answer');
}

class _FakeInsight extends PassiveInsightController {
  @override
  Future<PassiveInsight?> build() async => _insight;
}

class _FakeParser extends TransactionParser {
  @override
  AsyncValue<AiTransactionSuggestion?> build() => const AsyncData(null);

  @override
  Future<void> parse(String text) async => _parsed.add(text);
}

ChatMessage _msg(String content, {ChatRole role = ChatRole.user, bool isError = false}) =>
    ChatMessage(id: content, role: role, content: content, isError: isError);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    _initialChat = const ChatQaState();
    _insight = null;
    _classified.clear();
    _parsed.clear();
  });

  Future<void> pump(WidgetTester tester, {AiMode mode = AiMode.ask, bool pushed = false}) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final screen = AiAnalyzerScreen(initialMode: mode);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatQaProvider.overrideWith(_FakeChat.new),
          passiveInsightControllerProvider.overrideWith(_FakeInsight.new),
          transactionParserProvider.overrideWith(_FakeParser.new),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: pushed
              ? Builder(
                  builder: (context) => Scaffold(
                    body: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => screen),
                      ),
                      child: const Text('open'),
                    ),
                  ),
                )
              : screen,
        ),
      ),
    );
    if (pushed) {
      await tester.tap(find.text('open'));
    }
    await tester.pumpAndSettle();
  }

  group('Ask mode', () {
    testWidgets('opens on Ask with a prompt and example questions', (tester) async {
      await pump(tester);

      expect(find.text('Ask'), findsWidgets);
      expect(find.text('Ask a question about your income, spending, or goals.'), findsOneWidget);
      expect(find.text('How much did I spend on food last week?'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows the passive insight above the conversation when there is one', (tester) async {
      _insight = const PassiveInsight(
        headline: 'Dining is climbing',
        detail: 'Up 40% on last month.',
        trend: InsightTrend.up,
      );
      await pump(tester);

      expect(find.text('INSIGHT'), findsOneWidget);
      expect(find.text('Dining is climbing'), findsOneWidget);
    });

    testWidgets('tapping an example sends it and shows the answer', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Am I on pace for my goals?'));
      await tester.pumpAndSettle();

      expect(_classified, ['Am I on pace for my goals?']);
      expect(find.byType(ChatMessageBubble), findsNWidgets(2));
      expect(find.text('Here is your answer'), findsOneWidget);
      expect(find.text('Ask a question about your income, spending, or goals.'), findsNothing);
    });

    testWidgets('typing a message and pressing send posts it', (tester) async {
      await pump(tester);

      await tester.enterText(find.byType(TextField), 'How much on rent?');
      await tester.tap(find.byTooltip('Send'));
      await tester.pumpAndSettle();

      expect(_classified, ['How much on rent?']);
      expect(find.text('How much on rent?'), findsOneWidget);
    });

    testWidgets('an empty message is not sent', (tester) async {
      await pump(tester);

      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.byTooltip('Send'));
      await tester.pumpAndSettle();

      expect(_classified, isEmpty);
      expect(find.byType(ChatMessageBubble), findsNothing);
    });

    testWidgets('while the assistant is working it shows Thinking and disables send', (tester) async {
      _initialChat = ChatQaState(messages: [_msg('Hello')], isLoading: true);
      await pump(tester);

      expect(find.text('Thinking…'), findsOneWidget);
      final send = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.arrow_upward_rounded));
      expect(send.onPressed, isNull);
    });

    testWidgets('a failed answer can be retried by resending the question', (tester) async {
      _initialChat = ChatQaState(
        messages: [
          _msg('How much on food?'),
          _msg('Network error', role: ChatRole.assistant, isError: true),
        ],
      );
      await pump(tester);

      await tester.tap(find.byTooltip('Retry'));
      await tester.pumpAndSettle();

      expect(_classified, ['How much on food?']);
    });
  });

  group('Add mode', () {
    testWidgets('opens straight into Add when asked to', (tester) async {
      await pump(tester, mode: AiMode.add);

      expect(find.text('TRANSACTION'), findsOneWidget);
      expect(find.text('Parse'), findsOneWidget);
    });

    testWidgets('switching modes keeps what was typed in each', (tester) async {
      await pump(tester);

      await tester.enterText(find.byType(TextField), 'a half-written question');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.text('Parse'), findsOneWidget);

      await tester.tap(find.text('Ask').last);
      await tester.pumpAndSettle();
      expect(find.text('a half-written question'), findsOneWidget);
    });

    testWidgets('Parse sends the description to the parser', (tester) async {
      await pump(tester, mode: AiMode.add);

      await tester.enterText(find.byType(TextField), 'spent 50k on coffee');
      await tester.tap(find.text('Parse'));
      await tester.pumpAndSettle();

      expect(_parsed, ['spent 50k on coffee']);
    });

    testWidgets('Parse does nothing for an empty description', (tester) async {
      await pump(tester, mode: AiMode.add);

      await tester.tap(find.text('Parse'));
      await tester.pumpAndSettle();

      expect(_parsed, isEmpty);
    });
  });

  group('navigation', () {
    testWidgets('as a tab there is no back button', (tester) async {
      await pump(tester);

      expect(find.byTooltip('Back'), findsNothing);
    });

    testWidgets('when pushed there is a back button that returns', (tester) async {
      await pump(tester, pushed: true);

      expect(find.byTooltip('Back'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.text('open'), findsOneWidget);
    });
  });

  group('ChatMessageBubble', () {
    Widget bubble(ChatMessage message, {VoidCallback? onRetry}) => MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: ChatMessageBubble(message: message, onRetry: onRetry)),
        );

    testWidgets('your messages sit on the right, the assistant\'s on the left', (tester) async {
      await tester.pumpWidget(bubble(_msg('Mine')));
      final mine = tester.getTopRight(find.text('Mine')).dx;
      await tester.pumpWidget(bubble(_msg('Theirs', role: ChatRole.assistant)));
      final theirs = tester.getTopLeft(find.text('Theirs')).dx;

      expect(mine, greaterThan(200));
      expect(theirs, lessThan(100));
    });

    testWidgets('only a failed message offers retry', (tester) async {
      var retries = 0;
      await tester.pumpWidget(
        bubble(_msg('Oops', role: ChatRole.assistant, isError: true), onRetry: () => retries++),
      );
      await tester.tap(find.byTooltip('Retry'));
      expect(retries, 1);

      await tester.pumpWidget(bubble(_msg('Fine', role: ChatRole.assistant), onRetry: () {}));
      expect(find.byTooltip('Retry'), findsNothing);
    });
  });
}
