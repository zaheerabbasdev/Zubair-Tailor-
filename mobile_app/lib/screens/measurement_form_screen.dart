import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/customer.dart';
import '../models/measurement.dart';
import '../providers/backup_provider.dart';
import '../repositories/measurement_repository.dart';
import '../utils/fraction_helper.dart';
import '../utils/app_colors.dart';

class FractionFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final converted = FractionHelper.convertToUnicode(newValue.text);
    if (converted != newValue.text) {
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
  final MeasurementRepository _measurementRepository = MeasurementRepository();
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
  String? _pocketType;

  // Stitching & Details (Booleans)
  bool _frontPocket = false;
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
    _pocketType = m?.pocketType;

    _frontPocket = m?.frontPocket ?? false;
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
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        title: Text(
          widget.measurement == null ? "Add Measurement" : "Edit Measurement",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: Colors.white, size: 28),
            onPressed: _submit,
            tooltip: l10n.save,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionCard(
              icon: Icons.straighten_rounded,
              title: "Dimensions / پیمائش",
              children: [
                _buildTwoFieldRow(l10n.shirtLength, _shirtLengthCont, l10n.shirtWidth, _shirtWidthCont),
                const SizedBox(height: 16),
                _buildTwoFieldRow(l10n.shoulder, _shoulderCont, l10n.sleeve, _sleeveCont),
                const SizedBox(height: 16),
                _buildTwoFieldRow(l10n.chest, _chestCont, l10n.ghera, _gheraCont),
                const SizedBox(height: 16),
                _buildTwoFieldRow(l10n.pancha, _panchaCont, l10n.shalwarLength, _shalwarLengthCont),
                const SizedBox(height: 16),
                _buildField(l10n.collar, _collarCont),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              icon: Icons.style_rounded,
              title: l10n.style,
              children: [
                _buildDropdownLocalized(l10n.banType, _banType, {
                  'ban': l10n.ban,
                  'gol_ban': l10n.golBan,
                  'none': l10n.none,
                }, (v) => setState(() => _banType = v)),
                const SizedBox(height: 16),
                _buildDropdownLocalized(l10n.damanType, _damanType, {
                  'square': l10n.square,
                  'round': l10n.round,
                  'none': l10n.none,
                }, (v) => setState(() => _damanType = v)),
                const SizedBox(height: 16),
                _buildDropdownLocalized(l10n.sleeveType, _sleeveType, {
                  'gol': l10n.gol,
                  'cuff': l10n.cuff,
                  'none': l10n.none,
                }, (v) => setState(() => _sleeveType = v)),
                const SizedBox(height: 16),
                _buildDropdownLocalized(l10n.sidePocket, _pocketType, {
                  'single': l10n.single,
                  'double': l10n.double,
                  'none': l10n.none,
                }, (v) => setState(() => _pocketType = v)),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              icon: Icons.tune_rounded,
              title: l10n.stitchingDetails,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildToggleChip(l10n.frontPocket, _frontPocket, (v) => setState(() => _frontPocket = v)),
                    _buildToggleChip(l10n.shalwarPocket, _shalwarPocket, (v) => setState(() => _shalwarPocket = v)),
                    _buildToggleChip(l10n.ringButton, _ringButton, (v) => setState(() => _ringButton = v)),
                    _buildToggleChip(l10n.doubleSilai, _doubleSilai, (v) => setState(() => _doubleSilai = v)),
                    _buildToggleChip(l10n.chamakTar, _chamakTar, (v) => setState(() => _chamakTar = v)),
                    _buildToggleChip(l10n.sadaPatti, _sadaPatti, (v) => setState(() => _sadaPatti = v)),
                    _buildToggleChip(l10n.designButton, _designButton, (v) => setState(() => _designButton = v)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
              ),
              child: TextFormField(
                controller: _notesCont,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: AppColors.primary,
                shadowColor: AppColors.primary.withOpacity(0.4),
                elevation: 4,
              ),
              child: Text(
                l10n.save,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Color(0xFFEEEEEE), height: 1),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          textDirection: TextDirection.ltr,
          textAlign: isRtl ? TextAlign.right : TextAlign.left,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildToggleChip(String label, bool value, Function(bool) onChanged) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: value ? Colors.white : AppColors.textDark,
          fontSize: 13,
        ),
      ),
      selected: value,
      onSelected: onChanged,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: value ? AppColors.primary : Colors.grey.shade300, width: 1),
      showCheckmark: false,
    );
  }

  void _submit() async {
    final measurement = Measurement(
      customerId: widget.customer.id!,
      shirtLength: _shirtLengthCont.text,
      shirtWidth: _shirtWidthCont.text,
      shoulder: _shoulderCont.text,
      sleeve: _sleeveCont.text,
      collar: _collarCont.text,
      banType: _banType,
      chest: _chestCont.text,
      ghera: _gheraCont.text,
      pancha: _panchaCont.text,
      shalwarLength: _shalwarLengthCont.text,
      damanType: _damanType,
      frontPocket: _frontPocket,
      pocketType: _pocketType,
      sleeveType: _sleeveType,
      shalwarPocket: _shalwarPocket,
      ringButton: _ringButton,
      doubleSilai: _doubleSilai,
      chamakTar: _chamakTar,
      sadaPatti: _sadaPatti,
      designButton: _designButton,
      notes: _notesCont.text,
    );

    try {
      if (widget.measurement == null) {
        await _measurementRepository.add(measurement);
      } else {
        await _measurementRepository.update(widget.measurement!.id!, measurement);
      }
      if (mounted) {
        context.read<BackupProvider>().syncInBackground();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving measurements / ناپ محفوظ کرنے میں خرابی')),
        );
      }
    }
  }
}
