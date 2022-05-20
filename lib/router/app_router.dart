import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi/business_logic/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:taxi/business_logic/cubit/map_cubit/maps_cubit.dart';
import 'package:taxi/constants/strings.dart';
import 'package:taxi/presentation/screens/login_screen.dart';
import 'package:taxi/presentation/screens/search_screen.dart';

import '../presentation/screens/map_screen.dart';
import '../presentation/screens/registration_screen.dart';

class AppRouter {
  final _authenticationCubit = AuthenticationCubit();
  final _mapCubit = MapsCubit();

  Route? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case loginScreen:
        return MaterialPageRoute(
            builder: (context) => BlocProvider.value(
                  value: _authenticationCubit,
                  child: const LoginScreen(),
                ));
      case registrationScreen:
        return MaterialPageRoute(
            builder: (context) => BlocProvider.value(
                  value: _authenticationCubit,
                  child: const RegistrationScreen(),
                ));
      case mapScreen:
        return MaterialPageRoute(
            builder: (context) => BlocProvider.value(
                  value: _mapCubit,
                  child: const MapScreen(),
                ));
      case searchScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: _mapCubit,
            child: const SearchScreen(),
          ),
        );
      default:
        return null;
    }
  }

  void dispose() {
    _authenticationCubit.close();
    _mapCubit.close();
  }
}
