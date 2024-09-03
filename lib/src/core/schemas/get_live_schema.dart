class GetLiveSchema {
  static String getMyLiveJson = """
  query allLiveClasses(\$search: String, \$category: String, \$duration: String, \$pageCount:Int, \$pageNumber:Int){
  allLiveClasses(
    search: \$search
    category: \$category
    duration: \$duration
    pageCount: \$pageCount
    pageNumber: \$pageNumber
  ) {
    id
    user {
      id
      lastName
      firstName
      username
      userType
      label
      email
      bio
      profilePicture
      profilePictureUrl
      gender
    }
    title
    liveType
    description
    price
    startTime
    duration
    preparation
    classDifficulty
    status
    category
    banners
    hasTimeline
    dateCreated
    lastUpdated
    isDeleted
    liveclasstimelineSet {
      id
      step
      step
      title
      description
      duration
      liveClass {
        id
        title
        description
        banners
      }
      status
      dateCreated
      lastUpdated
    }
    liveclassattendeeSet {
      id
      liveClass {
        id
        title
        description
        banners
      }
      attendee {
        id
        lastName
        firstName
        username
        userType
        label
        email
        bio
        profilePicture
        profilePictureUrl
        gender
      }
      paid
      paymentInfo {
        id
        amount
        user {
          id
          lastName
          firstName
          username
          userType
          label
          email
          bio
          profilePicture
          profilePictureUrl
          gender
        }
        liveClass {
          id
          title
          description
          banners
        }
        paymentRef
        status
        paymentMethod
        createdAt
        updatedAt
      }
    }
    liveclasspaymentSet {
      id
      amount
      user {
        id
        lastName
        firstName
        username
        userType
        label
        email
        bio
        profilePicture
        profilePictureUrl
        gender
      }
      liveClass {
        id
        title
        description
        banners
      }
      paymentRef
      status
      paymentMethod
      createdAt
      updatedAt
    }
    timelines {
      id
      step
      step
      title
      description
      duration
      liveClass {
        id
        title
        description
        banners
      }
      status
      dateCreated
      lastUpdated
    }
    attendees {
      id
      liveClass {
        id
        title
        description
        banners
      }
      attendee {
        id
        lastName
        firstName
        username
        userType
        label
        email
        bio
        profilePicture
        profilePictureUrl
        gender
      }
      paid
      paymentInfo {
        id
        amount
        user {
          id
          lastName
          firstName
          username
          userType
          label
          email
          bio
          profilePicture
          profilePictureUrl
          gender
        }
        liveClass {
          id
          title
          description
          banners
        }
        paymentRef
        status
        paymentMethod
        createdAt
        updatedAt
      }
    }
  }
  allLiveClassesTotalNumber
}
  """;
}