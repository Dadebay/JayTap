import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
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
  final UserProfilController controller = Get.find<UserProfilController>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = controller.user.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController =
        TextEditingController(text: '+993' + (user?.username ?? ''));
    controller.selectedImageFile.value = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(IconlyBold.camera, size: 35),
              title:
                  Text('select_by_camera'.tr, style: TextStyle(fontSize: 18)),
              onTap: () async {
                Get.back();
                final XFile? pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                controller.onImageSelected(pickedFile);
              },
            ),
            ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(IconlyBold.image, size: 30),
              ),
              title:
                  Text('select_by_gallery'.tr, style: TextStyle(fontSize: 18)),
              onTap: () async {
                Get.back();
                final XFile? pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                controller.onImageSelected(pickedFile);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "edit_user_data", showBackButton: true),
      body: Obx(() {
        if (controller.isLoading.value) return CustomWidgets.loader();
        if (controller.user.value == null) return CustomWidgets.emptyData();
        final user = controller.user.value!;
        ImageProvider<Object> imageProvider;
        if (controller.selectedImageFile.value != null) {
          imageProvider = FileImage(controller.selectedImageFile.value!);
        } else if (user.img != null && user.img!.isNotEmpty) {
          imageProvider = CachedNetworkImageProvider(user.img!);
        } else {
          imageProvider = AssetImage(IconConstants.noImageUser); // Yedek resim
        }
        print(imageProvider);
        return Stack(
          children: [
            _body(context, imageProvider),
            controller.isUpdatingProfile.value
                ? Positioned.fill(
                    child: Container(
                      color:
                          Theme.of(context).colorScheme.surface.withOpacity(.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: controller.uploadProgress.value,
                            color: Theme.of(context).colorScheme.onSurface,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3),
                            strokeWidth: 3,
                          ),
                          // Yüzdeyi gösteren metin
                          Text(
                            "please_wait_to_upload".tr +
                                ' ${(controller.uploadProgress.value * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        );
      }),
    );
  }

  ListView _body(BuildContext context, ImageProvider<Object> imageProvider) {
    return ListView(
      padding: context.padding.normal,
      children: [
        SizedBox(height: 20.h),
        Center(
          child: Stack(
            children: [
              CircleAvatar(radius: 60.r, backgroundImage: imageProvider),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: CircleAvatar(
                    radius: 15.r,
                    backgroundColor: ColorConstants.kPrimaryColor,
                    child: Icon(Icons.edit,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 16.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        _buildTextFieldWithLabel(
          context: context,
          label: 'name_label'.tr,
          controller: _nameController,
        ),
        SizedBox(height: 20.h),
        _buildTextFieldWithLabel(
          context: context,
          label: 'number_label'.tr,
          controller: _phoneController,
          isEnabled: false,
        ),
        SizedBox(height: 40.h),
        Obx(() => AgreeButton(
              onTap: controller.isUpdatingProfile.value
                  ? () {} // Yüklenirken butonu pasif yap
                  : () => controller.updateUserProfile(_nameController.text),
              text: 'agree',
            )),
      ],
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
              fontSize: 14.sp,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: isEnabled,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 17,
            color: isEnabled ? null : context.greyColor,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isEnabled
                ? context.general.colorScheme.surface
                : context.greyColor.withOpacity(0.1),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                  color: context.greyColor.withOpacity(0.3), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                  color: context.greyColor.withOpacity(0.3), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: context.primaryColor, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                  color: context.greyColor.withOpacity(0.2), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
