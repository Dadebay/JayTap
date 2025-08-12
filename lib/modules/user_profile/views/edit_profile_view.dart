import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/core/services/api_constants.dart';
// Projenizdeki bu importları kendi dosya yollarınıza göre düzeltmeniz gerekebilir.
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:jaytap/shared/dialogs/dialogs_utils.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/sizes/image_sizes.dart';
import 'package:jaytap/shared/widgets/agree_button.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:kartal/kartal.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final UserProfilController userProfileController = Get.find<UserProfilController>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = userProfileController.user.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: '+993' + (user?.username ?? ''));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "edit_user_data", showBackButton: true),
      body: Obx(() {
        if (userProfileController.isLoading.value) return CustomWidgets.loader();
        if (userProfileController.user.value == null) return CustomWidgets.emptyData();
        final user = userProfileController.user.value!;

        return ListView(
          padding: context.padding.normal,
          children: [
            CustomWidgets().imageSelector(
                context: context,
                imageUrl: user.img,
                onTap: () {
                  DialogUtils.showImagePicker(context, _picker);
                },
                addPadding: false),
            _buildTextFieldWithLabel(
              context: context,
              label: 'Ady'.tr,
              controller: _nameController,
            ),
            _buildTextFieldWithLabel(
              context: context,
              label: 'Nomer'.tr,
              controller: _phoneController,
              isEnabled: false, // Bu alanın değiştirilmesini engeller
            ),
            AgreeButton(onTap: () {}, text: 'save'.tr)
          ],
        );
      }),
    );
  }
  Widget _buildTextFieldWithLabel({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            label,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: isEnabled,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            // Değiştirilemez ise rengi soluk yap
            color: isEnabled ? null : context.greyColor,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isEnabled ? context.general.colorScheme.surface : context.greyColor.withOpacity(0.1),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: context.greyColor.withOpacity(0.3), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: context.greyColor.withOpacity(0.3), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: context.primaryColor, width: 2),
            ),
            // Değiştirilemez alanın kenarlık rengi
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: context.greyColor.withOpacity(0.2), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
