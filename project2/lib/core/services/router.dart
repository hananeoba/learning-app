import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project2/core/common/views/page_under_construction.dart';
import 'package:project2/core/services/injection.dart';
import 'package:project2/src/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:project2/src/onboarding/presentation/onboarding_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case OnboardingScreen.routeName:
      return _pageBuilder(
        (_) => BlocProvider(
          create: (context) => sl<OnboardingCubit>(),
          child: const OnboardingScreen(),
        ),
        settings: settings,
      );

    default:
      return _pageBuilder((_) => const PageUnderConstruction(),
          settings: settings,);
  }
}

PageRouteBuilder<dynamic> _pageBuilder(
  Widget Function(BuildContext) page, {
  required RouteSettings settings,
}) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page(context),
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
            opacity: animation,
            child: child,
          ),);
}
