import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

Future<File> getImageFileFromAssets(String path) async {
  var bytes = await rootBundle.load(path);
  String tempPath = (await getTemporaryDirectory()).path;
  File file = File('$tempPath/profile.png');
  await file.writeAsBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));

  return file;
}
