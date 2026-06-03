import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:downloadsfolder/downloadsfolder.dart';
import '../../../core/helper/string_format_helper.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
import '../snack_bar/show_custom_snackbar.dart';

class DownloadingDialog extends StatefulWidget {
  final String url;
  final String fileName;
  final bool isPdf;
  final bool isImage;
  const DownloadingDialog({super.key, required this.isImage, required this.url, this.isPdf = true, required this.fileName});

  @override
  DownloadingDialogState createState() => DownloadingDialogState();
}

class DownloadingDialogState extends State<DownloadingDialog> {
  int _total = 0, _received = 0;
  late http.StreamedResponse _response;
  File? _image;
  final List<int> _bytes = [];

  Future<void> _downloadFile() async {
    // Permission granted, proceed with file download
    _response = await http.Client().send(http.Request('GET', Uri.parse(widget.url)));
    _total = _response.contentLength ?? 0;
    // Extract file extension from the URL
    String fileExtension = widget.url.split('.').last;
    _response.stream.listen((value) {
      setState(() {
        _bytes.addAll(value);
        _received += value.length;
      });
    }).onDone(() async {
      Directory? directory;

      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = (await getDownloadsDirectory())!;
      }
      final file = File('${directory.path}/${MyStrings.appName}_${DateTime.now()}.$fileExtension');

      File savedFile = await file.writeAsBytes(_bytes, flush: false);

      bool? success = await copyFileIntoDownloadFolder(file.path, "${MyStrings.appName}_${DateTime.now()}.$fileExtension");
      if (success == true) {
        printx('File copied successfully.');
        deleteFile(savedFile.path);
      } else {
        printx('Failed to copy file.');
      }

      Get.back();
      // CustomSnackBar.success(successList: ['${MyStrings.fileDownloadedSuccess}: ${raf.path.toString()}']);
      CustomSnackBar.success(successList: [(MyStrings.fileDownloadedSuccess)]);
      setState(() {
        _image = file;
      });
    });
  }

  Future<void> deleteFile(String filePath) async {
    try {
      // Create a File object for the file to be deleted
      File file = File(filePath);

      // Check if the file exists
      if (await file.exists()) {
        // Delete the file
        await file.delete();
        printx('Temp File deleted successfully: $filePath');
      } else {
        printx('Temp File not found: $filePath');
      }
    } catch (e) {
      printx('Error deleting file: $e');
    }
  }

  _saveImage() async {
    var response = await Dio().get(widget.url, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaverPlus.saveImage(Uint8List.fromList(response.data), quality: 60, name: widget.fileName);

    try {
      dynamic value = result['isSuccess'];
      if (value.toString() == 'true') {
        Get.back();
        CustomSnackBar.success(successList: [(MyStrings.fileDownloadedSuccess)]);
      } else {
        Get.back();
        dynamic errorMessage = result['errorMessage'];
        CustomSnackBar.error(errorList: [errorMessage]);
      }
    } catch (e) {
      if (kDebugMode) {
        printx(e.toString());
      }
      Get.back();
      CustomSnackBar.error(errorList: [MyStrings.requestFail]);
    }
  }

  @override
  void initState() {
    super.initState();
    downloadFileInStorage();
  }

  downloadFileInStorage() async {
    // Check and request storage permission if needed
    // await Permission.manageExternalStorage.request();
    // var status = await Permission.manageExternalStorage.status;
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();

      if (!status.isGranted) {
        status = await Permission.storage.request();
        print('Storage permission denied.');
        return;
      }
    }
    printx(status.isGranted);

    if (status.isGranted) {
      if (widget.isImage) {
        _saveImage();
      } else {
        _downloadFile();
      }
    } else {
      status = await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: MyColor.transparentColor,
      backgroundColor: MyColor.getCardBgColor(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: SpinKitThreeBounce(
                    color: MyColor.primaryColor,
                    size: 20.0,
                  ))),
          Visibility(
              visible: !widget.isImage,
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text('${MyStrings.downloading.tr} ${_received ~/ 1024}/${_total ~/ 1024} ${'KB'.tr}', style: regularDefault),
                ],
              ))
        ],
      ),
    );
  }
}
