import 'package:vmodel/src/features/settings/views/account_settings/widgets/account_settings_card.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:go_router/go_router.dart';

class PersonalSettingsPage extends StatelessWidget {
   const PersonalSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  const VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "Personal Information", 
      ),
      body: SingleChildScrollView(
      padding:  const VWidgetsPagePadding.horizontalSymmetric(18),
      child: Column(

        children: [
         addVerticalSpacing(15),
        VWidgetsAccountSettingsCard(
          title: "Full Name",
          subtitle: "John Doe",
          onTap: () {
            context.push('AccountSettingsNamePage');
          },
        ),
         VWidgetsAccountSettingsCard(
          title: "Email",
          subtitle: "john@vmodel.app",
          onTap: () {
            context.push('AccountSettingsEmailPage') ;
          },
        ),

         VWidgetsAccountSettingsCard(
          title: "Location (City)",
          subtitle: "London",
          onTap: () {
            context.push('AccountSettingsLocationPage');
          },
        ),

         VWidgetsAccountSettingsCard(
          title: "Phone",
          subtitle: "+44 123 456 789",
          onTap: () {
            context.push('AccountSettingsPhonePage');
          },
        ),

        VWidgetsAccountSettingsCard(
          title: "Date of Birth",
          subtitle: "01/01/2000",
          onTap: () {

          },
        ),
      ]),
    ),
    );
  }
}
