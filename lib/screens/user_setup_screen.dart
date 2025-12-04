import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/user_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/balance_provider.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _saving = false;
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _balanceController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _saving = true);
    try {
      final userProvider = context.read<UserProvider>();
      final created = await userProvider.addUser(
        _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );
      
      if (created != null && mounted) {
        // Set initial balance from user input (required field)
        final balanceText = _balanceController.text.trim();
        final initialBalance = double.tryParse(balanceText) ?? 0;
        
        // Set the balance
        await context.read<BalanceProvider>().setBalance(initialBalance);
        
        // Load initial data
        await Future.wait([
          context.read<ExpenseProvider>().load(),
          context.read<CategoryProvider>().load(),
          context.read<BalanceProvider>().load(),
        ]);
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating profile: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1d3a),
              Color(0xFF0f1123),
              Color(0xFF1e2139),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Lottie
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Lottie.asset(
                            'assets/lottie/Wallet Essentials_ Money & Savings.json',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.account_balance_wallet,
                                size: 100,
                                color: Color(0xFF6C5CE7),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Welcome Text
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFF6C5CE7),
                            Color(0xFF00D4FF),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Welcome!',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Text(
                        'Let\'s get started by setting up your profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Name Field
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF161936).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: _nameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Your Name',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Color(0xFF6C5CE7),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Please enter your name'
                              : null,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Email Field (Optional)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF161936).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email (Optional)',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF6C5CE7),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Initial Balance Field
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF161936).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: _balanceController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Initial Balance',
                            labelStyle: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            prefixIcon: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Color(0xFF6C5CE7),
                            ),
                            prefixText: '₹ ',
                            prefixStyle: const TextStyle(
                              color: Color(0xFF6C5CE7),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _save(),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your initial balance';
                            }
                            final balance = double.tryParse(v.trim());
                            if (balance == null) {
                              return 'Please enter a valid number';
                            }
                            if (balance < 0) {
                              return 'Balance cannot be negative';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Get Started Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C5CE7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF6C5CE7).withOpacity(0.5),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
