import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_lock_provider.dart';
import '../utils/app_colors.dart';
import 'dashboard_screen.dart';

class AppLockScreen extends StatefulWidget {
  final bool isSetup;
  const AppLockScreen({super.key, this.isSetup = false});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String _pin = '';
  String? _firstPin;
  String? _error;
  bool _isConfirmStep = false;

  String _title(AppLocalizations l10n) {
    if (!widget.isSetup) return l10n.enterPin;
    return _isConfirmStep ? l10n.confirmPin : l10n.setPin;
  }

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _error = null;
      _pin += digit;
    });
    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 150), _handleComplete);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _handleComplete() async {
    if (widget.isSetup) {
      if (!_isConfirmStep) {
        setState(() {
          _firstPin = _pin;
          _pin = '';
          _isConfirmStep = true;
        });
        return;
      }

      if (_pin == _firstPin) {
        await context.read<AppLockProvider>().setPin(_pin);
        if (mounted) Navigator.pop(context, true);
      } else {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = l10n.pinMismatch;
          _pin = '';
          _firstPin = null;
          _isConfirmStep = false;
        });
      }
    } else {
      final correct = await context.read<AppLockProvider>().verifyPin(_pin);
      if (correct) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      } else {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = l10n.incorrectPin;
          _pin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: widget.isSetup,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 16),
                Text(_title(l10n), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < _pin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? AppColors.accent : Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white54),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 20,
                  child: _error != null
                      ? Text(_error!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13))
                      : null,
                ),
                const SizedBox(height: 32),
                _buildKeypad(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 68, height: 68);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  onTap: () => key == '⌫' ? _onBackspace() : _onDigit(key),
                  borderRadius: BorderRadius.circular(34),
                  child: Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                    child: key == '⌫'
                        ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 22)
                        : Text(key, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
