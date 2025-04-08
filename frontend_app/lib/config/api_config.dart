class ApiConfig {
  static const String baseUrl = 'http://192.168.126.63:8000/api';

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
   static const String anganwadi_supplements = '$baseUrl/anganwadi-supplements';

 static const String request_supplements = '$baseUrl/anganwadi/request_supplements';
 static const String all_supplement_requests = '$baseUrl/anganwadi/supplement_requests';

  static const String children_with_reports = '$baseUrl/anganwadi/children_with_reports';
 static const String get_program = '$baseUrl/head_officer/programs';
  static const String home_data = '$baseUrl/anganwadi/profile';




  // Add other API endpoints here as needed
}
