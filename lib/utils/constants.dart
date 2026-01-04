import 'package:flutter/material.dart';

class AppColors {
<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
  // 1. MÀU THƯƠNG HIỆU (BRAND) - Dùng nhiều nhất
  // Màu xanh chủ đạo (Dùng cho: Header, Nút chính "Mua ngay", Icon đang chọn)
  static const Color primary = Color(0xFF1570EF);

  // Màu đỏ cam (Dùng cho: Giá tiền, Nút "Sale", Badges thông báo, Nút Xóa)
  // Trong App bán hàng, màu này cực quan trọng để kích thích mua hàng
  static const Color primaryRed = Color(0xFFE53935);
<<<<<<< Updated upstream

  // Màu vàng (Dùng cho: Icon ngôi sao đánh giá, Trạng thái "Đang giao hàng")
  static const Color primaryYellow = Color(0xFFFFC107);

=======
  // Màu vàng (Dùng cho: Icon ngôi sao đánh giá, Trạng thái "Đang giao hàng")
  static const Color primaryYellow = Color(0xFFFFC107);
>>>>>>> Stashed changes
  // 2. MÀU NỀN (BACKGROUND)
  // Nền trắng tinh (Dùng cho: Card sản phẩm, Nền khung nhập liệu, Dialog)
  static const Color white = Colors.white;

  // Nền xám nhạt (Dùng cho: Nền tổng thể của App - phía sau các Card trắng)
<<<<<<< Updated upstream
  // Mấy đứa lưu ý: Đừng dùng màu trắng cho background tổng, nhìn sẽ bị chói mắt
  static const Color backgroundLight = Color(0xFFF2F4F7);

=======
  static const Color backgroundLight = Color(0xFFF2F4F7);
>>>>>>> Stashed changes
  // 3. MÀU CHỮ (TEXT) - Quan trọng, cấm dùng Colors.black lung tung
  // Màu đen đậm (Dùng cho: Tên sản phẩm, Tiêu đề màn hình "Giỏ hàng")
  static const Color textTitle = Color(0xFF101828);

  // Màu xám đậm (Dùng cho: Mô tả ngắn, Giá gốc bị gạch ngang)
  static const Color textBody = Color(0xFF475467);

  // Màu xám nhạt (Dùng cho: Placeholder "Nhập mật khẩu...", Chữ mờ "Ngày tạo...")
  static const Color textHint = Color(0xFF98A2B3);

  // Màu trắng (Dùng cho: Chữ nằm trên nút màu Xanh hoặc Đỏ)
  static const Color textWhite = Colors.white;


<<<<<<< Updated upstream
  // 4. MÀU VIỀN & DÒNG KẺ (BORDER & DIVIDER)
  // Màu xám siêu nhạt (Dùng cho: Viền ô nhập liệu, Đường gạch ngang phân cách)
  static const Color border = Color(0xFFEAECF0);

=======

  // 4. MÀU VIỀN & DÒNG KẺ (BORDER & DIVIDER)


  // Màu xám siêu nhạt (Dùng cho: Viền ô nhập liệu, Đường gạch ngang phân cách)
  static const Color border = Color(0xFFEAECF0);



>>>>>>> Stashed changes
  // 5. MÀU TRẠNG THÁI ĐƠN HÀNG (STATUS)

  // Màu xanh lá (Dùng cho: Trạng thái "Giao thành công", "Thanh toán thành công")
  static const Color success = Color(0xFF12B76A);

  // Màu đỏ (Dùng cho: Trạng thái "Đã hủy", Báo lỗi "Sai mật khẩu")
  static const Color error = Color(0xFFF04438);
}