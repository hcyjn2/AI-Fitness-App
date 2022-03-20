import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:scidart/numdart.dart';

class Utils {
  Utils._();

  /*
  Java source code use PointF3D instead of PoseLandmark therefore
    no type and likelihood in the constructor.
  */

  static PoseLandmark add(PoseLandmark a, PoseLandmark b) {
    return PoseLandmark(a.type, a.x + b.x, a.y + b.y, a.z + b.z, a.likelihood);
  }

  static PoseLandmark subtract(PoseLandmark b, PoseLandmark a) {
    return PoseLandmark(a.type, a.x - b.x, a.y - b.y, a.z - b.z, a.likelihood);
  }

  static PoseLandmark multiplyWithDouble(PoseLandmark a, double multiple) {
    return PoseLandmark(
        a.type, a.x * multiple, a.y * multiple, a.z * multiple, a.likelihood);
  }

  static PoseLandmark multiply(PoseLandmark a, PoseLandmark multiple) {
    return PoseLandmark(a.type, a.x * multiple.x, a.y * multiple.y,
        a.z * multiple.z, a.likelihood);
  }

  static PoseLandmark average(PoseLandmark a, PoseLandmark b) {
    return PoseLandmark(a.type, (a.x + b.x) * 0.5, (a.y + b.y) * 0.5,
        (a.z + b.z) * 0.5, a.likelihood);
  }

  static double l2Norm2D(PoseLandmark point) {
    return hypotenuse(point.x, point.y);
  }

  static double maxAbs(PoseLandmark point) {
    List temp = [point.x.abs(), point.y.abs(), point.z.abs()];
    return temp.reduce((curr, next) => curr > next ? curr : next);
  }

  static double sumAbs(PoseLandmark point) {
    return point.x.abs() + point.y.abs() + point.z.abs();
  }

  static List<PoseLandmark> addAll(
      List<PoseLandmark> pointList, PoseLandmark p) {
    List<PoseLandmark> out = [];

    for (var landmark in pointList) out.add(add(landmark, p));

    return out;
  }

  static List<PoseLandmark> subtractAll(
      PoseLandmark p, List<PoseLandmark> pointList) {
    List<PoseLandmark> out = [];

    for (var landmark in pointList) out.add(subtract(p, landmark));

    return out;
  }

  static List<PoseLandmark> multiplyAll(
      List<PoseLandmark> pointList, PoseLandmark multiple) {
    List<PoseLandmark> out = [];

    for (var landmark in pointList) out.add(multiply(landmark, multiple));

    return out;
  }

  static List<PoseLandmark> multiplyWithDoubleAll(
      List<PoseLandmark> pointList, double multiple) {
    List<PoseLandmark> out = [];

    for (var landmark in pointList)
      out.add(multiplyWithDouble(landmark, multiple));

    return out;
  }
}
