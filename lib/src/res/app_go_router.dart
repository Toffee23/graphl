import 'dart:convert';
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:river_player/river_player.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/enum/album_type.dart';
import 'package:vmodel/src/core/utils/shared.dart';
import 'package:vmodel/src/features/activity/views/activity_homepage.dart';
import 'package:vmodel/src/features/authentication/login/views/auth_widget.dart';
import 'package:vmodel/src/features/authentication/login/views/user_verification.dart';
import 'package:vmodel/src/features/authentication/login/views/widgets/phone_verification_code_page.dart';
import 'package:vmodel/src/features/authentication/login/views/widgets/phone_verification_page.dart';
import 'package:vmodel/src/features/authentication/new_Login_screens/controller/new_user_onboarding.dart';
import 'package:vmodel/src/features/authentication/new_Login_screens/views/login_screen.dart';
import 'package:vmodel/src/features/authentication/views/create_password_view.dart';
import 'package:vmodel/src/features/authentication/views/login_view.dart';
import 'package:vmodel/src/features/authentication/views/new_login_screens/signup_view.dart';
import 'package:vmodel/src/features/authentication/register/views/create_password_view.dart'
    as otpCreatePassword;
import 'package:vmodel/src/features/authentication/register/views/signup_bio_setup.dart';
import 'package:vmodel/src/features/authentication/register/views/signup_display_name_setup.dart';
import 'package:vmodel/src/features/authentication/register/views/upload_photo_page.dart';
import 'package:vmodel/src/features/authentication/register/views/user_type_view.dart';

import 'package:vmodel/src/features/beta_dashboard/views/beta_dashboard_browser.dart';
import 'package:vmodel/src/features/booking/views/booking_list/booking_list.dart';
import 'package:vmodel/src/features/booking/views/booking_sequence/booking_sequence.dart';
import 'package:vmodel/src/features/booking/views/booking_settings/booking_settings.dart';
import 'package:vmodel/src/features/booking/views/booking_settings/booking_settings_option.dart';
import 'package:vmodel/src/features/booking/views/create_booking/create_booking_second.dart';
import 'package:vmodel/src/features/booking/views/create_booking/views/booking_payment_completetd.dart';
import 'package:vmodel/src/features/booking/views/create_booking/views/booking_payment_view.dart';
import 'package:vmodel/src/features/booking/views/create_booking/views/create_booking_first.dart';
import 'package:vmodel/src/features/create_contract/views/create_contract_view.dart';
import 'package:vmodel/src/features/create_contract/views/preview_contract.dart';
import 'package:vmodel/src/features/create_posts/models/post_set_model.dart';
import 'package:vmodel/src/features/create_posts/views/create_post_with_camera.dart';
import 'package:vmodel/src/features/create_posts/views/create_post_with_images.dart';
import 'package:vmodel/src/features/create_posts/views/edit_post.dart';
import 'package:vmodel/src/features/create_posts/views/preview_video_post.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_filter.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_main_screen.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_verified_section.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_view_category_based.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_view_category_detail.dart';
import 'package:vmodel/src/features/dashboard/discover/views/discover_view_new.dart';
import 'package:vmodel/src/features/dashboard/discover/views/explore.dart';
import 'package:vmodel/src/features/dashboard/discover/views/map_search_view.dart';
import 'package:vmodel/src/features/dashboard/discover/views/most_liked_album.dart';
import 'package:vmodel/src/features/dashboard/feed/views/feed_bottom_widget.dart';
import 'package:vmodel/src/features/dashboard/feed/views/feed_explore.dart';
import 'package:vmodel/src/features/dashboard/feed/views/feed_explore_search.dart';
import 'package:vmodel/src/features/dashboard/feed/views/feed_home.dart';
import 'package:vmodel/src/features/dashboard/feed/views/feed_home_view.dart';
import 'package:vmodel/src/features/dashboard/feed/views/feed_main.dart';
import 'package:vmodel/src/features/dashboard/feed/views/gallery_feed_strip.dart';
import 'package:vmodel/src/features/dashboard/feed/views/gallery_feed_view_homepage.dart';
import 'package:vmodel/src/features/dashboard/menu_settings/menu_sheet.dart';
import 'package:vmodel/src/features/dashboard/new_profile/model/gallery_model.dart';
import 'package:vmodel/src/features/dashboard/new_profile/other_user_profile/other_user_profile.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/views/services_homepage.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/user_jobs/views/user_jobs_homepage.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/business_profile/local/local_business_profile.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/business_profile/local/local_business_profile_buttons.widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/business_profile/local/local_business_profile_header_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/business_profile/remote/remote_business_profile.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/business_profile/remote/remote_business_profile_buttons.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/business_profile/remote/remote_business_profile_header_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/games_page.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/my_business_profile.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/new_profile_homepage.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/paginated_gallery_profile/paginated_gallery_profile_homepage%20copy.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/paginated_gallery_profile/widget/paginated_gallery_page.dart';
import 'package:vmodel/src/features/dashboard/new_profile/views/vmodel_maps.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/gallery_tabs_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/gallery_tabscreen_widget.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/profile_header_widget.dart';
import 'package:vmodel/src/features/dashboard/polaroid/views/new_post.dart';
import 'package:vmodel/src/features/dashboard/polaroid/views/polaroid_screen.dart';
import 'package:vmodel/src/features/dashboard/profile/view/network_connections_search.dart';
import 'package:vmodel/src/features/dashboard/profile/view/webview_page.dart';
import 'package:vmodel/src/features/dashboard/profile/widget/connection_shimmer.dart';
import 'package:vmodel/src/features/dashboard/profile/widget/network_search_empty_widget.dart';
import 'package:vmodel/src/features/dashboard/profile/widget/user_profile/expanded_bio_card.dart';
import 'package:vmodel/src/features/dashboard/profile/widget/user_profile/payment_checkout_info.dart';
import 'package:vmodel/src/features/dashboard/profile/widget/user_profile/profile_sub_info_widget.dart';
import 'package:vmodel/src/features/deleted_posts/views/deleted_posts.dart';
import 'package:vmodel/src/features/deleted_posts/views/restore_deleted_posts.dart';
import 'package:vmodel/src/features/faq_s/views/faq_topics.dart';
import 'package:vmodel/src/features/faq_s/views/faqs_homepage.dart';
import 'package:vmodel/src/features/guess_page/views/guess_page.dart';
import 'package:vmodel/src/features/guess_page/views/leadership_boards.dart';
import 'package:vmodel/src/features/help_support/views/help_details_two.dart';
import 'package:vmodel/src/features/jobs/create_jobs/views/create_job_view_second.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/jobs/job_market/views/all_jobs_end_widget.dart';
import 'package:vmodel/src/features/jobs/job_market/views/all_jobs_search_widget.dart';
import 'package:vmodel/src/features/jobs/job_market/views/business_user/business_offers_homepage.dart';
import 'package:vmodel/src/features/jobs/job_market/views/business_user/market_place.dart';
import 'package:vmodel/src/features/jobs/job_market/views/business_user/market_place_simple.dart';
import 'package:vmodel/src/features/jobs/job_market/views/coupon_end_widget.dart';
import 'package:vmodel/src/features/jobs/job_market/views/coupons.dart';
import 'package:vmodel/src/features/jobs/job_market/views/coupons_search_result.dart';
import 'package:vmodel/src/features/jobs/job_market/views/coupons_simplified.dart';
import 'package:vmodel/src/features/jobs/job_market/views/filter_bottom_sheet.dart';
import 'package:vmodel/src/features/jobs/job_market/views/job_booker_applications_homepage.dart';
import 'package:vmodel/src/features/jobs/job_market/views/job_detail_booker.dart';
import 'package:vmodel/src/features/jobs/job_market/views/job_detail_creative.dart';
import 'package:vmodel/src/features/jobs/job_market/views/job_detail_creative_updated.dart';
import 'package:vmodel/src/features/jobs/job_market/views/job_details_homepage.dart';
import 'package:vmodel/src/features/jobs/job_market/views/job_market_offer_accepted.dart';
import 'package:vmodel/src/features/jobs/job_market/views/live_class_marketplace_page.dart';
import 'package:vmodel/src/features/jobs/job_market/views/local_services.dart';
import 'package:vmodel/src/features/jobs/job_market/views/marketplace_home.dart';
import 'package:vmodel/src/features/jobs/job_market/views/marketplace_jobs_simplified.dart';
import 'package:vmodel/src/features/jobs/job_market/views/marketplace_services_simplified.dart';
import 'package:vmodel/src/features/jobs/job_market/views/offer_accepted.dart';
import 'package:vmodel/src/features/jobs/job_market/views/recommended_jobs_page.dart';
import 'package:vmodel/src/features/jobs/job_market/views/remote_jobs_page.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/features/jobs/job_market/views/services_search_results.dart';
import 'package:vmodel/src/features/jobs/job_market/views/sugesstion_screen.dart';
import 'package:vmodel/src/features/likes/views/likes.dart';
import 'package:vmodel/src/features/live_classes/views/view_full_video.dart';
import 'package:vmodel/src/features/messages/model/messages_route_model.dart';
import 'package:vmodel/src/features/messages/views/archived_messages.dart';
import 'package:vmodel/src/features/messages/views/create_offer.dart';
import 'package:vmodel/src/features/messages/views/messages_chat_screen.dart';
import 'package:vmodel/src/features/notifications/views/notifications_ui.dart';
import 'package:vmodel/src/features/onboarding/views/birthday_view_settings.dart';
import 'package:vmodel/src/features/onboarding/views/business_address_view.dart';
import 'package:vmodel/src/features/onboarding/views/email_view.dart';
import 'package:vmodel/src/features/onboarding/views/location_view.dart';
import 'package:vmodel/src/features/onboarding/views/name_view.dart';
import 'package:vmodel/src/features/onboarding/views/onboarding_address_page.dart';
import 'package:vmodel/src/features/onboarding/views/onboarding_email_page.dart';
import 'package:vmodel/src/features/onboarding/views/onboarding_name_page.dart';
import 'package:vmodel/src/features/onboarding/views/onboarding_photo_page.dart';
import 'package:vmodel/src/features/onboarding/views/phone_view.dart';
import 'package:vmodel/src/features/qr_code/views/qr_page.dart';
import 'package:vmodel/src/features/refer_and_earn/views/invite_contact.dart';
import 'package:vmodel/src/features/requests/views/pages/create_request_page.dart';
import 'package:vmodel/src/features/requests/views/pages/create_request_page2.dart';
import 'package:vmodel/src/features/requests/views/pages/my_request_page.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/views/gig_service_detail.dart';
import 'package:vmodel/src/features/reviews/views/booking_details.dart';
import 'package:vmodel/src/features/reviews/views/bookings_view.dart';
import 'package:vmodel/src/features/reviews/views/empty_upcoming_bookings.dart';
import 'package:vmodel/src/features/reviews/views/select_user_to_rate_screen.dart';
import 'package:vmodel/src/features/saved/views/display_boards.dart';
import 'package:vmodel/src/features/saved/views/saved_services.dart';
import 'package:vmodel/src/features/saved/views/user_created_boards.dart';
import 'package:vmodel/src/features/saved/widgets/text_overlayed_image.dart';
import 'package:vmodel/src/features/search_history/views/search_history.dart';
import 'package:vmodel/src/features/settings/other_options/views/account_settings/views/account_settings.dart';
import 'package:vmodel/src/features/settings/other_options/views/account_settings/views/account_settings_sub_base.dart';
import 'package:vmodel/src/features/settings/other_options/views/account_settings/views/email_update_view.dart';
import 'package:vmodel/src/features/settings/other_options/views/account_settings/views/name_update_view.dart';
import 'package:vmodel/src/features/settings/other_options/views/alert_settings.dart';
import 'package:vmodel/src/features/settings/other_options/views/await_design.dart';
import 'package:vmodel/src/features/settings/other_options/views/bio_screen.dart';
import 'package:vmodel/src/features/settings/other_options/views/gender_screen.dart';
import 'package:vmodel/src/features/settings/other_options/views/interaction_settings.dart';
import 'package:vmodel/src/features/settings/other_options/views/jobTypes.dart';
import 'package:vmodel/src/features/settings/other_options/views/location_screen.dart';
import 'package:vmodel/src/features/settings/other_options/views/nickname_settings.dart';
import 'package:vmodel/src/features/settings/other_options/views/profile_settings.dart';
import 'package:vmodel/src/features/settings/other_options/views/settings_base.dart';
import 'package:vmodel/src/features/settings/two_step_verification/views/auth_app_two_fa_otp_verification.dart';
import 'package:vmodel/src/features/settings/two_step_verification/views/email_two_fa_otp_verification.dart';
import 'package:vmodel/src/features/settings/two_step_verification/views/sms_two_fa_otp_verification.dart';
import 'package:vmodel/src/features/settings/two_step_verification/views/two_factor_authentication.dart';
import 'package:vmodel/src/features/settings/two_step_verification/views/two_factor_qrcode.dart';
import 'package:vmodel/src/features/settings/two_step_verification/views/login_to_continue.dart';
import 'package:vmodel/src/features/settings/views/account_settings/views/account_settings_email_page.dart';
import 'package:vmodel/src/features/settings/views/account_settings/views/account_settings_location_page.dart';
import 'package:vmodel/src/features/settings/views/account_settings/views/account_settings_name_page.dart';
import 'package:vmodel/src/features/settings/views/account_settings/views/account_settings_phone_page.dart';
import 'package:vmodel/src/features/settings/views/account_settings/views/password_settings_page.dart';
import 'package:vmodel/src/features/settings/views/account_settings/views/personal_settings_page.dart';
import 'package:vmodel/src/features/settings/views/account_settings/views/security_and_privacy_settings.dart';
import 'package:vmodel/src/features/settings/views/account_settings/views/verify_password.dart';
import 'package:vmodel/src/features/settings/views/activities_menu/views/activities.view.dart';
import 'package:vmodel/src/features/settings/views/activities_menu/views/activities_page.dart';
import 'package:vmodel/src/features/settings/views/alert_settings.dart';
import 'package:vmodel/src/features/settings/views/apperance/views/apperance_screen.dart';
import 'package:vmodel/src/features/settings/views/apperance/views/default_icon.dart';
import 'package:vmodel/src/features/settings/views/apperance/views/haptics_page.dart';
import 'package:vmodel/src/features/settings/views/apperance/views/languages.dart';
import 'package:vmodel/src/features/settings/views/apperance/views/onboarding_profile_ring.dart';
import 'package:vmodel/src/features/settings/views/apperance/views/profile_ring.dart';
import 'package:vmodel/src/features/settings/views/apperance/views/themes.dart';
import 'package:vmodel/src/features/settings/views/blocked_list/blocked_list_card_widget.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/views/booking_prices_settings.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/views/booking_settings.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/views/create_offer_page.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/views/job_types_settings.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/views/view_all_dates.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/widgets/booking_settings_card.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/widgets/category_modal.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/widgets/service_image_listview.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/widgets/service_image_tile.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/widgets/service_length_dropdowns.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/widgets/unavailable_dates.dart';
import 'package:vmodel/src/features/settings/views/email_notifications.dart';
import 'package:vmodel/src/features/settings/views/favorite_hashtags.dart';
import 'package:vmodel/src/features/settings/views/feed/feed_settings_homepage.dart';
import 'package:vmodel/src/features/settings/views/feed/feed_view/content_feed_view.dart';
import 'package:vmodel/src/features/settings/views/feed/feed_view/default_feed_view.dart';
import 'package:vmodel/src/features/settings/views/menu/menu_page.dart';
import 'package:vmodel/src/features/settings/views/payment/views/create_payment_page.dart';
import 'package:vmodel/src/features/settings/views/payment/views/currency_page.dart';
import 'package:vmodel/src/features/settings/views/payment/views/payment_methods_page.dart';
import 'package:vmodel/src/features/settings/views/payment/views/payments_homepage.dart';
import 'package:vmodel/src/features/settings/views/permissions/views/connections.dart';
import 'package:vmodel/src/features/settings/views/permissions/views/permissions_homepage.dart';
import 'package:vmodel/src/features/settings/views/personality_setting.dart';
import 'package:vmodel/src/features/settings/views/privacy_setting.dart';
import 'package:vmodel/src/features/settings/views/profile/views/account_settings.dart';
import 'package:vmodel/src/features/settings/views/profile_settings_homepage.dart';
import 'package:vmodel/src/features/settings/views/push_notifications.dart';
import 'package:vmodel/src/features/settings/views/refer_and_earn_page.dart';
import 'package:vmodel/src/features/settings/views/upload_settings/gallery_settings_homepage.dart';
import 'package:vmodel/src/features/settings/views/upload_settings/portfolio_galleries_settings_homepage.dart';
import 'package:vmodel/src/features/settings/views/verification_setting.dart';
import 'package:vmodel/src/features/splash/views/splash_view.dart';
import 'package:vmodel/src/features/splitter/splitter_page.dart';
import 'package:vmodel/src/features/suite/views/business_hours_page.dart';
import 'package:vmodel/src/features/suite/views/user_coupons.dart';
import 'package:vmodel/src/features/tutorials/views/tutorial_details.dart';
import 'package:vmodel/src/features/vmagazine/views/vMagzine_page_view.dart';
import 'package:vmodel/src/features/vmagazine/views/vmagazine_body.dart';
import 'package:vmodel/src/features/vmodel_credits/views/achievement_detail_page.dart';
import 'package:vmodel/src/features/vmodel_credits/views/creditHistoryPage.dart';
import 'package:vmodel/src/features/vmodel_credits/views/creditWithdrawalPage.dart';
import 'package:vmodel/src/features/vmodel_credits/views/vmc_history_main.dart';
import 'package:vmodel/src/features/vmodel_credits/views/vmc_leaderboard.dart';
import 'package:vmodel/src/features/vmodel_credits/views/vmodel_credit_help.dart';
import 'package:vmodel/src/features/vmodel_credits/views/vmodel_credits.dart';
import 'package:vmodel/src/features/vmodel_credits/views/withdrawalHistory.dart';
import 'package:vmodel/src/res/date.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/appbar/appbar_title_text.dart';
import 'package:vmodel/src/shared/bottom_sheets/confirmation_bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/description_detail_bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/input_bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/picture_confirmation_bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/tile.dart';
import 'package:vmodel/src/shared/carousel_indicators.dart';
import 'package:vmodel/src/shared/category_chips/category_button.dart';
import 'package:vmodel/src/shared/cupertino_modal_pop_up/cupertino_action_sheet.dart';
import 'package:vmodel/src/shared/date_picker/v_picker.dart';
import 'package:vmodel/src/shared/dialogs/discard_dialog.dart';
import 'package:vmodel/src/shared/job_service_section_container.dart';
import 'package:vmodel/src/shared/list_styles/h_listview_view_all.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';
import 'package:vmodel/src/shared/picture_styles/avatar.dart';
import 'package:vmodel/src/shared/picture_styles/pick_image_widget.dart';
import 'package:vmodel/src/shared/picture_styles/rounded_square_avatar.dart';
import 'package:vmodel/src/shared/picture_styles/rounded_square_avatar_asset_img.dart';
import 'package:vmodel/src/shared/picture_styles/vmodel_network_image.dart';
import 'package:vmodel/src/shared/popup_dialogs/confirmation_popup.dart';
import 'package:vmodel/src/shared/popup_dialogs/customisable_popup.dart';
import 'package:vmodel/src/shared/popup_dialogs/input_popup.dart';
import 'package:vmodel/src/shared/popup_dialogs/popup_without_save.dart';
import 'package:vmodel/src/shared/popup_dialogs/profile_popup.dart';
import 'package:vmodel/src/shared/popup_dialogs/textfield_popup.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/response_widgets/created_success_dialogue.dart';
import 'package:vmodel/src/shared/slider/range_slider.dart';
import 'package:vmodel/src/shared/tabs/primary_tab.dart';
import 'package:vmodel/src/shared/text_fields/profile_input_field.dart';
import 'package:vmodel/src/shared/username_verification.dart';
import 'package:vmodel/src/waiting_room.dart';
import '../../main.dart';
import '../features/applications/views/applications_page.dart';
import '../features/archived/views/archived_view.dart';
import '../features/authentication/login/views/sign_in.dart';
import '../features/authentication/login/views/verify_2fa_otp.dart';
import '../features/authentication/register/views/location_set_up.dart';
import '../features/authentication/register/views/sign_up.dart';
import '../features/authentication/reset_password/views/forgot_password_view.dart';
import '../features/authentication/views/confirm_password_reset_otp.dart';
import '../features/beta_dashboard/views/beta_dashboard_homepage.dart';
import '../features/create_coupons/add_coupons.dart';
import '../features/dashboard/content/views/content_screen_feed.dart';
import '../features/dashboard/content/views/content_screen_improved.dart';
import '../features/dashboard/creation_tools/creation_tools.dart';
import '../features/dashboard/dash/dashboard_ui.dart';
import '../features/dashboard/discover/views/discover_view_v3.dart';
import '../features/dashboard/discover/views/sub_screens/view_all.dart';
import '../features/dashboard/feed/model/feed_model.dart';
import '../features/dashboard/new_profile/profile_features/services/views/new_service_detail.dart';
import '../features/dashboard/new_profile/profile_features/services/views/view_all_services.dart';
import '../features/dashboard/new_profile/user_offerings/views/tabbed_user_offerings.dart';
import '../features/dashboard/new_profile/views/other_profile_router.dart';
import '../features/dashboard/new_profile/widgets/live_classes_offerings.dart';
import '../features/dashboard/profile/view/connections_page.dart';
import '../features/dashboard/profile/view/network_received_requests_page.dart';
import '../features/dashboard/profile/view/network_sent_requests_page.dart';
import '../features/earnings/views/earnings_homepage.dart';
import '../features/faq_s/views/popular_faqs_page.dart';
import '../features/help_support/views/help_center.dart';
import '../features/help_support/views/help_home.dart';
import '../features/help_support/views/report_a_bug_page.dart';
import '../features/help_support/views/report_abuse_or_spam_page.dart';
import '../features/help_support/views/report_illegal_page.dart';
import '../features/help_support/views/reportsPage.dart';
import '../features/jobs/create_jobs/model/job_application.dart';
import '../features/jobs/create_jobs/views/create_job_view_first.dart';
import '../features/jobs/job_market/views/all_coupons.dart';
import '../features/jobs/job_market/views/all_jobs.dart';
import '../features/jobs/job_market/views/business_user/business_offers_details_page.dart';
import '../features/jobs/job_market/views/category_services.dart';
import '../features/jobs/job_market/views/hottest_coupon_list.dart';
import '../features/jobs/job_market/views/job_applicants_details_page.dart';
import '../features/jobs/job_market/views/job_market_homepage.dart';
import '../features/jobs/job_market/views/make_payment_jobs.dart';
import '../features/jobs/job_market/views/popular_jobs_page.dart';
import '../features/jobs/job_market/views/sub_all_jobs.dart';
import '../features/live_classes/model/live_class_type.dart';
import '../features/live_classes/views/category_lives.dart';
import '../features/live_classes/views/create_live_class.dart';
import '../features/live_classes/views/live_class_card_input_page.dart';
import '../features/live_classes/views/live_class_checkout_page.dart';
import '../features/live_classes/views/live_class_detail.dart';
import '../features/live_classes/views/live_class_payment_failed_page.dart';
import '../features/live_classes/views/live_class_payment_success_page.dart';
import '../features/live_classes/views/live_class_prep_page.dart';
import '../features/live_classes/views/live_class_timeline_page.dart';
import '../features/live_classes/views/live_class_video_page.dart';
import '../features/live_classes/views/live_landing_page.dart';
import '../features/live_classes/views/my_classes.dart';
import '../features/live_classes/views/upcoming_classes.dart';
import '../features/messages/views/messages_homepage.dart';
import '../features/notifications/widgets/single_post_view.dart';
import '../features/onboarding/views/birthday_view.dart';
import '../features/print/views/preview_screen.dart';
import '../features/print/views/print_homepage.dart';
import '../features/print/views/print_profile.dart';
import '../features/refer_and_earn/views/invite_and_earn_homepage.dart';
import '../features/refer_and_earn/views/invite_contacts.dart';
import '../features/reviews/views/booking/created_gigs/controller/gig_controller.dart';
import '../features/reviews/views/booking/created_gigs/views/gig_job_detail.dart';
import '../features/reviews/views/booking/model/booking_model.dart';
import '../features/reviews/views/booking/my_bookings/views/tabbed_bookings_view.dart';
import '../features/reviews/views/review_page_content.dart';
import '../features/reviews/views/reviews_view.dart';
import '../features/saved/views/boards_main.dart';
import '../features/saved/views/boards_search.dart';
import '../features/saved/views/saved_posts_view.dart';
import '../features/settings/views/blocked_list/blocked_list_homepage.dart';
import '../features/settings/views/booking_settings/views/create_service_page.dart';
import '../features/settings/views/booking_settings/views/new_unavailable_screen.dart';
import '../features/settings/views/feed/followers_list/views/followers_list_homepage.dart';
import '../features/settings/views/feed/following_list copy/views/following_list_homepage.dart';
import '../features/settings/views/in_app_notification_setting.dart';
import '../features/settings/views/my_network/my_network.dart';
import '../features/settings/views/permissions/views/printings.dart';
import '../features/settings/views/settings_page.dart';
import '../features/shortcuts_tricks/shortcuts_tricks.dart';
import '../features/suite/crop_tests/views/crop1.dart';
import '../features/suite/views/analytics.dart';
import '../features/suite/views/business_opening_times/views/business_opening_times_form.dart';
import '../features/suite/views/business_suite_homepage.dart';
import '../features/suite/views/splitter/view/image_grid_splitter.dart';
import '../features/vmagazine/views/vmagzine_view.dart';
import '../features/vmodel_credits/views/vmc_notifications.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/views/tabbed_created_gigs_view.dart';

import '../features/walk_though/views/walkThoughScreen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _liveNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'live');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');
final _marketplaceNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'marketplace');
final _contentNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'content');

GoRouter router = GoRouter(
    errorBuilder: (context, state) {
      //p=page, a=action, i=id,
      return WaitingRoom(name: state.uri.toString());
    },
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
          builder:
              (BuildContext context, GoRouterState state, navigationShell) {
            navigationModel.navigationModel = navigationShell;

            return DashBoardView(navigationShell: navigationShell);
          },
          branches: <StatefulShellBranch>[
            //Home
            StatefulShellBranch(
              navigatorKey: _homeNavigatorKey,
              initialLocation: '/feedMainUI',
              routes: <RouteBase>[
                GoRoute(
                  path: '/feedMainUI',
                  builder: (context, state) => FeedMainUI(),
                ),

                GoRoute(
                    path: '/contentViewFeed',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      return ContentViewFeed(
                        feed: extra["feed"] as FeedPostSetModel,
                        videoController:
                            extra['controller'] as BetterPlayerController,
                        //widget.postDataList,
                        // itemId: extra["itemId"] as int,
                        // uploadedVideoUrl: extra["uploadedVideoUrl"] as String,
                      );
                    },
                    pageBuilder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      return CupertinoPage(
                          child: ContentViewFeed(
                        feed: extra["feed"] as FeedPostSetModel,
                        videoController: extra['controller']
                            as BetterPlayerController, //widget.postDataList,
                        // itemId: extra["itemId"] as int,
                        // uploadedVideoUrl: extra["uploadedVideoUrl"] as String,
                      ));
                    }),
                GoRoute(
                  path: Routes.otherProfileRouter,
                  builder: (context, state) => OtherProfileRouter(
                    username: state.pathParameters['username'] ?? '',
                    deep: (state.extra ?? false) as bool,
                  ),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: OtherProfileRouter(
                    username: state.pathParameters['username'] ?? '',
                  )),
                ),
                GoRoute(
                  path: Routes.otherUserProfile,
                  pageBuilder: (context, state) => CupertinoPage(
                      child: OtherUserProfile(
                    username: state.pathParameters['username'] ?? '',
                    deep: state.extra == null ? false : (state.extra as bool),
                  )),
                ),
                GoRoute(
                  path: '/view_all/:title',
                  builder: (context, state) => ViewAllScreen(
                      title: state.pathParameters['title'] ?? 'Spotlight'),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: ViewAllScreen(
                          title: state.pathParameters['title'] ?? 'Spotlight')),
                ),

                GoRoute(
                    name: '/SinglePostView',
                    path: '/SinglePostView',
                    builder: (BuildContext context, GoRouterState state) =>
                        SinglePostView(
                            isCurrentUser: false,
                            postSet: state.extra as FeedPostSetModel)),

                GoRoute(
                  path: '/SinglePostView/:deep',
                  builder: (context, state) => SinglePostView(
                      isCurrentUser: false,
                      postSet: FeedPostSetModel.fromMap(
                          state.extra as Map<String, dynamic>),
                      deep: state.pathParameters['deep'] == 'true'
                          ? true
                          : false),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: SinglePostView(
                          isCurrentUser: false,
                          postSet: FeedPostSetModel.fromMap(
                              state.extra as Map<String, dynamic>),
                          deep: state.pathParameters['deep'] == 'true'
                              ? true
                              : false)),
                ),
                // GoRoute(
                //   path: '/discoverFilter',
                //   builder: (context, state) => DiscoverFilter(),
                //   pageBuilder: (context, state) => CupertinoPage(child: DiscoverFilter()),
                // ),
                // GoRoute(
                //   path: '/discoverView',
                //   builder: (context, state) => DiscoverView(),
                //   pageBuilder: (context, state) => CupertinoPage(child: DiscoverView()),
                // ),
                // GoRoute(
                //   path: '/discoverVerifiedSection',
                //   builder: (context, state) => DiscoverVerifiedSection(),
                //   pageBuilder: (context, state) => CupertinoPage(child: DiscoverVerifiedSection()),
                // ),
                // GoRoute(
                //   path: '/categoryDiscoverViewNew',
                //   builder: (context, state) => CategoryDiscoverViewNew(),
                //   pageBuilder: (context, state) => CupertinoPage(child: CategoryDiscoverViewNew()),
                // ),
                // GoRoute(
                //   path: '/categoryDiscoverDetail/:title',
                //   builder: (context, state) => CategoryDiscoverDetail(title: state.pathParameters['title']!),
                //   pageBuilder: (context, state) => CupertinoPage(child: CategoryDiscoverDetail(title: state.pathParameters['title']!)),
                // ),
                // GoRoute(
                //   path: '/discoverViewNew',
                //   builder: (context, state) => DiscoverViewNew(),
                //   pageBuilder: (context, state) => CupertinoPage(child: DiscoverViewNew()),
                // ),
                // GoRoute(
                //   path: '/explore/:title',
                //   builder: (context, state) => Explore(
                //     title: state.pathParameters['title'] ?? 'Trending',
                //   ),
                //   pageBuilder: (context, state) => CupertinoPage(
                //       child: Explore(
                //     title: state.pathParameters['title'] ?? 'Trending',
                //   )),
                // ),
                // GoRoute(
                //   path: '/feedExplore/:issearching',
                //   builder: (context, state) => FeedExplore(issearching: state.pathParameters['issearching'] == 'true' ? true : false),
                //   pageBuilder: (context, state) => CupertinoPage(child: FeedAfterWidget(canLoadMore: state.pathParameters['canLoadMore'] == 'true' ? true : false)),
                // ),
                // GoRoute(
                //   path: '/feedExploreSearchView',
                //   builder: (context, state) => FeedExploreSearchView(),
                //   pageBuilder: (context, state) => CupertinoPage(child: FeedExploreSearchView()),
                // ),
                GoRoute(
                  path: '/feedHomeUI',
                  builder: (context, state) => FeedHomeUI(),
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: FeedHomeUI()),
                ),
                GoRoute(
                  path: '/feedHomeView',
                  builder: (context, state) => FeedHomeView(),
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: FeedHomeView()),
                ),
                GoRoute(
                  path: '/Likes/:username',
                  builder: (context, state) => Likes(
                    usersThatLiked: state.extra as List,
                    username: state.pathParameters['username']!,
                  ),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: Likes(
                    usersThatLiked: state.extra as List,
                    username: state.pathParameters['username']!,
                  )),
                ),
                //Content
                GoRoute(
                  path: '/contentView',
                  builder: (context, state) => ContentViewMain(
                    customVideosList: state.extra as List<FeedPostSetModel>?,
                  ),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: ContentViewMain(
                    customVideosList: state.extra as List<FeedPostSetModel>?,
                  )),
                ),

                //Live Routes
                GoRoute(
                  path: Routes.liveClassesMarketplacePage,
                  builder: (context, state) => LiveClassesMarketplacePage(),
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: LiveClassesMarketplacePage()),
                ),
                GoRoute(
                  path: Routes.suggestedScreen,
                  builder: (context, state) => SuggestedScreen(),
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: SuggestedScreen()),
                ),
                GoRoute(
                  path: '/live_landing_page',
                  builder: (context, state) => LiveLandingPageView(),
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: LiveLandingPageView()),
                ),
                GoRoute(
                  path: '/live_class_timeline_page',
                  builder: (context, state) => LiveClassTimelinePage(),
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: LiveClassTimelinePage()),
                ),
                GoRoute(
                  path: '/upcoming_classes',
                  builder: (context, state) => UpcomingClassesPage(),
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: UpcomingClassesPage()),
                ),
                GoRoute(
                  path: '/my_classes',
                  builder: (context, state) => MyClassesPage(),
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: MyClassesPage()),
                ),
                GoRoute(
                  path: '/live_class_prep_page',
                  builder: (context, state) => LiveClassPrepPage(
                      liveClass: state.extra as LiveClassesInput),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: LiveClassPrepPage(
                          liveClass: state.extra as LiveClassesInput)),
                ),
                GoRoute(
                  path: '/category_lives/:category',
                  builder: (context, state) => CategoryLives(
                      category: state.pathParameters['category'] ?? ''),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: CategoryLives(
                          category: state.pathParameters['category'] ?? '')),
                ),
                GoRoute(
                  path: '/live_class_checkout_page',
                  builder: (context, state) => LiveClassCheckoutPage(
                      liveClass: state.extra as LiveClassesInput),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: LiveClassCheckoutPage(
                          liveClass: state.extra as LiveClassesInput)),
                ),
                GoRoute(
                  path: '/live_class_card_input_page',
                  builder: (context, state) => LiveClassCardInputPage(
                      liveClass: state.extra as LiveClassesInput),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: LiveClassCardInputPage(
                          liveClass: state.extra as LiveClassesInput)),
                ),
                GoRoute(
                  path: '/live_class_payment_success_page',
                  builder: (context, state) => LiveClassPaymentSuccessPage(
                      liveClass: state.extra as LiveClassesInput),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: LiveClassPaymentSuccessPage(
                          liveClass: state.extra as LiveClassesInput)),
                ),
                GoRoute(
                  path: '/live_class_payment_failed_page',
                  builder: (context, state) => LiveClassPaymentErrorPage(),
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: LiveClassPaymentErrorPage()),
                ),
                GoRoute(
                  path: '/live_class_video_page',
                  builder: (context, state) => LiveClassVideoPage(),
                  pageBuilder: (context, state) =>
                      CupertinoPage(child: LiveClassVideoPage()),
                ),
                GoRoute(
                  path: '/live_class_detail',
                  builder: (context, state) => LiveClassDetail(
                      username: 'null',
                      liveClass: state.extra as LiveClassesInput),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: LiveClassDetail(
                          username: 'null',
                          liveClass: state.extra as LiveClassesInput)),
                ),
                GoRoute(
                  path: '/liveClassDetail/:username',
                  builder: (context, state) => LiveClassDetail(
                      username: state.pathParameters['username']!,
                      liveClass: state.extra as LiveClassesInput),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: LiveClassDetail(
                          username: state.pathParameters['username']!,
                          liveClass: state.extra as LiveClassesInput)),
                ),
                GoRoute(
                  path: '/live_class_detail_new',
                  builder: (context, state) => LiveClassDetailNew(
                      username: 'null', liveClass: state.extra as LiveClasses),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: LiveClassDetailNew(
                          username: 'null',
                          liveClass: state.extra as LiveClasses)),
                ),
                GoRoute(
                  path: '/liveClassDetailNew/:username',
                  builder: (context, state) => LiveClassDetailNew(
                      username: state.pathParameters['username']!,
                      liveClass: state.extra as LiveClasses),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: LiveClassDetailNew(
                          username: state.pathParameters['username']!,
                          liveClass: state.extra as LiveClasses)),
                ),
                GoRoute(
                  path:
                      '/horizontalListViewViewAll/:isCurrentUser/:username/:title/:items/:onTap/:itemBuilder/:separatorBuilder',
                  builder: (context, state) => HorizontalListViewViewAll(
                      isCurrentUser:
                          json.decode(state.pathParameters['isCurrentUser']!),
                      username: json.decode(state.pathParameters['username']!),
                      title: json.decode(state.pathParameters['title']!),
                      items: json.decode(state.pathParameters['items']!),
                      onTap: json.decode(state.pathParameters['onTap']!),
                      itemBuilder:
                          json.decode(state.pathParameters['itemBuilder']!),
                      separatorBuilder: json
                          .decode(state.pathParameters['separatorBuilder']!)),
                  pageBuilder: (context, state) => CupertinoPage(
                      child: HorizontalListViewViewAll(
                          isCurrentUser: json
                              .decode(state.pathParameters['isCurrentUser']!),
                          username:
                              json.decode(state.pathParameters['username']!),
                          title: json.decode(state.pathParameters['title']!),
                          items: json.decode(state.pathParameters['items']!),
                          onTap: json.decode(state.pathParameters['onTap']!),
                          itemBuilder:
                              json.decode(state.pathParameters['itemBuilder']!),
                          separatorBuilder: json.decode(
                              state.pathParameters['separatorBuilder']!))),
                ),
                //End of Live Routes
              ],
            ),

            //LiveClass
            StatefulShellBranch(
                navigatorKey: _liveNavigatorKey,
                initialLocation:
                    Routes.discoverViewV3, //Routes.liveClassesMarketplacePage,
                routes: <RouteBase>[
                  //Discover Routes
                  GoRoute(
                    path: Routes.discoverViewV3,
                    builder: (context, state) => DiscoverViewV3(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: DiscoverViewV3()),
                  ),
                  GoRoute(
                    path: '/discoverFilter',
                    builder: (context, state) => DiscoverFilter(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: DiscoverFilter()),
                  ),
                  GoRoute(
                    path: '/discoverView',
                    builder: (context, state) => DiscoverView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: DiscoverView()),
                  ),
                  GoRoute(
                    path: '/discoverVerifiedSection',
                    builder: (context, state) => DiscoverVerifiedSection(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: DiscoverVerifiedSection()),
                  ),
                  GoRoute(
                    path: '/categoryDiscoverViewNew',
                    builder: (context, state) => CategoryDiscoverViewNew(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: CategoryDiscoverViewNew()),
                  ),
                  GoRoute(
                    path: '/categoryDiscoverDetail/:title',
                    builder: (context, state) => CategoryDiscoverDetail(
                        title: state.pathParameters['title']!),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: CategoryDiscoverDetail(
                            title: state.pathParameters['title']!)),
                  ),
                  GoRoute(
                    path: '/discoverViewNew',
                    builder: (context, state) => DiscoverViewNew(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: DiscoverViewNew()),
                  ),
                  GoRoute(
                    path: '/explore/:title',
                    builder: (context, state) => Explore(
                      title: state.pathParameters['title'] ?? 'Trending',
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: Explore(
                      title: state.pathParameters['title'] ?? 'Trending',
                    )),
                  ),
                  GoRoute(
                    path: '/feedExplore/:issearching',
                    builder: (context, state) => FeedExplore(
                        issearching:
                            state.pathParameters['issearching'] == 'true'
                                ? true
                                : false),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: FeedAfterWidget(
                            canLoadMore:
                                state.pathParameters['canLoadMore'] == 'true'
                                    ? true
                                    : false)),
                  ),
                  GoRoute(
                    path: '/feedExploreSearchView',
                    builder: (context, state) => FeedExploreSearchView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: FeedExploreSearchView()),
                  ),
                  // End of Discover Routes
                  // GoRoute(
                  //   path: Routes.liveClassesMarketplacePage,
                  //   builder: (context, state) => LiveClassesMarketplacePage(),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveClassesMarketplacePage()),
                  // ),
                  // GoRoute(
                  //   path: Routes.suggestedScreen,
                  //   builder: (context, state) => SuggestedScreen(),
                  //   pageBuilder: (context, state) => CupertinoPage(child: SuggestedScreen()),
                  // ),
                  // GoRoute(
                  //   path: '/live_landing_page',
                  //   builder: (context, state) => LiveLandingPageView(),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveLandingPageView()),
                  // ),
                  // GoRoute(
                  //   path: '/live_class_timeline_page',
                  //   builder: (context, state) => LiveClassTimelinePage(),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveClassTimelinePage()),
                  // ),
                  // GoRoute(
                  //   path: '/upcoming_classes',
                  //   builder: (context, state) => UpcomingClassesPage(),
                  //   pageBuilder: (context, state) => CupertinoPage(child: UpcomingClassesPage()),
                  // ),
                  // GoRoute(
                  //   path: '/my_classes',
                  //   builder: (context, state) => MyClassesPage(),
                  //   pageBuilder: (context, state) => CupertinoPage(child: MyClassesPage()),
                  // ),
                  // GoRoute(
                  //   path: '/live_class_prep_page',
                  //   builder: (context, state) => LiveClassPrepPage(liveClass: state.extra as LiveClassesInput),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveClassPrepPage(liveClass: state.extra as LiveClassesInput)),
                  // ),
                  // GoRoute(
                  //   path: '/category_lives/:category',
                  //   builder: (context, state) => CategoryLives(category: state.pathParameters['category'] ?? ''),
                  //   pageBuilder: (context, state) => CupertinoPage(child: CategoryLives(category: state.pathParameters['category'] ?? '')),
                  // ),
                  // GoRoute(
                  //   path: '/live_class_checkout_page',
                  //   builder: (context, state) => LiveClassCheckoutPage(liveClass: state.extra as LiveClassesInput),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveClassCheckoutPage(liveClass: state.extra as LiveClassesInput)),
                  // ),
                  // GoRoute(
                  //   path: '/live_class_card_input_page',
                  //   builder: (context, state) => LiveClassCardInputPage(liveClass: state.extra as LiveClassesInput),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveClassCardInputPage(liveClass: state.extra as LiveClassesInput)),
                  // ),
                  // GoRoute(
                  //   path: '/live_class_payment_success_page',
                  //   builder: (context, state) => LiveClassPaymentSuccessPage(liveClass: state.extra as LiveClassesInput),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveClassPaymentSuccessPage(liveClass: state.extra as LiveClassesInput)),
                  // ),
                  // GoRoute(
                  //   path: '/live_class_payment_failed_page',
                  //   builder: (context, state) => LiveClassPaymentErrorPage(),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveClassPaymentErrorPage()),
                  // ),
                  // GoRoute(
                  //   path: '/live_class_video_page',
                  //   builder: (context, state) => LiveClassVideoPage(),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveClassVideoPage()),
                  // ),
                  // GoRoute(
                  //   path: '/live_class_detail',
                  //   builder: (context, state) => LiveClassDetail(username: 'null', liveClass: state.extra as LiveClassesInput),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveClassDetail(username: 'null', liveClass: state.extra as LiveClassesInput)),
                  // ),
                  // GoRoute(
                  //   path: '/liveClassDetail/:username',
                  //   builder: (context, state) => LiveClassDetail(username: state.pathParameters['username']!, liveClass: state.extra as LiveClassesInput),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveClassDetail(username: state.pathParameters['username']!, liveClass: state.extra as LiveClassesInput)),
                  // ),
                  // GoRoute(
                  //   path: '/live_class_detail_new',
                  //   builder: (context, state) => LiveClassDetailNew(username: 'null', liveClass: state.extra as LiveClasses),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveClassDetailNew(username: 'null', liveClass: state.extra as LiveClasses)),
                  // ),
                  // GoRoute(
                  //   path: '/liveClassDetailNew/:username',
                  //   builder: (context, state) => LiveClassDetailNew(username: state.pathParameters['username']!, liveClass: state.extra as LiveClasses),
                  //   pageBuilder: (context, state) => CupertinoPage(child: LiveClassDetailNew(username: state.pathParameters['username']!, liveClass: state.extra as LiveClasses)),
                  // ),
                  // GoRoute(
                  //   path: '/horizontalListViewViewAll/:isCurrentUser/:username/:title/:items/:onTap/:itemBuilder/:separatorBuilder',
                  //   builder: (context, state) => HorizontalListViewViewAll(isCurrentUser: json.decode(state.pathParameters['isCurrentUser']!), username: json.decode(state.pathParameters['username']!), title: json.decode(state.pathParameters['title']!), items: json.decode(state.pathParameters['items']!), onTap: json.decode(state.pathParameters['onTap']!), itemBuilder: json.decode(state.pathParameters['itemBuilder']!), separatorBuilder: json.decode(state.pathParameters['separatorBuilder']!)),
                  //   pageBuilder: (context, state) => CupertinoPage(child: HorizontalListViewViewAll(isCurrentUser: json.decode(state.pathParameters['isCurrentUser']!), username: json.decode(state.pathParameters['username']!), title: json.decode(state.pathParameters['title']!), items: json.decode(state.pathParameters['items']!), onTap: json.decode(state.pathParameters['onTap']!), itemBuilder: json.decode(state.pathParameters['itemBuilder']!), separatorBuilder: json.decode(state.pathParameters['separatorBuilder']!))),
                  // ),
                ]),

            //Marketplace
            StatefulShellBranch(
                navigatorKey: _marketplaceNavigatorKey,
                initialLocation: '/businessMyJobsPageMarketplaceSimple',
                routes: <RouteBase>[
                  GoRoute(
                    path: '/businessMyJobsPageMarketplaceSimple',
                    builder: (context, state) =>
                        BusinessMyJobsPageMarketplaceSimple(),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: BusinessMyJobsPageMarketplaceSimple()),
                    routes: [],
                  ),
                  GoRoute(
                    path: Routes.allJobs,
                    builder: (context, state) {
                      return AllJobs(
                        title: state.pathParameters['title'] ?? 'All jobs',
                      );
                    },
                    pageBuilder: (context, state) => CupertinoPage(
                        child: AllJobs(
                      title: state.pathParameters['title'] ?? 'All jobs',
                    )),
                  ),
                  GoRoute(
                    path: Routes.popularJobs,
                    builder: (context, state) => PopularJobsCategoryPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PopularJobsCategoryPage()),
                  ),
                  GoRoute(
                    path: Routes.recommendedJobs,
                    builder: (context, state) => RecommendedJobsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: RecommendedJobsPage()),
                  ),
                  GoRoute(
                    path: Routes.remoteJobs,
                    builder: (context, state) => RemoteJobsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: RemoteJobsPage()),
                  ),
                  GoRoute(
                    path: Routes.allSubJobs,
                    builder: (context, state) {
                      return SubAllJobs(
                        title: state.pathParameters['title'] ?? 'All jobs',
                      );
                    },
                    pageBuilder: (context, state) => CupertinoPage(
                        child: SubAllJobs(
                      title: state.pathParameters['title'] ?? 'All jobs',
                    )),
                  ),
                  GoRoute(
                    path: Routes.jobBookerApplication,
                    builder: (context, state) =>
                        JobBookerApplicationsHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: JobBookerApplicationsHomepage()),
                  ),
                  GoRoute(
                    path: Routes.jobDetailUpdated,
                    builder: (context, state) => JobDetailPageUpdated(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: JobDetailPageUpdated()),
                  ),
                  GoRoute(
                    path: Routes.jobDetail,
                    builder: (context, state) => JobDetailPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: JobDetailPage()),
                  ),
                  GoRoute(
                      path: '/job_applicants_detail_page',
                      builder: (context, state) {
                        final applicant =
                            state.extra as Map<String, JobApplication>;
                        return JobApplicantDetails(
                          applicant: applicant["applicants"] as JobApplication,
                        );
                      },
                      pageBuilder: (context, state) {
                        final applicant =
                            state.extra as Map<String, JobApplication>;
                        return CupertinoPage(
                            child: JobApplicantDetails(
                          applicant: applicant["applicants"] as JobApplication,
                        ));
                      }),
                  GoRoute(
                    path: '/hottest_coupon_list',
                    builder: (context, state) => HottestCouponList(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: HottestCouponList()),
                  ),
                  GoRoute(
                    path: '/all_coupons',
                    builder: (context, state) => AllCouponsList(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: AllCouponsList()),
                  ),
                  // GoRoute(
                  //   path: '/all_coupons',
                  //   builder: (context, state) => AllCouponsList(),
                  //   pageBuilder: (context, state) => CupertinoPage(child: AllCouponsList()),
                  // ),
                  GoRoute(
                    path: '/business_suite_homepage',
                    builder: (context, state) => BusinessSuiteHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BusinessSuiteHomepage()),
                  ),
                  GoRoute(
                    path: '/marketPlaceServicesTabPage',
                    builder: (context, state) => MarketPlaceServicesTabPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: MarketPlaceServicesTabPage()),
                  ),
                  GoRoute(
                    path: '/servicesSearchResult',
                    builder: (context, state) => ServicesSearchResult(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ServicesSearchResult()),
                  ),
                  GoRoute(
                    path: '/allJobsSearch',
                    builder: (context, state) => AllJobsSearch(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: AllJobsSearch()),
                  ),
                  GoRoute(
                    path: '/jobsSimplified',
                    builder: (context, state) => JobsSimplified(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: JobsSimplified()),
                  ),
                  GoRoute(
                    path: '/couponsSearchResult',
                    builder: (context, state) => CouponsSearchResult(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: CouponsSearchResult()),
                  ),
                  GoRoute(
                    path: '/couponsSimple',
                    builder: (context, state) => CouponsSimple(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: CouponsSimple()),
                  ),
                  GoRoute(
                    path: '/myRequestPage',
                    // parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => MyRequestPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: MyRequestPage()),
                  ),
                  GoRoute(
                    path:
                        '/view_all_services/:username/:title/:isRecommended/:isDiscounted',
                    builder: (context, state) {
                      return ViewAllServicesHomepage(
                        username: state.pathParameters['username'] ?? '',
                        title: state.pathParameters['title'] ??
                            'Discounted services',
                        isRecommended: state.pathParameters['isRecommended'] ==
                                    "false" ||
                                state.pathParameters['isRecommended'] == false
                            ? false
                            : true,
                        isDiscounted: state.pathParameters['isDiscounted'] ==
                                    "false" ||
                                state.pathParameters['isDiscounted'] == false
                            ? false
                            : true,
                      );
                    },
                    pageBuilder: (context, state) => CupertinoPage(
                        child: ViewAllServicesHomepage(
                      username: state.pathParameters['username'] ?? '',
                      title: state.pathParameters['title'] ??
                          'Discounted services',
                      isRecommended:
                          state.pathParameters['isRecommended'] == "false" ||
                                  state.pathParameters['isRecommended'] == false
                              ? false
                              : true,
                      isDiscounted:
                          state.pathParameters['isDiscounted'] == "false" ||
                                  state.pathParameters['isDiscounted'] == false
                              ? false
                              : true,
                    )),
                  ),
                  GoRoute(
                    path: Routes.serviceDetail,
                    builder: (context, state) => ServicePackageDetail(
                      username: state.pathParameters['username'] ?? '',
                      isCurrentUser:
                          state.pathParameters['isCurrentUser'] == "false" ||
                                  state.pathParameters['isCurrentUser'] == false
                              ? false
                              : true,
                      serviceId: state.pathParameters['serviceId'] ?? '',
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: ServicePackageDetail(
                      username: state.pathParameters['username'] ?? '',
                      isCurrentUser:
                          state.pathParameters['isCurrentUser'] == "false" ||
                                  state.pathParameters['isCurrentUser'] == false
                              ? false
                              : true,
                      serviceId: state.pathParameters['serviceId'] ?? '',
                    )),
                  ),
                  GoRoute(
                    path: Routes.localServices,
                    builder: (context, state) => LocalServices(
                      title: state.pathParameters['title'],
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: LocalServices(
                      title: state.pathParameters['title'],
                    )),
                  ),
                  GoRoute(
                    path: Routes.categoryService,
                    builder: (context, state) =>
                        CategoryServices(title: state.pathParameters['title']!),
                  ),
                  GoRoute(
                      path: '/make_payment_jobs',
                      builder: (context, state) {
                        final params = state.extra as Map<String, dynamic>;
                        return MakePaymentJobs(
                          applicationId: params['applicationId'] ?? '',
                          bookingId: params['bookingId'] ?? '',
                          paymentRef: params['paymentRef'] ?? '',
                          paymentLink: params['paymentLink'] ?? '',
                          job: params['job'] as JobPostModel,
                        );
                      },
                      pageBuilder: (context, state) {
                        final params = state.extra as Map<String, dynamic>;
                        return CupertinoPage(
                            child: MakePaymentJobs(
                          applicationId: params['applicationId'] ?? '',
                          bookingId: params['bookingId'] ?? '',
                          paymentRef: params['paymentRef'] ?? '',
                          paymentLink: params['paymentLink'] ?? '',
                          job: params['job'] as JobPostModel,
                        ));
                      }),
                  // GoRoute(
                  //     path: '/gig_progress_page',
                  //     builder: (context, state) {
                  //       final params = state.extra as Map<String, dynamic>;
                  //       return GigProgressPage(bookingIdTab: params["bookingIdTab"], bookingId: params["bookingId"]);
                  //     },
                  //     pageBuilder: (context, state) {
                  //       final params = state.extra as Map<String, dynamic>;
                  //       return CupertinoPage(
                  //         child: GigProgressPage(bookingIdTab: params["bookingIdTab"], bookingId: params["bookingId"] as String ?? ''),
                  //       );
                  //     }),
                  // GoRoute(
                  //     path: '/booking_progress_page',
                  //     builder: (context, state) {
                  //       final params = state.extra as Map<String, dynamic>;
                  //       return BookingsProgressPage(bookingIdTab: params["bookingIdTab"], bookingId: params["bookingId"]);
                  //     },
                  //     pageBuilder: (context, state) {
                  //       final params = state.extra as Map<String, dynamic>;
                  //       return CupertinoPage(
                  //         child: BookingsProgressPage(bookingIdTab: params["bookingIdTab"], bookingId: params["bookingId"] as String ?? ''),
                  //       );
                  //     }),
                  GoRoute(
                    path: '/popular_faqs_page',
                    builder: (context, state) => PopularFAQsHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PopularFAQsHomepage()),
                  ),
                  GoRoute(
                    path: '/help_center_page',
                    builder: (context, state) => HelpCenterPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: HelpCenterPage()),
                  ),
                  GoRoute(
                    path: '/couponsEndWidget',
                    builder: (context, state) => CouponsEndWidget(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: CouponsEndWidget()),
                  ),
                  GoRoute(
                    path: '/allJobsEndWidget',
                    builder: (context, state) => AllJobsEndWidget(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: AllJobsEndWidget()),
                  ),
                ]),

            //Profile
            StatefulShellBranch(
                navigatorKey: _profileNavigatorKey,
                initialLocation: '/profileBaseScreen',
                routes: <RouteBase>[
                  GoRoute(
                    path: '/profileBaseScreen',
                    builder: (context, state) =>
                        ProfileBaseScreen(isCurrentUser: true),
                    pageBuilder: (context, state) => CupertinoPage(
                      child: ProfileBaseScreen(
                        isCurrentUser: true,
                      ),
                    ),
                  ),
                  GoRoute(
                      path: '/localBusinessProfileBaseScreen/:username',
                      builder: (context, state) =>
                          LocalBusinessProfileBaseScreen(
                              username: state.pathParameters['username']!)),
                  GoRoute(
                    path: '/saved_posts_view',
                    builder: (context, state) => SavedView(),
                    pageBuilder: (context, state) => CupertinoPage(
                      child: SavedView(),
                    ),
                  ),
                  GoRoute(
                    path: '/menuPage',
                    builder: (context, state) => MenuPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: MenuPage()),
                  ),
                  GoRoute(
                    path: '/businessHoursPage',
                    builder: (context, state) => BusinessHoursPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BusinessHoursPage()),
                  ),
                  GoRoute(
                    path: '/vmagzine_view',
                    builder: (context, state) => VMagazineView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: VMagazineView()),
                  ),
                  GoRoute(
                    path: '/review-a-user',
                    builder: (context, state) => SelectUserRateScreen(),
                    pageBuilder: (context, state) => CupertinoPage(
                      child: SelectUserRateScreen(),
                    ),
                  ),
                  GoRoute(
                    path: '/archived_view',
                    builder: (context, state) => ArchivedView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ArchivedView()),
                  ),
                  GoRoute(
                    path: '/settings_page',
                    builder: (context, state) => SettingsSheet(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: SettingsSheet()),
                  ),
                  GoRoute(
                    path: '/activities_page',
                    builder: (context, state) => ActivitiesPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ActivitiesPage()),
                  ),
                  GoRoute(
                    path: '/activities_menu',
                    builder: (context, state) => ActivitiesMenu(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ActivitiesMenu()),
                  ),
                  GoRoute(
                    path: '/gig_job_detail',
                    builder: (context, state) {
                      final details = state.extra as Map<String, dynamic>;
                      return GigJobDetailPage(
                        booking: details['booking'] as BookingModel,
                        moduleId: details['jobId'] as String,
                        tab: details['tab'] as BookingTab,
                        onMoreTap: details['onMoreTap'],
                        isBooking: details['isBooking'] as bool,
                        isBooker: false,
                      );
                    },
                    pageBuilder: (context, state) {
                      final details = state.extra as Map<String, dynamic>;

                      return CupertinoPage(
                        child: GigJobDetailPage(
                          booking: details['booking'] as BookingModel,
                          moduleId: details['jobId'] as String,
                          tab: details['tab'] as BookingTab,
                          onMoreTap: details['onMoreTap'],
                          isBooking: details['isBooking'] as bool,
                          isBooker: false,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: '/gig_service_detail',
                    builder: (context, state) {
                      final details = state.extra as Map<String, dynamic>;
                      return GigServiceDetail(
                          booking: details['booking'] as BookingModel,
                          moduleId: details['jobId'] as String,
                          tab: details['tab'] as BookingTab,
                          isCurrentUser: details['isCurrentUser'] as bool,
                          username: details['username']);
                    },
                    pageBuilder: (context, state) {
                      final details = state.extra as Map<String, dynamic>;
                      return CupertinoPage(
                        child: GigServiceDetail(
                          booking: details['booking'] as BookingModel,
                          moduleId: details['moduleId'] as String,
                          tab: details['tab'] as BookingTab,
                          isCurrentUser: details['isCurrentUser'] as bool,
                          username: details['username'] as String,
                        ),
                      );
                    },
                  ),

                  GoRoute(
                    path: '/user_credit_homepage',
                    builder: (context, state) => UserVModelCreditHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: UserVModelCreditHomepage()),
                  ),
                  GoRoute(
                    path: '/achievement_detail',
                    builder: (context, state) => AchievementDetailPage(
                      details: state.extra as Map<String, dynamic>,
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: AchievementDetailPage(
                      details: state.extra as Map<String, dynamic>,
                    )),
                  ),
                  GoRoute(
                    path: '/user_credit_help',
                    builder: (context, state) => UserVModelCreditHelp(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: UserVModelCreditHelp()),
                  ),
                  GoRoute(
                    path: '/boards_main',
                    builder: (context, state) => BoardsHomePageV3(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BoardsHomePageV3()),
                  ),
                  GoRoute(
                    path: '/invite_and_earn_homepage',
                    builder: (context, state) => ReferAndEarnHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ReferAndEarnHomepage()),
                  ),

                  GoRoute(
                    path: '/invite_contacts',
                    builder: (context, state) =>
                        ReferAndEarnInviteContactsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ReferAndEarnInviteContactsPage()),
                  ),

                  GoRoute(
                    path:
                        '/reviews_view/:username/:profilePictureUrl/:thumbnailUrl',
                    builder: (context, state) => ReviewsUI(
                        user: state.extra as VAppUser,
                        username: state.pathParameters['username'] ?? '',
                        profilePictureUrl:
                            (state.pathParameters['profilePictureUrl'] ?? "")
                                .replaceAll('****', ''),
                        thumbnailUrl:
                            (state.pathParameters['thumbnailUrl'] ?? "")
                                .replaceAll('****', '')),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: ReviewsUI(
                            user: state.extra as VAppUser,
                            username: state.pathParameters['username'] ?? '',
                            profilePictureUrl:
                                (state.pathParameters['profilePictureUrl'] ??
                                        "")
                                    .replaceAll('****', ''),
                            thumbnailUrl:
                                (state.pathParameters['thumbnailUrl'] ?? "")
                                    .replaceAll('****', ''))),
                  ),
                  GoRoute(
                    path: '/reviews_view/:username',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;

                      final user = extra["user"] as VAppUser ??
                          null; // Todo: Control what happens when user is null

                      final username =
                          state.pathParameters['username'] as String;

                      final profilePictureUrl = extra['profilePictureUrl'] ??
                          "".replaceAll('****', '');

                      final thumbnailUrl =
                          extra['thumbnailUrl'] ?? "".replaceAll('****', '');

                      return ReviewsUI(
                          user: user,
                          username: username,
                          profilePictureUrl: profilePictureUrl,
                          thumbnailUrl: thumbnailUrl);
                    },
                    pageBuilder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;

                      final user = extra["user"] as VAppUser ??
                          null; // Todo: Control what happens when user is null

                      final username =
                          state.pathParameters['username'] as String;

                      final profilePictureUrl = extra['profilePictureUrl'] ??
                          "".replaceAll('****', '');

                      final thumbnailUrl =
                          extra['thumbnailUrl'] ?? "".replaceAll('****', '');

                      return CupertinoPage(
                          child: ReviewsUI(
                              user: user,
                              username: username,
                              profilePictureUrl: profilePictureUrl,
                              thumbnailUrl: thumbnailUrl));
                    },
                  ),
                  GoRoute(
                    path: '/my_network',
                    builder: (context, state) => MyNetwork(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: MyNetwork()),
                  ),
                  GoRoute(
                    path: '/messages_homepage',
                    builder: (context, state) => MessagingHomePage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: MessagingHomePage()),
                  ),
                  GoRoute(
                    path: '/tabbed_bookings_view',
                    builder: (context, state) => BookingsTabbedView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BookingsTabbedView()),
                  ),
                  GoRoute(
                    path: '/connections_page',
                    builder: (context, state) => Connections(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: Connections()),
                  ),
                  GoRoute(
                    path: '/following_list_homepage',
                    builder: (context, state) => FollowingListHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: FollowingListHomepage()),
                  ),
                  GoRoute(
                    path: '/followers_list_homepage',
                    builder: (context, state) => FollowersListHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: FollowersListHomepage()),
                  ),
                  GoRoute(
                    path: '/network_sent_requests_page',
                    builder: (context, state) => SentRequests(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: SentRequests()),
                  ),
                  GoRoute(
                    path: '/network_received_requests_page',
                    builder: (context, state) => ReceivedRequests(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ReceivedRequests()),
                  ),
                  GoRoute(
                    path: '/invite_contact',
                    builder: (context, state) =>
                        ReferAndEarnInviteContactsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ReferAndEarnInviteContactsPage()),
                  ),
                  GoRoute(
                    path: '/blocked_list_homepage',
                    builder: (context, state) => BlockedListHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BlockedListHomepage()),
                  ),
                  GoRoute(
                    path: '/tabbed_created_gigs_view',
                    builder: (context, state) => MyCreatedGigs(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: MyCreatedGigs()),
                  ),
                  // GoRoute(
                  //   path: '/analytics',
                  //   builder: (context, state) => Analytics(),
                  //   pageBuilder: (context, state) => CupertinoPage(child: Analytics()),
                  // ),
                  GoRoute(
                    path: '/tabbed_bookings_view',
                    builder: (context, state) => BookingsTabbedView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BookingsTabbedView()),
                  ),
                  GoRoute(
                    path: '/applications_page',
                    builder: (context, state) => ApplicationsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ApplicationsPage()),
                  ),
                  GoRoute(
                    path: '/earnings_page',
                    builder: (context, state) => EarningsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: EarningsPage()),
                  ),
                  // GoRoute(
                  //   path: '/availability_view',
                  //   builder: (context, state) => AvailabilityView(),
                  //   pageBuilder: (context, state) =>
                  //       CupertinoPage(child: AvailabilityView()),
                  // ),
                  GoRoute(
                    path: '/availability_view',
                    builder: (context, state) => NewUnavailableScreen(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: NewUnavailableScreen()),
                  ),
                  // GoRoute(
                  //   path: '/unavailable_dates',
                  //   builder: (context, state) => ViewUnAvDates(),
                  //   pageBuilder: (context, state) =>
                  //       CupertinoPage(child: ViewUnAvDates()),
                  // ),
                  GoRoute(
                    path: '/business_opening_times_form',
                    builder: (context, state) => OpeningTimesHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: OpeningTimesHomepage()),
                  ),
                  GoRoute(
                    path: '/review_page_content',
                    builder: (context, state) => ReviewsPageContent(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ReviewsPageContent()),
                  ),
                  GoRoute(
                    path: '/print_homepage',
                    builder: (context, state) => PrintHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PrintHomepage()),
                  ),
                  GoRoute(
                    path: '/image_grid_splitter',
                    builder: (context, state) => ImageGridSplitterPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ImageGridSplitterPage()),
                  ),
                  GoRoute(
                    path: '/print_profile/:username',
                    builder: (context, state) => PrintProfile(
                        username: state.pathParameters['username']),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: PrintProfile(
                            username: state.pathParameters['username'])),
                  ),
                  GoRoute(
                    path: '/printings',
                    builder: (context, state) => PrintingSettingsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PrintingSettingsPage()),
                  ),
                  GoRoute(
                    path: '/preview_screen',
                    builder: (context, state) => PreviewScreen(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PreviewScreen()),
                  ),
                  GoRoute(
                    path: '/boards_search',
                    builder: (context, state) => BoardsSearchPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BoardsSearchPage()),
                  ),
                  GoRoute(
                    path: '/report_a_bag_home_page',
                    builder: (context, state) => ReportABugHomePage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ReportABugHomePage()),
                  ),
                  GoRoute(
                    path: '/report_abuse_or_spam_page',
                    builder: (context, state) => ReportAbuseSpamPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ReportAbuseSpamPage()),
                  ),
                  GoRoute(
                    path: '/report_illegal_page',
                    builder: (context, state) => ReportIllegalPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ReportIllegalPage()),
                  ),
                  GoRoute(
                    path: '/reportsPage',
                    builder: (context, state) => ReportsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ReportsPage()),
                  ),
                  GoRoute(
                    path: '/tabbed_user_offerings/:username',
                    builder: (context, state) => UserOfferingsTabbedView(
                      username: state.pathParameters['username'],
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: UserOfferingsTabbedView(
                      username: state.pathParameters['username'],
                    )),
                  ),
                  GoRoute(
                    path: '/activityHomePage',
                    builder: (context, state) => ActivityHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ActivityHomepage()),
                  ),
                  GoRoute(
                    path:
                        '/reviews_view/:username/:profilePictureUrl/:thumbnailUrl',
                    builder: (context, state) => ReviewsUI(
                        user: state.extra as VAppUser,
                        username: state.pathParameters['username'] ?? '',
                        profilePictureUrl:
                            (state.pathParameters['profilePictureUrl'] ?? "")
                                .replaceAll('****', ''),
                        thumbnailUrl:
                            (state.pathParameters['thumbnailUrl'] ?? "")
                                .replaceAll('****', '')),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: ReviewsUI(
                            user: state.extra as VAppUser,
                            username: state.pathParameters['username'] ?? '',
                            profilePictureUrl:
                                (state.pathParameters['profilePictureUrl'] ??
                                        "")
                                    .replaceAll('****', ''),
                            thumbnailUrl:
                                (state.pathParameters['thumbnailUrl'] ?? "")
                                    .replaceAll('****', ''))),
                  ),
                  GoRoute(
                    path: '/bookingList',
                    builder: (context, state) => BookingList(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BookingList()),
                  ),
                  GoRoute(
                    path: '/bookingSequencePage',
                    builder: (context, state) => BookingSequencePage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BookingSequencePage()),
                  ),
                  GoRoute(
                    path: '/VerifyNewPhone',
                    builder: (context, state) => VerifyNewPhone(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: VerifyNewPhone()),
                  ),
                  GoRoute(
                    path: '/bookingSettings',
                    builder: (context, state) => BookingSettings(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BookingSettings()),
                  ),
                  GoRoute(
                    path: '/bookingSettingsOptions',
                    builder: (context, state) => BookingSettingsOptions(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BookingSettingsOptions()),
                  ),
                  GoRoute(
                    path: '/paymentCompletedView',
                    builder: (context, state) => PaymentCompletedView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PaymentCompletedView()),
                  ),
                  GoRoute(
                    path: '/bookingCheckoutPaymentView',
                    builder: (context, state) => BookingCheckoutPaymentView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BookingCheckoutPaymentView()),
                  ),
                  GoRoute(
                    path:
                        '/createBookingFirstPage/:username/:displayName/:unavailableDates/:serviceId',
                    builder: (context, state) => CreateBookingFirstPage(
                      username: state.pathParameters['username'] ?? '',
                      displayName: state.pathParameters['displayName'] ?? '',
                      serviceId: state.pathParameters['serviceId'] ?? '',
                      unavailableDates: DateClass().listOfStringToListOfDate(
                          json.decode(
                              state.pathParameters['unavailableDates'] ?? '')),
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                      child: CreateBookingFirstPage(
                        username: state.pathParameters['username'] ?? '',
                        displayName: state.pathParameters['displayName'] ?? '',
                        serviceId: state.pathParameters['serviceId'] ?? '',
                        unavailableDates: DateClass().listOfStringToListOfDate(
                            json.decode(
                                state.pathParameters['unavailableDates'] ??
                                    '')),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: '/createBookingSecondPage/:jobType',
                    builder: (context, state) => CreateBookingSecondPage(
                      jobType: state.pathParameters['jobType'] ?? '',
                      service: state.extra as ServicePackageModel,
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: CreateBookingSecondPage(
                            service: state.extra as ServicePackageModel,
                            jobType: state.pathParameters['jobType'] ?? '')),
                  ),
                  GoRoute(
                    path: '/createContractView',
                    builder: (context, state) => CreateContractView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: CreateContractView()),
                  ),
                  GoRoute(
                    path: '/PreviewContractView',
                    builder: (context, state) => PreviewContractView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PreviewContractView()),
                  ),
                  GoRoute(
                    path:
                        '/addNewCouponHomepage/:servicePackage/:couponCode/:coupoTtitle/:couponId/:isUpdate',
                    builder: (context, state) => AddNewCouponHomepage(context,
                        servicePackage: ServicePackageModel.fromJson(
                            state.pathParameters['servicePackage'] ?? '{}'),
                        couponCode: state.pathParameters['couponCode'],
                        coupoTtitle: state.pathParameters['coupoTtitle'],
                        couponId: state.pathParameters['couponId'],
                        isUpdate: state.pathParameters['isUpdate'] == true
                            ? true
                            : false),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: AddNewCouponHomepage(context,
                            servicePackage: ServicePackageModel.fromJson(
                                state.pathParameters['servicePackage'] ?? '{}'),
                            couponCode: state.pathParameters['couponCode'],
                            coupoTtitle: state.pathParameters['coupoTtitle'],
                            couponId: state.pathParameters['couponId'],
                            isUpdate: state.pathParameters['isUpdate'] == true
                                ? true
                                : false)),
                  ),
                  GoRoute(
                    path: '/faqsTopics',
                    builder: (context, state) => FAQsTopics(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: FAQsTopics()),
                  ),
                  GoRoute(
                    path: '/faqsHomepage',
                    builder: (context, state) => FAQsHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: FAQsHomepage()),
                  ),
                  GoRoute(
                    path: '/guessPage',
                    builder: (context, state) => GuessPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: GuessPage()),
                  ),
                  GoRoute(
                    path: '/leadershipBoards',
                    builder: (context, state) => LeadershipBoards(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: LeadershipBoards()),
                  ),
                  GoRoute(
                    path:
                        '/GotoIndexFeed/:data/:index/:username/:profilePictureUrl/:profileThumbnailUrl/:navigationDepth',
                    builder: (context, state) => GotoIndexFeed(
                      data: GalleryModel.fromMap(
                          json.decode(state.pathParameters['data']!)),
                      index: int.parse(state.pathParameters['data']!),
                      username: state.pathParameters['username']!,
                      profilePictureUrl:
                          state.pathParameters['profilePictureUrl']!,
                      profileThumbnailUrl:
                          state.pathParameters['profileThumbnailUrl']!,
                      navigationDepth:
                          int.parse(state.pathParameters['navigationDepth']!),
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: GotoIndexFeed(
                      data: GalleryModel.fromMap(
                          json.decode(state.pathParameters['data']!)),
                      index: int.parse(state.pathParameters['data']!),
                      username: state.pathParameters['username']!,
                      profilePictureUrl:
                          state.pathParameters['profilePictureUrl']!,
                      profileThumbnailUrl:
                          state.pathParameters['profileThumbnailUrl']!,
                      navigationDepth:
                          int.parse(state.pathParameters['navigationDepth']!),
                    )),
                  ),

                  GoRoute(
                    path:
                        '/galleryFeedViewHomepage/:galleryId/:galleryName/:username/:tappedIndex',
                    builder: (context, state) {
                      final extraObject = state.extra as Map<String, String>;
                      return GalleryFeedViewHomepage(
                          galleryId: state.pathParameters['galleryId']!,
                          galleryName: state.pathParameters['galleryName']!,
                          username: state.pathParameters['username']!,
                          profilePictureUrl:
                              extraObject['profilePictureUrl'] ?? '',
                          profileThumbnailUrl:
                              extraObject['profileThumbnailUrl'] ?? '',
                          tappedIndex:
                              int.parse(state.pathParameters['tappedIndex']!));
                    },
                    pageBuilder: (context, state) {
                      final extraObject = state.extra as Map<String, String>;
                      return CupertinoPage(
                          child: GalleryFeedViewHomepage(
                              galleryId: state.pathParameters['galleryId']!,
                              galleryName: state.pathParameters['galleryName']!,
                              username: state.pathParameters['username']!,
                              profilePictureUrl:
                                  extraObject['profilePictureUrl'] ?? '',
                              profileThumbnailUrl:
                                  extraObject['profileThumbnailUrl'] ?? '',
                              tappedIndex: int.parse(
                                  state.pathParameters['tappedIndex']!)));
                    },
                  ),

                  // GoRoute(
                  //   path: '/galleryFeedViewHomepage/:galleryId/:galleryName/:username/:tappedIndex',
                  //   builder: (context, state) {
                  //     final extraObject = state.extra as Map<String, String>;
                  //     return GalleryFeedViewHomepage(
                  //         galleryId: state.pathParameters['galleryId']!,
                  //         galleryName: state.pathParameters['galleryName']!,
                  //         username: state.pathParameters['username']!,
                  //         profilePictureUrl: extraObject['profilePictureUrl'] ?? '',
                  //         profileThumbnailUrl: extraObject['profileThumbnailUrl'] ?? '',
                  //         tappedIndex: int.parse(state.pathParameters['tappedIndex']!));
                  //   },
                  //   pageBuilder: (context, state) {
                  //     final extraObject = state.extra as Map<String, String>;
                  //     return CustomTransitionPage(
                  //         transitionDuration: Duration(milliseconds: 300),
                  //         child: GalleryFeedViewHomepage(
                  //             galleryId: state.pathParameters['galleryId']!,
                  //             galleryName: state.pathParameters['galleryName']!,
                  //             username: state.pathParameters['username']!,
                  //             profilePictureUrl: extraObject['profilePictureUrl'] ?? '',
                  //             profileThumbnailUrl: extraObject['profileThumbnailUrl'] ?? '',
                  //             tappedIndex: int.parse(state.pathParameters['tappedIndex']!)),
                  //         transitionsBuilder: (context, animation, secondAnimation, child) {
                  //           return ScaleTransition(
                  //             scale: CurvedAnimation(
                  //               parent: animation,
                  //               curve: Curves.easeInOut,
                  //             ),
                  //             child: child,
                  //           );
                  //         });
                  //   },
                  // ),
                  GoRoute(
                    path: '/menuSheet',
                    builder: (context, state) => MenuSheet(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: MenuSheet()),
                  ),
                  GoRoute(
                    path: '/games',
                    builder: (context, state) => Games(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: Games()),
                  ),
                  GoRoute(
                    path: '/myBusinessProfile',
                    builder: (context, state) => MyBusinessProfile(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: MyBusinessProfile()),
                  ),
                  GoRoute(
                    path: '/polaroid',
                    builder: (context, state) => Polaroid(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: Polaroid()),
                  ),
                  GoRoute(
                    path:
                        '/helpDetailsViewTwo/:tutorialDetailsDescription/:tutorialDetailsTitle',
                    builder: (context, state) => HelpDetailsViewTwo(
                      tutorialDetailsDescription:
                          state.pathParameters['tutorialDetailsDescription'],
                      tutorialDetailsTitle:
                          state.pathParameters['tutorialDetailsTitle'],
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: HelpDetailsViewTwo(
                      tutorialDetailsDescription:
                          state.pathParameters['tutorialDetailsDescription'],
                      tutorialDetailsTitle:
                          state.pathParameters['tutorialDetailsTitle'],
                    )),
                  ),
                  GoRoute(
                    path: '/verifyNationalID/:imagePath',
                    builder: (context, state) => VerifyNationalID(
                      image: XFile(state.pathParameters['imagePath']!),
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: VerifyNationalID(
                      image: XFile(state.pathParameters['imagePath']!),
                    )),
                  ),
                  GoRoute(
                    path: '/archivedMessagesScreen',
                    builder: (context, state) => ArchivedMessagesScreen(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ArchivedMessagesScreen()),
                  ),

                  GoRoute(
                    path: '/notificationsView',
                    builder: (context, state) => NotificationsView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: NotificationsView()),
                  ),
                  GoRoute(
                    path: '/referAndEarnQrPage',
                    builder: (context, state) => ReferAndEarnQrPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ReferAndEarnQrPage()),
                  ),
                  GoRoute(
                    path: '/referAndEarnInviteContactPage/:contact',
                    builder: (context, state) => ReferAndEarnInviteContactPage(
                        contact: Contact.fromMap(
                            json.decode(state.pathParameters['contact']!))),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: ReferAndEarnInviteContactPage(
                            contact: Contact.fromMap(json
                                .decode(state.pathParameters['contact']!)))),
                  ),
                  GoRoute(
                    path: '/bookingDetailsView',
                    builder: (context, state) => BookingDetailsView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BookingDetailsView()),
                  ),
                  GoRoute(
                    path: '/bookingsMenuView',
                    builder: (context, state) => BookingsMenuView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BookingsMenuView()),
                  ),
                  GoRoute(
                    path: '/emptyUpComingView',
                    builder: (context, state) => EmptyUpComingView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: EmptyUpComingView()),
                  ),
                  GoRoute(
                    path: '/profileSettingsHomepage',
                    builder: (context, state) => ProfileSettingsHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ProfileSettingsHomepage()),
                  ),
                  GoRoute(
                    path: '/verificationSettingPage',
                    builder: (context, state) => VerificationSettingPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: VerificationSettingPage()),
                  ),
                  GoRoute(
                    path: '/personalitySettingPage',
                    builder: (context, state) => PersonalitySettingPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PersonalitySettingPage()),
                  ),
                  GoRoute(
                    path: '/UserCoupons/:username/:showAppBar',
                    builder: (context, state) => UserCoupons(
                        username: state.pathParameters['username'],
                        showAppBar:
                            state.pathParameters['showAppBar'] == 'false'
                                ? false
                                : true),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: UserCoupons(
                            username: state.pathParameters['username'],
                            showAppBar:
                                state.pathParameters['showAppBar'] == 'false'
                                    ? false
                                    : true)),
                  ),
                  GoRoute(
                    path: '/UserCoupons/:username',
                    builder: (context, state) => UserCoupons(
                      username: state.pathParameters['username'],
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: UserCoupons(
                      username: state.pathParameters['username'],
                    )),
                  ),
                  GoRoute(
                    path: '/tutorialDetailsView/:helpDetailsTitle',
                    builder: (context, state) => TutorialDetailsView(
                      helpDetailsTitle:
                          state.pathParameters['helpDetailsTitle'] ??
                              'Account settings',
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: TutorialDetailsView(
                      helpDetailsTitle:
                          state.pathParameters['helpDetailsTitle'] ??
                              'Account settings',
                    )),
                  ),
                  GoRoute(
                    path: '/vMagazineBody/:check',
                    builder: (context, state) => VMagazineBody(
                        check: state.pathParameters['check'] == 'true'
                            ? true
                            : state.pathParameters['check'] == 'false'
                                ? false
                                : null),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: VMagazineBody(
                            check: state.pathParameters['check'] == 'true'
                                ? true
                                : state.pathParameters['check'] == 'false'
                                    ? false
                                    : null)),
                  ),
                  GoRoute(
                    path: '/vWidgetsMagazinePageView',
                    builder: (context, state) => VWidgetsMagazinePageView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: VWidgetsMagazinePageView()),
                  ),
                  GoRoute(
                    path: '/CreditHistoryPage/:intabs',
                    builder: (context, state) => CreditHistoryPage(
                        intabs: state.pathParameters['intabs'] == 'true'
                            ? true
                            : state.pathParameters['intabs'] == 'false'
                                ? false
                                : true),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: CreditHistoryPage(
                            intabs: state.pathParameters['intabs'] == 'true'
                                ? true
                                : state.pathParameters['intabs'] == 'false'
                                    ? false
                                    : true)),
                  ),
                  GoRoute(
                    path: '/creditWithdrawalPage',
                    builder: (context, state) => CreditWithdrawalPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: CreditWithdrawalPage()),
                  ),
                  GoRoute(
                    path: '/NotificationMain',
                    builder: (context, state) => NotificationMain(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: NotificationMain()),
                  ),
                  GoRoute(
                    path: '/vMCLeaderboard',
                    builder: (context, state) => VMCLeaderboard(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: VMCLeaderboard()),
                  ),
                  GoRoute(
                    path: '/vMCNotifications/:showAppBar',
                    builder: (context, state) => VMCNotifications(
                      showAppBar: state.pathParameters['showAppBar'] == 'true'
                          ? true
                          : false,
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                      child: VMCNotifications(
                        showAppBar: state.pathParameters['showAppBar'] == 'true'
                            ? true
                            : false,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: '/userVModelCreditHomepage',
                    builder: (context, state) => UserVModelCreditHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: UserVModelCreditHomepage()),
                  ),
                  GoRoute(
                    path: '/withdrawalHistoryPage',
                    builder: (context, state) => WithdrawalHistoryPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: WithdrawalHistoryPage()),
                  ),
                  GoRoute(
                    path:
                        '/profileInputField/:username/:isVerified/:blueTickVerified',
                    builder: (context, state) => VerifiedUsernameWidget(
                        username: state.pathParameters['username']!,
                        isVerified: state.pathParameters['isVerified'] == 'true'
                            ? true
                            : false,
                        blueTickVerified:
                            state.pathParameters['blueTickVerified'] == 'true'
                                ? true
                                : false),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: VerifiedUsernameWidget(
                            username: state.pathParameters['username']!,
                            isVerified:
                                state.pathParameters['isVerified'] == 'true'
                                    ? true
                                    : false,
                            blueTickVerified:
                                state.pathParameters['blueTickVerified'] ==
                                        'true'
                                    ? true
                                    : false)),
                  ),
                  GoRoute(
                    path: '/profileHeaderWidget',
                    builder: (context, state) => ProfileHeaderWidget(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ProfileHeaderWidget()),
                  ),
                  GoRoute(
                    path: '/galleryTabs/:tabs',
                    builder: (context, state) => GalleryTabs(
                        tabs: json.decode(state.pathParameters['tabs']!)),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: GalleryTabs(
                            tabs: json.decode(state.pathParameters['tabs']!))),
                  ),
                  GoRoute(
                    path:
                        '/gallery/:albumID/:userProfilePictureUrl/:userProfileThumbnailUrl/:username/:isSaved',
                    builder: (context, state) => Gallery(
                        albumID: state.pathParameters['albumID']!,
                        userProfilePictureUrl:
                            state.pathParameters['userProfilePictureUrl']!,
                        userProfileThumbnailUrl:
                            state.pathParameters['userProfileThumbnailUrl']!,
                        username: state.pathParameters['username']!,
                        isSaved: state.pathParameters['isSaved'] == 'true'
                            ? true
                            : false,
                        photos: galleryMap(state.pathParameters['photos']!),
                        gallery: GalleryModel.fromMap(
                            json.decode(state.pathParameters['gallery']!)),
                        hasVideo: state.pathParameters['hasVideo'] == 'true'
                            ? true
                            : false),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: Gallery(
                            albumID: state.pathParameters['albumID']!,
                            userProfilePictureUrl:
                                state.pathParameters['userProfilePictureUrl']!,
                            userProfileThumbnailUrl: state
                                .pathParameters['userProfileThumbnailUrl']!,
                            username: state.pathParameters['username']!,
                            isSaved: state.pathParameters['isSaved'] == 'true'
                                ? true
                                : false,
                            photos: galleryMap(state.pathParameters['photos']!),
                            gallery: GalleryModel.fromMap(
                                json.decode(state.pathParameters['gallery']!)),
                            hasVideo: state.pathParameters['hasVideo'] == 'true'
                                ? true
                                : false)),
                  ),
                  GoRoute(
                    path: '/UserCreatedBoardsWidget',
                    builder: (context, state) => UserCreatedBoardsWidget(
                      boards: [],
                      mockImages: [],
                      scrollBack: () {},
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                      child: UserCreatedBoardsWidget(
                        boards: [],
                        mockImages: [],
                        scrollBack: () {},
                      ),
                    ),
                  ),
                  GoRoute(
                    path: '/savedServicesHomepage/:likedServices',
                    builder: (context, state) => SavedServicesHomepage(
                      likedServices:
                          json.decode(state.pathParameters['likedServices']!),
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: SavedServicesHomepage(
                      likedServices:
                          json.decode(state.pathParameters['likedServices']!),
                    )),
                  ),
                  GoRoute(
                    path: '/paginatedGalleryProfileBaseScreen',
                    builder: (context, state) =>
                        PaginatedGalleryProfileBaseScreen(),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: PaginatedGalleryProfileBaseScreen()),
                  ),
                  GoRoute(
                    path:
                        '/galleryHello/:albumID/:userProfilePictureUrl/:userProfileThumbnailUrl/:username/:isSaved/:photos/:gallery',
                    builder: (context, state) => GalleryHello(
                        albumID: json.decode(state.pathParameters['albumID']!),
                        userProfilePictureUrl: json.decode(
                            state.pathParameters['userProfilePictureUrl']!),
                        userProfileThumbnailUrl: json.decode(
                            state.pathParameters['userProfileThumbnailUrl']!),
                        username:
                            json.decode(state.pathParameters['username']!),
                        isSaved: json.decode(state.pathParameters['isSaved']!),
                        photos: json.decode(state.pathParameters['photos']!),
                        gallery: json.decode(state.pathParameters['gallery']!)),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: GalleryHello(
                            albumID:
                                json.decode(state.pathParameters['albumID']!),
                            userProfilePictureUrl: json.decode(
                                state.pathParameters['userProfilePictureUrl']!),
                            userProfileThumbnailUrl: json.decode(state
                                .pathParameters['userProfileThumbnailUrl']!),
                            username:
                                json.decode(state.pathParameters['username']!),
                            isSaved:
                                json.decode(state.pathParameters['isSaved']!),
                            photos:
                                json.decode(state.pathParameters['photos']!),
                            gallery:
                                json.decode(state.pathParameters['gallery']!))),
                  ),
                  GoRoute(
                    path: '/remoteBusinessProfileBaseScreen',
                    builder: (context, state) =>
                        RemoteBusinessProfileBaseScreen(
                            username: state.pathParameters['username']!),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: RemoteBusinessProfileBaseScreen(
                            username: state.pathParameters['username']!)),
                  ),
                  GoRoute(
                    path: '/AccountSettings',
                    builder: (context, state) => AccountSettings(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: AccountSettings()),
                  ),
                  GoRoute(
                    path: '/AccountBase',
                    builder: (context, state) => AccountBase(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: AccountBase()),
                  ),
                  GoRoute(
                    path: '/EmailUpdateView',
                    builder: (context, state) => EmailUpdateView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: EmailUpdateView()),
                  ),
                  GoRoute(
                    path: '/NameUpdateView',
                    builder: (context, state) => NameUpdateView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: NameUpdateView()),
                  ),
                  GoRoute(
                    path: '/AlertSettings',
                    builder: (context, state) => AlertSettings(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: AlertSettings()),
                  ),
                  GoRoute(
                    path: '/InteractionSettings',
                    builder: (context, state) => InteractionSettings(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: InteractionSettings()),
                  ),
                  GoRoute(
                    path: '/JobTypesSettings',
                    builder: (context, state) => JobTypesSettings(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: JobTypesSettings()),
                  ),
                  GoRoute(
                    path: '/LocationScreen',
                    builder: (context, state) => LocationScreen(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: LocationScreen()),
                  ),
                  GoRoute(
                    path: '/NickNameSettings',
                    builder: (context, state) => NickNameSettings(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: NickNameSettings()),
                  ),
                  GoRoute(
                    path: '/ProfileSettings',
                    builder: (context, state) => ProfileSettings(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ProfileSettings()),
                  ),
                  GoRoute(
                    path: '/VSettingsBase',
                    builder: (context, state) => VSettingsBase(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: VSettingsBase()),
                  ),
                  GoRoute(
                    path: '/AccountSettingsEmailPage',
                    builder: (context, state) => AccountSettingsEmailPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: AccountSettingsEmailPage()),
                  ),
                  GoRoute(
                    path: '/AccountSettingsLocationPage',
                    builder: (context, state) => AccountSettingsLocationPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: AccountSettingsLocationPage()),
                  ),
                  GoRoute(
                    path: '/AccountSettingsNamePage',
                    builder: (context, state) => AccountSettingsNamePage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: AccountSettingsNamePage()),
                  ),
                  GoRoute(
                    path: '/AccountSettingsPhonePage',
                    builder: (context, state) => AccountSettingsPhonePage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: AccountSettingsPhonePage()),
                  ),
                  GoRoute(
                    path: '/PasswordSettingsPage',
                    builder: (context, state) => PasswordSettingsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PasswordSettingsPage()),
                  ),
                  GoRoute(
                    path: '/PersonalSettingsPage',
                    builder: (context, state) => PersonalSettingsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PersonalSettingsPage()),
                  ),
                  GoRoute(
                    path: '/AccountSettingsPage',
                    builder: (context, state) => AccountSettingsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: AccountSettingsPage()),
                  ),
                  GoRoute(
                    path: '/PrivacySettingPage',
                    builder: (context, state) => PrivacySetting(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PrivacySetting()),
                  ),

                  GoRoute(
                    path: '/VerifyPasswordPage',
                    builder: (context, state) => VerifyPasswordPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: VerifyPasswordPage()),
                  ),
                  GoRoute(
                    path: '/ApperanceHomepage',
                    builder: (context, state) => ApperanceHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ApperanceHomepage()),
                  ),
                  GoRoute(
                    path: '/BookingPricesSettingsPage',
                    builder: (context, state) => BookingPricesSettingsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BookingPricesSettingsPage()),
                  ),
                  GoRoute(
                    path: '/JobTypesSettingPage',
                    builder: (context, state) => JobTypesSettingPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: JobTypesSettingPage()),
                  ),
                  GoRoute(
                    path: '/BookingSettingsPage',
                    builder: (context, state) => BookingSettingsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BookingSettingsPage()),
                  ),
                  GoRoute(
                    path: '/GallerySettingsHomepage',
                    builder: (context, state) => GallerySettingsHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: GallerySettingsHomepage()),
                  ),
                  GoRoute(
                    path: '/CreateOfferPage',
                    builder: (context, state) => CreateOfferPage(
                        onCreatOffer:
                            json.decode(state.pathParameters['onCreatOffer']!)),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: CreateOfferPage(
                            onCreatOffer: json.decode(
                                state.pathParameters['onCreatOffer']!))),
                  ),
                  GoRoute(
                    path: '/AllDates',
                    builder: (context, state) => AllDates(
                        selectedDays:
                            json.decode(state.pathParameters['selectedDays']!)),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: AllDates(
                            selectedDays: json.decode(
                                state.pathParameters['selectedDays']!))),
                  ),
                  GoRoute(
                    path: '/VWidgetsBookingSettingsCard',
                    builder: (context, state) => VWidgetsBookingSettingsCard(
                        title: json.decode(state.pathParameters['title']!),
                        onTap: json.decode(state.pathParameters['onTap']!)),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: VWidgetsBookingSettingsCard(
                            title: json.decode(state.pathParameters['title']!),
                            onTap:
                                json.decode(state.pathParameters['onTap']!))),
                  ),
                  GoRoute(
                    path: '/CategoryModal',
                    builder: (context, state) => CategoryModal(
                        categoryList:
                            json.decode(state.pathParameters['categoryList']!),
                        selectedCategoryList: json.decode(
                            state.pathParameters['selectedCategoryList']!),
                        onTap: json.decode(state.pathParameters['onTap']!)),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: CategoryModal(
                            categoryList: json
                                .decode(state.pathParameters['categoryList']!),
                            selectedCategoryList: json.decode(
                                state.pathParameters['selectedCategoryList']!),
                            onTap:
                                json.decode(state.pathParameters['onTap']!))),
                  ),
                  GoRoute(
                    path: '/ServiceImageListView',
                    builder: (context, state) => ServiceImageListView(
                        fileImages:
                            json.decode(state.pathParameters['fileImages']!),
                        addMoreImages: json
                            .decode(state.pathParameters['addMoreImages']!)),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: ServiceImageListView(
                            fileImages: json
                                .decode(state.pathParameters['fileImages']!),
                            addMoreImages: json.decode(
                                state.pathParameters['addMoreImages']!))),
                  ),
                  GoRoute(
                    path: '/SelectedServiceImage',
                    builder: (context, state) => SelectedServiceImage(
                        image: json.decode(state.pathParameters['image']!)),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: SelectedServiceImage(
                            image:
                                json.decode(state.pathParameters['image']!))),
                  ),
                  GoRoute(
                    path: '/VWidgetsServiceLength',
                    builder: (context, state) => VWidgetsServiceLength(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: VWidgetsServiceLength()),
                  ),
                  GoRoute(
                    path: '/UnavailableDates',
                    builder: (context, state) => UnavailableDates(
                        date: json.decode(state.pathParameters['date']!),
                        day: json.decode(state.pathParameters['day']!),
                        removeFunc:
                            json.decode(state.pathParameters['displayName']!)),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: UnavailableDates(
                            date: json.decode(state.pathParameters['date']!),
                            day: json.decode(state.pathParameters['day']!),
                            removeFunc: json
                                .decode(state.pathParameters['displayName']!))),
                  ),
                  GoRoute(
                    path: '/AlertSettingsPage/:user',
                    builder: (context, state) => AlertSettingsPage(
                        user: json.decode(state.pathParameters['user']!)),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: AlertSettingsPage(
                            user: json.decode(state.pathParameters['user']!))),
                  ),
                  GoRoute(
                    path: '/AlertSettingsPage',
                    builder: (context, state) =>
                        AlertSettingsPage(user: state.extra as VAppUser),
                    pageBuilder: (context, state) => CupertinoPage(
                        child:
                            AlertSettingsPage(user: state.extra as VAppUser)),
                  ),
                  GoRoute(
                    path: '/ReferAndEarnPage',
                    builder: (context, state) => ReferAndEarnPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ReferAndEarnPage()),
                  ),
                  GoRoute(
                    path: '/ProfileSettingPage',
                    builder: (context, state) => ProfileSettingPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ProfileSettingPage()),
                  ),
                  GoRoute(
                    path: '/ServicesHomepage/:username/:showAppBar',
                    builder: (context, state) => ServicesHomepage(
                      username: state.pathParameters['username'],
                      showAppBar:
                          state.pathParameters['showAppBar'] == "false" ||
                                  state.pathParameters['showAppBar'] == false
                              ? false
                              : true,
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: ServicesHomepage(
                      username: state.pathParameters['username'],
                      showAppBar:
                          state.pathParameters['showAppBar'] == "false" ||
                                  state.pathParameters['showAppBar'] == false
                              ? false
                              : true,
                    )),
                  ),
                  GoRoute(
                    path: '/ServicesHomepage/:username',
                    builder: (context, state) => ServicesHomepage(
                      username: state.pathParameters['username'],
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                      child: ServicesHomepage(
                        username: state.pathParameters['username'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: '/portfolio-gallery-settings/:title/:galleryType',
                    builder: (context, state) =>
                        PortfolioGalleriesSettingsHomepage(
                      title: state.pathParameters['title'] ?? "",
                      galleryType: state.pathParameters['galleryType'] ==
                              AlbumType.portfolio.name
                          ? AlbumType.portfolio
                          : AlbumType.polaroid,
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                      child: PortfolioGalleriesSettingsHomepage(
                        title: state.pathParameters['title'] ?? "",
                        galleryType: state.pathParameters['galleryType'] ==
                                AlbumType.portfolio.name
                            ? AlbumType.portfolio
                            : AlbumType.polaroid,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: '/UserJobsPage/:username/:showAppBar',
                    builder: (context, state) => UserJobsPage(
                      username: state.pathParameters['username'],
                      showAppBar:
                          state.pathParameters['showAppBar'] == "false" ||
                                  state.pathParameters['showAppBar'] == false
                              ? false
                              : true,
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: UserJobsPage(
                      username: state.pathParameters['username'],
                      showAppBar:
                          state.pathParameters['showAppBar'] == "false" ||
                                  state.pathParameters['showAppBar'] == false
                              ? false
                              : true,
                    )),
                  ),
                  GoRoute(
                    path: '/UserJobsPage/:username',
                    builder: (context, state) => UserJobsPage(
                      username: state.pathParameters['username'],
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                      child: UserJobsPage(
                        username: state.pathParameters['username'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: '/UserLivesPage/:username/:showAppBar',
                    builder: (context, state) => UserLivesOfferings(
                      username: state.pathParameters['username'],
                      showAppBar:
                          state.pathParameters['showAppBar'] == "false" ||
                                  state.pathParameters['showAppBar'] == false
                              ? false
                              : true,
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: UserLivesOfferings(
                      username: state.pathParameters['username'],
                      showAppBar:
                          state.pathParameters['showAppBar'] == "false" ||
                                  state.pathParameters['showAppBar'] == false
                              ? false
                              : true,
                    )),
                  ),
                  GoRoute(
                    path: '/UserLivesPage/:username',
                    builder: (context, state) => UserLivesOfferings(
                      username: state.pathParameters['username'],
                    ),
                    pageBuilder: (context, state) => CupertinoPage(
                      child: UserLivesOfferings(
                        username: state.pathParameters['username'],
                      ),
                    ),
                  ),
                  GoRoute(
                    path: '/PaymentSettingsHomepage',
                    builder: (context, state) => PaymentSettingsHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PaymentSettingsHomepage()),
                  ),
                  GoRoute(
                    path: '/PaymentSettingsPage',
                    builder: (context, state) => PaymentSettingsPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: PaymentSettingsPage()),
                  ),
                  GoRoute(
                    path: '/FeedSettingsHomepage',
                    builder: (context, state) => FeedSettingsHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: FeedSettingsHomepage()),
                  ),
                  GoRoute(
                    path: '/PermissionsHomepage/:user',
                    builder: (context, state) => PermissionsHomepage(
                        user: json.decode(state.pathParameters['user']!)),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: PermissionsHomepage(
                            user: json.decode(state.pathParameters['user']!))),
                  ),
                  GoRoute(
                    path: '/ThemesPage',
                    builder: (context, state) => ThemesPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ThemesPage()),
                  ),
                  GoRoute(
                    path: '/LanguagesPage',
                    builder: (context, state) => LanguagesPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: LanguagesPage()),
                  ),
                  GoRoute(
                    path: '/DefaultIconPage',
                    builder: (context, state) => DefaultIconPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: DefaultIconPage()),
                  ),

                  GoRoute(
                    path: '/HaptickFeedbackSettings',
                    builder: (context, state) => HaptickFeedbackSettings(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: HaptickFeedbackSettings()),
                  ),
                  GoRoute(
                    path: TwoFactorAuthentication.route,
                    builder: (context, state) => TwoFactorAuthentication(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: TwoFactorAuthentication()),
                  ),
                  GoRoute(
                    path: '/betaDashBoardWeb/:title',
                    builder: (context, state) => BetaDashBoardWeb(
                        title: state.pathParameters['title']!,
                        url: state.extra as String),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: BetaDashBoardWeb(
                            title: state.pathParameters['title']!,
                            url: state.extra as String)),
                  ),
                  GoRoute(
                    path: '/betaDashboardHomepage',
                    builder: (context, state) => BetaDashboardHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BetaDashboardHomepage()),
                  ),
                  GoRoute(
                    path: '/beta_dashboard_homepage',
                    builder: (context, state) => BetaDashboardHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BetaDashboardHomepage()),
                  ),
                  GoRoute(
                    path: '/shortcuts_tricks',
                    builder: (context, state) => ShortcutsAndTricksHomepage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: ShortcutsAndTricksHomepage()),
                  ),
                  GoRoute(
                    path: '/help_home',
                    builder: (context, state) => HelpAndSupportMainView(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: HelpAndSupportMainView()),
                  ),
                  GoRoute(
                    path: '/webViewPage/:url',
                    builder: (context, state) =>
                        WebViewPage(url: state.pathParameters['url']!),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: WebViewPage(url: state.pathParameters['url']!)),
                  ),
                  GoRoute(
                    path: '/creation_tools',
                    builder: (context, state) => CreationTools(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: CreationTools()),
                  ),
                  GoRoute(
                    path: '/crop1',
                    builder: (context, state) => CropTestPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: CropTestPage()),
                  ),
                  GoRoute(
                    path: '/vmc_notifications/:showAppBar',
                    builder: (context, state) => VMCNotifications(
                        showAppBar:
                            state.pathParameters['showAppBar'] == "false"
                                ? false
                                : true),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: VMCNotifications(
                            showAppBar:
                                state.pathParameters['showAppBar'] == "false"
                                    ? false
                                    : true)),
                  ),
                  GoRoute(
                    path: '/splitterPage',
                    builder: (context, state) => SplitterPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: SplitterPage()),
                  ),
                  // GoRoute(
                  //   path: '/gigJobsList',
                  //   builder: (context, state) => GigJobsList(
                  //       canLoadMore: state.pathParameters['tab'] == 'true' ? true : false,
                  //       tab: json.decode(state.pathParameters['tab']!),
                  //       bookings: json.decode(state.pathParameters['data']!),
                  //       isBooking: false,
                  //       refresh: json.decode(state.pathParameters['refresh']!),
                  //       loadMore: json.decode(state.pathParameters['loadMore']!),
                  //       onItemTap: json.decode(state.pathParameters['onItemTap']!)),
                  //   pageBuilder: (context, state) => CupertinoPage(
                  //       child: GigJobsList(
                  //           canLoadMore: state.pathParameters['tab'] == 'true' ? true : false,
                  //           tab: json.decode(state.pathParameters['tab']!),
                  //           isBooking: false,
                  //           bookings: json.decode(state.pathParameters['data']!),
                  //           refresh: json.decode(state.pathParameters['refresh']!),
                  //           loadMore: json.decode(state.pathParameters['loadMore']!),
                  //           onItemTap: json.decode(state.pathParameters['onItemTap']!))),
                  // ),
                  GoRoute(
                    path: '/WebViewPage/:url',
                    builder: (context, state) =>
                        WebViewPage(url: state.pathParameters['url']!),
                    pageBuilder: (context, state) => CupertinoPage(
                        child: WebViewPage(url: state.pathParameters['url']!)),
                  ),
                  GoRoute(
                    path: '/AwaitDesignScreen',
                    builder: (context, state) => AwaitDesignScreen(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: AwaitDesignScreen()),
                  ),
                  GoRoute(
                    path: '/BioScreen',
                    builder: (context, state) => BioScreen(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: BioScreen()),
                  ),
                  GoRoute(
                    path: '/GenderScreen',
                    builder: (context, state) => GenderScreen(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: GenderScreen()),
                  ),
                  GoRoute(
                    path: '/PermissionsHomepage',
                    builder: (context, state) =>
                        PermissionsHomepage(user: state.extra as VAppUser),
                    pageBuilder: (context, state) => CupertinoPage(
                        child:
                            PermissionsHomepage(user: state.extra as VAppUser)),
                  ),
                  GoRoute(
                    path: '/CreatePaymentPage',
                    builder: (context, state) => CreatePaymentPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: CreatePaymentPage()),
                  ),
                  GoRoute(
                    path: '/CurrencyPage',
                    builder: (context, state) => CurrencyPage(),
                    pageBuilder: (context, state) =>
                        CupertinoPage(child: CurrencyPage()),
                  ),
                ]),
          ]),
      GoRoute(
        path: '/ProfileRingPage',
        builder: (context, state) => ProfileRing(),
        pageBuilder: (context, state) => CupertinoPage(child: ProfileRing()),
      ),
      GoRoute(
        path: Routes.createJobFirstPage,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return CreateJobFirstPage(
            isEdit: state.pathParameters['isEdit'] == "false" ||
                    state.pathParameters['isEdit'] == false
                ? false
                : true,
          );
        },
        pageBuilder: (context, state) => CupertinoPage(
            child: CreateJobFirstPage(
          isEdit: state.pathParameters['isEdit'] == "false" ||
                  state.pathParameters['isEdit'] == false
              ? false
              : true,
        )),
      ),
      GoRoute(
        path: Routes.createJobSecondPage,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          return CreateJobSecondPage(
            isEdit: state.pathParameters['isEdit'] == "false" ||
                    state.pathParameters['isEdit'] == false
                ? false
                : true,
            jobType: state.pathParameters['jobType'] ?? 'Remote',
          );
        },
        pageBuilder: (context, state) => CupertinoPage(
            child: CreateJobSecondPage(
          isEdit: state.pathParameters['isEdit'] == "false" ||
                  state.pathParameters['isEdit'] == false
              ? false
              : true,
          jobType: state.pathParameters['jobType'] ?? 'Remote',
        )),
      ),
      GoRoute(
        path: '/createOffer',
        builder: (context, state) => CreateOffer(),
        pageBuilder: (context, state) => CupertinoPage(child: CreateOffer()),
      ),
      GoRoute(
        path:
            '/messagesChatScreen/:id/:username/:profilePicture/:profileThumbnailUrl/:label',
        // parentNavigatorKey: _profileNavigatorKey,
        builder: (context, state) => MessagesChatScreen(
          id: int.parse(state.pathParameters['id']!),
          username: state.pathParameters['username']!,
          profilePicture: state.pathParameters['profilePicture'],
          profileThumbnailUrl: state.pathParameters['profileThumbnailUrl'],
          label: state.pathParameters['label'],
          deep: (state.extra as MessageRouteModel).deep,
          messages: (state.extra as MessageRouteModel).messages,
        ),
        pageBuilder: (context, state) => CupertinoPage(
            child: MessagesChatScreen(
          id: int.parse(state.pathParameters['id']!),
          username: state.pathParameters['username']!,
          profilePicture: state.pathParameters['profilePicture'],
          profileThumbnailUrl: state.pathParameters['profileThumbnailUrl'],
          label: state.pathParameters['label'],
          deep: (state.extra as MessageRouteModel).deep,
          messages: (state.extra as MessageRouteModel).messages,
        )),
      ),

      GoRoute(
        path: '/create_service_route',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CreateServicePage(
          servicePackage: null,
        ),
        pageBuilder: (context, state) => CupertinoPage(
            child: CreateServicePage(
          servicePackage: null,
        )),
      ),
      GoRoute(
        path: '/create_live_class',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CreateLiveClass(),
        pageBuilder: (context, state) => CupertinoPage(
          child: CreateLiveClass(),
        ),
      ),
      GoRoute(
        path: '/add_coupons',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => AddNewCouponHomepage(context),
        pageBuilder: (context, state) =>
            CupertinoPage(child: AddNewCouponHomepage(context)),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => SplashView(),
        pageBuilder: (context, state) => CupertinoPage(child: SplashView()),
      ),
      GoRoute(
        path: '/walkThoughScreen',
        builder: (context, state) => WalkThoughScreen(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: WalkThoughScreen()),
      ),
      GoRoute(
        path: '/sign_in',
        builder: (context, state) => LoginPage(),
        pageBuilder: (context, state) => CupertinoPage(child: LoginPage()),
      ),
      GoRoute(
        path: '/sign_up',
        builder: (context, state) => SignUpPage(),
        pageBuilder: (context, state) => CupertinoPage(child: SignUpPage()),
      ),
      GoRoute(
        path: '/new_user_onboarding',
        builder: (context, state) => UserOnBoardingPage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: UserOnBoardingPage()),
      ),
      GoRoute(
        path: '/login_screen',
        builder: (context, state) => OnBoardingPage(),
        pageBuilder: (context, state) => CupertinoPage(child: OnBoardingPage()),
      ),
      GoRoute(
        path: '/birthday_setting',
        builder: (context, state) => BirthdaySetting(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: BirthdaySetting()),
      ),
      GoRoute(
        path: '/birthday_view',
        builder: (context, state) => OnboardingBirthday(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: OnboardingBirthday()),
      ),
      GoRoute(
        path: '/location_set_up',
        builder: (context, state) => SignUpLocationViews(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: SignUpLocationViews()),
      ),
      GoRoute(
        path: '/reset_password_provider',
        builder: (context, state) => ForgotPasswordView(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: ForgotPasswordView()),
      ),
      GoRoute(
        path: '/verify_2fa_otp',
        builder: (context, state) => Verify2FAOtp(),
        pageBuilder: (context, state) => CupertinoPage(child: Verify2FAOtp()),
      ),
      GoRoute(
        path: '/UserVerificationScreen',
        builder: (context, state) => UserVerificationScreen(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: UserVerificationScreen()),
      ),
      GoRoute(
        path: '/onboardingAddress',
        builder: (context, state) => OnboardingAddress(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: OnboardingAddress()),
      ),
      GoRoute(
        path: '/onboardingEmail',
        builder: (context, state) => OnboardingEmail(
            selectedIndustry: state.pathParameters['selectedIndustry']!),
        pageBuilder: (context, state) => CupertinoPage(
            child: OnboardingEmail(
                selectedIndustry: state.pathParameters['selectedIndustry']!)),
      ),
      GoRoute(
        path: '/onboardingEmail/:selectedIndustry',
        builder: (context, state) => OnboardingEmail(
            selectedIndustry: state.pathParameters['selectedIndustry']!),
        pageBuilder: (context, state) => CupertinoPage(
            child: OnboardingEmail(
                selectedIndustry: state.pathParameters['selectedIndustry']!)),
      ),
      GoRoute(
        path: '/onboardingLocation',
        builder: (context, state) => OnboardingLocation(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: OnboardingLocation()),
      ),
      GoRoute(
        path: '/onboardingName',
        builder: (context, state) => OnboardingName(
            selectedIndustry: state.pathParameters['selectedIndustry']!),
        pageBuilder: (context, state) => CupertinoPage(
            child: OnboardingName(
                selectedIndustry: state.pathParameters['selectedIndustry']!)),
      ),
      GoRoute(
        path: '/onboardingAddressPage',
        builder: (context, state) => OnboardingAddressPage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: OnboardingAddressPage()),
      ),
      GoRoute(
        path: '/onboardingEmailPage',
        builder: (context, state) => OnboardingEmailPage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: OnboardingEmailPage()),
      ),
      GoRoute(
        path: '/onboardingNamePage',
        builder: (context, state) => OnboardingNamePage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: OnboardingNamePage()),
      ),
      GoRoute(
        path: '/onboardingPhotoPage',
        builder: (context, state) => OnboardingPhotoPage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: OnboardingPhotoPage()),
      ),
      GoRoute(
        path: '/onboardingPhone',
        builder: (context, state) => OnboardingPhone(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: OnboardingPhone()),
      ),
      GoRoute(
        path: '/signup-display-name',
        builder: (context, state) => SignUpDisplayNameSetup(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: SignUpDisplayNameSetup()),
      ),
      GoRoute(
        path: '/onboarding-profile-ring',
        builder: (context, state) => OnboardingProfileRing(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: OnboardingProfileRing()),
      ),
      GoRoute(
        path: '/signup-upload-photo',
        builder: (context, state) => SignUpUploadPhotoPage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: SignUpUploadPhotoPage()),
      ),
      GoRoute(
        path: '/signup-select-user-type',
        builder: (context, state) => SignUpSelectUserTypeView(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: SignUpSelectUserTypeView()),
      ),
      GoRoute(
        path: '/signup-bio-setup',
        builder: (context, state) => SignUpBioSetup(),
        pageBuilder: (context, state) => CupertinoPage(child: SignUpBioSetup()),
      ),
      GoRoute(
        path: '/auth_widget',
        builder: (context, state) => AuthWidgetPage(),
        pageBuilder: (context, state) => CupertinoPage(child: AuthWidgetPage()),
        // redirect: (context, state) async {
        //   // final getToken = await VCredentials.inst.getUserCredentials();
        //   // final getUsername = await VCredentials.inst.getUsername();
        //   // if (getToken != null && getUsername != null) {
        //   //   return '/feedMainUI';
        //   // }else{
        //   //   return '/login_screen';
        //   // }
        //
        //   final tto = vRef.ref!.watch(authenticationStatusProvider);
        //
        //   return tto.maybeWhen(
        //     data: (status) {
        //     print(status);
        //       switch (status) {
        //         case AuthStatus.authenticated:
        //           return '/feedMainUI';
        //         case AuthStatus.firstLogin:
        //           return '/birthday_view';
        //         default:
        //           return '/login_screen';
        //       }
        //     },
        //     orElse: () => '/login_screen',
        //   );
        //
        // },
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => Analytics(),
        pageBuilder: (context, state) => CupertinoPage(child: Analytics()),
      ),

      GoRoute(
        path: '/dashboard_ui',
        builder: (context, state) => DashBoardView(navigationShell: null),
        pageBuilder: (context, state) => CupertinoPage(
            child: DashBoardView(
          navigationShell: null,
        )),
      ),
      GoRoute(
        path: '/phoneVerificationCodePage',
        builder: (context, state) => PhoneVerificationCodePage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: PhoneVerificationCodePage()),
      ),
      GoRoute(
        path: '/phoneVerificationPage',
        builder: (context, state) => PhoneVerificationPage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: PhoneVerificationPage()),
      ),
      GoRoute(
        path: '/SignupView',
        builder: (context, state) => SignupView(),
        pageBuilder: (context, state) => CupertinoPage(child: SignupView()),
      ),
      GoRoute(
        path: '/createPasswordLink/:link',
        builder: (context, state) => CreatePasswordView(
          link: state.extra as String?,
        ),
        pageBuilder: (context, state) =>
            CupertinoPage(child: CreatePasswordView()),
      ),
      GoRoute(
        path: '/createPasswordView/:otpCode',
        builder: (context, state) => otpCreatePassword.CreatePasswordView(
          otpCode: state.pathParameters['otpCode'] ?? "",
        ),
        pageBuilder: (context, state) => CupertinoPage(
            child: otpCreatePassword.CreatePasswordView(
          otpCode: state.pathParameters['otpCode'] ?? "",
        )),
      ),
      GoRoute(
        path: '/confirmPasswordReset/:otpCode',
        builder: (context, state) => ConfirmPasswordResetPage(
          otpCode: state.pathParameters['otpCode'] ?? "",
        ),
        pageBuilder: (context, state) => CupertinoPage(
            child: ConfirmPasswordResetPage(
          otpCode: state.pathParameters['otpCode'] ?? "",
        )),
      ),
      GoRoute(
        path: '/createPostWithImagesMediaPicker',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CreatePostWithImagesMediaPicker(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: CreatePostWithImagesMediaPicker()),
      ),

      //NOT USED ROUTES
      //NOT USED ROUTES
      //NOT USED ROUTES
      GoRoute(
        path: '/marketplaceHome',
        builder: (context, state) => MarketplaceHome(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: MarketplaceHome()),
      ),
      GoRoute(
        path: '/job_market_homepage',
        builder: (context, state) => JobMarketHomepage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: JobMarketHomepage()),
      ),
      GoRoute(
        path: '/business_offers_details_page',
        builder: (context, state) => BusinessOfferDetailsPage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: BusinessOfferDetailsPage()),
      ),
      GoRoute(
        path: '/coupons',
        builder: (context, state) => Coupons(),
        pageBuilder: (context, state) => CupertinoPage(child: Coupons()),
      ),
      GoRoute(
        path: '/businessMyJobsPageMarketplace',
        builder: (context, state) => BusinessMyJobsPageMarketplace(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: BusinessMyJobsPageMarketplace()),
      ),
      GoRoute(
        path: '/businessOffersPage',
        builder: (context, state) => BusinessOffersPage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: BusinessOffersPage()),
      ),
      GoRoute(
        path: '/jobMarketFilterBottomSheet',
        builder: (context, state) => JobMarketFilterBottomSheet(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: JobMarketFilterBottomSheet()),
      ),
      GoRoute(
        path: '/bookerJobDetailsPage',
        builder: (context, state) => BookerJobDetailsPage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: BookerJobDetailsPage()),
      ),
      GoRoute(
        path: '/jobDetailPageUpdated',
        builder: (context, state) => JobDetailPageUpdated(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: JobDetailPageUpdated()),
      ),
      GoRoute(
        path: '/jobDetails',
        builder: (context, state) => JobDetails(),
        pageBuilder: (context, state) => CupertinoPage(child: JobDetails()),
      ),

      GoRoute(
        path: '/jobMarketOfferAccepted',
        builder: (context, state) => JobMarketOfferAccepted(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: JobMarketOfferAccepted()),
      ),
      GoRoute(
        path: '/splashView',
        builder: (context, state) => SplashView(),
        pageBuilder: (context, state) => CupertinoPage(child: SplashView()),
      ),
      GoRoute(
        path: '/ConnectionsSettingsPage',
        builder: (context, state) => ConnectionsSettingsPage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: ConnectionsSettingsPage()),
      ),
      GoRoute(
        path: '/viewFullVideoPage/:videoUrl',
        builder: (context, state) =>
            ViewFullVideoPage(state.pathParameters['videoUrl']!),
        pageBuilder: (context, state) => CupertinoPage(
            child: ViewFullVideoPage(state.pathParameters['videoUrl']!)),
      ),
      GoRoute(
        path: '/loginView',
        builder: (context, state) => LoginView(),
        pageBuilder: (context, state) => CupertinoPage(child: LoginView()),
      ),
      GoRoute(
        path: '/networkPageSearch',
        builder: (context, state) => NetworkPageSearch(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: NetworkPageSearch()),
      ),
      GoRoute(
        path: '/uploadVideoPostPage/:videoFile',
        builder: (context, state) => UploadVideoPostPage(
            videoFile: json.decode(state.pathParameters['videoFile']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: UploadVideoPostPage(
                videoFile: json.decode(state.pathParameters['videoFile']!))),
      ),
      GoRoute(
        path: '/mapSearch',
        builder: (context, state) => MapSearch(),
        pageBuilder: (context, state) => CupertinoPage(child: MapSearch()),
      ),
      GoRoute(
        path: '/mostViewdAlbum',
        builder: (context, state) => MostViewdAlbum(),
        pageBuilder: (context, state) => CupertinoPage(child: MostViewdAlbum()),
      ),
      GoRoute(
        path: '/feedAfterWidget/:canLoadMore',
        builder: (context, state) => FeedAfterWidget(
            canLoadMore:
                state.pathParameters['canLoadMore'] == 'true' ? true : false),
        pageBuilder: (context, state) => CupertinoPage(
            child: FeedAfterWidget(
                canLoadMore: state.pathParameters['canLoadMore'] == 'true'
                    ? true
                    : false)),
      ),
      GoRoute(
        path: '/vModelMaps',
        builder: (context, state) => VModelMaps(),
        pageBuilder: (context, state) => CupertinoPage(child: VModelMaps()),
      ),
      GoRoute(
        path: '/newPostPolaroidView/:shouldHaveBackButton',
        builder: (context, state) => NewPostPolaroidView(
          shouldHaveBackButton:
              state.pathParameters['shouldHaveBackButton'] == 'true'
                  ? true
                  : false,
        ),
        pageBuilder: (context, state) => CupertinoPage(
            child: NewPostPolaroidView(
          shouldHaveBackButton:
              state.pathParameters['shouldHaveBackButton'] == 'true'
                  ? true
                  : false,
        )),
      ),
      // END NOT USED ROUTES
      // END NOT USED ROUTES
      // END NOT USED ROUTES

      // FOLLOWING ROUTES SHOULD NOT BE ROUTES
      // FOLLOWING ROUTES SHOULD NOT BE ROUTES
      // FOLLOWING ROUTES SHOULD NOT BE ROUTES
      GoRoute(
        path: '/vWidgetsBackButton',
        builder: (context, state) => VWidgetsBackButton(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: VWidgetsBackButton()),
      ),
      GoRoute(
        path: '/searchTextFieldWidget',
        builder: (context, state) => SearchTextFieldWidget(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: SearchTextFieldWidget()),
      ),
      GoRoute(
        path: '/editPostPage/:postId/:images',
        builder: (context, state) => EditPostPage(
            postId: int.parse(state.pathParameters['postId']!),
            images: json.decode(state.pathParameters['images']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: EditPostPage(
                postId: int.parse(state.pathParameters['postId']!),
                images: json.decode(state.pathParameters['images']!))),
      ),
      GoRoute(
        path: '/createPostWithCameraPicker/:cameraPath',
        builder: (context, state) => CreatePostWithCameraPicker(
            cameraImage: File(state.pathParameters['cameraPath'] ?? '')),
        pageBuilder: (context, state) => CupertinoPage(
            child: CreatePostWithCameraPicker(
                cameraImage: File(state.pathParameters['cameraPath'] ?? ''))),
      ),
      GoRoute(
        path: '/vWidgetsModalPill',
        builder: (context, state) => VWidgetsModalPill(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: VWidgetsModalPill()),
      ),
      GoRoute(
        path: '/displayBoards/:boardWidget',
        builder: (context, state) => DisplayBoards(
            boardWidget: json.decode(state.pathParameters['boardWidget']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: DisplayBoards(
                boardWidget:
                    json.decode(state.pathParameters['boardWidget']!))),
      ),
      GoRoute(
        path: '/vWidgetsAppBar',
        builder: (context, state) => VWidgetsAppBar(),
        pageBuilder: (context, state) => CupertinoPage(child: VWidgetsAppBar()),
      ),
      GoRoute(
        path: '/roundedSquareAvatar/:thumbnail/:url',
        builder: (context, state) => RoundedSquareAvatar(
            url: state.pathParameters['url'],
            thumbnail: state.pathParameters['thumbnail']),
        pageBuilder: (context, state) => CupertinoPage(
            child: RoundedSquareAvatar(
                url: state.pathParameters['url'],
                thumbnail: state.pathParameters['thumbnail'])),
      ),
      GoRoute(
        path: '/renderSvg/:svgPath/:svgHeight/:svgWidth',
        builder: (context, state) => RenderSvg(
          svgPath: state.pathParameters['svgPath']!,
          svgHeight: double.parse(state.pathParameters['svgHeight']!),
          svgWidth: double.parse(state.pathParameters['svgWidth']!),
        ),
        pageBuilder: (context, state) => CupertinoPage(
          child: RenderSvg(
            svgPath: state.pathParameters['svgPath']!,
            svgHeight: double.parse(state.pathParameters['svgHeight']!),
            svgWidth: double.parse(state.pathParameters['svgWidth']!),
          ),
        ),
      ),
      GoRoute(
        path: '/textOverlayedImage/:imageUrl/:onTap/:onLongPress/:title',
        builder: (context, state) => TextOverlayedImage(
            imageUrl: json.decode(state.pathParameters['imageUrl']!),
            onTap: json.decode(state.pathParameters['onTap']!),
            onLongPress: json.decode(state.pathParameters['onLongPress']!),
            title: json.decode(state.pathParameters['title']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: TextOverlayedImage(
                imageUrl: json.decode(state.pathParameters['imageUrl']!),
                onTap: json.decode(state.pathParameters['onTap']!),
                onLongPress: json.decode(state.pathParameters['onLongPress']!),
                title: json.decode(state.pathParameters['title']!))),
      ),
      GoRoute(
        path: '/vWidgetsAppBarTitleText/:titleText',
        builder: (context, state) => VWidgetsAppBarTitleText(
            titleText: state.pathParameters['titleText']),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsAppBarTitleText(
                titleText: state.pathParameters['titleText'])),
      ),
      GoRoute(
        path: '/vWidgetsConfirmationBottomSheet',
        builder: (context, state) => VWidgetsConfirmationBottomSheet(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: VWidgetsConfirmationBottomSheet()),
      ),
      GoRoute(
        path: '/detailBottomSheet',
        builder: (context, state) => DetailBottomSheet(
            title: state.pathParameters['title']!,
            content: json.decode(state.pathParameters['title']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: DetailBottomSheet(
                title: state.pathParameters['title']!,
                content: json.decode(state.pathParameters['title']!))),
      ),
      GoRoute(
        path: '/VWidgetsInputBottomSheet/:controller',
        builder: (context, state) => VWidgetsInputBottomSheet(
            controller: json.decode(state.pathParameters['controller']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsInputBottomSheet(
                controller: json.decode(state.pathParameters['controller']!))),
      ),
      GoRoute(
        path: '/vWidgetsConfirmationWithPictureBottomSheet',
        builder: (context, state) => VWidgetsConfirmationWithPictureBottomSheet(
            username: state.pathParameters['username']!,
            profilePictureUrl: state.pathParameters['profilePictureUrl']!,
            profileThumbnailUrl: state.pathParameters['profileThumbnailUrl']!,
            dialogMessage: state.pathParameters['dialogMessage']!),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsConfirmationWithPictureBottomSheet(
                username: state.pathParameters['username']!,
                profilePictureUrl: state.pathParameters['profilePictureUrl']!,
                profileThumbnailUrl:
                    state.pathParameters['profileThumbnailUrl']!,
                dialogMessage: state.pathParameters['dialogMessage']!)),
      ),
      GoRoute(
        path: '/vWidgetsBottomSheetTile/:onTap/:message',
        builder: (context, state) => VWidgetsBottomSheetTile(
            onTap: json.decode(state.pathParameters['onTap']!),
            message: state.pathParameters['message']!),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsBottomSheetTile(
                onTap: json.decode(state.pathParameters['onTap']!),
                message: state.pathParameters['message']!)),
      ),
      GoRoute(
        path: '/vWidgetsCategoryButton/:isSelected/:text/:onPressed',
        builder: (context, state) => VWidgetsCategoryButton(
            isSelected: json.decode(state.pathParameters['isSelected']!),
            text: json.decode(state.pathParameters['text']!),
            onPressed: json.decode(state.pathParameters['onPressed']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsCategoryButton(
                isSelected: json.decode(state.pathParameters['isSelected']!),
                text: json.decode(state.pathParameters['text']!),
                onPressed: json.decode(state.pathParameters['onPressed']!))),
      ),
      GoRoute(
        path: '/vCupertinoActionSheet/:text',
        builder: (context, state) =>
            VCupertinoActionSheet(text: state.pathParameters['text']!),
        pageBuilder: (context, state) => CupertinoPage(
            child: VCupertinoActionSheet(text: state.pathParameters['text']!)),
      ),
      GoRoute(
        path: '/vWidgetsDatePickerUI',
        builder: (context, state) => VWidgetsDatePickerUI(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: VWidgetsDatePickerUI()),
      ),
      GoRoute(
        path: '/discardDialog',
        builder: (context, state) => DiscardDialog(),
        pageBuilder: (context, state) => CupertinoPage(child: DiscardDialog()),
      ),
      GoRoute(
        path: '/vWidgetsPictureAvataStyle/:imagePath/:imageHeight/:imageWidth',
        builder: (context, state) => VWidgetsPictureAvataStyle(
            imagePath: json.decode(state.pathParameters['separatorBuilder']!),
            imageHeight: json.decode(state.pathParameters['separatorBuilder']!),
            imageWidth: json.decode(state.pathParameters['separatorBuilder']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsPictureAvataStyle(
                imagePath:
                    json.decode(state.pathParameters['separatorBuilder']!),
                imageHeight:
                    json.decode(state.pathParameters['separatorBuilder']!),
                imageWidth:
                    json.decode(state.pathParameters['separatorBuilder']!))),
      ),
      GoRoute(
        path: '/vWidgetsAddImageWidget',
        builder: (context, state) => VWidgetsAddImageWidget(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: VWidgetsAddImageWidget()),
      ),
      GoRoute(
        path: '/roundedSquareAvatar/:url/:thumbnail',
        builder: (context, state) => RoundedSquareAvatar(
            url: json.decode(state.pathParameters['url']!),
            thumbnail: json.decode(state.pathParameters['thumbnail']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: RoundedSquareAvatar(
                url: json.decode(state.pathParameters['url']!),
                thumbnail: json.decode(state.pathParameters['thumbnail']!))),
      ),
      GoRoute(
        path: '/roundedSquareAvatarAsset/:img',
        builder: (context, state) => RoundedSquareAvatarAsset(
            img: json.decode(state.pathParameters['img']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: RoundedSquareAvatarAsset(
                img: json.decode(state.pathParameters['img']!))),
      ),
      GoRoute(
        path: '/VWidgetNetworkImage/:url',
        builder: (context, state) =>
            VWidgetNetworkImage(url: state.pathParameters['url']),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetNetworkImage(url: state.pathParameters['url'])),
      ),
      GoRoute(
        path:
            '/vWidgetsConfirmationPopUp/:popupTitle/:popupDescription/:onPressedYes/:onPressedNo',
        builder: (context, state) => VWidgetsConfirmationPopUp(
            popupTitle: json.decode(state.pathParameters['popupTitle']!),
            popupDescription:
                json.decode(state.pathParameters['popupDescription']!),
            onPressedYes: json.decode(state.pathParameters['onPressedYes']!),
            onPressedNo: json.decode(state.pathParameters['onPressedNo']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsConfirmationPopUp(
                popupTitle: json.decode(state.pathParameters['popupTitle']!),
                popupDescription:
                    json.decode(state.pathParameters['popupDescription']!),
                onPressedYes:
                    json.decode(state.pathParameters['onPressedYes']!),
                onPressedNo:
                    json.decode(state.pathParameters['onPressedNo']!))),
      ),
      GoRoute(
        path:
            '/vWidgetsCustomisablePopUp/:popupTitle/:popupDescription/:onPressed2/onPressed1/:option1/:option2',
        builder: (context, state) => VWidgetsCustomisablePopUp(
          popupTitle: json.decode(state.pathParameters['popupTitle']!),
          popupDescription:
              json.decode(state.pathParameters['popupDescription']!),
          onPressed1: json.decode(state.pathParameters['onPressed1']!),
          onPressed2: json.decode(state.pathParameters['onPressed2']!),
          option1: json.decode(state.pathParameters['option1']!),
          option2: json.decode(state.pathParameters['option2']!),
        ),
        pageBuilder: (context, state) => CupertinoPage(
          child: VWidgetsCustomisablePopUp(
            popupTitle: json.decode(state.pathParameters['popupTitle']!),
            popupDescription:
                json.decode(state.pathParameters['popupDescription']!),
            onPressed1: json.decode(state.pathParameters['onPressed1']!),
            onPressed2: json.decode(state.pathParameters['onPressed2']!),
            option1: json.decode(state.pathParameters['option1']!),
            option2: json.decode(state.pathParameters['option2']!),
          ),
        ),
      ),
      GoRoute(
        path: '/vWidgetsInputPopUp/:popupTitle/:popupField/:onPressedYes',
        builder: (context, state) => VWidgetsInputPopUp(
            popupTitle: json.decode(state.pathParameters['popupTitle']!),
            popupField: json.decode(state.pathParameters['popupField']!),
            onPressedYes: json.decode(state.pathParameters['onPressedYes']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsInputPopUp(
                popupTitle: json.decode(state.pathParameters['popupTitle']!),
                popupField: json.decode(state.pathParameters['popupField']!),
                onPressedYes:
                    json.decode(state.pathParameters['onPressedYes']!))),
      ),
      GoRoute(
        path: '/vWidgetsPopUpWithoutSaveButton',
        builder: (context, state) => VWidgetsPopUpWithoutSaveButton(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: VWidgetsPopUpWithoutSaveButton()),
      ),
      GoRoute(
        path: '/popupWrapper',
        builder: (context, state) => PopupWrapper(
          child: json.decode(state.pathParameters['child']!),
          popup: json.decode(state.pathParameters['popup']!),
        ),
        pageBuilder: (context, state) => CupertinoPage(
          child: PopupWrapper(
            child: json.decode(state.pathParameters['child']!),
            popup: json.decode(state.pathParameters['popup']!),
          ),
        ),
      ),
      GoRoute(
        path: '/vWidgetsAddAlbumPopUp',
        builder: (context, state) => VWidgetsAddAlbumPopUp(
            onPressed: json.decode(state.pathParameters['onPressed']!),
            controller: json.decode(state.pathParameters['controller']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsAddAlbumPopUp(
                onPressed: json.decode(state.pathParameters['onPressed']!),
                controller: json.decode(state.pathParameters['controller']!))),
      ),
      GoRoute(
        path: '/renderSvg/:svgPath',
        builder: (context, state) =>
            RenderSvg(svgPath: state.pathParameters['svgPath']!),
        pageBuilder: (context, state) => CupertinoPage(
            child: RenderSvg(svgPath: state.pathParameters['svgPath']!)),
      ),
      GoRoute(
        path: '/createdSuccessDialogue',
        builder: (context, state) => CreatedSuccessDialogue(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: CreatedSuccessDialogue()),
      ),
      GoRoute(
        path:
            '/vWidgetsRangeSlider/:sliderMaxValue/:sliderMinValue/:sliderValue/:onChanged',
        builder: (context, state) => VWidgetsRangeSlider(
            sliderMaxValue:
                json.decode(state.pathParameters['sliderMaxValue']!),
            sliderMinValue:
                json.decode(state.pathParameters['sliderMinValue']!),
            sliderValue: json.decode(state.pathParameters['sliderValue']!),
            onChanged: json.decode(state.pathParameters['onChanged']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsRangeSlider(
                sliderMaxValue:
                    json.decode(state.pathParameters['sliderMaxValue']!),
                sliderMinValue:
                    json.decode(state.pathParameters['sliderMinValue']!),
                sliderValue: json.decode(state.pathParameters['sliderValue']!),
                onChanged: json.decode(state.pathParameters['onChanged']!))),
      ),
      GoRoute(
        path:
            '/vWidgetsTabs/:tabItems/:containerHeight/containerWidth:/:tabBarHeight/:tabViewHeight/:tabViews',
        builder: (context, state) => VWidgetsTabs(
            tabItems: json.decode(state.pathParameters['tabItems']!),
            containerHeight:
                json.decode(state.pathParameters['containerHeight']!),
            containerWidth:
                json.decode(state.pathParameters['containerWidth']!),
            tabBarHeight: json.decode(state.pathParameters['tabBarHeight']!),
            tabViewHeight: json.decode(state.pathParameters['tabViewHeight']!),
            tabViews: json.decode(state.pathParameters['tabViews']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsTabs(
                tabItems: json.decode(state.pathParameters['tabItems']!),
                containerHeight:
                    json.decode(state.pathParameters['containerHeight']!),
                containerWidth:
                    json.decode(state.pathParameters['containerWidth']!),
                tabBarHeight:
                    json.decode(state.pathParameters['tabBarHeight']!),
                tabViewHeight:
                    json.decode(state.pathParameters['tabViewHeight']!),
                tabViews: json.decode(state.pathParameters['tabViews']!))),
      ),
      GoRoute(
        path: '/vWidgetsCarouselIndicator',
        builder: (context, state) => VWidgetsCarouselIndicator(
            currentIndex: json.decode(state.pathParameters['currentIndex']!),
            totalIndicators:
                json.decode(state.pathParameters['totalIndicators']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsCarouselIndicator(
                currentIndex:
                    json.decode(state.pathParameters['currentIndex']!),
                totalIndicators:
                    json.decode(state.pathParameters['totalIndicators']!))),
      ),
      GoRoute(
        path: '/sectionContainer/:child/:topRadius/:bottomRadius',
        builder: (context, state) => SectionContainer(
          child: json.decode(state.pathParameters['child']!),
          topRadius: json.decode(state.pathParameters['topRadius']!),
          bottomRadius: json.decode(state.pathParameters['bottomRadius']!),
        ),
        pageBuilder: (context, state) => CupertinoPage(
          child: SectionContainer(
            child: json.decode(state.pathParameters['child']!),
            topRadius: json.decode(state.pathParameters['topRadius']!),
            bottomRadius: json.decode(state.pathParameters['bottomRadius']!),
          ),
        ),
      ),
      GoRoute(
        path:
            '/VWidgetsProfileBio/:extendedbioInfo/:onPressedIcon/:mainBioInfo/:imgLink/:key',
        builder: (context, state) => VWidgetsProfileBio(
            extendedbioInfo:
                json.decode(state.pathParameters['extendedbioInfo']!),
            onPressedIcon: json.decode(state.pathParameters['onPressedIcon']!),
            mainBioInfo: json.decode(state.pathParameters['mainBioInfo']!),
            imgLink: json.decode(state.pathParameters['imgLink']!),
            key: json.decode(state.pathParameters['key']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsProfileBio(
                extendedbioInfo:
                    json.decode(state.pathParameters['extendedbioInfo']!),
                onPressedIcon:
                    json.decode(state.pathParameters['onPressedIcon']!),
                mainBioInfo: json.decode(state.pathParameters['mainBioInfo']!),
                imgLink: json.decode(state.pathParameters['imgLink']!),
                key: json.decode(state.pathParameters['key']!))),
      ),
      GoRoute(
        path: '/checkOutInfo/:',
        builder: (context, state) => CheckOutInfo(),
        pageBuilder: (context, state) => CupertinoPage(child: CheckOutInfo()),
      ),
      GoRoute(
        path: '/vWidgetsProfileSubInfoDetails',
        builder: (context, state) => VWidgetsProfileSubInfoDetails(
            stars: json.decode(state.pathParameters['stars']!),
            userName: json.decode(state.pathParameters['userName']!),
            address: json.decode(state.pathParameters['address']!),
            budget: json.decode(state.pathParameters['budget']!),
            companyUrl: json.decode(state.pathParameters['companyUrl']!),
            onPressedCompanyURL:
                json.decode(state.pathParameters['onPressedCompanyURL']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsProfileSubInfoDetails(
                stars: json.decode(state.pathParameters['stars']!),
                userName: json.decode(state.pathParameters['userName']!),
                address: json.decode(state.pathParameters['address']!),
                budget: json.decode(state.pathParameters['budget']!),
                companyUrl: json.decode(state.pathParameters['companyUrl']!),
                onPressedCompanyURL:
                    json.decode(state.pathParameters['onPressedCompanyURL']!))),
      ),
      GoRoute(
        path: '/connectionShimmerPage',
        builder: (context, state) => ConnectionShimmerPage(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: ConnectionShimmerPage()),
      ),
      GoRoute(
        path: '/emptySearchResultsWidget',
        builder: (context, state) => EmptySearchResultsWidget(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: EmptySearchResultsWidget()),
      ),
      GoRoute(
        path:
            '/vWidgetsLocalBusinessProfileButtons/:bookNowOnPressed/:topPicksOnPressed/:messagesOnPressed/:onNetworkPressed/:socialAccoutsOnPressed/:socialAccoutsLongPressed',
        builder: (context, state) => VWidgetsLocalBusinessProfileButtons(
            bookNowOnPressed:
                json.decode(state.pathParameters['bookNowOnPressed']!),
            topPicksOnPressed:
                json.decode(state.pathParameters['topPicksOnPressed']!),
            messagesOnPressed:
                json.decode(state.pathParameters['messagesOnPressed']!),
            onNetworkPressed:
                json.decode(state.pathParameters['onNetworkPressed']!),
            socialAccoutsOnPressed:
                json.decode(state.pathParameters['socialAccoutsOnPressed']!),
            socialAccoutsLongPressed:
                json.decode(state.pathParameters['socialAccoutsLongPressed']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsLocalBusinessProfileButtons(
                bookNowOnPressed:
                    json.decode(state.pathParameters['bookNowOnPressed']!),
                topPicksOnPressed:
                    json.decode(state.pathParameters['topPicksOnPressed']!),
                messagesOnPressed:
                    json.decode(state.pathParameters['messagesOnPressed']!),
                onNetworkPressed:
                    json.decode(state.pathParameters['onNetworkPressed']!),
                socialAccoutsOnPressed: json
                    .decode(state.pathParameters['socialAccoutsOnPressed']!),
                socialAccoutsLongPressed: json.decode(
                    state.pathParameters['socialAccoutsLongPressed']!))),
      ),
      GoRoute(
        path: '/localBusinessProfileHeaderWidget/username',
        builder: (context, state) => LocalBusinessProfileHeaderWidget(
            username: json.decode(state.pathParameters['username']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: LocalBusinessProfileHeaderWidget(
                username: json.decode(state.pathParameters['username']!))),
      ),
      GoRoute(
        path:
            '/vWidgetsOtherBusinessProfileButtons/:username/:connectionStatus/:messagesOnPressed/:socialAccountsOnPressed/:servicesOnPressed/:connectOnPressed/:removeOnPressed/:requestConnectOnPressed/:removeRequestOnPressed',
        builder: (context, state) => VWidgetsOtherBusinessProfileButtons(
            username: json.decode(state.pathParameters['username']!),
            connectionStatus:
                json.decode(state.pathParameters['connectionStatus']!),
            messagesOnPressed:
                json.decode(state.pathParameters['messagesOnPressed']!),
            socialAccountsOnPressed:
                json.decode(state.pathParameters['socialAccountsOnPressed']!),
            servicesOnPressed:
                json.decode(state.pathParameters['servicesOnPressed']!),
            connectOnPressed:
                json.decode(state.pathParameters['connectOnPressed']!),
            removeOnPressed:
                json.decode(state.pathParameters['removeOnPressed']!),
            requestConnectOnPressed:
                json.decode(state.pathParameters['requestConnectOnPressed']!),
            removeRequestOnPressed:
                json.decode(state.pathParameters['removeRequestOnPressed']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsOtherBusinessProfileButtons(
                username: json.decode(state.pathParameters['username']!),
                connectionStatus:
                    json.decode(state.pathParameters['connectionStatus']!),
                messagesOnPressed:
                    json.decode(state.pathParameters['messagesOnPressed']!),
                socialAccountsOnPressed: json
                    .decode(state.pathParameters['socialAccountsOnPressed']!),
                servicesOnPressed:
                    json.decode(state.pathParameters['servicesOnPressed']!),
                connectOnPressed:
                    json.decode(state.pathParameters['connectOnPressed']!),
                removeOnPressed:
                    json.decode(state.pathParameters['removeOnPressed']!),
                requestConnectOnPressed: json
                    .decode(state.pathParameters['requestConnectOnPressed']!),
                removeRequestOnPressed: json
                    .decode(state.pathParameters['removeRequestOnPressed']!))),
      ),
      GoRoute(
        path:
            '/remoteBusinessProfileHeaderWidget/:username/:connectionStatus/:connectionId/:profilePictureUrlThumbnail',
        builder: (context, state) => RemoteBusinessProfileHeaderWidget(
            username: json.decode(state.pathParameters['username']!),
            connectionStatus:
                json.decode(state.pathParameters['connectionStatus']!),
            connectionId:
                json.decode(state.pathParameters['connectionStatus']!),
            profilePictureUrlThumbnail:
                json.decode(state.pathParameters['connectionStatus']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: RemoteBusinessProfileHeaderWidget(
                username: json.decode(state.pathParameters['username']!),
                connectionStatus:
                    json.decode(state.pathParameters['connectionStatus']!),
                connectionId:
                    json.decode(state.pathParameters['connectionStatus']!),
                profilePictureUrlThumbnail:
                    json.decode(state.pathParameters['connectionStatus']!))),
      ),
      GoRoute(
        path: '/VWidgetsSettingUsersListTile',
        builder: (context, state) => VWidgetsSettingUsersListTile(
            displayName: json.decode(state.pathParameters['displayName']!),
            title: json.decode(state.pathParameters['title']!),
            profileImage: json.decode(state.pathParameters['profileImage']!),
            profileImageThumbnail:
                json.decode(state.pathParameters['profileImageThumbnail']!),
            subTitle: json.decode(state.pathParameters['subTitle']!),
            onPressedDelete:
                json.decode(state.pathParameters['onPressedDelete']!),
            isVerified: json.decode(state.pathParameters['isVerified']!),
            blueTickVerified:
                json.decode(state.pathParameters['blueTickVerified']!)),
        pageBuilder: (context, state) => CupertinoPage(
            child: VWidgetsSettingUsersListTile(
                displayName: json.decode(state.pathParameters['displayName']!),
                title: json.decode(state.pathParameters['title']!),
                profileImage:
                    json.decode(state.pathParameters['profileImage']!),
                profileImageThumbnail:
                    json.decode(state.pathParameters['profileImageThumbnail']!),
                subTitle: json.decode(state.pathParameters['subTitle']!),
                onPressedDelete:
                    json.decode(state.pathParameters['onPressedDelete']!),
                isVerified: json.decode(state.pathParameters['isVerified']!),
                blueTickVerified:
                    json.decode(state.pathParameters['blueTickVerified']!))),
      ),
      GoRoute(
        path: '/ContentFeedViewDropdownInput',
        builder: (context, state) => ContentFeedViewDropdownInput(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: ContentFeedViewDropdownInput()),
      ),
      GoRoute(
        path: '/DefaultFeedViewDropdownInput',
        builder: (context, state) => DefaultFeedViewDropdownInput(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: DefaultFeedViewDropdownInput()),
      ),

      GoRoute(
        path: '/createRequestPage',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CreateRequestFirstPage(
          user: state.extra as VAppUser?,
        ),
        pageBuilder: (context, state) => CupertinoPage(
            child: CreateRequestFirstPage(
          user: state.extra as VAppUser?,
        )),
      ),
      GoRoute(
        path: '/createRequestPage2/:jobType/:username',
        builder: (context, state) => CreateRequestPage2(
          jobType: state.pathParameters['jobType']!,
          username: state.pathParameters['username']!,
        ),
        pageBuilder: (context, state) => CupertinoPage(
            child: CreateRequestPage2(
          jobType: state.pathParameters['jobType']!,
          username: state.pathParameters['username']!,
        )),
      ),

      GoRoute(
        path: '/deleted_posts',
        builder: (context, state) => DeletedPostView(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: DeletedPostView()),
      ),

      GoRoute(
        path: '/restore_deleted_posts',
        builder: (context, state) => RestoreDeletedPostView(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: RestoreDeletedPostView()),
      ),

      GoRoute(
        path: SearchHistory.route,
        builder: (context, state) => SearchHistory(),
        pageBuilder: (context, state) => CupertinoPage(child: SearchHistory()),
      ),

      GoRoute(
        path: FavoriteHashtags.route,
        builder: (context, state) => FavoriteHashtags(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: FavoriteHashtags()),
      ),

      GoRoute(
        path: TwoFactorQRCode.route,
        builder: (context, state) => TwoFactorQRCode(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: TwoFactorQRCode()),
      ),

      GoRoute(
        path: LoginToContinueScreen.route,
        builder: (context, state) => LoginToContinueScreen(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: LoginToContinueScreen()),
      ),

      GoRoute(
        path: SmsTwoFaOtpVerificationScreen.route,
        builder: (context, state) => SmsTwoFaOtpVerificationScreen(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: SmsTwoFaOtpVerificationScreen()),
      ),

      GoRoute(
        path: EmailTwoFaOtpVerificationScreen.route,
        builder: (context, state) => EmailTwoFaOtpVerificationScreen(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: EmailTwoFaOtpVerificationScreen()),
      ),

      GoRoute(
        path: AuthAppTwoFaOtpVerificationScreen.route,
        builder: (context, state) => AuthAppTwoFaOtpVerificationScreen(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: AuthAppTwoFaOtpVerificationScreen()),
      ),

      GoRoute(
        path: EmailNotificationsScreen.route,
        builder: (context, state) => EmailNotificationsScreen(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: EmailNotificationsScreen()),
      ),

      GoRoute(
        path: PushNotificationsScreen.route,
        builder: (context, state) => PushNotificationsScreen(),
        pageBuilder: (context, state) =>
            CupertinoPage(child: PushNotificationsScreen()),
      ),
    ]);

class CreateRequestFirstPage2 {}

List<AlbumPostSetModel> galleryMap(photos) {
  return json
      .decode(photos)
      .map((e) => {AlbumPostSetModel.fromJson(e)})
      .toList();
}
