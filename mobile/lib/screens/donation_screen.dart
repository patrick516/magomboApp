import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';
import '../models/donation.dart';
import '../providers/donation_provider.dart';

// TODO: confirm real per-transaction limits directly with Airtel Money and
// TNM Mpamba — this is a placeholder threshold, not a verified figure.
const double _mobileMoneyLimit = 300000;

const Map<String, String> _methodLogos = {
  'AIRTEL_MONEY': 'assets/images/airtel_money.png',
  'MPAMBA': 'assets/images/tnm_mpamba.png',
};

const Map<String, String> _methodLabels = {
  'AIRTEL_MONEY': 'Airtel Money',
  'MPAMBA': 'TNM Mpamba',
  'BANK_TRANSFER': 'Bank Transfer',
  'CARD': 'Card',
};

const Map<String, String> _phonePrefixes = {
  'AIRTEL_MONEY': '+2659',
  'MPAMBA': '+2658',
};

// TODO: confirm official account name with the church office before display
const String _bankName = 'National Bank of Malawi (NBM)';
const String _bankAccountName = 'Magombo Assemblies of God - New Jerusalem';
const String _bankAccountNumber = '1009922217';

class DonationScreen extends ConsumerStatefulWidget {
  const DonationScreen({super.key});

  @override
  ConsumerState<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends ConsumerState<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvcController = TextEditingController();

  DonationCategory _category = DonationCategory.tithe;
  String _method = 'AIRTEL_MONEY';
  bool _isAnonymous = false;
  bool _saveCard = false;

  List<String> get _availableMethods {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount > _mobileMoneyLimit) {
      return ['BANK_TRANSFER'];
    }
    return ['AIRTEL_MONEY', 'MPAMBA', 'BANK_TRANSFER', 'CARD'];
  }

  void _onAmountChanged(String _) {
    setState(() {
      if (!_availableMethods.contains(_method)) {
        _selectMethod(_availableMethods.first);
      }
    });
  }

  void _selectMethod(String method) {
    setState(() {
      _method = method;
      final prefix = _phonePrefixes[method];
      if (prefix != null && !_phoneController.text.startsWith(prefix)) {
        _phoneController.text = prefix;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(donationProvider.notifier).submit(
          amount: double.parse(_amountController.text),
          category: _category,
          method: _method,
          isAnonymous: _isAnonymous,
          donorFirstName: _isAnonymous ? null : _firstNameController.text,
          donorLastName: _isAnonymous ? null : _lastNameController.text,
          donorPosition: _isAnonymous ? null : _positionController.text,
          donorLocation: _isAnonymous ? null : _locationController.text,
          phoneNumber: (_method == 'AIRTEL_MONEY' || _method == 'MPAMBA')
              ? _phoneController.text
              : null,
          // NOTE: card number/expiry/CVC are intentionally NOT sent anywhere
          // from here. When Imosys is wired in for real, the hosted checkout
          // page (opened via url_launcher, same as other methods) should
          // collect card details directly — not this app, and not our
          // backend. Handling raw card numbers/CVCs ourselves would put the
          // app in PCI-DSS scope, which a church giving app should avoid.
        );

    final submission = ref.read(donationProvider);
    if (!mounted) return;

    if (submission.state == DonationSubmitState.success) {
      if (_method == 'BANK_TRANSFER' && submission.bankReference != null) {
        // Manual/asynchronous — show account details + reference now,
        // clearly marked as pending, instead of pretending it's done.
        await _showBankTransferDialog(submission.bankReference!);
      } else if (submission.checkoutUrl != null) {
        final uri = Uri.parse(submission.checkoutUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

Future<void> _copyBankDetails() async {
    final text = '$_bankAccountName\n$_bankName\nAccount Number: $_bankAccountNumber';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account details copied')),
      );
    }
  }

  Future<void> _showBankTransferDialog(String reference) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Complete Your Transfer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your gift has been recorded as pending. Please complete the transfer using these details:',
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account Name: $_bankAccountName',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(_bankName),
                      const SizedBox(height: 4),
                      Text('Account Number: $_bankAccountNumber',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _copyBankDetails,
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copy account details',
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Reference: $reference',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            const Text(
              'Please use this reference when transferring, so the church office can match your gift. '
              'This donation will show as pending until the transfer is confirmed.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submission = ref.watch(donationProvider);
    final isBusy = submission.state == DonationSubmitState.submitting ||
        submission.state == DonationSubmitState.awaitingPayment;
    final methods = _availableMethods;

    return Scaffold(
      appBar: AppBar(title: const Text('Give / Donate')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (submission.state == DonationSubmitState.failure)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      submission.errorMessage ?? 'Something went wrong. Please try again.',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),

                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: _onAmountChanged,
                  decoration: const InputDecoration(
                    labelText: 'Amount (MWK)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter an amount';
                    if (double.tryParse(value) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                if (double.tryParse(_amountController.text) != null &&
                    double.parse(_amountController.text) > _mobileMoneyLimit)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Large amount — mobile money isn\'t available above this limit. Please use bank transfer.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),

                const SizedBox(height: 16),
                DropdownButtonFormField<DonationCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Giving Category',
                    border: OutlineInputBorder(),
                  ),
                  items: DonationCategory.values
                      .map((c) => DropdownMenuItem(value: c, child: Text(_categoryLabel(c))))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),

                const SizedBox(height: 16),
                const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: methods.map((m) => _buildMethodChip(m)).toList(),
                ),

                const SizedBox(height: 16),
                _buildMethodSpecificFields(),

                const SizedBox(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Give anonymously'),
                  subtitle: const Text('Your name won\'t be recorded with this gift'),
                  value: _isAnonymous,
                  onChanged: (value) => setState(() => _isAnonymous = value),
                ),

                if (!_isAnonymous) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_isAnonymous) return null;
                      if (value == null || value.isEmpty) return 'Enter your first name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_isAnonymous) return null;
                      if (value == null || value.isEmpty) return 'Enter your last name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _positionController,
                    decoration: const InputDecoration(
                      labelText: 'Position in Church (optional)',
                      hintText: 'e.g. Choir Member, Usher, Elder',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (optional)',
                      hintText: 'e.g. Blantyre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isBusy ? null : _submit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: isBusy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Give Now'),
                ),
                if (submission.state == DonationSubmitState.success && _method != 'BANK_TRANSFER') ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Thank you! Complete your payment in the window that opened.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.success),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSpecificFields() {
    switch (_method) {
      case 'AIRTEL_MONEY':
      case 'MPAMBA':
        return TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: '${_methodLabels[_method]} Number',
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            final prefix = _phonePrefixes[_method]!;
            if (value == null || value.length <= prefix.length) {
              return 'Enter your phone number';
            }
            return null;
          },
        );

      case 'BANK_TRANSFER':
        // Details are intentionally NOT shown here. Bank transfer isn't
        // instant and can't be confirmed automatically like mobile money or
        // card, so we avoid implying it's a live checkout. The actual
        // account number + a reference to quote are shown in a dialog after
        // "Give Now" is tapped — see _showBankTransferDialog.
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'You\'ll see our bank account details and a reference to quote after you tap Give Now. '
            'This gift will be marked pending until the church office confirms the transfer.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        );

      case 'CARD':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // NOTE: placeholder UI only — see _submit() for why raw card
            // details aren't transmitted from this form.
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Card payments are completed securely on the payment provider\'s page after you tap Give Now.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cardExpiryController,
                    decoration: const InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cardCvcController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'CVC',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Save this card for future giving'),
              value: _saveCard,
              onChanged: (value) => setState(() => _saveCard = value ?? false),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMethodChip(String method) {
    final selected = _method == method;
    final logo = _methodLogos[method];

    return ChoiceChip(
      selected: selected,
      onSelected: (_) => _selectMethod(method),
      avatar: logo != null
          ? CircleAvatar(backgroundImage: AssetImage(logo), radius: 12)
          : const Icon(Icons.account_balance, size: 18),
      label: Text(_methodLabels[method] ?? method),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(color: selected ? AppColors.primary : Colors.grey.shade300),
    );
  }

  String _categoryLabel(DonationCategory c) {
    switch (c) {
      case DonationCategory.tithe:
        return 'Tithe';
      case DonationCategory.offering:
        return 'Offering';
      case DonationCategory.buildingFund:
        return 'Building Fund';
      case DonationCategory.missions:
        return 'Missions';
      case DonationCategory.thanksgiving:
        return 'Thanksgiving';
      case DonationCategory.other:
        return 'Other';
    }
  }
}