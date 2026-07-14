import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/customer.dart';
import '../models/measurement.dart';
import '../providers/backup_provider.dart';
import '../providers/theme_provider.dart';
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

  String _clothingType = 'Shalwar Kameez';

  // Dimensions (Shalwar Kameez & Waistcoat overlapping fields)
  late TextEditingController _shirtLengthCont;
  late TextEditingController _shirtWidthCont;
  late TextEditingController _shoulderCont;
  late TextEditingController _sleeveCont;
  late TextEditingController _collarCont;
  late TextEditingController _chestCont;
  late TextEditingController _gheraCont;
  late TextEditingController _panchaCont;
  late TextEditingController _shalwarLengthCont;

  // New dimensions
  late TextEditingController _waistCont;
  late TextEditingController _coatLengthCont;
  late TextEditingController _coatShoulderCont;
  late TextEditingController _coatSleeveCont;
  late TextEditingController _coatChestCont;
  late TextEditingController _coatWaistCont;
  late TextEditingController _coatCollarCont;
  late TextEditingController _vestLengthCont;
  late TextEditingController _vestChestCont;
  late TextEditingController _vestWaistCont;
  late TextEditingController _pantLengthCont;
  late TextEditingController _pantWaistCont;
  late TextEditingController _pantHipCont;
  late TextEditingController _pantPanchaCont;

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
    _clothingType = m?.clothingType ?? 'Shalwar Kameez';

    _shirtLengthCont = TextEditingController(text: m?.shirtLength?.toString() ?? '');
    _shirtWidthCont = TextEditingController(text: m?.shirtWidth?.toString() ?? '');
    _shoulderCont = TextEditingController(text: m?.shoulder?.toString() ?? '');
    _sleeveCont = TextEditingController(text: m?.sleeve?.toString() ?? '');
    _collarCont = TextEditingController(text: m?.collar?.toString() ?? '');
    _chestCont = TextEditingController(text: m?.chest?.toString() ?? '');
    _gheraCont = TextEditingController(text: m?.ghera?.toString() ?? '');
    _panchaCont = TextEditingController(text: m?.pancha?.toString() ?? '');
    _shalwarLengthCont = TextEditingController(text: m?.shalwarLength?.toString() ?? '');

    _waistCont = TextEditingController(text: m?.waist?.toString() ?? '');
    _coatLengthCont = TextEditingController(text: m?.coatLength?.toString() ?? '');
    _coatShoulderCont = TextEditingController(text: m?.coatShoulder?.toString() ?? '');
    _coatSleeveCont = TextEditingController(text: m?.coatSleeve?.toString() ?? '');
    _coatChestCont = TextEditingController(text: m?.coatChest?.toString() ?? '');
    _coatWaistCont = TextEditingController(text: m?.coatWaist?.toString() ?? '');
    _coatCollarCont = TextEditingController(text: m?.coatCollar?.toString() ?? '');
    _vestLengthCont = TextEditingController(text: m?.vestLength?.toString() ?? '');
    _vestChestCont = TextEditingController(text: m?.vestChest?.toString() ?? '');
    _vestWaistCont = TextEditingController(text: m?.vestWaist?.toString() ?? '');
    _pantLengthCont = TextEditingController(text: m?.pantLength?.toString() ?? '');
    _pantWaistCont = TextEditingController(text: m?.pantWaist?.toString() ?? '');
    _pantHipCont = TextEditingController(text: m?.pantHip?.toString() ?? '');
    _pantPanchaCont = TextEditingController(text: m?.pantPancha?.toString() ?? '');

    _banType = m?.banType == 'none' ? null : m?.banType;
    _damanType = m?.damanType == 'none' ? null : m?.damanType;
    _sleeveType = m?.sleeveType == 'none' ? null : m?.sleeveType;
    _pocketType = m?.pocketType == 'none' ? null : m?.pocketType;

    _frontPocket = m?.frontPocket ?? false;
    _shalwarPocket = m?.shalwarPocket ?? false;
    _ringButton = m?.ringButton ?? false;
    _doubleSilai = m?.doubleSilai ?? false;
    _chamakTar = m?.chamakTar ?? false;
    _sadaPatti = m?.sadaPatti ?? false;
    _designButton = m?.designButton ?? false;
  }

  @override
  void dispose() {
    _shirtLengthCont.dispose();
    _shirtWidthCont.dispose();
    _shoulderCont.dispose();
    _sleeveCont.dispose();
    _collarCont.dispose();
    _chestCont.dispose();
    _gheraCont.dispose();
    _panchaCont.dispose();
    _shalwarLengthCont.dispose();

    _waistCont.dispose();
    _coatLengthCont.dispose();
    _coatShoulderCont.dispose();
    _coatSleeveCont.dispose();
    _coatChestCont.dispose();
    _coatWaistCont.dispose();
    _coatCollarCont.dispose();
    _vestLengthCont.dispose();
    _vestChestCont.dispose();
    _vestWaistCont.dispose();
    _pantLengthCont.dispose();
    _pantWaistCont.dispose();
    _pantHipCont.dispose();
    _pantPanchaCont.dispose();
    super.dispose();
  }

  String _getLabel(String en, String? ur) {
    final isUr = Localizations.localeOf(context).languageCode == 'ur';
    return (isUr && ur != null) ? ur : en;
  }

  @override
  Widget build(BuildContext context) {
    AppColors.dark = context.watch<ThemeProvider>().isDark;
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
          widget.measurement == null ? l10n.addMeasurement : l10n.editMeasurement,
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
            // Clothing Type Card (always visible at top of form)
            _buildSectionCard(
              icon: Icons.style_rounded,
              title: l10n.clothingType,
              children: [
                DropdownButtonFormField<String>(
                  value: _clothingType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                  items: [
                    DropdownMenuItem(value: 'Shalwar Kameez', child: Text(_getLabel('Shalwar Kameez', 'شلوار قمیض'))),
                    DropdownMenuItem(value: 'Waistcoat', child: Text(_getLabel('Waistcoat', 'واسکٹ'))),
                    DropdownMenuItem(value: 'Two Piece', child: Text(_getLabel('Two Piece', 'ٹو پیس'))),
                    DropdownMenuItem(value: 'Three Piece', child: Text(_getLabel('Three Piece', 'تھری پیس'))),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _clothingType = v;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Conditional forms based on clothing type
            if (_clothingType == 'Shalwar Kameez') ...[
              _buildSectionCard(
                icon: Icons.straighten_rounded,
                title: l10n.dimensions,
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
                  }, (v) => setState(() => _banType = v)),
                  const SizedBox(height: 16),
                  _buildDropdownLocalized(l10n.damanType, _damanType, {
                    'square': l10n.square,
                    'round': l10n.round,
                  }, (v) => setState(() => _damanType = v)),
                  const SizedBox(height: 16),
                  _buildDropdownLocalized(l10n.sleeveType, _sleeveType, {
                    'gol': l10n.gol,
                    'cuff': l10n.cuff,
                  }, (v) => setState(() => _sleeveType = v)),
                  const SizedBox(height: 16),
                  _buildDropdownLocalized(l10n.sidePocket, _pocketType, {
                    'single': l10n.single,
                    'double': l10n.double,
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
            ] else if (_clothingType == 'Waistcoat') ...[
              _buildSectionCard(
                icon: Icons.straighten_rounded,
                title: _getLabel('Waistcoat Dimensions', 'واسکٹ کی پیمائش'),
                children: [
                  _buildTwoFieldRow(_getLabel('Length', 'لمبائی'), _shirtLengthCont, _getLabel('Shoulder', 'تیرا'), _shoulderCont),
                  const SizedBox(height: 16),
                  _buildTwoFieldRow(_getLabel('Chest', 'چھاتی'), _chestCont, l10n.waist, _waistCont),
                  const SizedBox(height: 16),
                  _buildField(_getLabel('Collar', 'کالر'), _collarCont),
                ],
              ),
            ] else if (_clothingType == 'Two Piece') ...[
              _buildSectionCard(
                icon: Icons.straighten_rounded,
                title: _getLabel('Coat Dimensions', 'کوٹ کی پیمائش'),
                children: [
                  _buildTwoFieldRow(_getLabel('Coat Length', 'کوٹ لمبائی'), _coatLengthCont, _getLabel('Coat Shoulder', 'کوٹ تیرا'), _coatShoulderCont),
                  const SizedBox(height: 16),
                  _buildTwoFieldRow(_getLabel('Coat Sleeve', 'کوٹ بازو'), _coatSleeveCont, _getLabel('Coat Chest', 'کوٹ چھاتی'), _coatChestCont),
                  const SizedBox(height: 16),
                  _buildTwoFieldRow(_getLabel('Coat Waist', 'کوٹ کمر'), _coatWaistCont, _getLabel('Coat Collar', 'کوٹ کالر'), _coatCollarCont),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                icon: Icons.straighten_rounded,
                title: _getLabel('Pant Dimensions', 'پینٹ کی پیمائش'),
                children: [
                  _buildTwoFieldRow(_getLabel('Pant Length', 'پینٹ لمبائی'), _pantLengthCont, _getLabel('Pant Waist', 'پینٹ کمر'), _pantWaistCont),
                  const SizedBox(height: 16),
                  _buildTwoFieldRow(_getLabel('Pant Hip', 'پینٹ ہپ'), _pantHipCont, _getLabel('Pant Pancha / Bottom', 'پینٹ پانچا'), _pantPanchaCont),
                ],
              ),
            ] else if (_clothingType == 'Three Piece') ...[
              _buildSectionCard(
                icon: Icons.straighten_rounded,
                title: _getLabel('Coat Dimensions', 'کوٹ کی پیمائش'),
                children: [
                  _buildTwoFieldRow(_getLabel('Coat Length', 'کوٹ لمبائی'), _coatLengthCont, _getLabel('Coat Shoulder', 'کوٹ تیرا'), _coatShoulderCont),
                  const SizedBox(height: 16),
                  _buildTwoFieldRow(_getLabel('Coat Sleeve', 'کوٹ بازو'), _coatSleeveCont, _getLabel('Coat Chest', 'کوٹ چھاتی'), _coatChestCont),
                  const SizedBox(height: 16),
                  _buildTwoFieldRow(_getLabel('Coat Waist', 'کوٹ کمر'), _coatWaistCont, _getLabel('Coat Collar', 'کوٹ کالر'), _coatCollarCont),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                icon: Icons.straighten_rounded,
                title: _getLabel('Vest Dimensions', 'واسکٹ کی پیمائش'),
                children: [
                  _buildTwoFieldRow(_getLabel('Vest Length', 'واسکٹ لمبائی'), _vestLengthCont, _getLabel('Vest Chest', 'واسکٹ چھاتی'), _vestChestCont),
                  const SizedBox(height: 16),
                  _buildField(_getLabel('Vest Waist', 'واسکٹ کمر'), _vestWaistCont),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                icon: Icons.straighten_rounded,
                title: _getLabel('Pant Dimensions', 'پینٹ کی پیمائش'),
                children: [
                  _buildTwoFieldRow(_getLabel('Pant Length', 'پینٹ لمبائی'), _pantLengthCont, _getLabel('Pant Waist', 'پینٹ کمر'), _pantWaistCont),
                  const SizedBox(height: 16),
                  _buildTwoFieldRow(_getLabel('Pant Hip', 'پینٹ ہپ'), _pantHipCont, _getLabel('Pant Pancha / Bottom', 'پینٹ پانچا'), _pantPanchaCont),
                ],
              ),
            ],

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
        color: AppColors.surfaceCard,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.divider, height: 1),
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
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
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
              tooltip: AppLocalizations.of(context)!.addFraction,
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
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
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
      side: BorderSide(color: value ? AppColors.primary : AppColors.divider, width: 1),
      showCheckmark: false,
    );
  }

  void _submit() async {
    final measurement = Measurement(
      customerId: widget.customer.id!,
      clothingType: _clothingType,
      shirtLength: _shirtLengthCont.text,
      shirtWidth: _shirtWidthCont.text,
      shoulder: _shoulderCont.text,
      sleeve: _sleeveCont.text,
      collar: _collarCont.text,
      banType: _clothingType == 'Shalwar Kameez' ? _banType : null,
      chest: _chestCont.text,
      ghera: _gheraCont.text,
      pancha: _panchaCont.text,
      shalwarLength: _shalwarLengthCont.text,
      damanType: _clothingType == 'Shalwar Kameez' ? _damanType : null,
      frontPocket: _clothingType == 'Shalwar Kameez' ? _frontPocket : false,
      pocketType: _clothingType == 'Shalwar Kameez' ? _pocketType : null,
      sleeveType: _clothingType == 'Shalwar Kameez' ? _sleeveType : null,
      shalwarPocket: _clothingType == 'Shalwar Kameez' ? _shalwarPocket : false,
      ringButton: _clothingType == 'Shalwar Kameez' ? _ringButton : false,
      doubleSilai: _clothingType == 'Shalwar Kameez' ? _doubleSilai : false,
      chamakTar: _clothingType == 'Shalwar Kameez' ? _chamakTar : false,
      sadaPatti: _clothingType == 'Shalwar Kameez' ? _sadaPatti : false,
      designButton: _clothingType == 'Shalwar Kameez' ? _designButton : false,
      notes: '',
      waist: _waistCont.text,
      coatLength: _coatLengthCont.text,
      coatShoulder: _coatShoulderCont.text,
      coatSleeve: _coatSleeveCont.text,
      coatChest: _coatChestCont.text,
      coatWaist: _coatWaistCont.text,
      coatCollar: _coatCollarCont.text,
      vestLength: _vestLengthCont.text,
      vestChest: _vestChestCont.text,
      vestWaist: _vestWaistCont.text,
      pantLength: _pantLengthCont.text,
      pantWaist: _pantWaistCont.text,
      pantHip: _pantHipCont.text,
      pantPancha: _pantPanchaCont.text,
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
          SnackBar(content: Text(AppLocalizations.of(context)!.errorSavingMeasurement)),
        );
      }
    }
  }
}
