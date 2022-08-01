abstract class ApphudPlusListener {
  /// Method called when paywalls did load
  ///
  /// If the parameter is true, the paywalls did load.
  /// If the parameter is false, some error occurred, debug with Xcode
  /// for more details.
  Future<void> paywallsDidLoadCallback(bool result);
}
