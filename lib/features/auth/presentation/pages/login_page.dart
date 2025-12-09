import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mm/features/auth/presentation/bloc/auth%20bloc/auth_bloc.dart';
import 'package:mm/features/auth/presentation/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc,AuthState>(
        listener: (context, state) {
          if (state is AuthError){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message),backgroundColor: Colors.red,)
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Welcome Back", style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                  const SizedBox(height: 32.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value){
                      if (value == null || value.isEmpty){
                        return "Please enter your email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value){
                      if (value == null || value.isEmpty){
                        return "Please enter your password";
                      } else if (value.length < 6){
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24.0),
          
                  BlocBuilder<AuthBloc,AuthState>(builder: (context, state) {
                    if (state is AuthLoading){
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            AuthLoginRequested(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            )
                          );
                        }
                      },
                      child: Text("Login"),
                    );
                  },),
                  
          
                  const SizedBox(height: 16,),
          
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)
                    ),
                    icon: Icon(Icons.g_mobiledata,size: 28,),
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthGoogleLoginRequested());
                    },
                    label: Text("Sign in With Google")
                  ),
          
                  const SizedBox(height: 16,),
          
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage(),));
                    },
                    child: Text("Don't Have Account? Register")
                  )
                ],
              )
              ),
          ),
        ),
      ),
    );
  }
}