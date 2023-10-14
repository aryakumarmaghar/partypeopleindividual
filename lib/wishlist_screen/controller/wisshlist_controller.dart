import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../centralize_api.dart';
class WishlistController extends GetxController{
  List allParties = [];

  @override
  void onInit(){
    super.onInit();
    getWishlistParty();


  }
  Future<void> getWishlistParty() async {
    final response = await http.post(
      Uri.parse(API.getWishListParty),
      headers: <String, String>{
        'x-access-token': GetStorage().read('token'),
      },
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 1) {
        print('Fetched wishlist parties successfully');
        print(jsonResponse); // Print the fetched data
          allParties = jsonResponse['data'];
           update();
      } else {
        print('Failed to fetch wishlist parties');
        allParties=[];
        update();
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to fetch wishlist parties');
    }
  }


  Future<void> deleteWishListParty(partyID) async {

    // Request headers
    Map<String, String> headers = {
      'x-access-token': '${GetStorage().read('token')}',
    };

    // Request body
    Map<String, dynamic> body = {
      'party_id': partyID,
    };

    try {
      // Send POST request
      http.Response response = await http.post(
        Uri.parse(API.deleteWishListParty),
        headers: headers,
        body: body,
      );
      print(response.body);
      // Check response status code
      if (response.statusCode == 200) {
        // Request successful
        print('Party successfully removed from wish list');
      } else {
        // Request failed
        print(
            'Failed to remove party from wish list. Status code: ${response.statusCode}');
      }
      getWishlistParty();
    } catch (e) {
      // Error occurred
      print('Error occurred while deleting wish list party: $e');
    }

  }

}