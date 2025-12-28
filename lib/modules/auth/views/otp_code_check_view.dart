import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/auth/controllers/auth_service.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/widgets/agree_button.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:kartal/kartal.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OTPCodeCheckView extends StatefulWidget {
  final String phoneNumber;

  const OTPCodeCheckView({required this.phoneNumber, super.key});

  @override
  State<OTPCodeCheckView> createState() => _OTPCodeCheckViewState();
}

class _OTPCodeCheckViewState extends State<OTPCodeCheckView> with CodeAutoFill {
  final otpCheck = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();

  Future<void> _processOtp() async {
    if (otpCheck.currentState?.validate() ?? false) {
      try {
        await AuthService()
            .otpCheck(otp: otpController.text, phoneNumber: widget.phoneNumber);
      } catch (_) {}
    } else {
      CustomWidgets.showSnackBar(
          'noConnection3', 'errorEmpty', context.redColor);
    }
  }

  String formatPhoneNumber(String raw) {
    if (raw.length != 8) return raw;
    final match = RegExp(r'(\d{2})(\d{2})(\d{2})(\d{2})').firstMatch(raw);
    return '${match?[1]} ${match?[2]} ${match?[3]} ${match?[4]}';
  }

  @override
  void dispose() {
    cancel();
    otpController.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void codeUpdated() {
    setState(() {
      otpController.text = code!;
    });
    _processOtp();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: 'agree2', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 40),
        children: [
          CustomWidgets().logo(context),
          Column(
            children: [
              Padding(
                padding: context.padding.onlyTopNormal,
                child: Text(
                  'otpTitle'.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: isDarkMode
                          ? context.whiteColor
                          : context.primaryColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "+993 " + formatPhoneNumber(widget.phoneNumber),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 18.sp),
                ),
              ),
              Text(
                'otpSubtitle'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.normal),
              ),
              Form(
                key: otpCheck,
                child: Padding(
                  padding: context.padding.normal.copyWith(bottom: 40),
                  child: PinFieldAutoFill(
                    codeLength: 4,
                    decoration: UnderlineDecoration(
                      textStyle: TextStyle(
                          fontSize: 25,
                          color: isDarkMode
                              ? context.whiteColor
                              : context.blackColor,
                          fontWeight: FontWeight.bold),
                      colorBuilder: FixedColorBuilder(context.greyColor),
                    ),
                    controller: otpController,
                    focusNode: otpFocusNode,
                    onCodeSubmitted: (val) => _processOtp(),
                    onCodeChanged: (code) {
                      if (code != null && code.length == 4) {
                        _processOtp();
                      }
                    },
                  ),
                ),
              ),
              Center(
                  child: GradientButton(
                onTap: _processOtp,
                text: 'agree3',
              )),
            ],
          ),
        ],
      ),
    );
  }
}
