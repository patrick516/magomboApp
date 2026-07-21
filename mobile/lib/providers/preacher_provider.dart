import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/preacher.dart';
import '../repositories/preacher_repository.dart';
import '../services/device_service.dart';

final preacherRepositoryProvider = Provider((ref) => PreacherRepository());

/// Holds the list of preacher profiles registered on this device
final devicePreachersProvider =
    FutureProvider<List<Preacher>>((ref) async {
  final deviceId = await DeviceService.getDeviceId();
  final repo = ref.read(preacherRepositoryProvider);
  return repo.getByDevice(deviceId);
});

/// Currently selected "who is preaching" profile
class SelectedPreacherNotifier extends Notifier<Preacher?> {
  @override
  Preacher? build() => null;

  void select(Preacher? preacher) {
    state = preacher;
  }
}

final selectedPreacherProvider =
    NotifierProvider<SelectedPreacherNotifier, Preacher?>(
  SelectedPreacherNotifier.new,
);