// LoginView.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/auth/controllers/auth_service.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/widgets/agree_button.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:jaytap/shared/widgets/custom_text_field.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:kartal/kartal.dart';

class LoginView extends StatefulWidget {
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final FocusNode phoneNumberFocusNode = FocusNode();
  final FocusNode nameFocusNode = FocusNode();

  bool isLoginMode = false; // Başlangıç modu: Kayıt Ol (Signup)

  dynamic onTap(BuildContext context) async {
    if (phoneNumberController.text.length != 8) {
      CustomWidgets.showSnackBar('login_error'.tr, 'phone_number_error'.tr, context.redColor);
      return;
    }
    if (isLoginMode) {
      await AuthService().login(phone: phoneNumberController.text);
    } else {
      if (nameController.text.isEmpty) {
        CustomWidgets.showSnackBar('signup_error'.tr, 'name_empty_error'.tr, context.redColor);
        return;
      }
      await AuthService().signup(phone: phoneNumberController.text, name: nameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: isLoginMode ? 'login' : 'signUp', showBackButton: false),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        shrinkWrap: true,
        children: [
          CustomWidgets().logo(context),
          Padding(
            padding: context.padding.verticalNormal,
            child: Text(
              isLoginMode ? "login_title".tr : "sign_up_title".tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500, fontSize: 18.sp),
            ),
          ),
          if (!isLoginMode)
            CustomTextField(
              labelName: 'name'.tr,
              controller: nameController,
              focusNode: nameFocusNode,
              requestfocusNode: phoneNumberFocusNode,
            ),
          PhoneNumberTextField(
            controller: phoneNumberController,
            focusNode: phoneNumberFocusNode,
            requestfocusNode: phoneNumberFocusNode,
          ),
          Padding(
            padding: context.padding.verticalNormal,
            child: Center(
              child: GradientButton(
                onTap: () => onTap(context),
                text: isLoginMode ? "login".tr : "agree".tr,
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  isLoginMode = !isLoginMode;
                });
              },
              child: Text(
                isLoginMode ? "create_account".tr : "have_account".tr,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.primaryColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
