import 'package:flutter/material.dart';

class DangerousZone extends StatelessWidget {
  final List<Widget> children;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final String warningMessage;
  final IconData warningIcon;

  const DangerousZone({
    super.key,
    required this.children,
    this.backgroundColor = const Color(0xFFFFFBFB),
    this.borderColor = const Color(0xFF4A000A),
    this.iconColor = const Color(0xFF840016),
    this.textColor = const Color(0xFF840016),
    this.warningMessage = "危险操作区域",
    this.warningIcon = Icons.warning_amber_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey expansionTileKey = GlobalKey();
    var body = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade100,
            blurRadius: 2,
            spreadRadius: 0,
          )
        ],
      ),
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 警告图标和文字
          Center(
            child: Text(
              "APP数据仅本地保存，删除操作不可逆，谨慎操作",
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // 自定义内容
          ...children.map((child) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: child,
              )),
          const SizedBox(height: 4),
        ],
      ),
    );
    return ExpansionTile(
      initiallyExpanded: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            warningIcon,
            color: iconColor,
            size: 28,
          ),
          const SizedBox(width: 10),
          Text(
            warningMessage,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
      key: expansionTileKey,
      onExpansionChanged: (value) {
        if (value) {
          final keyContext = expansionTileKey.currentContext;
          if (keyContext != null) {
            Future.delayed(Duration(milliseconds: 230)).then((value) {
              Scrollable.ensureVisible(keyContext, duration: Duration(milliseconds: 200));
            });
          }
        }
      },
      children: [body],
    );
  }
}
