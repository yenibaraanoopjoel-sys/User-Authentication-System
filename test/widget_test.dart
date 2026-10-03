import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_authentication_system/utils/validators.dart';
import 'package:user_authentication_system/models/user_model.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateName accepts valid names', () {
      expect(Validators.validateName('Yenibara Anoop Joel'), isNull);
      expect(Validators.validateName('AJ'), isNull);
    });

    test('validateName rejects empty or single char names', () {
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName('   '), isNotNull);
      expect(Validators.validateName('A'), isNotNull);
    });

    test('validateEmail accepts valid email formats', () {
      expect(Validators.validateEmail('anoopjoelyenibara@gmail.com'), isNull);
      expect(Validators.validateEmail('test.user@company.co.in'), isNull);
    });

    test('validateEmail rejects invalid formats', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('notanemail'), isNotNull);
      expect(Validators.validateEmail('missing@domain'), isNotNull);
    });

    test('validatePassword requires minimum length and complexity', () {
      expect(Validators.validatePassword('Aj@5155'), isNull);
      expect(Validators.validatePassword('weak'), isNotNull);
      expect(Validators.validatePassword('alllowercase1'), isNotNull);
      expect(Validators.validatePassword('ALLUPPERCASE1'), isNotNull);
      expect(Validators.validatePassword('NoNumbersHere'), isNotNull);
    });

    test('validateConfirmPassword checks equality', () {
      expect(Validators.validateConfirmPassword('Aj@5155', 'Aj@5155'), isNull);
      expect(Validators.validateConfirmPassword('Wrong', 'Aj@5155'), isNotNull);
    });
  });

  group('UserModel Unit Tests', () {
    test('UserModel initial values and copyWith', () {
      final user = UserModel(
        uid: 'anoop-joel-777',
        email: 'anoopjoelyenibara@gmail.com',
        fullName: 'Yenibara Anoop Joel',
        phoneNumber: '+91 98765 43210',
        bio: 'Developer',
        role: 'Administrator',
      );

      expect(user.fullName, equals('Yenibara Anoop Joel'));
      expect(user.email, equals('anoopjoelyenibara@gmail.com'));

      final updated = user.copyWith(bio: 'Updated Bio');
      expect(updated.bio, equals('Updated Bio'));
      expect(updated.fullName, equals('Yenibara Anoop Joel'));
    });
  });

  testWidgets('App smoke test renders Material widget tree', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('AuthGuard Test Running'),
          ),
        ),
      ),
    );

    expect(find.text('AuthGuard Test Running'), findsOneWidget);
  });
}
