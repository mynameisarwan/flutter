// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('tap-select a day', (WidgetTester tester) async {
    Key _datePickerKey = new UniqueKey();
    DateTime _selectedDate = new DateTime(2016, DateTime.JULY, 26);

    await tester.pumpWidget(
      new Overlay(
        initialEntries: <OverlayEntry>[
          new OverlayEntry(
            builder: (BuildContext context) => new StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return new Positioned(
                  width: 400.0,
                  child: new SingleChildScrollView(
                    child: new Material(
                      child: new MonthPicker(
                        firstDate: new DateTime(0),
                        lastDate: new DateTime(9999),
                        key: _datePickerKey,
                        selectedDate: _selectedDate,
                        onChanged: (DateTime value) {
                          setState(() {
                            _selectedDate = value;
                          });
                        }
                      )
                    )
                  )
                );
              }
            )
          )
        ]
      )
    );

    await tester.tapAt(const Point(50.0, 100.0));
    expect(_selectedDate, equals(new DateTime(2016, DateTime.JULY, 26)));
    await tester.pump(const Duration(seconds: 2));

    await tester.tapAt(const Point(300.0, 100.0));
    expect(_selectedDate, equals(new DateTime(2016, DateTime.JULY, 1)));
    await tester.pump(const Duration(seconds: 2));

    await tester.tapAt(const Point(380.0, 20.0));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(_selectedDate, equals(new DateTime(2016, DateTime.JULY, 1)));

    await tester.tapAt(const Point(300.0, 100.0));
    expect(_selectedDate, equals(new DateTime(2016, DateTime.AUGUST, 5)));
    await tester.pump(const Duration(seconds: 2));

    await tester.scroll(find.byKey(_datePickerKey), const Offset(-300.0, 0.0));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(_selectedDate, equals(new DateTime(2016, DateTime.AUGUST, 5)));

    await tester.tapAt(const Point(45.0, 270.0));
    expect(_selectedDate, equals(new DateTime(2016, DateTime.SEPTEMBER, 25)));
    await tester.pump(const Duration(seconds: 2));

    await tester.scroll(find.byKey(_datePickerKey), const Offset(300.0, 10.0));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(_selectedDate, equals(new DateTime(2016, DateTime.SEPTEMBER, 25)));

    await tester.tapAt(const Point(210.0, 180.0));
    expect(_selectedDate, equals(new DateTime(2016, DateTime.AUGUST, 17)));
    await tester.pump(const Duration(seconds: 2));

  });

  testWidgets('render picker with intrinsic dimensions', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Overlay(
        initialEntries: <OverlayEntry>[
          new OverlayEntry(
            builder: (BuildContext context) => new StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return new IntrinsicWidth(
                  child: new IntrinsicHeight(
                    child: new Material(
                      child: new SingleChildScrollView(
                        child: new MonthPicker(
                          firstDate: new DateTime(0),
                          lastDate: new DateTime(9999),
                          onChanged: (DateTime value) { },
                          selectedDate: new DateTime(2000, DateTime.JANUARY, 1)
                        )
                      )
                    )
                  )
                );
              }
            )
          )
        ]
      )
    );
    await tester.pump(const Duration(seconds: 5));
  });

  Future<Null> preparePicker(WidgetTester tester, Future<Null> callback(Future<DateTime> date)) async {
    BuildContext buttonContext;
    await tester.pumpWidget(new MaterialApp(
      home: new Material(
        child: new Builder(
          builder: (BuildContext context) {
            return new RaisedButton(
              onPressed: () {
                buttonContext = context;
              },
              child: new Text('Go'),
            );
          },
        ),
      ),
    ));

    await tester.tap(find.text('Go'));
    expect(buttonContext, isNotNull);

    Future<DateTime> date = showDatePicker(
      context: buttonContext,
      initialDate: new DateTime(2016, DateTime.JANUARY, 15),
      firstDate: new DateTime(2001, DateTime.JANUARY, 1),
      lastDate: new DateTime(2031, DateTime.DECEMBER, 31),
    );

    await tester.pumpUntilNoTransientCallbacks(const Duration(seconds: 1));
    await callback(date);
  }

  testWidgets('Initial date is the default', (WidgetTester tester) async {
    await preparePicker(tester, (Future<DateTime> date) async {
      await tester.tap(find.text('OK'));
      expect(await date, equals(new DateTime(2016, DateTime.JANUARY, 15)));
    });
  });

  testWidgets('Can cancel', (WidgetTester tester) async {
    await preparePicker(tester, (Future<DateTime> date) async {
      await tester.tap(find.text('CANCEL'));
      expect(await date, isNull);
    });
  });

  testWidgets('Can select a day', (WidgetTester tester) async {
    await preparePicker(tester, (Future<DateTime> date) async {
      await tester.tap(find.text('12'));
      await tester.tap(find.text('OK'));
      expect(await date, equals(new DateTime(2016, DateTime.JANUARY, 12)));
    });
  });

  testWidgets('Can select a month', (WidgetTester tester) async {
    await preparePicker(tester, (Future<DateTime> date) async {
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpUntilNoTransientCallbacks(const Duration(seconds: 1));
      await tester.tap(find.text('25'));
      await tester.tap(find.text('OK'));
      expect(await date, equals(new DateTime(2015, DateTime.DECEMBER, 25)));
    });
  });

  testWidgets('Can select a year', (WidgetTester tester) async {
    await preparePicker(tester, (Future<DateTime> date) async {
      await tester.tap(find.text('2016'));
      await tester.pump();
      await tester.tap(find.text('2006'));
      await tester.tap(find.text('OK'));
      expect(await date, equals(new DateTime(2006, DateTime.JANUARY, 15)));
    });
  });

  testWidgets('Can select a year and then a day', (WidgetTester tester) async {
    await preparePicker(tester, (Future<DateTime> date) async {
      await tester.tap(find.text('2016'));
      await tester.pump();
      await tester.tap(find.text('2005'));
      await tester.pump();
      String dayLabel = new DateFormat('E, MMM\u00a0d').format(new DateTime(2005, DateTime.JANUARY, 15));
      await tester.tap(find.text(dayLabel));
      await tester.pump();
      await tester.tap(find.text('19'));
      await tester.tap(find.text('OK'));
      expect(await date, equals(new DateTime(2005, DateTime.JANUARY, 19)));
    });
  });
}
