import '../api_service.dart';
import '../../models/donation.dart';

class DonationApi {
  final _dio = ApiService.instance.client;

  Future<List<Donation>> listDonations() async {
    final response = await _dio.get('/donations');
    final List data = response.data as List;
    return data.map((json) => Donation.fromJson(json)).toList();
  }

  Future<Donation> createDonation(Donation donation) async {
    final response = await _dio.post('/donations', data: donation.toJson());
    return Donation.fromJson(response.data);
  }
}