import 'package:flutter/material.dart';
import 'package:do_an/Stores/auth_store.dart';
import 'package:do_an/Theme/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRegPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập đầy đủ thông tin');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await AuthStore().loginWithEmail(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _regEmailController.text.isEmpty ||
        _regPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập đầy đủ thông tin');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await AuthStore().registerWithEmail(
      _nameController.text,
      _regEmailController.text,
      _regPasswordController.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await AuthStore().loginWithGoogle();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildTabBar(),
              const SizedBox(height: 24),
              _buildTabContent(),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildGoogleButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.location_city_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 24),
          const Text('Chào mừng\nđến CIR 👋',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: AppTheme.textPrimaryColor)),
          const SizedBox(height: 8),
          Text('Báo cáo và theo dõi sự cố đô thị',
              style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimaryColor.withOpacity(0.5))),
        ],
      );

  Widget _buildTabBar() => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          indicator: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Đăng nhập'),
            Tab(text: 'Đăng ký'),
          ],
          onTap: (_) => setState(() => _errorMessage = null),
        ),
      );

  Widget _buildTabContent() => AnimatedBuilder(
        animation: _tabController,
        builder: (_, __) => _tabController.index == 0
            ? _buildLoginForm()
            : _buildRegisterForm(),
      );

  Widget _buildLoginForm() => Column(
        children: [
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'your@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Mật khẩu',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: _toggleVisibilityButton(
              _obscurePassword,
              () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          _buildErrorMessage(),
          const SizedBox(height: 24),
          _buildPrimaryButton('Đăng nhập', _isLoading ? null : _loginWithEmail),
        ],
      );

  Widget _buildRegisterForm() => Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Họ và tên',
            hint: 'Nguyễn Văn A',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _regEmailController,
            label: 'Email',
            hint: 'your@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _regPasswordController,
            label: 'Mật khẩu',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureRegPassword,
            suffixIcon: _toggleVisibilityButton(
              _obscureRegPassword,
              () => setState(() => _obscureRegPassword = !_obscureRegPassword),
            ),
          ),
          _buildErrorMessage(),
          const SizedBox(height: 24),
          _buildPrimaryButton('Tạo tài khoản', _isLoading ? null : _register),
        ],
      );

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.red, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('hoặc',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      );

  Widget _buildGoogleButton() => SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _isLoading ? null : _loginWithGoogle,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://www.google.com/favicon.ico',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.g_mobiledata_rounded,
                          size: 24,
                          color: Colors.red),
                    ),
                    const SizedBox(width: 10),
                    const Text('Tiếp tục với Google',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                  ],
                ),
        ),
      );

  Widget _buildPrimaryButton(String label, VoidCallback? onPressed) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
            elevation: 0,
          ),
          child: onPressed == null
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.textPrimaryColor)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
            ),
          ),
        ],
      );

  Widget _toggleVisibilityButton(bool obscure, VoidCallback onTap) =>
      IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey,
          size: 20,
        ),
        onPressed: onTap,
      );
}
