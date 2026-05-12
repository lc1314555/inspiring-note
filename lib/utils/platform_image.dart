import 'package:flutter/material.dart';

/// 🖼️ 平台适配图片组件（Web 简化版）
/// Web 平台暂不支持本地文件访问，显示占位符
/// 移动端编译后可正常显示本地图片
class PlatformImage extends StatelessWidget {
  final String? imagePath;
  final double? height;
  final double? width;
  final BoxFit fit;

  const PlatformImage({
    super.key,
    this.imagePath,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) return const SizedBox.shrink();
    
    // Web 平台：显示占位符（本地文件路径无法直接访问）
    // 生产环境建议：上传图片到云存储后用 Image.network
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image, color: Colors.grey, size: 32),
            SizedBox(height: 4),
            Text('图片', style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
