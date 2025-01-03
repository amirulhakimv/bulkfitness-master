import 'package:flutter/material.dart';

double responsiveWidth(double pixel, var context) {
  if (MediaQuery.of(context).size.shortestSide >= 600) {
    return MediaQuery.of(context).size.width * (pixel / 1024);
  } else {
    return MediaQuery.of(context).size.width * (pixel / 430);
  }
}

double responsiveHeight(double pixel, var context) {
  if (MediaQuery.of(context).size.shortestSide >= 600) {
    return MediaQuery.of(context).size.height * (pixel / 1366);
  } else {
    return MediaQuery.of(context).size.height * (pixel / 932);
  }
}

double responsive(pixel, context) {
  return responsiveWidth(pixel / 2, context) + responsiveHeight(pixel / 2, context);
}

void navigateTo(BuildContext context, Widget screen) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
}

class CustomPageRoute extends PageRouteBuilder {
  final Widget page;

  CustomPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Screen slides in from the right
            const end = Offset.zero; // Ends at its normal position
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}
