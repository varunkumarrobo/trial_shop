import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trial_shop/models/http_exception.dart';

import '../providers/auth.dart';

// ignore: constant_identifier_names
enum AuthMode { SignUp, Login }

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(117, 191, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(117, 255, 131, 0.755).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(136, 5, 60, 45),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'My Shop',
                        style: TextStyle(
                          color: Theme.of(context).secondaryHeaderColor,
                          fontSize: 50,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  bool _isLoading = false;
  final _passwordController = TextEditingController();


   void _showErrorDialog(String message){
    showDialog(
      context: context, 
      builder: (ctx) =>
        AlertDialog(
          title: const Text('An Error Occurred!'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(ctx).pop();
              }, 
              child: const Text('Okay')),
          ],
        ),
      );
   }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      //InVALID!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try{
      if (_authMode == AuthMode.Login) {
      //log user in
      await Provider.of<Auth>(context,listen: false).logIn(
        _authData['email']!,
        _authData['password']!,
      );
    } else {
      //Sign user up
      await Provider.of<Auth>(context,listen: false).signup(
        _authData['email']!, 
        _authData['password']!,
        );
    } 
    } on HTTPException catch (error){
      var errorMessage = 'Authentication failed';
      if(error.toString().contains('EMAIL_EXISTS')){
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')){
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')){
        errorMessage = 'This password is too weak.';
      } else if(error.toString().contains('EMAIL_NOT_FOUND')){
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')){
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch(error){
      const errorMessage = 'Could not authenticate you. Try after some time.';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.SignUp ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.SignUp ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  // controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                    // return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                if (_authMode == AuthMode.SignUp)
                  TextFormField(
                    enabled: _authMode == AuthMode.SignUp,
                    decoration:
                        const InputDecoration(labelText: 'Confirm Password',),
                    obscureText: true,
                    validator: _authMode == AuthMode.SignUp
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                            // return null;
                          }
                        : null,
                  ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      textStyle: TextStyle(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .displayLarge!
                            .color,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 8.0),
                    ),
                    onPressed: _submit,
                    child: Text(
                      _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
                      style: TextStyle(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .displayLarge!
                            .color,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: _switchAuthMode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 4,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
