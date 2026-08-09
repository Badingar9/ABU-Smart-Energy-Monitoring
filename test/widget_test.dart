// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:scada_app/data/providers/fake_data_provider.dart';
import 'package:scada_app/main.dart';

void main() {
  testWidgets('App se lance et affiche au moins un bâtiment', (
    WidgetTester tester,
  ) async {
    // Chaque test reçoit sa propre instance de FakeDataProvider — évite
    // qu'un test hérite de l'état (alertes, coupures) laissé par un autre.
    await tester.pumpWidget(
      AbuSmartEnergyApp(dataProvider: FakeDataProvider()),
    );

    // Laisse le premier frame se stabiliser sans attendre les Timer
    // périodiques de la simulation (pump, pas pumpAndSettle — sinon le
    // test ne se termine jamais à cause du Timer.periodic).
    await tester.pump();

    expect(find.text('Validation Repositories & Services'), findsOneWidget);
  });
}
