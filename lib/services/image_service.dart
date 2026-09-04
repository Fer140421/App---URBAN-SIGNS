import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/app_constants.dart';

class ImageService {
  ImageService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> pickCamera() => _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 82,
        maxWidth: 1800,
      );

  Future<XFile?> pickGallery() => _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1800,
      );

  Future<String> uploadToSupabase(XFile image) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw StateError('Usuario no autenticado.');

    final bytes = await image.readAsBytes();
    final rawExt = image.name.contains('.') ? image.name.split('.').last : 'jpg';
    final ext = rawExt.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final path = '$userId/${DateTime.now().microsecondsSinceEpoch}.${ext.isEmpty ? 'jpg' : ext}';

    await client.storage.from(AppConstants.storageBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: false,
            contentType: image.mimeType,
          ),
        );
    return client.storage.from(AppConstants.storageBucket).getPublicUrl(path);
  }
}
