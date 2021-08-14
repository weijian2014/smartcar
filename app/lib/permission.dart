// import 'package:permission_handler/permission_handler.dart';

// class MyPermission {
//   static requsetPermission() {
//     // 添加要访问的权限是什么
// Permission permission = Permission.;  // 相机权限

// // 获取当前权限的状态
// PermissionStatus status = permission.status as PermissionStatus;

// // 判断当前状态处于什么类型
// if( status.isUndetermined ){
//     // 第一次申请权限
// } else if( status.isDenied ){
//     // 第一次申请被拒绝 再次重试
// } else if( status.isPermanentlyDenied ){
//     // 第二次申请被拒绝 去设置中心
// } else if( status.isGranted ){
//     // 同意了访问权限。
//     // 处理该处理的事情
// }

// // 处理权限申请
// PermissionStatus status = await permission.request();
// ————————————————
// 版权声明：本文为CSDN博主「勤奋的宇威」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
// 原文链接：https://blog.csdn.net/weixin_45080852/article/details/112260111
//   }
// }
