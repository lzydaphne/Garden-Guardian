import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/services/navigation.dart';
import 'package:flutter_app/views/nav_bar.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  
  var _isLogin = true;
  var _passwordVisible = false;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  var _isAuthenticating = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Log In' : 'Sign Up')
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _form,
                    child: Column(
                      children: [
                        if(!_isLogin)
                          TextFormField(
                            key: const ValueKey('name'),
                            decoration: const InputDecoration(
                              labelText: 'Name'
                            ),
                            validator: (value) {
                              if(value == null || value.isEmpty || value.trim().length < 4) {
                                return 'Please enter at least 4 characters.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredUsername = value!;
                            }
                          ),
                        TextFormField(
                          key: const ValueKey('email'),
                          decoration: const InputDecoration(
                            labelText: 'Email'
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if(value == null || value.trim().isEmpty || !value.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                        ),
                        TextFormField(
                          key: const ValueKey('password'),
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            )
                          ),
                          validator: (value) {
                            if(value == null || value.trim().length < 6) {
                              return 'Password must be at least 6 characters long.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                        ),
                        const SizedBox(height: 24),
                        if(_isAuthenticating)
                          const Center(
                            child: CircularProgressIndicator()
                          ),
                        if(!_isAuthenticating) ...[
                          SizedBox(
                            child: FilledButton(
                              onPressed: _submit,
                              child: Text(_isLogin ? 'Log in' : 'Sign up'),
                            )
                          )
                        ],
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin ? 'Create an account' : 'I already have an account'
                          )
                        )
                      ]
                    )
                  )
                )
              )
            )
          )
        )
      )
    );
  }

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if(!isValid) return;
    Provider.of<NavigationService>(context, listen: false).goHome(tab: HomeTab.home);
  }
}