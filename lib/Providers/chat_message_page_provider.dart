import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

final String baseUrl = "http://192.168.1.22/dating_backend_springboot/admin";
class ChatMessagePageProvider extends GetConnect{

    final token =
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJUaGVfY2xhaW0iLCJhdWQiOiJUaGVfQXVkIiwiaWF0IjoxNzMxMzk4MDUyLCJuYmYiOjE3MzEzOTgwNTIsImV4cCI6MTczMzk5MDA1MiwiZGF0YSI6WyIyOSIsInVzZXIiLCIzIl19.9BehUe9zCCEia9UU2EguEJygGY-Hxe968Rawm7dvnYc";



  Future<bool> chatHistory() async{
    try {
      final response =
          await post(Uri.parse('$baseUrl/Chats/chat_history'),headers: {
          'Authorization': 'Bearer $token',
        },);
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Chat History: ${jsonResponse['payload']}');
          return true;
        } else {
          debugPrint(
              "Error occured in Chat History: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Chat History. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Chat History: $e');
      return false;
    }
  } 

  Future<bool> usersSuggestions() async{
    try {
      final response =
          await post(Uri.parse('$baseUrl/Chats/user_suggestions'),headers: {
          'Authorization': 'Bearer $token',
        },);
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Chat User Suggestions: ${jsonResponse['payload']}');
          return true;
        } else {
          debugPrint(
              "Error occured in Chat User Suggestions: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Chat User Suggestions. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Chat User Suggestions: $e');
      return false;
    }
  } 
}