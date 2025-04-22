import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_trace/screens/login.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/quickalert.dart';

class RegisterClientScreen extends StatefulWidget {
  RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final formKey = GlobalKey<FormState>();
  final fnCtrl = TextEditingController();
  final lnCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register as Client'), centerTitle: true),
      body: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            alignment: Alignment.bottomCenter,
            opacity: 0.5,
          ),
        ),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const Text(
                'To register as a client, please enter the needed information.',
              ),
              const Gap(22),
              TextFormField(
                decoration: setTextDecoration('First name'),
                controller: fnCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                },
              ),
              const Gap(8),
              TextFormField(
                decoration: setTextDecoration('Last name'),
                controller: lnCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                },
              ),
              const Gap(8),
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
              const Gap(8),
              TextFormField(
                decoration: setTextDecoration(
                  'Confirm password',
                  isPasswordField: true,
                ),
                obscureText: hidePassword,
                controller: confirmPassCtrl,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '*Required';
                  }
                  if (passwordCtrl.text != value) {
                    return '*Passwords do not match.';
                  }
                },
              ),
              const Gap(16),
              ElevatedButton(onPressed: doRegister, child: Text('Register')),
              const Gap(8),
              TextButton(
                onPressed:
                    () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => LoginScreen())),
                child: Text('Have an account? Login here.'),
              ),
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

  void doRegister() {
    //validate form
    if (!formKey.currentState!.validate()) {
      return;
    }
    //confirm with the user
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Are you sure?',
      confirmBtnText: 'YES',
      cancelBtnText: 'No',
      onConfirmBtnTap: () {
        //dismiss the dialog
        Navigator.of(context).pop();
        //call the actual registration
        registerClient();
      },
    );
  }

  void registerClient() async {
    //registration with firebase auth
    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Please wait',
        text: 'Registering your account',
      );
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtrl.text,
            password: passwordCtrl.text,
          );
      print(userCredential.user?.uid);

      //store to firebase firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'firstName': fnCtrl.text,
            'lastName': lnCtrl.text,
            'email': emailCtrl.text,
          });
      // await FirebaseFirestore.instance.collection('users').add({
      //   'firstName': fnCtrl.text,
      //   'lastName': lnCtrl.text,
      //   'email': emailCtrl.text,
      // });

      Navigator.of(context).pop();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'User Registration',
        text: 'You account has been registered. You can now login',
      );
    } on FirebaseAuthException catch (ex) {
      print(ex.code);
      print(ex.message);
      Navigator.of(context).pop();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: ex.message,
      );
      // if (ex.code == 'weak-password') {

      // }
    }
  }
}
