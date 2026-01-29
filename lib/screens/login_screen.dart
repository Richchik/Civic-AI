import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please enter email and password"),
        ),
      );
      return;
    }

    try {
      setState(() => loading = true);

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = cred.user!;

      // 🔐 EMAIL VERIFICATION CHECK
      if (!user.emailVerified) {
        await user.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "📧 Email not verified. Verification email has been sent.",
            ),
          ),
        );

        await FirebaseAuth.instance.signOut();
        return;
      }

      // 🔍 Fetch role from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = doc.data()?['role'] ?? 'user';

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            Image.asset(
              'assets/logo.png',
              height: 90,
            ),

            const SizedBox(height: 12),

            const Text(
              "Civic AI",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),
            ),

            const SizedBox(height: 10),

            // 🔁 RESEND VERIFICATION EMAIL
            TextButton(
              onPressed: () async {
                if (emailController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("⚠️ Enter email to resend verification"),
                    ),
                  );
                  return;
                }

                try {
                  final cred = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  final user = cred.user!;
                  if (!user.emailVerified) {
                    await user.sendEmailVerification();
                    await FirebaseAuth.instance.signOut();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("📨 Verification email resent"),
                      ),
                    );
                  }
                } catch (_) {}
              },
              child: const Text("Resend verification email"),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignupScreen(),
                  ),
                );
              },
              child: const Text("New user? Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
