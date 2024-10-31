import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:recoface/pages/face_recognition/image_compare/functions.dart';
import 'package:recoface/utils/local_db.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;
import '../../../models/user.dart';
import '../../utils/utils.dart';
import 'image_converter.dart';

class MLService {
  late Interpreter interpreter;
  List? predictedArray;

  Future<User?> predict(CameraImage cameraImage, Face face, bool loginUser, String name) async {
    List input = _preProcess(cameraImage, face);

    printIfDebug("preProcess: $input");

    input = input.reshape([1, 112, 112, 3]);

    List output = List.generate(1, (index) => List.filled(192, 0));

    await initializeInterpreter();

    interpreter.run(input, output);
    output = output.reshape([192]);

    predictedArray = List.from(output);

    if (!loginUser) {
      printIfDebug("### Salvando Usuario");
      // LocalDb.setUserDetails(User(name: name, array: predictedArray!));
      LocalDb.saveUser(User(name: name, array: predictedArray!));
      return null;
    } else {
      printIfDebug("### Recuperando Usuario");
      int minDist = 999;
      double threshold = 1.5;
      printIfDebug("### Predicty $predictedArray");
      //var userFound = LocalDb.foundUser(predictedArray!);
      User? userFound;
      LocalDb.getUsers().forEach((u) async {
        printIfDebug("### User Name: ${u.name}");
        printIfDebug("### User Array: ${u.array}");
        //var dist = await compareImages(src1: predictedArray!, src2: u.array!);
        var dist = euclideanDistance(predictedArray!, u.array!);
        printIfDebug("Dist: $dist");
        if (dist <= threshold && dist < minDist) {
          printIfDebug("Encontrei o seguinte User: ${u.name}");
          userFound = u;
        }
      });
      return userFound;
    }
  }

  euclideanDistance(List l1, List l2) {
    double sum = 0;
    for (int i = 0; i < l1.length; i++) {
      sum += pow((l1[i] - l2[i]), 2);
    }

    return pow(sum, 0.5);
  }

  initializeInterpreter() async {
    Delegate? delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
            options: GpuDelegateOptionsV2(
          isPrecisionLossAllowed: false,
          // inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
          // inferencePriority1: TfLiteGpuInferencePriority.minLatency,
          // inferencePriority2: TfLiteGpuInferencePriority.auto,
          // inferencePriority3: TfLiteGpuInferencePriority.auto,
        ));
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(
            allowPrecisionLoss: true,
            waitType: 1,
          ),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate!);

      interpreter = await Interpreter.fromAsset(
        'assets/mobilefacenet.tflite',
        options: interpreterOptions,
      );
    } catch (e) {
      printIfDebug('Failed to load model.');
      printIfDebug(e);
    }
  }

  List _preProcess(CameraImage image, Face faceDetected) {
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, size: 112);

    Float32List imageAsList = _imageToByteListFloat32(img);
    return imageAsList;
  }

  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(
      convertedImage,
      x: x.round(),
      y: y.round(),
      width: w.round(),
      height: h.round(),
    );
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    var img1 = imglib.copyRotate(img!, angle: -90);
    return img1;
  }

  Float32List _imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        int pixel = image.getPixelIndex(j, i);

        // Extract RGBA components from pixel value
        int r = (pixel >> 24) & 0xFF;
        int g = (pixel >> 16) & 0xFF;
        int b = (pixel >> 8) & 0xFF;

        // Normalize and store pixel values
        buffer[pixelIndex++] = (r - 128) / 128.0;
        buffer[pixelIndex++] = (g - 128) / 128.0;
        buffer[pixelIndex++] = (b - 128) / 128.0;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }
}
