class ApiConfig {
  static const String baseUrl = 'http://192.168.133.63:8000/api';

  // Auth endpoints
  static const String login = '$baseUrl/anganwadi/login';

  // Children endpoints
  static const String childrenCreate = '$baseUrl/anganwadi/children/create/';

  static const String getfood = '$baseUrl/anganwadi/getfood';
  static const String getChildren = '$baseUrl/anganwadi/children';
    static const String check_mal = '$baseUrl/anganwadi/check_malnutrtion/';


  // Add other API endpoints here as needed
}
