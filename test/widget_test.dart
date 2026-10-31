import 'package:flutter_test/flutter_test.dart';

import 'package:architect_solver_app/main.dart';

void main() {
  testWidgets('Home screen opens and shows app title', (tester) async {
    await tester.pumpWidget(const ArchitectSolverApp());

    expect(find.text('مساعد البدائل الهندسية'), findsOneWidget);
    expect(find.text('عرض البدائل الهندسية'), findsOneWidget);
  });
}
