import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

/// Manages the Add a Server page in order to ensure that form data is validated successfully.
/// This also handles checking if the server is located with the ip address and port.
/// Validation will fail if the password is incorrect.
///
/// Author: Devon X. Dalrymple
/// Version: 2022-06-24
class AddAServerFormController extends GetxController {
  late RxString ipAddress;
  late RxInt port;
  late RxString password;
  late RxString displayName;

  late RxnString errorText;

  Rxn<Function()> submitFunc = Rxn<Function()>(null);

  AddAServerFormController() : super() {
    ipAddress = RxString("");
    port = RxInt(0);
    password = RxString("");
    displayName = RxString("");

    errorText = RxnString(null);
  }

  // https://stackoverflow.com/questions/64544571/flutter-getx-forms-validation - Baker
  @override
  void onInit() {
    super.onInit();
    debounce<String>(RxString(""), _validations, time: const Duration(milliseconds: 1000));
  }

  void _validations(String _) async {
    StringBuffer errorBuffer = StringBuffer();
    errorText.value = null; // reset validation errors to nothing
    submitFunc.value = null; // disable submit while validating

    _validateIPAddress(errorBuffer);
    _validatePortNumber(errorBuffer);
    _validatePassword(errorBuffer);
    _validateDisplayName(errorBuffer);

    if (errorBuffer.toString().length == 0) {
      submitFunc.value = _submitFunction();
      errorText.value = null;
    }

  }

  Future<bool> Function() _submitFunction() {
    return () async {
      print('Make database call to create account');
      await Future.delayed(const Duration(seconds: 1), () => print('User account created'));
      return true;
    };
  }

  void _validateIPAddress(StringBuffer errorBuffer) {
    // https://stackoverflow.com/questions/31684083/validate-if-input-string-is-a-number-between-0-255-using-regex - Etienne Lawlor
    RegExp regex = RegExp("/0?([0-9]{1,2}|1?[0-9]{1,2}|2[0-4][0-9]|25[0-5])");

    if (ipAddress.isEmpty) {
      errorBuffer.writeln("IP Address must not be empty");
    } else if (regex.allMatches(ipAddress.string).length != 4) {
      errorBuffer.writeln("IP Address must be formatted like '23.54.23.122' from 0-255.");
    }
  }

  void _validatePortNumber(StringBuffer errorBuffer) {
    if (port < 10 || port > 65535) {
      errorBuffer.writeln("Port number must be a valid port number greater than 10 and less than or equal to 65,535.");
    }
  }

  void _validatePassword(StringBuffer errorBuffer) {
    if (password.string.length < 6) {
      errorBuffer.writeln("The password must be at least six characters long.")
    }
  }

  void _validateDisplayName(StringBuffer errorBuffer) {
    if (displayName.string.length < 3) {
      errorBuffer.writeln("Your display name must be at least three characters long.")
    }
  }


}