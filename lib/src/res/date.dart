
class DateClass{
  List<DateTime> listOfStringToListOfDate(List<String> listOfString){
    try {
      return listOfString.map((e) => DateTime.parse(e)).toList();
    }catch (e){
      return <DateTime>[];
    }
  }
}