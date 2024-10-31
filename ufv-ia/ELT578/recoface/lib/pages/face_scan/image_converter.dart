import 'dart:typed_data';

import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';

import '../../utils/utils.dart';

const shift = (0xFF << 24);

imglib.Image? convertToImage(CameraImage image) {
  printIfDebug("convertToImage: ${image.format.group}");
  try {
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(image);
    }
    throw Exception('Image format not supported');
  } catch (e) {
    printIfDebug("ERROR: " + e.toString());
  }
  return null;
}

imglib.Image _convertBGRA8888(CameraImage image) {
  final plane = image.planes.first;
  return imglib.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: plane.bytes.buffer,
    format: imglib.Format.uint8,
  );
}

imglib.Image convertNV21(CameraImage image) {
  final width = image.width.toInt();
  final height = image.height.toInt();
  Uint8List yuv420sp = image.planes[0].bytes;

  // Initial conversion from NV21 to RGB
  final outImg = imglib.Image(height: height, width: width); // Note the swapped dimensions
  final int frameSize = width * height;

  for (int j = 0, yp = 0; j < height; j++) {
    int uvp = frameSize + (j >> 1) * width, u = 0, v = 0;
    for (int i = 0; i < width; i++, yp++) {
      int y = (0xff & yuv420sp[yp]) - 16;
      if ((i & 1) == 0) {
        v = (0xff & yuv420sp[uvp++]) - 128;
        u = (0xff & yuv420sp[uvp++]) - 128;
      }
      int y1192 = 1192 * y;
      int r = (y1192 + 1634 * v);
      int g = (y1192 - 833 * v - 400 * u);
      int b = (y1192 + 2066 * u);

      if (r < 0) {
        r = 0;
      } else if (r > 262143) r = 262143;
      if (g < 0) {
        g = 0;
      } else if (g > 262143) g = 262143;
      if (b < 0) {
        b = 0;
      } else if (b > 262143) b = 262143;

      outImg.setPixelRgba(
          j, width - i - 1, ((r << 6) & 0xff0000) >> 16, ((g >> 2) & 0xff00) >> 8, (b >> 10) & 0xff, shift);
    }
  }
  return outImg;
  // Rotate the image by 90 degrees (or 270 degrees if needed)
  // return imglib.copyRotate(outImg, -90); // Use -90 for a 270 degrees rotation
}

imglib.Image _convertYUV420(CameraImage image) {
  printIfDebug("Entrei no _convertYUV420");

  // // Get the Y, U, and V planes
  // final yPlane = image.planes[0].bytes;
  // final uPlane = image.planes[1].bytes;
  // final vPlane = image.planes[2].bytes;

  // // Get the image dimensions
  // final width = image.width;
  // final height = image.height;

  // // Convert YUV to RGB
  // final rgbBytes = yuvToRgb(yPlane, uPlane, vPlane, width, height);

  // // Create an imglib.Image from the RGB bytes
  // final img = imglib.Image.fromBytes(
  //   width: width,
  //   height: height,
  //   bytes: rgbBytes.buffer,
  // );

  int width = image.width;
  int height = image.height;

  var img = imglib.Image(width: width, height: height);

  const int hexFF = 0xFF000000;
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int? uvPixelStride = image.planes[1].bytesPerPixel;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex = uvPixelStride! * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);

      //img.data[index] = hexFF | (b << 16) | (g << 8) | r;

      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      if (img.isBoundsSafe(height - y, x)) {
        img.setPixelRgba(height - y, x, r, g, b, shift);
      }
    }
  }

  printIfDebug("Print img $img");
  return img;
}

// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
// Black
// imglib.Image _convertYUV420_2(CameraImage image) {
//   var img = imglib.Image(width: image.width, height: image.height); // Create Image buffer

//   Plane plane = image.planes[0];
//   const int shift = (0xFF << 24);

//   // Fill image buffer with plane[0] from YUV420_888
//   for (int x = 0; x < image.width; x++) {
//     for (int planeOffset = 0; planeOffset < image.height * image.width; planeOffset += image.width) {
//       final pixelColor = plane.bytes[planeOffset + x];
//       // color: 0x FF  FF  FF  FF
//       //           A   B   G   R
//       // Calculate pixel color
//       var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

//       img.data[planeOffset + x] = newVal;
//     }
//   }

//   return img;
// }

Uint8List yuvToRgb(Uint8List y, Uint8List u, Uint8List v, int width, int height) {
  final rgb = Uint8List(width * height * 3);
  for (int i = 0; i < width * height; i++) {
    final yValue = y[i];
    final uValue = u[i ~/ 2] - 128; // Adjust U value
    final vValue = v[i ~/ 2] - 128; // Adjust V value

    // Convert YUV to RGB
    final r = yValue + 1.402 * vValue;
    final g = yValue - 0.344136 * uValue - 0.714136 * vValue;
    final b = yValue + 1.772 * uValue;

    // Clamp values to [0, 255]
    rgb[i * 3] = r.clamp(0, 255).toInt();
    rgb[i * 3 + 1] = g.clamp(0, 255).toInt();
    rgb[i * 3 + 2] = b.clamp(0, 255).toInt();
  }
  return rgb;
}
