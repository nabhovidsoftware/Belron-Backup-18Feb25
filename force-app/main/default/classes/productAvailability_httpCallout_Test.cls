@IsTest
public class productAvailability_httpCallout_Test {

     @IsTest
    static void getResponse() {
        Map<String, String> requestMap = new Map<String, String>{};
       HttpResponse response = productAvailablility_httpCallout.makeCallout(requestMap);
    }
}