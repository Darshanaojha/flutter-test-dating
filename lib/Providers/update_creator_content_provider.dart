import 'dart:convert';
import 'package:dating_application/Models/RequestModels/update_creator_content_request.dart';
import 'package:dating_application/Models/ResponseModels/update_creator_content_response.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
class UpdateCreatorContentProvider {
  Future<UpdateCreatorContentResponse?> updateCreatorContent(
      UpdateCreatorContentRequest request) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      final uri =
          Uri.parse('$springbooturl/creator/update/${request.contentId}');
      final multipartRequest = http.MultipartRequest('POST', uri)
        ..fields['title'] = request.title
        ..fields['description'] = request.description
        ..fields['type'] = request.type
        ..fields['actual_amount'] = request.actualAmount
        ..fields['offered_discount'] = request.offeredDiscount
        ..headers['Authorization'] = 'Bearer $token';

      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          'file',
          request.file.path,
          contentType: MediaType('application', 'octet-stream'),
        ),
      );

      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return UpdateCreatorContentResponse.fromJson(
            response.body.isNotEmpty ? jsonDecode(response.body) : {});
      } else {
        failure('Error',
            'Upload failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      failure('Error in updateCreatorContent', e.toString());
      return null;
    }
  }
}
