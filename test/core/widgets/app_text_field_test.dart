import 'package:crowzy_finance/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    TextEditingController? controller,
    bool isPassword = false,
    FormFieldValidator<String>? validator,
    GlobalKey<FormState>? formKey,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: AppTextField(
              controller: controller ?? TextEditingController(),
              label: 'Email',
              isPassword: isPassword,
              validator: validator,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('sets the label above the field in capitals', (tester) async {
    await pump(tester);
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('Email'), findsNothing); // no floating label inside the border
  });

  testWidgets('keeps the plain label for assistive technology', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);

    expect(find.bySemanticsLabel(RegExp('Email')), findsWidgets);
    expect(find.bySemanticsLabel('EMAIL'), findsNothing); // the caption itself is excluded
    semantics.dispose();
  });

  testWidgets('writes typed text to the controller', (tester) async {
    final controller = TextEditingController();
    await pump(tester, controller: controller);

    await tester.enterText(find.byType(TextFormField), 'kaze@example.com');
    expect(controller.text, 'kaze@example.com');
  });

  testWidgets('shows the validator message', (tester) async {
    final formKey = GlobalKey<FormState>();
    await pump(tester, formKey: formKey, validator: (v) => v!.isEmpty ? 'Required' : null);

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('a password field can be revealed and hidden again', (tester) async {
    await pump(tester, isPassword: true);
    bool obscured() => tester.widget<EditableText>(find.byType(EditableText)).obscureText;

    expect(obscured(), isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(obscured(), isFalse);

    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(obscured(), isTrue);
  });
}
