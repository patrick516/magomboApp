// lib/providers/donation_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/donation.dart';
import '../repositories/donation_repository.dart';
import '../services/api/donation_api.dart';
import '../services/payment/imosys_service.dart';
import '../services/device_service.dart';

enum DonationSubmitState { idle, submitting, awaitingPayment, success, failure }

class DonationSubmission {
  final DonationSubmitState state;
  final String? checkoutUrl;
  final String? bankReference;
  final String? errorMessage;

  const DonationSubmission({
    this.state = DonationSubmitState.idle,
    this.checkoutUrl,
    this.bankReference,
    this.errorMessage,
  });

  DonationSubmission copyWith({
    DonationSubmitState? state,
    String? checkoutUrl,
    String? bankReference,
    String? errorMessage,
  }) {
    return DonationSubmission(
      state: state ?? this.state,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      bankReference: bankReference ?? this.bankReference,
      errorMessage: errorMessage,
    );
  }
}

class DonationNotifier extends Notifier<DonationSubmission> {
  final _donationApi = DonationApi();
  final _donationRepository = DonationRepository();
  final _paymentService = ImosysService();

  @override
  DonationSubmission build() => const DonationSubmission();

Future<void> submit({
    required double amount,
    required DonationCategory category,
    required String method,
    required bool isAnonymous,
    String? donorFirstName,
    String? donorLastName,
    String? donorPosition,
    String? donorLocation,
    String? phoneNumber,
  }) async {
    state = state.copyWith(state: DonationSubmitState.submitting);

    try {
      final deviceId = await DeviceService.getDeviceId();

      // 1. Create the donation record on the backend (status: PENDING)
      final draft = Donation(
        id: '', // backend assigns the real id
        amount: amount,
        category: category,
        method: method,
        isAnonymous: isAnonymous,
        donorFirstName: donorFirstName,
        donorLastName: donorLastName,
        donorPosition: donorPosition,
        donorLocation: donorLocation,
        deviceId: deviceId,
        createdAt: DateTime.now().toIso8601String(),
      );
      final created = await _donationApi.createDonation(draft);

      // 2. Save locally too, so the member can see it in their giving history
      await _donationRepository.insert(created);

      // Bank transfer is manual/asynchronous — there's no gateway to redirect
      // to. Stay PENDING and give the donor a reference to quote, instead of
      // pretending this completed like the instant payment methods do.
      if (method == 'BANK_TRANSFER') {
        state = state.copyWith(
          state: DonationSubmitState.success,
          bankReference: created.id.substring(0, 8).toUpperCase(),
        );
        return;
      }

      // 3. Initiate payment (placeholder until real Imosys keys are set)
      state = state.copyWith(state: DonationSubmitState.awaitingPayment);
      final payment = await _paymentService.initiatePayment(
        amount: amount,
        currency: 'MWK',
        donationId: created.id,
        customerPhone: phoneNumber,
      );

      state = state.copyWith(
        state: DonationSubmitState.success,
        checkoutUrl: payment.checkoutUrl,
      );
    } catch (e) {
      state = state.copyWith(
        state: DonationSubmitState.failure,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const DonationSubmission();
}

final donationProvider =
    NotifierProvider<DonationNotifier, DonationSubmission>(DonationNotifier.new);