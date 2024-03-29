abstract class GetStartedRepository {
  Future<int> listenToUserPoints();
  Future<void> resetAllCurrentToZero();
  Future<void> copyCurrentToLatest();
  Future<void> setResetToDo(bool boolean);
  Future<List<int>> getAllCurrentDone();
  Future<bool> isDeviceConnected();
  DateTime getLocalTimeStampSignUp();
  Future<void> setWizardToDisplay(bool boolean);
  Future<bool> getWizardToDisplay();
}