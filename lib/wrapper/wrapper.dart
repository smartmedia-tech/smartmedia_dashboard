
import 'package:smartmedia_campaign_manager/core/utils/custom_snackbar_widget.dart';
import 'package:smartmedia_campaign_manager/features/home/presentation/pages/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/widgets/signUp_dialog.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    // Schedule the auth check after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialAuth();
    });
  }

  void _checkInitialAuth() {
    final authBloc = context.read<AuthBloc>();
    if (!authBloc.authUseCases.isUserSignedIn()) {
      showSignupDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          CustomAnimatedSnackbar.show(
            context: context,
            message: "Authentication Error: ${state.message}",
            icon: Icons.error_outline,
            backgroundColor: Colors.red,
          );
        }

        if (state is Authenticated) {
          CustomAnimatedSnackbar.show(
            context: context,
            message: "Welcome back!!",
            icon: Icons.check_circle_outline,
            backgroundColor: Colors.green,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is Authenticated) {
            return const LandingPage();
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
