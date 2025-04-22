import 'package:contact_trace/screens/home.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hidePassword = true;
  var passwordCtrl = TextEditingController();
  var emailCtrl = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), centerTitle: true),
      body: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_back.webp'),
            alignment: Alignment.bottomCenter,
            opacity: 0.5,
          ),
        ),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const Text('To login, please enter the needed information.'),
              const Gap(22),
              TextFormField(
                decoration: setTextDecoration('Email address'),
                keyboardType: TextInputType.emailAddress,
                controller: emailCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                  if (!EmailValidator.validate(value)) {
                    return '*Invalid email';
                  }
                },
              ),
              const Gap(8),
              TextFormField(
                decoration: setTextDecoration(
                  'Password',
                  isPasswordField: true,
                ),
                obscureText: hidePassword,
                controller: passwordCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                },
              ),
              const Gap(16),
              ElevatedButton(onPressed: doLogin, child: Text('Login')),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration setTextDecoration(
    String name, {
    bool isPasswordField = false,
  }) {
    return InputDecoration(
      border: OutlineInputBorder(),
      label: Text(name),
      suffixIcon:
          isPasswordField
              ? IconButton(
                onPressed: toggleShowPassword,
                icon: Icon(
                  hidePassword ? Icons.visibility : Icons.visibility_off,
                ),
              )
              : null,
    );
  }

  void toggleShowPassword() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  void doLogin() async {
    //check form
    if (!formKey.currentState!.validate()) {
      return;
    }
    QuickAlert.show(context: context, type: QuickAlertType.loading);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailCtrl.text,
            password: passwordCtrl.text,
          );
      print(userCredential.user?.uid);
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
    } on FirebaseAuthException catch (ex) {
      print(ex.message);
      print(ex.code);
      if (ex.code == 'invalid-credential') {
        Navigator.of(context).pop();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: 'You have entered an incorrect password. Please try again.',
        );
      }
    }
  }
}
