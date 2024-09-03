import 'package:intl/intl.dart';
import 'package:vmodel/src/core/models/user.dart';

class VConstants {
  static bool isDarkMode = false;
  static VUser? logggedInUser;
  static dynamic loginReponse;
  static const double emojiOnlyMessageHugeSize = 28;
  static const double emojiOnlyMessageBigSize = 24;
  static const double emojiOnlyMessageMediumSize = 20;
  static const double normalChatMessageSize = 16;
  static const int discoverSectionItemsCount = 8;
  static const int maxServiceBannerImages = 10;
  static const double bottomPaddingForBottomSheets = 15;
  static const int maxPostHastagsAllowed = 50;
  static const int MB = 1 * 1024 * 1024;

  //Values
  static const int maxBioLength = 2000;

  static final noDecimalCurrencyFormatterGB =
      NumberFormat.simpleCurrency(locale: "en_GB", decimalDigits: 0);
  static final twoDigitsCurrencyFormatterGB =
      NumberFormat.simpleCurrency(locale: "en_GB");
  static final simpleDateFormatter = DateFormat('d MMM yyyy');
  static final simpleDateFormatterWithNoYear = DateFormat('d MMM');
  static final shortMonthOnlyFormatter = DateFormat('MMM');
  static final dayMonthDateFormatter = DateFormat('d MMMM');
  static final dayDateFormatter = DateFormat('d');
  static const String savedServicesSlidableGroupTag = "t_saved_services";

  // static const kDeliveryType = ["On-Location", "Hybrid", "Remote"];

  static const kUsageTypes = [
    'Private',
    'Commercial',
    'Social media',
    'Any',
    // 'All',
    // 'Other (please type)',
  ];

  static const kDeliveryOptions = [
//     2-3 days
// 4-7 days`
// 1-2 weeks
// 2-4 weeks
// 1-2 months
// 3 months
// 6 months
    '2-3 days',
    '4-7 days',
    '1-2 weeks',
    '2-4 weeks',
    '1-2 months',
    '3 months',
    '6 months',
    // 'On-Location',
    'Other (please specify)',
  ];

  static const kExpresssDeliveryOptions = [
    '1 hour',
    '4 hours',
    '12 hours',
    '24 hours',
    '48 hours',
    'Custom',
  ];

  static final kSserviceTiersRevision = [
    ...List.generate(11, (i) => i.toString())
  ];

  static const kUsageLengthOptions = [
    '1 week',
    '2 weeks',
    '3 weeks',
    '1 month',
    '2 months',
    '3 months',
    '4 months',
    '5 months',
    '6 months',
    '1 year',
    '2 years',
    '3 years',
    '4 years',
    '5 years',
    'Forever',
    // 'Other (please specify)',
  ];

  static const String patternedImage = 'assets/images/betaDashboardBanner.jpg';

  //Debug values
  static const assetImagesPrefix = 'assets/images';
  static const testImage =
      "https://images.unsplash.com/photo-1604514628550-37477afdf4e3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3327&q=80";
  static const testPetImage = 'https://i.imgur.com/5q9Me7Z.jpg';

  static const vellMagMockImages = [
    '$assetImagesPrefix/vell_magazine_images/vell_mag_art1.jpg',
    '$assetImagesPrefix/vell_magazine_images/vell_mag_art2.jpg',
    '$assetImagesPrefix/vell_magazine_images/vell_mag_art3.jpg',
  ];

  static const vellMagArticleLinks = [
    "https://vellmagazine.com/article/30/2",
    "https://vellmagazine.com/article/30/2",
    "https://vellmagazine.com/article/59/1",
  ];

  static const userTraits = [
    "Altruistic",
    "Artistic",
    "Bold",
    "Caring",
    "Charismatic",
    "Charming",
    "Creative",
    "Curious",
    "Energetic",
    "Enthusiastic",
    "Experimental",
    "Fact-minded",
    "Imaginative",
    "Idealist",
    "Inspiring",
    "Intellectual",
    "Innovative",
    "Kind",
    "Leader",
    "Logical",
    "Mystical",
    "Organised",
    "Perceptive",
    "Planner",
    "Poetic",
    "Popular",
    "Practical",
    "Punctual",
    "Quiet",
    "Reliable",
    "Sociable",
    "Smart",
    "Spontaneous",
    "Strategic",
    "Strong-willed",
    "Warm",
  ];

  static const userPersonalities = [
    'ISTJ',
    'INFJ',
    'INTJ',
    'ENFJ',
    'ISTP',
    'ESFJ',
    'INFP',
    'ESFP',
    'ENFP',
    'ESTP',
    'ESTJ',
    'ENTJ',
    'INTP',
    'ISFJ',
    'ENTP'
  ];

  static final platforms = [
    'Facebook',
    'Instagram',
    'Twitter',
    'Snapchat',
    'Tiktok',
    'Youtube',
    'Patreon',
    'Reddit',
    'Linkedin',
    'Pinterest',
    // 'Other'
  ];

  static final tempCategories = [
    'Modelling',
    'Photography',
    'Content Creation',
    'Event planning',
    'Beauty and Wellness',
    // 'Styling and Wardrobe',
    'Art and Design',
    'Culinary and baking',
    'Other',
  ];

  static final testImage2 = [
    "https://images.unsplash.com/photo-1604514628550-37477afdf4e3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3327&q=80",
    "https://plus.unsplash.com/premium_photo-1683910767532-3a25b821f7ae?q=80&w=2008&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "https://images.unsplash.com/photo-1626808642875-0aa545482dfb?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "https://images.unsplash.com/photo-1593696954577-ab3d39317b97?q=80&w=1933&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "https://images.unsplash.com/photo-1586810724476-c294fb7ac01b?q=80&w=1936&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "https://images.unsplash.com/photo-1628076674561-6e9a0b56f2c3?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "https://images.unsplash.com/photo-1617243876873-6cea4ea0b4eb?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "https://plus.unsplash.com/premium_photo-1684445034763-013f0525c40c?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "https://images.unsplash.com/photo-1549593076-9556c5abdc1f?q=80&w=1949&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    "https://images.unsplash.com/photo-1628924388761-d56dbb05e132?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  ];

  static final testJobImage = [
    'assets/images/job_and_services/Modelling.jpg',
    'assets/images/job_and_services/Photography.jpg',
    'assets/images/job_and_services/Content Creation.jpg',
    'assets/images/job_and_services/Event Planner.jpg',
    'assets/images/job_and_services/Stylist.jpg',
    'assets/images/job_and_services/Art.jpg',
    'assets/images/job_and_services/Chef.jpg',
    'assets/images/job_and_services/Other.jpg',
  ];

  static const List<Map<String, String>> personalityTypes = [
    {
      'title': 'ISTJ',
      'description':
          'ISTJs are practical and reliable. They value tradition and order, making them excellent organisers and detail-oriented workers.',
    },
    {
      'title': 'INFJ',
      'description':
          'INFJs are insightful and principled. They are driven by their values and passionate about making a positive impact on the world.',
    },
    {
      'title': 'INTJ',
      'description':
          'INTJs are strategic thinkers who love planning and analysing. They are independent and focus on long-term goals and innovative solutions.',
    },
    {
      'title': 'ENFJ',
      'description':
          'ENFJs are charismatic and inspiring leaders. They excel in connecting with others and driving groups towards common goals.',
    },
    {
      'title': 'ISTP',
      'description':
          'ISTPs are bold and practical. They love working with their hands and solving problems with a flexible, spontaneous approach.',
    },
    {
      'title': 'ESFJ',
      'description':
          'ESFJs are caring and sociable. They thrive in community settings and are excellent at creating harmony and cooperation.',
    },
    {
      'title': 'INFP',
      'description':
          'INFPs are idealistic and creative. They are deeply empathetic and passionate about personal values and self-expression.',
    },
    {
      'title': 'ESFP',
      'description':
          'ESFPs are energetic and fun-loving. They live in the moment and bring excitement and enthusiasm to their interactions.',
    },
    {
      'title': 'ENFP',
      'description':
          'ENFPs are imaginative and social. They are driven by their creativity and love exploring new ideas and possibilities.',
    },
    {
      'title': 'ESTP',
      'description':
          'ESTPs are dynamic and action-oriented. They excel in fast-paced environments and love taking on new challenges.',
    },
    {
      'title': 'ESTJ',
      'description':
          'ESTJs are organised and dedicated. They are natural leaders who value efficiency and clear, structured approaches.',
    },
    {
      'title': 'ENTJ',
      'description':
          'ENTJs are bold and decisive. They are strategic leaders who thrive on challenges and enjoy driving progress.',
    },
    {
      'title': 'INTP',
      'description':
          'INTPs are innovative and analytical. They love exploring complex ideas and theories, always seeking to understand how things work.',
    },
    {
      'title': 'ISFJ',
      'description':
          'ISFJs are loyal and meticulous. They are dedicated to helping others and maintaining stability and harmony in their environments.',
    },
    {
      'title': 'ENTP',
      'description':
          'ENTPs are curious and versatile. They enjoy debating ideas and exploring different perspectives to push the boundaries of what’s possible.',
    },
  ];
}
