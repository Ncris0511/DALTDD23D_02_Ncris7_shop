import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ncris7shop/screens/auth/register_screen.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Nền trắng
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Image.asset('assets/images/logo.png', width: 150),

              const SizedBox(height: 30),

              Text(
                "Ncris7",
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTitle,
                ),
              ),

              const SizedBox(height: 10),
              Text(
                "Nâng tầm trải nghiệm\n\t\tmua sắm của bạn",
                textAlign: TextAlign.center, // Căn giữa cho đẹp
                style: AppStyles.body.copyWith(
                  fontSize: 16, // Ghi đè size 14 mặc định thành 16
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Bắt đầu",
                    // 👇 Gọi style chuẩn từ kho ra, chỉnh size lên 18
                    style: AppStyles.buttonText.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Tôi đã có tài khoản", style: AppStyles.h3),
                  const SizedBox(width: 10),

                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
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
