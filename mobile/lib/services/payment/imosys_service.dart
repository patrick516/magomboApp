// lib/services/payment/imosys_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

/// Result of initiating a payment — a checkout URL to open (in a WebView
/// or external browser) plus the transaction reference to reconcile later.
class PaymentInitResult {
  final String checkoutUrl;
  final String txRef;

  PaymentInitResult({required this.checkoutUrl, required this.txRef});
}

/// Wraps the Imosys hosted checkout flow.
///
/// PLACEHOLDER MODE: until real Imosys credentials are added, this talks
/// to a mock endpoint (or fails gracefully) so the rest of the donation flow
/// (screen -> provider -> backend donation record) can be built and tested
/// end-to-end today.
///
/// TO GO LIVE: replace `_baseUrl` and `_secretKey` below with real Imosys
/// values (from .env), and confirm the request/response field names against
/// Imosys's actual API docs — the shape here is a best-effort standard
/// hosted-checkout pattern (tx_ref / amount / currency / callback_url) and
/// has NOT been verified against Imosys's real API — check their docs
/// before going live.
class ImosysService {
  final Dio _dio = Dio();
  final _uuid = const Uuid();

  // TODO: swap for the real Imosys checkout endpoint when going live
  String get _baseUrl =>
      dotenv.env['IMOSYS_BASE_URL'] ?? 'https://api.imosys.example/placeholder';

  // TODO: load the real secret key from .env once issued by Imosys
  String get _secretKey => dotenv.env['IMOSYS_SECRET_KEY'] ?? 'PLACEHOLDER_KEY';

  Future<PaymentInitResult> initiatePayment({
    required double amount,
    required String currency,
    required String donationId,
    String? customerEmail,
    String? customerPhone,
  }) async {
    final txRef = 'MAGOMBO-$donationId-${_uuid.v4().substring(0, 8)}';

    try {
      final response = await _dio.post(
        '$_baseUrl/payment',
        options: Options(headers: {'Authorization': 'Bearer $_secretKey'}),
        data: {
          'tx_ref': txRef,
          'amount': amount,
          'currency': currency,
          'email': customerEmail ?? 'member@magombo.church',
          'phone_number': customerPhone,
          'callback_url': dotenv.env['IMOSYS_CALLBACK_URL'] ??
              'https://magombo.church/donation/callback',
          'return_url': dotenv.env['IMOSYS_RETURN_URL'] ??
              'https://magombo.church/donation/complete',
        },
      );

      final checkoutUrl = response.data['data']?['checkout_url'] as String?;
      if (checkoutUrl == null) {
        throw Exception('Payment gateway did not return a checkout URL');
      }
      return PaymentInitResult(checkoutUrl: checkoutUrl, txRef: txRef);
    } on DioException {
      // Placeholder mode: no real gateway configured yet. Returning a
      // clearly-fake URL keeps the flow testable end-to-end without
      // pretending a real payment happened.
      return PaymentInitResult(
        checkoutUrl: 'https://example.com/placeholder-checkout?tx_ref=$txRef',
        txRef: txRef,
      );
    }
  }
}