import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'my_event_bus.dart';
import 'tcp_server.dart';

class ControlPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ControlPageWidgetState();
  }
}

class ControlPageWidgetState extends State<ControlPageWidget> {
  List<double> _accelerometerValues = <double>[0.0, 0.0, 0.0];
  List<double> _userAccelerometerValues = <double>[0.0, 0.0, 0.0];
  List<double> _gyroscopeValues = <double>[0.0, 0.0, 0.0];
  String _tcpServerEvent = "";
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );

    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );

    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );

    _streamSubscriptions.add(bus.listen<TcpServerEvent>((TcpServerEvent event) {
      setState(() {
        _tcpServerEvent = event.msg;
      });
    }));
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  final double doublePrecision = 0.01;
  final double doubleZero = 0.00000000;

  // double类型的精度问题, 此函数用于比较两个double类型接近相等
  bool _almostEqual(double a, double b) {
    if (a.isInfinite || b.isInfinite) {
      return a == b;
    }

    if (a.isNaN || b.isNaN) {
      return false;
    }

    return (a - b).abs() < doublePrecision;
  }

  // 1~89度的正切值
  final Map<double, int> tangentMap1 = {
    0.01746: 1,
    0.03492: 2,
    0.05241: 3,
    0.06993: 4,
    0.08749: 5,
    0.10510: 6,
    0.12278: 7,
    0.14054: 8,
    0.15838: 9,
    0.17633: 10,
    0.19438: 11,
    0.21256: 12,
    0.23087: 13,
    0.24933: 14,
    0.26795: 15,
    0.28675: 16,
    0.30573: 17,
    0.32492: 18,
    0.34433: 19,
    0.36397: 20,
    0.38386: 21,
    0.40403: 22,
    0.42447: 23,
    0.44523: 24,
    0.46631: 25,
    0.48773: 26,
    0.50953: 27,
    0.53171: 28,
    0.55431: 29,
    0.57735: 30,
    0.60086: 31,
    0.62487: 32,
    0.64941: 33,
    0.67451: 34,
    0.70021: 35,
    0.72654: 36,
    0.75355: 37,
    0.78129: 38,
    0.80978: 39,
    0.83910: 40,
    0.86929: 41,
    0.90040: 42,
    0.93252: 43,
    0.96569: 44,
    1.00000: 45,
    1.03553: 46,
    1.07237: 47,
    1.11061: 48,
    1.15037: 49,
    1.19175: 50,
    1.23490: 51,
    1.27994: 52,
    1.32704: 53,
    1.37638: 54,
    1.42815: 55,
    1.48256: 56,
    1.53986: 57,
    1.60033: 58,
    1.66428: 59,
    1.73205: 60,
    1.80405: 61,
    1.88073: 62,
    1.96261: 63,
    2.05030: 64,
    2.14451: 65,
    2.24604: 66,
    2.35585: 67,
    2.47509: 68,
    2.60509: 69,
    2.74748: 70,
    2.90421: 71,
    3.07768: 72,
    3.27085: 73,
    3.48741: 74,
    3.73205: 75,
    4.01078: 76,
    4.33148: 77,
    4.70463: 78,
    5.14455: 79,
    5.67128: 80,
    6.31375: 81,
    7.11537: 82,
    8.14435: 82,
    9.51436: 84,
    11.43005: 85,
    14.30067: 86,
    19.08114: 87,
    28.63625: 88,
    57.28996: 89
  };

  // 91~179度的正切值
  final Map<double, int> tangentMap2 = {
    -57.28996: 91,
    -28.63625: 92,
    -19.08114: 93,
    -14.30067: 94,
    -11.43005: 95,
    -9.51436: 96,
    -8.14435: 97,
    -7.11537: 98,
    -6.31375: 99,
    -5.67128: 100,
    -5.14455: 101,
    -4.70463: 102,
    -4.33148: 103,
    -4.01078: 104,
    -3.73205: 105,
    -3.48741: 106,
    -3.27085: 107,
    -3.07768: 108,
    -2.90421: 109,
    -2.74748: 110,
    -2.60509: 111,
    -2.47509: 112,
    -2.35585: 113,
    -2.24604: 114,
    -2.14451: 115,
    -2.05030: 116,
    -1.96261: 117,
    -1.88073: 118,
    -1.80405: 119,
    -1.73205: 120,
    -1.66428: 121,
    -1.60033: 122,
    -1.53986: 123,
    -1.48256: 124,
    -1.42815: 125,
    -1.37638: 126,
    -1.32704: 127,
    -1.27994: 128,
    -1.23490: 129,
    -1.19175: 130,
    -1.15037: 131,
    -1.11061: 132,
    -1.07237: 133,
    -1.03553: 134,
    -1.00000: 135,
    -0.96569: 136,
    -0.93252: 137,
    -0.90040: 138,
    -0.86929: 139,
    -0.83910: 140,
    -0.80978: 141,
    -0.78129: 142,
    -0.75355: 143,
    -0.72654: 144,
    -0.70021: 145,
    -0.67451: 146,
    -0.64941: 147,
    -0.62487: 148,
    -0.60086: 149,
    -0.57735: 150,
    -0.55431: 151,
    -0.53171: 152,
    -0.50953: 153,
    -0.48773: 154,
    -0.46631: 155,
    -0.44523: 156,
    -0.42447: 157,
    -0.40403: 158,
    -0.38386: 159,
    -0.36397: 160,
    -0.34433: 161,
    -0.32492: 162,
    -0.30573: 163,
    -0.28675: 164,
    -0.26795: 165,
    -0.24933: 166,
    -0.23087: 167,
    -0.21256: 168,
    -0.19438: 169,
    -0.17633: 170,
    -0.15838: 171,
    -0.14054: 172,
    -0.12278: 173,
    -0.10510: 174,
    -0.08749: 175,
    -0.06993: 176,
    -0.05241: 177,
    -0.03492: 178,
    -0.01746: 179
  };

  // 181~269度的正切值
  final Map<double, int> tangentMap3 = {
    0.01746: 181,
    0.03492: 182,
    0.05241: 183,
    0.06993: 184,
    0.08749: 185,
    0.10510: 186,
    0.12278: 187,
    0.14054: 188,
    0.15838: 189,
    0.17633: 190,
    0.19438: 191,
    0.21256: 192,
    0.23087: 193,
    0.24933: 194,
    0.26795: 195,
    0.28675: 196,
    0.30573: 197,
    0.32492: 198,
    0.34433: 199,
    0.36397: 200,
    0.38386: 201,
    0.40403: 202,
    0.42447: 203,
    0.44523: 204,
    0.46631: 205,
    0.48773: 206,
    0.50953: 207,
    0.53171: 208,
    0.55431: 209,
    0.57735: 210,
    0.60086: 211,
    0.62487: 212,
    0.64941: 213,
    0.67451: 214,
    0.70021: 215,
    0.72654: 216,
    0.75355: 217,
    0.78129: 218,
    0.80978: 219,
    0.83910: 220,
    0.86929: 221,
    0.90040: 222,
    0.93252: 223,
    0.96569: 224,
    1.00000: 225,
    1.03553: 226,
    1.07237: 227,
    1.11061: 228,
    1.15037: 229,
    1.19175: 230,
    1.23490: 231,
    1.27994: 232,
    1.32704: 233,
    1.37638: 234,
    1.42815: 235,
    1.48256: 236,
    1.53986: 237,
    1.60033: 238,
    1.66428: 239,
    1.73205: 240,
    1.80405: 241,
    1.88073: 242,
    1.96261: 243,
    2.05030: 244,
    2.14451: 245,
    2.24604: 246,
    2.35585: 247,
    2.47509: 248,
    2.60509: 249,
    2.74748: 250,
    2.90421: 251,
    3.07768: 252,
    3.27085: 253,
    3.48741: 254,
    3.73205: 255,
    4.01078: 256,
    4.33148: 257,
    4.70463: 258,
    5.14455: 259,
    5.67128: 260,
    6.31375: 261,
    7.11537: 262,
    8.14435: 263,
    9.51436: 264,
    11.43005: 265,
    14.30067: 266,
    19.08114: 267,
    28.63625: 268,
    57.28996: 269
  };

  // 271~359度的正切值
  final Map<double, int> tangentMap4 = {
    -57.28996: 271,
    -28.63625: 272,
    -19.08114: 273,
    -14.30067: 274,
    -11.43005: 275,
    -9.51436: 276,
    -8.14435: 277,
    -7.11537: 278,
    -6.31375: 279,
    -5.67128: 280,
    -5.14455: 281,
    -4.70463: 282,
    -4.33148: 283,
    -4.01078: 284,
    -3.73205: 285,
    -3.48741: 286,
    -3.27085: 287,
    -3.07768: 288,
    -2.90421: 289,
    -2.74748: 290,
    -2.60509: 291,
    -2.47509: 292,
    -2.35585: 293,
    -2.24604: 294,
    -2.14451: 295,
    -2.05030: 296,
    -1.96261: 297,
    -1.88073: 298,
    -1.80405: 299,
    -1.73205: 300,
    -1.66428: 301,
    -1.60033: 302,
    -1.53986: 303,
    -1.48256: 304,
    -1.42815: 305,
    -1.37638: 306,
    -1.32704: 307,
    -1.27994: 308,
    -1.23490: 309,
    -1.19175: 310,
    -1.15037: 311,
    -1.11061: 312,
    -1.07237: 313,
    -1.03553: 314,
    -1.00000: 315,
    -0.96569: 316,
    -0.93252: 317,
    -0.90040: 318,
    -0.86929: 319,
    -0.83910: 320,
    -0.80978: 321,
    -0.78129: 322,
    -0.75355: 323,
    -0.72654: 324,
    -0.70021: 325,
    -0.67451: 326,
    -0.64941: 327,
    -0.62487: 328,
    -0.60086: 329,
    -0.57735: 330,
    -0.55431: 331,
    -0.53171: 332,
    -0.50953: 333,
    -0.48773: 334,
    -0.46631: 335,
    -0.44523: 336,
    -0.42447: 337,
    -0.40403: 338,
    -0.38386: 339,
    -0.36397: 340,
    -0.34433: 341,
    -0.32492: 342,
    -0.30573: 343,
    -0.28675: 344,
    -0.26795: 345,
    -0.24933: 346,
    -0.23087: 347,
    -0.21256: 348,
    -0.19438: 349,
    -0.17633: 350,
    -0.15838: 351,
    -0.14054: 352,
    -0.12278: 353,
    -0.10510: 354,
    -0.08749: 355,
    -0.06993: 356,
    -0.05241: 357,
    -0.03492: 358,
    -0.01746: 359,
  };

  int _findTangentMap(Map<double, int> map, double tangent) {
    int angle = 0;
    double currentTan = 0;
    int currentAngle = 0;
    for (var e in map.entries) {
      currentTan = e.key;
      currentAngle = e.value;
      if (_almostEqual(currentTan, tangent)) {
        angle = currentAngle;
        break;
      } else {
        // Map升序
        if (1 == tangent.compareTo(currentTan)) {
          continue;
        } else {
          angle = currentAngle;
          break;
        }
      }
    }

    if (angle == 0) {
      angle = currentAngle;
    }
    return angle;
  }

  int _calcAngle(List<double>? accelerometerValues) {
    // 1) 对x和y取反, 使其与常规坐标糸相同(右为正x, 上为正y, 左为负x, 下为负y)
    double x = -(accelerometerValues![0]);
    double y = -(accelerometerValues[1]);

    int angel = 0;

    // 2) y/x的值与正切值表(以正x轴为0度,逆时针递增角度)比较, 取得角度
    if (_almostEqual(x, doubleZero) && _almostEqual(y, doubleZero)) {
      angel = 0;
    } else if (_almostEqual(x, doubleZero) && y > doubleZero) {
      angel = 90;
    } else if (_almostEqual(x, doubleZero) && y < doubleZero) {
      angel = 270;
    } else if (_almostEqual(y, doubleZero) && x > doubleZero) {
      angel = 0;
    } else if (_almostEqual(y, doubleZero) && x < doubleZero) {
      angel = 180;
    } else {
      // atan2通过x和y返回弧度, tan=y/x
      double radian = atan2(y, x);
      // tan通过弧度(radian)返回弧度的正切值
      double t = tan(radian);

      // 查找Map
      if (x > doubleZero && y > doubleZero) {
        angel = _findTangentMap(tangentMap1, t);
        // print("1--x=$x, y=$y, t=$t, angel=$angel");
      } else if (x < doubleZero && y > doubleZero) {
        angel = _findTangentMap(tangentMap2, t);
        // print("2--x=$x, y=$y, t=$t, angel=$angel");
      } else if (x < doubleZero && y < doubleZero) {
        angel = _findTangentMap(tangentMap3, t);
        // print("3--x=$x, y=$y, t=$t, angel=$angel");
      } else {
        angel = _findTangentMap(tangentMap4, t);
        // print("4--x=$x, y=$y, t=$t, angel=$angel");
      }
    }

    angel %= 360;
    return angel;
  }

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues.map((double v) => v.toStringAsFixed(1)).toList();

    final userAccelerometer = _userAccelerometerValues
        .map((double v) => v.toStringAsFixed(1))
        .toList();

    final gyroscope =
        _gyroscopeValues.map((double v) => v.toStringAsFixed(1)).toList();

    final int angel = _calcAngle(_accelerometerValues);

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("遥控"),
        ),
        body: Container(
          alignment: Alignment.center,
          height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "images/target.png",
                fit: BoxFit.cover,
                // width: 300,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Accelerometer: $accelerometer'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('UserAccelerometer: $userAccelerometer'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Gyroscope: $gyroscope'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('角度: $angel'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('服务器: ${server.getServerInfo()}'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('客户端: ${server.getClientInfo()}'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('服务器事件: $_tcpServerEvent'),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
