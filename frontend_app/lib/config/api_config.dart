class ApiConfig {
  static const String baseUrl = 'http://172.16.11.177:8000/api';

  // Auth endpoints
  static const String login = '$baseUrl/anganwadi/login';

  // Children endpoints
  static const String childrenCreate = '$baseUrl/anganwadi/children/create/';

  static const String getfood = '$baseUrl/anganwadi/getfood';
  static const String getChildren = '$baseUrl/anganwadi/children';
  static const String check_mal = '$baseUrl/anganwadi/check_malnutrtion/';
  static const String distribute_suppliment = '$baseUrl/supplements/distribute/';

  static const String get_child_report = '$baseUrl/anganwadi/get_child_report/';
    static const String get_child_reports = '$baseUrl/anganwadi/get_child_reports/';




  // Add other API endpoints here as needed
}
