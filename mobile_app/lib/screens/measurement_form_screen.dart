import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/customer.dart';
import '../models/measurement.dart';
import '../services/api_service.dart';
import '../utils/fraction_helper.dart';
import '../utils/app_colors.dart';

class FractionFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final converted = FractionHelper.convertToUnicode(newValue.text);
    if (converted != newValue.text) {
      // If conversion happened, we need to adjust cursor position carefully
      // But since we replace 3 chars with 1, it's tricky.
      // For now, let's just use the converted text and place cursor at end.
      return TextEditingValue(
        text: converted,
        selection: TextSelection.collapsed(offset: converted.length),
      );
    }
    return newValue;
  }
}

class MeasurementFormScreen extends StatefulWidget {
  final Customer customer;
  final Measurement? measurement;
  const MeasurementFormScreen({super.key, required this.customer, this.measurement});

  @override
  State<MeasurementFormScreen> createState() => _MeasurementFormScreenState();
}

class _MeasurementFormScreenState extends State<MeasurementFormScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Dimensions
  late TextEditingController _shirtLengthCont;
  late TextEditingController _shirtWidthCont;
  late TextEditingController _shoulderCont;
  late TextEditingController _sleeveCont;
  late TextEditingController _collarCont;
  late TextEditingController _chestCont;
  late TextEditingController _gheraCont;
  late TextEditingController _panchaCont;
  late TextEditingController _shalwarLengthCont;
  late TextEditingController _notesCont;

  // Style Selections
  String? _banType;
  String? _damanType;
  String? _sleeveType;

  // Stitching & Details (Booleans)
  bool _frontPocket = false;
  String? _pocketType;
  bool _shalwarPocket = false;
  bool _ringButton = false;
  bool _doubleSilai = false;
  bool _chamakTar = false;
  bool _sadaPatti = false;
  bool _designButton = false;

  @override
  void initState() {
    super.initState();
    final m = widget.measurement;
    _shirtLengthCont = TextEditingController(text: m?.shirtLength?.toString() ?? '');
    _shirtWidthCont = TextEditingController(text: m?.shirtWidth?.toString() ?? '');
    _shoulderCont = TextEditingController(text: m?.shoulder?.toString() ?? '');
    _sleeveCont = TextEditingController(text: m?.sleeve?.toString() ?? '');
    _collarCont = TextEditingController(text: m?.collar?.toString() ?? '');
    _chestCont = TextEditingController(text: m?.chest?.toString() ?? '');
    _gheraCont = TextEditingController(text: m?.ghera?.toString() ?? '');
    _panchaCont = TextEditingController(text: m?.pancha?.toString() ?? '');
    _shalwarLengthCont = TextEditingController(text: m?.shalwarLength?.toString() ?? '');
    _notesCont = TextEditingController(text: m?.notes ?? '');

    _banType = m?.banType;
    _damanType = m?.damanType;
    _sleeveType = m?.sleeveType;

    _frontPocket = m?.frontPocket ?? false;
    _pocketType = m?.pocketType;
    _shalwarPocket = m?.shalwarPocket ?? false;
    _ringButton = m?.ringButton ?? false;
    _doubleSilai = m?.doubleSilai ?? false;
    _chamakTar = m?.chamakTar ?? false;
    _sadaPatti = m?.sadaPatti ?? false;
    _designButton = m?.designButton ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.measurements, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader(Icons.straighten, "Dimensions / لمبائی / چوڑائی"),
            const SizedBox(height: 16),
            _buildTwoFieldRow(l10n.shirtLength, _shirtLengthCont, l10n.shirtWidth, _shirtWidthCont),
            const SizedBox(height: 12),
            _buildTwoFieldRow(l10n.shoulder, _shoulderCont, l10n.sleeve, _sleeveCont),
            const SizedBox(height: 12),
            _buildTwoFieldRow(l10n.chest, _chestCont, l10n.ghera, _gheraCont),
            const SizedBox(height: 12),
            _buildTwoFieldRow(l10n.pancha, _panchaCont, l10n.shalwarLength, _shalwarLengthCont),
            const SizedBox(height: 12),
            _buildField(l10n.collar, _collarCont),

            const SizedBox(height: 32),
            _buildSectionHeader(Icons.style, l10n.style),
            const SizedBox(height: 16),
            _buildDropdownLocalized(l10n.banType, _banType, {
              'ban': l10n.ban,
              'gol_ban': l10n.golBan,
              'none': l10n.none,
            }, (v) => setState(() => _banType = v)),
            const SizedBox(height: 12),
            _buildDropdownLocalized(l10n.damanType, _damanType, {
              'square': l10n.square,
              'round': l10n.round,
              'none': l10n.none,
            }, (v) => setState(() => _damanType = v)),
            const SizedBox(height: 12),
            _buildDropdownLocalized(l10n.sleeveType, _sleeveType, {
              'gol': l10n.gol,
              'cuff': l10n.cuff,
              'none': l10n.none,
            }, (v) => setState(() => _sleeveType = v)),
            const SizedBox(height: 12),
            _buildDropdownLocalized(l10n.sidePocket, _pocketType, {
              'single': l10n.single,
              'double': l10n.double,
              'none': l10n.none,
            }, (v) => setState(() => _pocketType = v)),

            const SizedBox(height: 32),
            _buildSectionHeader(Icons.settings, l10n.stitchingDetails),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildSwitch(l10n.frontPocket, _frontPocket, (v) => setState(() => _frontPocket = v)),
                _buildSwitch(l10n.shalwarPocket, _shalwarPocket, (v) => setState(() => _shalwarPocket = v)),
                _buildSwitch(l10n.ringButton, _ringButton, (v) => setState(() => _ringButton = v)),
                _buildSwitch(l10n.doubleSilai, _doubleSilai, (v) => setState(() => _doubleSilai = v)),
                _buildSwitch(l10n.chamakTar, _chamakTar, (v) => setState(() => _chamakTar = v)),
                _buildSwitch(l10n.sadaPatti, _sadaPatti, (v) => setState(() => _sadaPatti = v)),
                _buildSwitch(l10n.designButton, _designButton, (v) => setState(() => _designButton = v)),
              ],
            ),

            const SizedBox(height: 32),
            TextFormField(
              controller: _notesCont,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.notes, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text(l10n.save, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3E2723))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          textDirection: TextDirection.ltr, // Force LTR for numbers/fractions
          textAlign: isRtl ? TextAlign.right : TextAlign.left,
          decoration: InputDecoration(
            // Remove labelText since it's outside
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            suffixIcon: PopupMenuButton<String>(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
              tooltip: 'Add Fraction',
              onSelected: (String value) {
                String currentText = controller.text;
                currentText = currentText.replaceAll(RegExp(r'\s*[¼½¾]+$'), '');
                final newText = '$currentText $value'.trim();
                controller.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: newText.length),
                );
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: '¼', child: Text('¼')),
                const PopupMenuItem<String>(value: '⅓', child: Text('⅓')),
                const PopupMenuItem<String>(value: '½', child: Text('½')),
                const PopupMenuItem<String>(value: '¾', child: Text('¾')),
              ],
            ),
          ),
          keyboardType: TextInputType.text,
          inputFormatters: [FractionFormatter()],
        ),
      ],
    );
  }

  Widget _buildTwoFieldRow(String l1, TextEditingController c1, String l2, TextEditingController c2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align to top
      children: [
        Expanded(child: _buildField(l1, c1)),
        const SizedBox(width: 16),
        Expanded(child: _buildField(l2, c2)),
      ],
    );
  }

  Widget _buildDropdownLocalized(String label, String? value, Map<String, String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3E2723))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(filled: true, fillColor: Colors.white, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
          items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3E2723))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(filled: true, fillColor: Colors.white, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }

  void _submit() async {
    final data = {
      'customer_id': widget.customer.id,
      'shirt_length': _shirtLengthCont.text,
      'shirt_width': _shirtWidthCont.text,
      'shoulder': _shoulderCont.text,
      'sleeve': _sleeveCont.text,
      'collar': _collarCont.text,
      'ban_type': _banType,
      'chest': _chestCont.text,
      'ghera': _gheraCont.text,
      'pancha': _panchaCont.text,
      'shalwar_length': _shalwarLengthCont.text,
      'daman_type': _damanType,
      'front_pocket': _frontPocket,
      'pocket_type': _pocketType,
      'sleeve_type': _sleeveType,
      'shalwar_pocket': _shalwarPocket,
      'ring_button': _ringButton,
      'double_silai': _doubleSilai,
      'chamak_tar': _chamakTar,
      'sada_patti': _sadaPatti,
      'design_button': _designButton,
      'notes': _notesCont.text,
    };

    try {
      if (widget.measurement == null) {
        await _apiService.addMeasurement(data);
      } else {
        await _apiService.updateMeasurement(widget.measurement!.id!, data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving measurements / ناپ محفوظ کرنے میں خرابی')),
        );
      }
    }
  }
}
