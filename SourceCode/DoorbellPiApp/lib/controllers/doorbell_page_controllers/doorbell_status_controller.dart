import 'package:doorbell_pi_app/controllers/listening_controller.dart';
import 'package:doorbell_pi_app/helpers/observer.dart';
import 'package:doorbell_pi_app/repositories/main_server_repository.dart';
import 'package:doorbell_pi_app/widgets/doorbell_status_view.dart';
import 'package:get/get.dart';import '../data/database/app_persistence_db.dart';


import '../data/database/app_persistence_repository.dart';

class DoorbellStatusController extends ListeningController {
  late final String _doorbellDisplayName;
  late AppPersistenceRepository _persistenceRepository;

  late RxString state;
  late RxString activeSince;
  late RxString estimatedBatteryLeft;
  late RxBool canShutdownDoorbell;

  DoorbellStatusController(this._doorbellDisplayName, Observer observerForDoorbell) : super(observerForDoorbell) {
    _persistenceRepository = Get.find();

    state = RxString('N/A');
    activeSince = RxString('N/A');
    estimatedBatteryLeft = RxString('N/A');
    canShutdownDoorbell = RxBool(false);

    _updateViewWithNewInformation();
  }

  // Grabs the selected doorbell and updates each field for the widget to reflect the current state of the doorbell
  Future<void> _updateViewWithNewInformation() async {
    Doorbell selectedDoorbell = (await _persistenceRepository.getDoorbellByDisplayName(_doorbellDisplayName))!;
    DateTime timeDoorbellWasTurnedOn =  DateTime.fromMillisecondsSinceEpoch(selectedDoorbell.activeSinceUnix.toInt() * 1000, isUtc: true); // Server delivers the time in seconds since epoch
    timeDoorbellWasTurnedOn = timeDoorbellWasTurnedOn.toLocal().subtract(const Duration(hours: 4)); // TODO: Find out why DateTime is stuck in UTC here

    int hourPreformatted = (timeDoorbellWasTurnedOn.hour == 0) ? timeDoorbellWasTurnedOn.hour + 24 : timeDoorbellWasTurnedOn.hour; // Done for the following 24-hour to 12-hour conversion

    String timeString = (hourPreformatted > 12)
        ? '${hourPreformatted - 12}:${timeDoorbellWasTurnedOn.minute.toString().padLeft(2,'0')} PM'
        : '$hourPreformatted:${timeDoorbellWasTurnedOn.minute.toString().padLeft(2,'0')} AM';

    canShutdownDoorbell.value = !(selectedDoorbell.doorbellStatus == 'Disconnected or Off' || selectedDoorbell.doorbellStatus == 'Unknown State');
    state.value = selectedDoorbell.doorbellStatus;

    if (!canShutdownDoorbell.value) {
      activeSince.value = 'N/A';
      estimatedBatteryLeft.value = 'N/A';
    } else {
      activeSince.value = '${timeDoorbellWasTurnedOn.year}-${timeDoorbellWasTurnedOn.month.toString().padLeft(2,'0')}-${timeDoorbellWasTurnedOn.day.toString().padLeft(2,'0')} $timeString';
      estimatedBatteryLeft.value = '~${_calculateEstimatedBatteryLeftPercentage(selectedDoorbell)}%';
    }

  }

  // Returns 0-100 for the estimated power left on the doorbell system before it shuts down.
  int _calculateEstimatedBatteryLeftPercentage(Doorbell currentDoorbell) {
    // Estimated battery life using the data from https://www.tomshardware.com/reviews/raspberry-pi-zero-2-w-review and a 10,000 mAH battery pack is 33 hours in 20 minutes
    const int secondsExpectedFromDoorbellLife = 120000; // value was 119,999.88 from 33.333 * 3600
    int nowUTCSecondsSinceEpoch = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    int currentTimeInSecondsSinceEpochMinusTimeDoorbellBecameActive = (currentDoorbell.activeSinceUnix.toInt() - nowUTCSecondsSinceEpoch);

    int expectedTimeLeftFromDoorbell = secondsExpectedFromDoorbellLife - currentTimeInSecondsSinceEpochMinusTimeDoorbellBecameActive; // Numerator for percentage math
    if (expectedTimeLeftFromDoorbell < 0) return 0; // The doorbell might lose power any second now, prevents negative percentages

    return ((expectedTimeLeftFromDoorbell / secondsExpectedFromDoorbellLife) * 100).toInt();

  }

  @override
  void doListenerUpdate() {
    _updateViewWithNewInformation();
  }
}