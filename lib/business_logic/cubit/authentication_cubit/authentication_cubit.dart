import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationInitial());

  void login(String email, String password) async {
    emit(DialogShown('Logging you in'));
    if (await isConnected()) {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .catchError((error) {
        FirebaseAuthException exception = error;
        emit(ErrorOccured(exception.message!));
      });
      emit(AuthenticationSuccessful());
    } else {
      emit(ErrorOccured('No internet connection!'));
    }
  }

  void registerUser(String email, String password, String fullName,
      String phoneNumber) async {
    emit(DialogShown('Registering you in'));
    if (await isConnected()) {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .catchError((error) {
        FirebaseAuthException exception = error;
        emit(ErrorOccured(exception.message!));
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
      });
      emit(AuthenticationSuccessful());
    } else {
      emit(ErrorOccured('No internet connection!'));
    }
  }

  Future<bool> isConnected() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return false;
    } else {
      return true;
    }
  }
}
