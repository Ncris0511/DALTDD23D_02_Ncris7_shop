class ApiConfig {
  static const String baseUrl = "http://10.0.2.2:5001/api";

  //Các đường dẫn con
  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";
  static const String resetPassword = "$baseUrl/auth/reset-password-email";
  static const String address = "$baseUrl/addresses";
  static const String order = "$baseUrl/orders";
  static const String cart = "$baseUrl/cart";
  static const String voucher = "$baseUrl/marketing/vouchers/check";
}
