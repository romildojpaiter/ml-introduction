import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recoface/models/user.dart';
import 'package:recoface/pages/face_scan/extensions/nv21_converter.dart';
import 'package:recoface/pages/face_scan/ml_service.dart';
import 'package:recoface/pages/login_page.dart';
import 'package:recoface/utils/local_db.dart';
import 'package:recoface/utils/utils.dart';
import 'package:recoface/widgets/common_widgets.dart';

late List<CameraDescription> _cameras;

class FaceScanScreen extends StatefulWidget {
  final User? user;
  // final List<User> users;

  const FaceScanScreen({super.key, this.user});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  TextEditingController controller = TextEditingController();
  late CameraController _cameraController;
  bool flash = false;
  bool isControllerInitialized = false;
  late FaceDetector _faceDetector;
  final MLService _mlService = MLService();
  List<Face> facesDetected = [];

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  initState() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
      ),
    );
    initilizeCamera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: isControllerInitialized ? CameraPreview(_cameraController) : null,
            ),
            _backButton(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Lottie.asset("assets/loading.json", width: MediaQuery.of(context).size.width * 0.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Nome usuário",
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: CWidgets.customExtendedButton(
                            text: "Capturar",
                            context: context,
                            isClickable: true,
                            onTap: () {
                              bool canProcess = false;
                              _cameraController.startImageStream((CameraImage image) async {
                                printIfDebug('format -- ${image.format.group}');
                                await _cameraController.stopImageStream();
                                if (canProcess) {
                                  return;
                                }
                                canProcess = true;
                                _predictFacesFromImage(image: image).then((value) {
                                  canProcess = false;
                                });
                                return;
                              });
                            }),
                      ),
                      IconButton(
                          icon: Icon(
                            flash ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {})
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _backButton() => Positioned(
        top: 50,
        left: 10,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.arrow_back_ios_outlined,
              size: 20,
            ),
          ),
        ),
      );

  Future initilizeCamera() async {
    _cameras = await availableCameras();
    var imageGroup = Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888;
    printIfDebug("Image Group: $imageGroup");
    _cameraController = CameraController(
      _cameras[1],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
    isControllerInitialized = true;
    _cameraController.setFlashMode(flash ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<void> detectFacesFromImage(CameraImage image) async {
    printIfDebug("Planes ${image.planes}");
    final plane = image.planes.first;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    printIfDebug("Format da captura $format");
    InputImageMetadata imageMetadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotationIntToImageRotation(_cameraController.description.sensorOrientation),
        //format: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21,
        //format: format!,
        format: InputImageFormat.nv21,
        bytesPerRow: plane.bytesPerRow
        //bytesPerRow: 0
        );

    InputImage visionImage = InputImage.fromBytes(
      //bytes: plane.bytes,
      // metadata: imageMetadata,
      //bytes: imageConverted!.getBytes(),
      bytes: image.getNv21Uint8List(),
      metadata: imageMetadata,
    );

    _writeToFile(visionImage.bytes!);

    var faces = await _faceDetector.processImage(visionImage);

    if (faces.isNotEmpty) {
      facesDetected = faces;
      printIfDebug("### Face Detectada: $facesDetected");
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _cameras[1];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      printIfDebug("Estou na plataforma Android");
      var rotationCompensation = _orientations[_cameraController.value.deviceOrientation];
      printIfDebug("rotationCompensation $rotationCompensation");
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
      printIfDebug("rotationCompensation 2 $rotationCompensation");
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');
    printIfDebug("final rotation: $rotation");

    // get image format
    printIfDebug("format raw: ${image.format.raw}");
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    printIfDebug("format: $format");
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    // if (format == null ||
    //     (Platform.isAndroid && format != InputImageFormat.nv21) ||
    //     (Platform.isAndroid && format != InputImageFormat.yuv_420_888) ||
    //     (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;
    printIfDebug("Logo apos o format");

    // since format is constraint to nv21 or bgra8888, both only have one plane
    printIfDebug("plane: ${image.planes}");

    final plane = image.planes.first;
    printIfDebug("plane: $plane");

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format!, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  Future<void> _predictFacesFromImage({required CameraImage image}) async {
    printIfDebug("Entrei no _predictFacesFromImage");

    await detectFacesFromImage(image);

    if (facesDetected.isNotEmpty) {
      User? user = await _mlService.predict(
          image, facesDetected[0], widget.user != null, widget.user != null ? widget.user!.name! : controller.text);

      if (widget.user == null) {
        // register case
        printIfDebug("Usuário registrado com sucesso!!");

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Usuário registrado com sucesso!"),
            title: Text("Alert Dialog title"),
            actions: [
              ElevatedButton(
                child: Text("Voltar"),
                onPressed: () {
                  //Navigator.pushNamed(context, "/screen1");
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: Text("Logar"),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => FaceScanScreen(user: LocalDb.getUser()))),
              ),
            ],
          ),
        );
      } else {
        // login case
        if (user == null) {
          printIfDebug("Usuário desconhecido!!");

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Usuário desconhecido!"),
              content: Text("Não foi possível realizar o login"),
              actions: [
                ElevatedButton(
                  child: Text("Voltar"),
                  onPressed: () {
                    //Navigator.pushNamed(context, "/screen1");
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        } else {
          printIfDebug("Usuario Encontrado: $user");

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Usuário encontrado!"),
              content: Text("Parabéns sua face foi encontrada"),
              actions: [
                ElevatedButton(
                  child: Text("Logar"),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
                ),
              ],
            ),
          );
        }
      }
    }
    if (mounted) setState(() {});
    await takePicture();
  }

  Future<void> takePicture() async {
    if (facesDetected.isNotEmpty) {
      //await _cameraController.stopImageStream();
      XFile file = await _cameraController.takePicture();
      file = XFile(file.path);
      _convertToFile(file);
      _cameraController.setFlashMode(FlashMode.off);
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          content: Text('Rosto (Face) não encontrada!'),
        ),
      );
    }
  }

  File _convertToFile(XFile xFile) => File(xFile.path);

  Future<File> _writeToFile(Uint8List data) async {
    Directory tempDir = await getLibraryDirectory();
    String tempPath = tempDir.path;
    var filePath = "$tempPath/file_0${Random.secure().nextDouble()}.tmp"; // file_01.tmp is dump file, can be anything
    //return File(filePath).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    return File(filePath).writeAsBytes(data);
  }
}
