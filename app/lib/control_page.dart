import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'app_provider.dart';
// import 'my_event_bus.dart';
import 'my_event_bus.dart';
import 'tcp_server.dart';
import 'config.dart';
import 'msg.dart';

class ControlPageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ControlPageWidgetState();
  }
}

class ControlPageWidgetState extends State<ControlPageWidget> {
  final double doublePrecision = 0.01;
  final double doubleZero = 0.00000000;

  bool isStarted = false;

  bool isMotorStoped = true;

  List<double> _accelerometerValues = <double>[0.0, 0.0, 0.0];
  // List<double> _userAccelerometerValues = <double>[0.0, 0.0, 0.0];
  // List<double> _gyroscopeValues = <double>[0.0, 0.0, 0.0];
  // String _tcpServerEvent = "";
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

    // _streamSubscriptions.add(
    //   userAccelerometerEvents.listen(
    //     (UserAccelerometerEvent event) {
    //       setState(() {
    //         _userAccelerometerValues = <double>[event.x, event.y, event.z];
    //       });
    //     },
    //   ),
    // );

    // _streamSubscriptions.add(
    //   gyroscopeEvents.listen(
    //     (GyroscopeEvent event) {
    //       setState(() {
    //         _gyroscopeValues = <double>[event.x, event.y, event.z];
    //       });
    //     },
    //   ),
    // );

    _streamSubscriptions.add(bus.listen<TcpServerEvent>((TcpServerEvent event) {
      setState(() {
        // _tcpServerEvent = event.msg;
      });
    }));
  }

  @override
  void dispose() {
    // 停止小车马达
    ControlMessage msg = new ControlMessage(1, 90, MotorRotatingLevel.rpm_stop);
    server.sendToAll(msg);

    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

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
  final Map<double, int> _tangentMap1 = {
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
  final Map<double, int> _tangentMap2 = {
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
  final Map<double, int> _tangentMap3 = {
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
  final Map<double, int> _tangentMap4 = {
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

  final Map<int, int> _normalServoAngleMap = {
    0: 45,
    1: 45,
    2: 45,
    3: 45,
    4: 45,
    5: 45,
    6: 45,
    7: 45,
    8: 45,
    9: 45,
    10: 45,
    11: 45,
    12: 45,
    13: 45,
    14: 45,
    15: 45,
    16: 45,
    17: 45,
    18: 45,
    19: 45,
    20: 45,
    21: 45,
    22: 45,
    23: 45,
    24: 45,
    25: 45,
    26: 45,
    27: 45,
    28: 45,
    29: 45,
    30: 45,
    31: 45,
    32: 45,
    33: 45,
    34: 45,
    35: 45,
    36: 45,
    37: 45,
    38: 45,
    39: 45,
    40: 45,
    41: 45,
    42: 45,
    43: 45,
    44: 45,
    45: 45,
    46: 46,
    47: 47,
    48: 48,
    49: 49,
    50: 50,
    51: 51,
    52: 52,
    53: 53,
    54: 54,
    55: 55,
    56: 56,
    57: 57,
    58: 58,
    59: 59,
    60: 60,
    61: 61,
    62: 62,
    63: 63,
    64: 64,
    65: 65,
    66: 66,
    67: 67,
    68: 68,
    69: 69,
    70: 70,
    71: 71,
    72: 72,
    73: 73,
    74: 74,
    75: 75,
    76: 76,
    77: 77,
    78: 78,
    79: 79,
    80: 80,
    81: 81,
    82: 82,
    83: 83,
    84: 84,
    85: 85,
    86: 86,
    87: 87,
    88: 88,
    89: 90,
    90: 90,
    91: 90,
    92: 92,
    93: 93,
    94: 94,
    95: 95,
    96: 96,
    97: 97,
    98: 98,
    99: 99,
    100: 100,
    101: 101,
    102: 102,
    103: 103,
    104: 104,
    105: 105,
    106: 106,
    107: 107,
    108: 108,
    109: 109,
    110: 110,
    111: 111,
    112: 112,
    113: 113,
    114: 114,
    115: 115,
    116: 116,
    117: 117,
    118: 118,
    119: 119,
    120: 120,
    121: 121,
    122: 122,
    123: 123,
    124: 124,
    125: 125,
    126: 126,
    127: 127,
    128: 128,
    129: 129,
    130: 130,
    131: 131,
    132: 132,
    133: 133,
    134: 134,
    135: 135,
    136: 135,
    137: 135,
    138: 135,
    139: 135,
    140: 135,
    141: 135,
    142: 135,
    143: 135,
    144: 135,
    145: 135,
    146: 135,
    147: 135,
    148: 135,
    149: 135,
    150: 135,
    151: 135,
    152: 135,
    153: 135,
    154: 135,
    155: 135,
    156: 135,
    157: 135,
    158: 135,
    159: 135,
    160: 135,
    161: 135,
    162: 135,
    163: 135,
    164: 135,
    165: 135,
    166: 135,
    167: 135,
    168: 135,
    169: 135,
    170: 135,
    171: 135,
    172: 135,
    173: 135,
    174: 135,
    175: 135,
    176: 135,
    177: 135,
    178: 135,
    179: 135,
    180: 135,
    181: 135,
    182: 135,
    183: 135,
    184: 135,
    185: 135,
    186: 135,
    187: 135,
    188: 135,
    189: 135,
    190: 135,
    191: 135,
    192: 135,
    193: 135,
    194: 135,
    195: 135,
    196: 135,
    197: 135,
    198: 135,
    199: 135,
    200: 135,
    201: 135,
    202: 135,
    203: 135,
    204: 135,
    205: 135,
    206: 135,
    207: 135,
    208: 135,
    209: 135,
    210: 135,
    211: 135,
    212: 135,
    213: 135,
    214: 135,
    215: 135,
    216: 135,
    217: 135,
    218: 135,
    219: 135,
    220: 135,
    221: 135,
    222: 135,
    223: 135,
    224: 135,
    225: 135,
    226: 134,
    227: 133,
    228: 132,
    229: 131,
    230: 130,
    231: 129,
    232: 128,
    233: 127,
    234: 126,
    235: 125,
    236: 124,
    237: 123,
    238: 122,
    239: 121,
    240: 120,
    241: 119,
    242: 118,
    243: 117,
    244: 116,
    245: 115,
    246: 114,
    247: 113,
    248: 112,
    249: 111,
    250: 110,
    251: 109,
    252: 108,
    253: 107,
    254: 106,
    255: 105,
    256: 104,
    257: 103,
    258: 102,
    259: 101,
    260: 100,
    261: 99,
    262: 98,
    263: 97,
    264: 96,
    265: 95,
    266: 94,
    267: 93,
    268: 92,
    269: 90,
    270: 90,
    271: 90,
    272: 88,
    273: 87,
    274: 86,
    275: 85,
    276: 84,
    277: 83,
    278: 82,
    279: 81,
    280: 80,
    281: 79,
    282: 78,
    283: 77,
    284: 76,
    285: 75,
    286: 74,
    287: 73,
    288: 72,
    289: 71,
    290: 70,
    291: 69,
    292: 68,
    293: 67,
    294: 66,
    295: 65,
    296: 64,
    297: 63,
    298: 62,
    299: 61,
    300: 60,
    301: 59,
    302: 58,
    303: 57,
    304: 56,
    305: 55,
    306: 54,
    307: 53,
    308: 52,
    309: 51,
    310: 50,
    311: 49,
    312: 48,
    313: 47,
    314: 46,
    315: 45,
    316: 45,
    317: 45,
    318: 45,
    319: 45,
    320: 45,
    321: 45,
    322: 45,
    323: 45,
    324: 45,
    325: 45,
    326: 45,
    327: 45,
    328: 45,
    329: 45,
    330: 45,
    331: 45,
    332: 45,
    333: 45,
    334: 45,
    335: 45,
    336: 45,
    337: 45,
    338: 45,
    339: 45,
    340: 45,
    341: 45,
    342: 45,
    343: 45,
    344: 45,
    345: 45,
    346: 45,
    347: 45,
    348: 45,
    349: 45,
    350: 45,
    351: 45,
    352: 45,
    353: 45,
    354: 45,
    355: 45,
    356: 45,
    357: 45,
    358: 45,
    359: 45,
    360: 45,
  };

  final Map<int, int> _reduceServoSensitivityAngleMap = {
    0: 45,
    1: 45,
    2: 45,
    3: 45,
    4: 45,
    5: 45,
    6: 45,
    7: 45,
    8: 45,
    9: 45,
    10: 45,
    11: 45,
    12: 45,
    13: 45,
    14: 45,
    15: 45,
    16: 45,
    17: 45,
    18: 45,
    19: 45,
    20: 45,
    21: 45,
    22: 45,
    23: 45,
    24: 46,
    25: 47,
    26: 47,
    27: 48,
    28: 49,
    29: 49,
    30: 50,
    31: 51,
    32: 51,
    33: 52,
    34: 53,
    35: 53,
    36: 54,
    37: 55,
    38: 55,
    39: 56,
    40: 57,
    41: 57,
    42: 58,
    43: 59,
    44: 59,
    45: 60,
    46: 61,
    47: 61,
    48: 62,
    49: 63,
    50: 63,
    51: 64,
    52: 65,
    53: 65,
    54: 66,
    55: 67,
    56: 67,
    57: 68,
    58: 69,
    59: 69,
    60: 70,
    61: 71,
    62: 71,
    63: 72,
    64: 73,
    65: 73,
    66: 74,
    67: 75,
    68: 75,
    69: 76,
    70: 77,
    71: 77,
    72: 78,
    73: 79,
    74: 79,
    75: 80,
    76: 81,
    77: 81,
    78: 82,
    79: 83,
    80: 83,
    81: 84,
    82: 85,
    83: 85,
    84: 86,
    85: 87,
    86: 88,
    87: 88,
    88: 89,
    89: 90,
    90: 90,
    91: 90,
    92: 92,
    93: 92,
    94: 93,
    95: 94,
    96: 94,
    97: 95,
    98: 96,
    99: 96,
    100: 97,
    101: 98,
    102: 98,
    103: 99,
    104: 100,
    105: 100,
    106: 101,
    107: 102,
    108: 102,
    109: 103,
    110: 104,
    111: 104,
    112: 105,
    113: 106,
    114: 106,
    115: 107,
    116: 108,
    117: 108,
    118: 109,
    119: 110,
    120: 110,
    121: 111,
    122: 112,
    123: 112,
    124: 113,
    125: 114,
    126: 114,
    127: 115,
    128: 116,
    129: 116,
    130: 117,
    131: 118,
    132: 118,
    133: 119,
    134: 120,
    135: 120,
    136: 121,
    137: 122,
    138: 122,
    139: 123,
    140: 124,
    141: 124,
    142: 125,
    143: 126,
    144: 126,
    145: 127,
    146: 128,
    147: 128,
    148: 129,
    149: 130,
    150: 130,
    151: 131,
    152: 132,
    153: 132,
    154: 133,
    155: 134,
    156: 134,
    157: 135,
    158: 135,
    159: 135,
    160: 135,
    161: 135,
    162: 135,
    163: 135,
    164: 135,
    165: 135,
    166: 135,
    167: 135,
    168: 135,
    169: 135,
    170: 135,
    171: 135,
    172: 135,
    173: 135,
    174: 135,
    175: 135,
    176: 135,
    177: 135,
    178: 135,
    179: 135,
    180: 135,
    181: 135,
    182: 135,
    183: 135,
    184: 135,
    185: 135,
    186: 135,
    187: 135,
    188: 135,
    189: 135,
    190: 135,
    191: 135,
    192: 135,
    193: 135,
    194: 135,
    195: 135,
    196: 135,
    197: 135,
    198: 135,
    199: 135,
    200: 135,
    201: 135,
    202: 135,
    203: 134,
    204: 134,
    205: 133,
    206: 132,
    207: 132,
    208: 131,
    209: 130,
    210: 130,
    211: 129,
    212: 128,
    213: 128,
    214: 127,
    215: 126,
    216: 126,
    217: 125,
    218: 124,
    219: 124,
    220: 123,
    221: 122,
    222: 122,
    223: 121,
    224: 120,
    225: 120,
    226: 119,
    227: 118,
    228: 118,
    229: 117,
    230: 116,
    231: 116,
    232: 115,
    233: 114,
    234: 114,
    235: 113,
    236: 112,
    237: 112,
    238: 111,
    239: 110,
    240: 110,
    241: 109,
    242: 108,
    243: 108,
    244: 107,
    245: 106,
    246: 106,
    247: 105,
    248: 104,
    249: 104,
    250: 103,
    251: 102,
    252: 102,
    253: 101,
    254: 100,
    255: 100,
    256: 99,
    257: 98,
    258: 98,
    259: 97,
    260: 96,
    261: 96,
    262: 95,
    263: 94,
    264: 94,
    265: 93,
    266: 92,
    267: 92,
    268: 91,
    269: 90,
    270: 90,
    271: 90,
    272: 88,
    273: 88,
    274: 87,
    275: 86,
    276: 86,
    277: 85,
    278: 84,
    279: 84,
    280: 83,
    281: 82,
    282: 82,
    283: 81,
    284: 80,
    285: 80,
    286: 79,
    287: 78,
    288: 78,
    289: 77,
    290: 76,
    291: 76,
    292: 75,
    293: 74,
    294: 74,
    295: 73,
    296: 72,
    297: 72,
    298: 71,
    299: 70,
    300: 70,
    301: 69,
    302: 68,
    303: 68,
    304: 67,
    305: 66,
    306: 66,
    307: 65,
    308: 64,
    309: 64,
    310: 63,
    311: 62,
    312: 62,
    313: 61,
    314: 60,
    315: 60,
    316: 59,
    317: 58,
    318: 58,
    319: 57,
    320: 56,
    321: 56,
    322: 55,
    323: 54,
    324: 54,
    325: 53,
    326: 52,
    327: 52,
    328: 51,
    329: 50,
    330: 50,
    331: 49,
    332: 48,
    333: 48,
    334: 47,
    335: 46,
    336: 46,
    337: 45,
    338: 45,
    339: 45,
    340: 45,
    341: 45,
    342: 45,
    343: 45,
    344: 45,
    345: 45,
    346: 45,
    347: 45,
    348: 45,
    349: 45,
    350: 45,
    351: 45,
    352: 45,
    353: 45,
    354: 45,
    355: 45,
    356: 45,
    357: 45,
    358: 45,
    359: 45,
    360: 45,
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
        angel = _findTangentMap(_tangentMap1, t);
        // print("1--x=$x, y=$y, t=$t, angel=$angel");
      } else if (x < doubleZero && y > doubleZero) {
        angel = _findTangentMap(_tangentMap2, t);
        // print("2--x=$x, y=$y, t=$t, angel=$angel");
      } else if (x < doubleZero && y < doubleZero) {
        angel = _findTangentMap(_tangentMap3, t);
        // print("3--x=$x, y=$y, t=$t, angel=$angel");
      } else {
        angel = _findTangentMap(_tangentMap4, t);
        // print("4--x=$x, y=$y, t=$t, angel=$angel");
      }
    }

    angel %= 360;
    return angel;
  }

  int _calcSpeedLevel(List<double>? accelerometerValues) {
    if (config.motroRotatingLevel != 0) {
      return config.motroRotatingLevel;
    } else {
      int x = accelerometerValues![0].ceil().abs();
      int y = accelerometerValues[1].ceil().abs();
      int level = x + y;
      level = min(level, MotorRotatingLevel.rpm_max.index - 1);
      return level;
    }
  }

  String _getButtonTextString() {
    String ret;
    if (isStarted) {
      ret = '停止';
    } else {
      ret = '开始';
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    // final accelerometer =
    //     _accelerometerValues.map((double v) => v.toStringAsFixed(1)).toList();

    // final userAccelerometer = _userAccelerometerValues
    //     .map((double v) => v.toStringAsFixed(1))
    //     .toList();

    // final gyroscope =
    //     _gyroscopeValues.map((double v) => v.toStringAsFixed(1)).toList();

    // 加速度计的正切角度
    final int tangentAngel = _calcAngle(_accelerometerValues);
    int servoAngle = 90;

    if (_accelerometerValues[0] != 0 && _accelerometerValues[1] != 0) {
      if (config.isReduceServoSensitivity) {
        // 降低舵机灵敏度的正切角度
        servoAngle = _reduceServoSensitivityAngleMap[tangentAngel] as int;
      } else {
        // 舵机的正常正切角度
        servoAngle = _normalServoAngleMap[tangentAngel] as int;
      }
    }

    String info = '正切角度: $tangentAngel, ';

    int direction = 1; // 1: 前进, 2: 后退
    int level = _calcSpeedLevel(_accelerometerValues);

    if (tangentAngel == 0 || tangentAngel == 180 || tangentAngel == 360) {
      level = 0;
    } else if (tangentAngel <= 180) {
      direction = 1;
    } else {
      direction = 2;
    }

    if (direction == 1) {
      info += '行车方向: 前进, ';
    } else {
      info += '行车方向: 后退, ';
    }

    info += '舵机角度: $servoAngle, 速度等级: $level';

    if (isStarted) {
      ControlMessage msg = new ControlMessage(
          direction, servoAngle, MotorRotatingLevel.values[level]);
      server.sendToAll(msg);
    } else if (!isMotorStoped) {
      ControlMessage msg =
          new ControlMessage(1, 90, MotorRotatingLevel.rpm_stop);
      server.sendToAll(msg);
      isMotorStoped = true;
    }

    return Theme(
        data: Provider.of<ThemeState>(context).themeData,
        child: Scaffold(
            appBar: AppBar(
              title: Text("遥控"),
            ),
            floatingActionButton: FloatingActionButton(
              child: Text(_getButtonTextString()),
              elevation: 3.0,
              highlightElevation: 2.0,
              onPressed: () {
                setState(() {
                  isStarted = !isStarted;
                  if (isStarted) {
                    isMotorStoped = false;
                  }
                });
              },
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: Container(
              constraints: BoxConstraints.expand(),
              alignment: Alignment.center,
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset(
                    "assets/images/target.png",
                    fit: BoxFit.cover,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(10.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Text('Accelerometer: $accelerometer'),
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(10.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Text('UserAccelerometer: $userAccelerometer'),
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(10.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Text('Gyroscope: $gyroscope'),
                  //     ],
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('$info', style: TextStyle(fontSize: 12)),
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
                        Text(
                          '客户端: ${server.getClientInfo()}',
                          maxLines: 5,
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(10.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Text('服务器事件: $_tcpServerEvent'),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            )));
  }
}
