import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart'; // Import kho màu để dùng chung

class AppStyles {
  // 1. Tiêu đề lớn (Dùng cho tên màn hình: "Giỏ hàng", "Thanh toán")
  static TextStyle h1 = GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textTitle,
  );

  // 2. Tiêu đề vừa (Dùng cho tên sản phẩm trong list)
  static TextStyle h2 = GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textTitle,
  );

  // 3. Tiêu đề nhỏ (Dùng cho tên sản phẩm trong Card nhỏ)
  static TextStyle h3 = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textTitle,
  );

  // 4. Nội dung thường (Mô tả sản phẩm, đánh giá)
  static TextStyle body = GoogleFonts.roboto(
    fontSize: 14,
    color: AppColors.textBody, // Màu xám
  );

  // 5. Giá tiền (Quan trọng: Màu đỏ, in đậm)
  static TextStyle price = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryRed,
  );

  // 6. Chữ trên nút bấm (Màu trắng, in đậm)
  static TextStyle buttonText = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );
}
