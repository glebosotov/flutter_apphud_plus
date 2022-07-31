class ApphudNotificationPayload {
  String? ruleId;
  String? ruleName;
  String? screenId;
  String? screenName;
  Map<String, dynamic>? custom;

  ApphudNotificationPayload({
    this.ruleId,
    this.ruleName,
    this.screenId,
    this.screenName,
    this.custom,
  });

  factory ApphudNotificationPayload.fromJson(Map<String, dynamic> json) {
    return ApphudNotificationPayload(
      ruleId: json['ruleId'],
      ruleName: json['ruleName'],
      screenId: json['screenId'],
      screenName: json['screenName'],
      custom: json['custom'],
    );
  }
}
