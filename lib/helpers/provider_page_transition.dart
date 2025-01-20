import 'package:flutter/material.dart';
import 'package:video_news/models/direction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class ProviderPageTransition {
  static move(ConsumerStatefulWidget page, BuildContext context, Direction dicection){
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // 表示する画面のWidget
          return ProviderScope(child: page);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          Offset begin = dicection == Direction.right ? const Offset(1.0, 0.0): const Offset(-1.0, 0.0) ; // 右から左
          // final Offset begin = Offset(-1.0, 0.0); // 左から右
          const Offset end = Offset.zero;
          final Animatable<Offset> tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: Curves.easeInOut));
          final Animation<Offset> offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}