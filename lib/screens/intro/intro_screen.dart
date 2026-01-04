import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, //Nền trắng tinh
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 2), //Đẩy nội dung xuống giữa màn hình
              Image.asset('assets/images/logo.png', width: 150),
              const SizedBox(height: 30),
              Text(
                "Ncris7",
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTitle, //Màu đen đậm
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Nâng tầm trải nghiệm\n\t\t\t\tmua sắm của bạn",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: AppColors.textBody,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3), //Khoảng trống ở giữa
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0, //Kh có bóng đổ
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), //Bo tròn 30
                    ),
                  ),
                  child: const Text(
                    "Bắt đầu",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Tôi đã có tài khoản",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textTitle,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  //Nút tròn nhỏ có mũi tên
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle, //Hình tròn
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: AppColors.textWhite,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
