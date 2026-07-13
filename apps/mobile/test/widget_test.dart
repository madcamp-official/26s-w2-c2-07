import 'package:flutter_test/flutter_test.dart';
import 'package:nook_mobile/app.dart';

void main() {
  testWidgets('Nook 앱이 렌더링된다', (tester) async {
    await tester.pumpWidget(const NookApp());
    expect(find.text('Nook.'), findsOneWidget);
  });
}