class ApiConfig {
  static const String baseUrl = 'http://192.168.133.63:8000/api';
  
  // Auth endpoints
  static const String login = '$baseUrl/anganwadi/login';
  
  // Children endpoints
  static const String childrenCreate = '$baseUrl/anganwadi/children/create';
  
  // Add other API endpoints here as needed
} 