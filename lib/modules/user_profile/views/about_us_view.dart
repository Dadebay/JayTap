import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/user_profile/model/about_us_model.dart';
import 'package:jaytap/modules/user_profile/services/user_profile_service.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:kartal/kartal.dart';

class AboutUsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "aboutUs".tr, showElevation: true, showBackButton: true),
      body: FutureBuilder<AboutApiResponse>(
        future: UserProfileService().fetchAboutData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomWidgets.loader();
          } else if (snapshot.hasError) {
            return CustomWidgets.errorFetchData();
          } else if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
            return CustomWidgets.emptyData();
          } else {
            final String htmlContent = snapshot.data!.results.first.content;

            return SingleChildScrollView(
              padding: context.padding.normal,
              child: Html(
                data: htmlContent,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                  ),
                  "p": Style(
                    margin: Margins.only(bottom: 12.0),
                    fontSize: FontSize(16.0),
                    lineHeight: LineHeight(1.5),
                  ),
                  "strong": Style(
                    fontWeight: FontWeight.bold,
                  ),
                },
              ),
            );
          }
        },
      ),
    );
  }
}
