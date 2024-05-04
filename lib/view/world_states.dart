import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_covid19_tracker_app/models/WorldStatesModels.dart';
import 'package:flutter_covid19_tracker_app/services/states_services.dart';
import 'dart:math' as math;

import 'package:flutter_covid19_tracker_app/view/world_states.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pie_chart/pie_chart.dart';

import 'Countries_list.dart';

class WorldStatescreen extends StatefulWidget {
  const WorldStatescreen({Key? key});

  @override
  State<WorldStatescreen> createState() => _WorldStatescreenState();
}

class _WorldStatescreenState extends State<WorldStatescreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final colorList = const [
    Color(0xff4285F4),
    Color(0xff1aa260),
    Color(0xffde5246),
  ];

  Future<WorldStatesModels> fetchWorldStatesRecords() async {
    final response = await http.get(Uri.parse(AppUrl.worldStateApi)); // Using AppUrl to get API endpoint
    if (response.statusCode == 200) {
      return WorldStatesModels.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load world states data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: FutureBuilder<WorldStatesModels>(
              future: fetchWorldStatesRecords(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitFadingCircle(
                      color: Colors.white,
                      size: 50.0,
                      controller: _controller,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  return Column(
                    children: [
                      PieChart(
                        dataMap: {
                          "Total": double.parse(snapshot.data!.cases.toString()),
                          "Recovered": double.parse(snapshot.data!.recovered.toString()),
                          "Deaths": double.parse(snapshot.data!.deaths.toString()),
                        },
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValuesInPercentage: true
                        ),
                        chartRadius: MediaQuery.of(context).size.width / 3.2,
                        animationDuration: const Duration(milliseconds: 1200),
                        legendOptions: const LegendOptions(
                          legendPosition: LegendPosition.left,
                        ),
                        chartType: ChartType.ring,
                        colorList: colorList,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * .08),
                        child: Card(
                          child: Column(
                            children: [
                              ReusableRow(title: "Total", value: snapshot.data!.cases.toString()),
                              ReusableRow(title: "Recovered", value: snapshot.data!.recovered.toString()),
                              ReusableRow(title: "Deaths", value: snapshot.data!.deaths.toString()),
                              ReusableRow(title: "Effected Countries", value: snapshot.data!.affectedCountries.toString()),
                              ReusableRow(title: "Critical", value: snapshot.data!.critical.toString()),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder:(context)=> CountriesListScreen()));
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xff1aa260),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(child: Text("Track Countries")),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: Text('No data available'),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ReusableRow extends StatelessWidget {
  final String title;
  final String value;

  const ReusableRow({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(value),
            ],
          ),
          const SizedBox(height: 5),
          const Divider(),
        ],
      ),
    );
  }
}

class AppUrl {
  static const String baseUrl = "https://disease.sh/v3/covid-19/";

  static const String worldStateApi = baseUrl + "all";
  static const String countriesList = baseUrl + "countries";
}
