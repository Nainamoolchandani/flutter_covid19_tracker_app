import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_covid19_tracker_app/models/WorldStatesModels.dart';
import 'package:flutter_covid19_tracker_app/services/utilities/app_url.dart';
import 'package:http/http.dart' as http;
class StateServices{

   Future<WorldStatesModels> fetchWorldStatesRecords () async{
    final response =  await http.get(Uri.parse(AppUrl.worldStateApi));

    if(response.statusCode == 200){

          var data = jsonDecode(response.body);
         return WorldStatesModels.fromJson(data);
    }
    else{
      throw Exception("Error");


    }
       

   }

}