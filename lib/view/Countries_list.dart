import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

import '../services/utilities/app_url.dart';

class CountriesListScreen extends StatefulWidget {
  const CountriesListScreen({Key? key}) : super(key: key);

  @override
  State<CountriesListScreen> createState() => _CountriesListScreenState();
}

class _CountriesListScreenState extends State<CountriesListScreen> {
  late Future<List<dynamic>> _countriesListFuture;
  TextEditingController _searchController = TextEditingController();
  late List<dynamic> _filteredCountries;

  @override
  void initState() {
    super.initState();
    _countriesListFuture = countriesListApi();
    _filteredCountries = [];
  }

  Future<List<dynamic>> countriesListApi() async {
    final response = await http.get(Uri.parse(AppUrl.countriesList));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load countries data');
    }
  }

  void _filterCountries(String searchText) {
    _countriesListFuture.then((countries) {
      setState(() {
        _filteredCountries = countries
            .where((country) =>
            country["country"]
                .toString()
                .toLowerCase()
                .contains(searchText.toLowerCase()))
            .toList();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _searchController,
                onChanged: _filterCountries,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  hintText: "Search with Country name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _countriesListFuture,
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerEffect();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  } else if (snapshot.hasData || _filteredCountries.isNotEmpty) {
                    final countries =
                    _filteredCountries.isNotEmpty ? _filteredCountries : snapshot.data!;
                    return ListView.builder(
                      itemCount: countries.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(countries[index]["country"]),
                          subtitle: Text(
                            countries[index]["cases"].toString(),
                          ),
                          leading: Image.network(
                            countries[index]["countryInfo"]["flag"],
                            height: 50,
                            width: 50,
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text("No data available"),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Container(
              width: 200,
              height: 20,
              color: Colors.white,
            ),
            subtitle: Container(
              width: 100,
              height: 15,
              color: Colors.white,
            ),
            leading: Container(
              width: 50,
              height: 50,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
class AppUrl{
  static const String baseUrl = "https://disease.sh/v3/covid-19/";

  static const String worldStateApi = baseUrl + "all";
  static const String countriesList = baseUrl + "countries";
}