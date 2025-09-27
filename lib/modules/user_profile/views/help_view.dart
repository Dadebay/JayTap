import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/user_profile/model/help_model.dart';
import 'package:jaytap/modules/user_profile/services/user_profile_service.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:kartal/kartal.dart';

class HelpView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: "helpApp".tr, showElevation: true, showBackButton: true),
      body: FutureBuilder<HelpApiResponse>(
        future: UserProfileService().fetchHelpData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomWidgets.loader();
          } else if (snapshot.hasError) {
            return CustomWidgets.errorFetchData();
          } else if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
            return CustomWidgets.emptyData();
          } else {
            return ListView.builder(
              padding: context.padding.normal,
              itemCount: snapshot.data!.results.length,
              itemBuilder: (context, index) {
                final helpItem = snapshot.data!.results[index];
                final locale = Get.locale?.languageCode ?? 'tr';

                String title;
                String subtitle;

                switch (locale) {
                  case 'ru':
                    title = helpItem.titleRu;
                    subtitle = helpItem.subtitleRu;
                    break;
                  case 'en':
                    title = helpItem.titleEn;
                    subtitle = helpItem.subtitleEn;
                    break;
                  default:
                    title = helpItem.titleTm;
                    subtitle = helpItem.subtitleTm;
                }

                return Theme(
                  data: ThemeData().copyWith(
                    dividerColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
                  child: Container(
                    margin: context.padding.onlyBottomNormal,
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  Theme.of(context).shadowColor.withOpacity(.1),
                              blurRadius: 5)
                        ]),
                    child: ExpansionTile(
                      key: PageStorageKey(helpItem.titleTm),
                      title: Text(
                        title,
                        style: context.general.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0)
                              .copyWith(bottom: 16.0),
                          child: Html(
                            data: subtitle,
                            style: {
                              "body": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero),
                              "p": Style(
                                fontSize: FontSize(15.0),
                                lineHeight: LineHeight(1.5),
                              ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
