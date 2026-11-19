import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/features/auth/providers/auth_provider.dart';
import 'package:crowzy_finance/features/auth/repository/auth_repository.dart';
import 'package:crowzy_finance/features/auth/ui/forgot_password_screen.dart';
import 'package:crowzy_finance/features/auth/ui/login_screen.dart';
import 'package:crowzy_finance/features/auth/ui/reset_password_screen.dart';
import 'package:crowzy_finance/features/auth/ui/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _NoRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

final List<String> _calls = [];
bool _loading = false;

class _FakeAuth extends AuthController {
  _FakeAuth() : super(_NoRepository()) {
    if (_loading) state = const AsyncValue.loading();
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    _calls.add('signIn $email $password');
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    _calls.add('signUp $email $password');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    _calls.add('reset $email');
  }

  @override
  Future<void> resetPasswordWithRecoveryLink({
    required String recoveryUrl,
    required String newPassword,
  }) async {
    _calls.add('recover $recoveryUrl $newPassword');
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    _calls.clear();
    _loading = false;
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWith((ref) => _FakeAuth())],
        child: MaterialApp(theme: AppTheme.dark, home: screen),
      ),
    );
    // A spinner animates forever, so there is nothing to settle in that case.
    if (_loading) {
      await tester.pump(const Duration(seconds: 1));
    } else {
      await tester.pumpAndSettle();
    }
  }

  Finder field(String label) => find.byType(TextFormField).at(
        {'Email': 0, 'Password': 1, 'Confirm password': 2}[label] ?? 0,
      );

  group('Login', () {
    testWidgets('shows the brand, two labelled fields and the actions', (tester) async {
      await pump(tester, const LoginScreen());

      expect(find.text('Crowzy Finance'), findsOneWidget);
      expect(find.text('YOUR MONEY, IN ORDER'), findsOneWidget);
      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('refuses an empty form and says why', (tester) async {
      await pump(tester, const LoginScreen());

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(_calls, isEmpty);
    });

    testWidgets('rejects a bad email and a short password', (tester) async {
      await pump(tester, const LoginScreen());

      await tester.enterText(field('Email'), 'not-an-email');
      await tester.enterText(field('Password'), '123');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
      expect(_calls, isEmpty);
    });

    testWidgets('signs in with the trimmed email and the password as typed', (tester) async {
      await pump(tester, const LoginScreen());

      await tester.enterText(field('Email'), '  kaze@example.com ');
      await tester.enterText(field('Password'), 'secret123');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(_calls, ['signIn kaze@example.com secret123']);
    });

    testWidgets('shows a spinner and blocks the button while signing in', (tester) async {
      _loading = true;
      await pump(tester, const LoginScreen());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign in'), findsNothing);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('links to the other auth screens', (tester) async {
      await pump(tester, const LoginScreen());

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();
      expect(find.byType(SignupScreen), findsOneWidget);
    });
  });

  group('Sign up', () {
    testWidgets('needs matching passwords', (tester) async {
      await pump(tester, const SignupScreen());

      expect(find.text('Sign up'), findsOneWidget); // app bar title
      await tester.enterText(field('Email'), 'kaze@example.com');
      await tester.enterText(field('Password'), 'secret123');
      await tester.enterText(field('Confirm password'), 'different1');
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(_calls, isEmpty);
    });

    testWidgets('creates the account and returns to sign in', (tester) async {
      await pump(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SignupScreen()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(field('Email'), 'kaze@example.com');
      await tester.enterText(field('Password'), 'secret123');
      await tester.enterText(field('Confirm password'), 'secret123');
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(_calls, ['signUp kaze@example.com secret123']);
      expect(find.byType(SignupScreen), findsNothing);
      expect(find.textContaining('Check your email to confirm'), findsOneWidget);
    });
  });

  group('Forgot password', () {
    testWidgets('sends the reset link and confirms it', (tester) async {
      await pump(tester, const ForgotPasswordScreen());

      expect(find.text('Forgot password'), findsOneWidget);
      expect(find.textContaining('Check your email'), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'kaze@example.com');
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(_calls, ['reset kaze@example.com']);
      expect(find.text('Check your email for the reset link.'), findsOneWidget);
    });

    testWidgets('does not send without a valid email', (tester) async {
      await pump(tester, const ForgotPasswordScreen());

      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(_calls, isEmpty);
    });

    testWidgets('leads on to the reset screen', (tester) async {
      await pump(tester, const ForgotPasswordScreen());

      await tester.tap(find.text('I have my reset link'));
      await tester.pumpAndSettle();

      expect(find.byType(ResetPasswordScreen), findsOneWidget);
    });
  });

  group('Reset password', () {
    testWidgets('needs the link and a matching new password', (tester) async {
      await pump(tester, const ResetPasswordScreen());

      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();

      expect(find.text('Paste the reset link'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(_calls, isEmpty);
    });

    testWidgets('submits the pasted link with the new password', (tester) async {
      await pump(tester, const ResetPasswordScreen());

      await tester.enterText(find.byType(TextFormField).at(0), ' https://x.test/#token ');
      await tester.enterText(find.byType(TextFormField).at(1), 'newsecret1');
      await tester.enterText(find.byType(TextFormField).at(2), 'newsecret1');
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();

      expect(_calls, ['recover https://x.test/#token newsecret1']);
    });
  });
}
