import 'package:flutter/material.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;

import 'package:flutter/material.dart';

class BarChartDemo extends StatelessWidget {
  final List<SymptomData> data;

  BarChartDemo({required this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<SymptomData, DateTime>> seriesList = [
      charts.Series<SymptomData, DateTime>(
        id: 'Symptom Data',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (SymptomData data, _) => data.date,
        measureFn: (SymptomData data, _) => data.value,
        data: data,
      )
    ];

    return SizedBox(
      height: 100,
      child: charts.TimeSeriesChart(
        seriesList,
        animate: true,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(zeroBound: false),
          renderSpec: charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 12,
              color: charts.MaterialPalette.gray.shade400,
            ),
            lineStyle: charts.LineStyleSpec(
              dashPattern: [4, 4],
              color: charts.MaterialPalette.gray.shade300,
            ),
          ),
        ),
        domainAxis: charts.DateTimeAxisSpec(
          tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
            day: charts.TimeFormatterSpec(
              format: 'd',
              transitionFormat: 'MM/dd/yyyy',
            ),
          ),
          renderSpec: charts.SmallTickRendererSpec(
            labelStyle: charts.TextStyleSpec(
              fontSize: 12,
              color: charts.MaterialPalette.gray.shade400,
            ),
            lineStyle: charts.LineStyleSpec(
              color: charts.MaterialPalette.gray.shade300,
            ),
          ),
        ),
        defaultRenderer: charts.BarRendererConfig<DateTime>(
          cornerStrategy: const charts.ConstCornerStrategy(30),
          barRendererDecorator: charts.BarLabelDecorator<DateTime>(),
        ),
      ),
    );
  }
}

class SymptomData {
  final DateTime date;
  final String symptom;
  final double value;

  SymptomData({required this.date, required this.symptom, required this.value});
}
