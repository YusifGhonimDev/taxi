import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi/business_logic/cubit/authentication_cubit/authentication_cubit.dart';
import 'package:taxi/constants/strings.dart';

import '../../constants/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dialog.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  Future<dynamic> _buildDialog(BuildContext context, DialogShown state) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => CustomDialog(
        status: state.statusMessage,
      ),
    );
  }

  SnackBar buildSnackBar(ErrorOccured state) {
    return SnackBar(
      content: Text(
        state.errorMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) {
            if (state is DialogShown) {
              _buildDialog(context, state);
            }
            if (state is ErrorOccured) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(buildSnackBar(state));
            }
            if (state is AuthenticationSuccessful) {
              Navigator.pushNamedAndRemoveUntil(
                  context, mapScreen, (route) => false);
            }
          },
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    const SizedBox(height: 72),
                    const SizedBox(height: 40),
                    const Text(
                      'Create an Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Bolt-SemiBold',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextFormField(
                            validator: (value) => value!.length < 3
                                ? 'Please provide a valid name!'
                                : null,
                            controller: fullNameController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              labelStyle: TextStyle(fontSize: 16),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            validator: (value) => !value!.contains('@')
                                ? 'Please proivde a valid email address!'
                                : null,
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              labelStyle: TextStyle(fontSize: 16),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            validator: (value) => value!.length < 11
                                ? 'Please provide a valid phone number!'
                                : null,
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Phone number',
                              labelStyle: TextStyle(fontSize: 16),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            validator: (value) => value!.length < 8
                                ? 'Please provide a valid password!'
                                : null,
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(fontSize: 16),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 40),
                          CustomButton(
                              color: colorGreen,
                              title: 'REGISTER',
                              onPressed: () => formKey.currentState!.validate()
                                  ? context
                                      .read<AuthenticationCubit>()
                                      .registerUser(
                                          emailController.text,
                                          passwordController.text,
                                          fullNameController.text,
                                          phoneController.text)
                                  : null),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, loginScreen),
                      child: const Text(
                        'Already have an account? Log in',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
