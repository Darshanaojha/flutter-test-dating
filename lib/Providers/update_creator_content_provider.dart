import 'dart:convert';
import 'dart:io';
import 'package:dating_application/Models/RequestModels/update_creator_content_request.dart';
import 'package:dating_application/Models/ResponseModels/update_creator_content_response.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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

      // Check if the file is an image and compress it
      File fileToUpload = request.file;
      String contentType = 'application/octet-stream';
      
      // Check if file is an image by extension
      final fileExtension = path.extension(request.file.path).toLowerCase();
      final isImage = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(fileExtension);
      
      if (isImage) {
        try {
          // Compress the image before uploading
          final compressedImageBytes = await FlutterImageCompress.compressWithFile(
            request.file.path,
            quality: 50,
          );

          if (compressedImageBytes != null) {
            // Create a temporary file for the compressed image
            final tempDir = await getTemporaryDirectory();
            final fileName = path.basename(request.file.path);
            final compressedFilePath = path.join(
              tempDir.path,
              'compressed_${DateTime.now().millisecondsSinceEpoch}_$fileName',
            );
            fileToUpload = File(compressedFilePath);
            await fileToUpload.writeAsBytes(compressedImageBytes);
            contentType = 'image/jpeg';
          } else {
            print('⚠️ Image compression failed, uploading original image');
          }
        } catch (e) {
          print('⚠️ Error compressing image: $e, uploading original file');
        }
      }

      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          'file',
          fileToUpload.path,
          contentType: MediaType.parse(contentType),
        ),
      );

      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Clean up temporary compressed file if it was created (after upload completes)
      if (isImage && fileToUpload.path != request.file.path) {
        try {
          await fileToUpload.delete();
        } catch (e) {
          print('Warning: Could not delete temporary compressed file: $e');
        }
      }

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
