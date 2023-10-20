import 'package:flutter/material.dart';
// import 'package:malachapp/auth/admin.dart';
import 'package:malachapp/auth/auth_service.dart' as auth;
import 'package:malachapp/components/text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  // final adminAuthService = AdminAuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(children: [
        MyTextField(hintText: 'Login', obscureText: false, controller: loginController),
        // MyTextField(hintText: 'Email', obscureText: false, controller: emailController),
        ElevatedButton(
          onPressed: () => auth.AuthService().resetPassword(email: loginController.text), 
          // onPressed: () async {
          //   final adminAuthService = AdminAuthService();
          //   final link = await adminAuthService.sendPasswordResetEmail(
          //     email: emailController.text,
          //     login: loginController.text,
          //   );
            // if (link != null) {
            //   // Show the link to the user, e.g., in a dialog or on a UI element.
            //   print("Password reset link: $link");
            // } else {
            //   // Handle the case where an error occurred during link generation.
            //   print("Error generating password reset link");
            // }
          // },
          child: const Text('Reset password')
        )
      ],)
      ) 
    );
  }
}