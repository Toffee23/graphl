class CreateLiveSchema {
  static String createLiveJson = """
  mutation createLive(
  \$liveClassData:LiveClassesInput!
){
  createLiveClass(liveClassData:\$liveClassData){
    success
    message
    liveClass{
      id
    }
  }
}
  """;
}