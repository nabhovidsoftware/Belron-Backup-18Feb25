/** @description : Test class for BLN_HttpCalloutUtility.
*   @Story : FOUK-5189
*   @author: Subhamita Dutta (PwC)
*   @CreatedDate: 04/03/2024
*   @Last Modified Date:07/06/2024
*/
@isTest
private class BLN_HttpCalloutUtilityTest {
     private class MockResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String contentType = 'application/x-www-form-urlencoded';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', contentType);
            res.setBody('{"access_token": "MockAccessToken123", "expires_in": 3600}');
            res.setStatusCode(200);
            return res;
        }
    }
    

     @TestSetup
    static void testMakeCalloutWithPayloadBody() {
        
        User users= BLN_TestDataFactory.createAdminUser( 'Test User');
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
        //User adminUser = new User(
            users.ProfileId = adminProfileId;
            users.FirstName = 'PS';
            users.LastName = 'Test User';
            users.UserName = System.now().getTime() + '@test.demo';
            users.Alias = 'pstes';
            users.Email = 'test@sample.demo';
            users.EmailEncodingKey = 'UTF-8';
            users.LanguageLocaleKey = 'en_US';
            users.LocaleSidKey = 'nl_NL';
            //Role='System Administrator',
            users.TimeZoneSidKey = UserInfo.getTimeZone().getID();
            users.UserPermissionsSupportUser = true; 
        insert Users;
        
        // Test data
        String targetSystem = 'SampleSystem';
        String apiEndPoint = 'https://example.com/api/endpoint';
        String methodType = 'POST';
        Map<String, String> headerMap = new Map<String, String>{'Content-Type' => 'application/json'};
        String recordId = '001XXXXXXXXXXXXXXX';
        String payloadBody = '{"key": "value"}';
        
      
       Test.startTest();
        
         //System.runAs(adminUser){
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
       //System.enqueueJob(calloutInstance);

        // Test HTTP callout with payload body
       
        HttpResponse response = BLN_HttpCalloutUtility.makeCallout(targetSystem, apiEndPoint, methodType, headerMap, recordId, payloadBody);
        Test.stopTest();
         
        
        System.assertEquals(200, response.getStatusCode(),'Test');
        
    }
    //}
    @isTest
    static void testMakeCalloutWithoutPayloadBody() {
        // Test data
        String targetSystem = 'SampleSystem';
        String apiEndPoint = 'https://example.com/api/endpoint';
        String methodType = 'GET';
        Map<String, String> headerMap = new Map<String, String>{'Authorization' => 'Bearer XXXXXXXX'};
        //String recordId = '001XXXXXXXXXXXXXXX';

        // Test HTTP callout without payload body
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        HttpResponse response = BLN_HttpCalloutUtility.makeCallout(targetSystem, apiEndPoint, methodType, headerMap,10000);

        Test.stopTest();

        
        System.assertEquals(200, response.getStatusCode(),'Test');
        
    }

    @isTest
    static void testMakeCalloutWithoutPayloadBodyAndRecordId() {
        // Test data
        String targetSystem = 'SampleSystem';
        String apiEndPoint = 'https://example.com/api/endpoint';
        String methodType = 'GET';
        Map<String, String> headerMap = new Map<String, String>{'Authorization' => 'Bearer XXXXXXXX'};

        // Test HTTP callout without payload body and recordId
        Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        HttpResponse response = BLN_HttpCalloutUtility.makeCallout(targetSystem, apiEndPoint, methodType, headerMap);
        Test.stopTest();

        // Add your assertions based on expected behavior
        System.assertEquals(200, response.getStatusCode(),'Test');
       
    }
}