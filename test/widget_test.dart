import 'package:flutter_test/flutter_test.dart';
import 'package:savefood/main.dart';

void main() {
  testWidgets('SaveFood app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SaveFoodApp());
    expect(find.text('SaveFood'), findsOneWidget);
  });
}
