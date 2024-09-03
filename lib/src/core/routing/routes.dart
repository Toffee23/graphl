class Routes {
  static String recommendedJobs = "/recommended-jobs";
  static String remoteJobs = "/remote-jobs";
  static String allSubJobs = "/all-sub-jobs/:title";
  static String allJobs = "/all-jobs/:title";
  static String popularJobs = "/popular-jobs/:title";
  static String jobDetailUpdated = "/job-details-updated";
  static String jobDetail = "/job-details";
  static String jobBookerApplication = "/job-booker-application";
  static String createJobFirstPage = "/create-job-page-one/:isEdit";
  static String createJobSecondPage = "/create-job-page-two/:isEdit/:jobType";
  static String serviceDetail = "/service-details/:username/:isCurrentUser/:serviceId";
  static String categoryService = "/category-service/:title";
  static String otherProfileRouter = "/other-profile-router/:username";
  static String otherUserProfile = "/profile/:username";
  static String localServices = "/local-services/:title";
  static String liveLandingPage = "/live-landing-page";
  static String discoverViewV3 = "/discover-view-v3";
  static String liveClassesMarketplacePage = "/liveClassesMarketplacePage";
  static String suggestedScreen = "/suggestedScreen";
}
