// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:event_booking_app/main.dart';

void main() {
  testWidgets('App builds without crashing', (tester) async {
    await tester.pumpWidget(const EventBookingApp());

    expect(find.byType(EventBookingApp), findsOneWidget);
  });
}
