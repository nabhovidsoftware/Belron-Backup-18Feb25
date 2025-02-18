/**@description : This Apex class used to cover BLN_QueueMDMCallout class.
*  @author: PwC India
*  @Story: FOUK-5167
*  @CreatedDate: 29/05/2024
*/
@isTest
public class BLN_QueueMDMCalloutTest {
    @testSetup
    @TestVisible static void createTestAccount() {
        Account acc =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert acc;
       // return acc.Id;
    }

    // Test method to verify successful execution and response handling
    @isTest
     static  void testExecuteSuccessfulCallout() {

        Account acc=[select id from account limit 1];
        // Prepare test data
        String fieldsJson = '{"First_Name": "John", "Last_Name": "Doe"}'; 
        BLN_MDMConfiguration.MDMParameters parameters = new BLN_MDMConfiguration.MDMParameters();
        parameters.eventType = 'create';
        parameters.accountId = acc.id;

        // Set the mock HTTP callout using anonymous inner class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        BLN_QueueMDMCallout queueable = new BLN_QueueMDMCallout(fieldsJson, parameters);
        queueable.execute(null); 
        Test.stopTest();

       System.assertEquals('{"First_Name": "John", "Last_Name": "Doe"}', queueable.fieldsJson,'Success');
    }

// Test method to verify exception handling
    @isTest
    static  void testExecuteExceptionHandling() {
        Account acc=[select id from account limit 1];

        // Prepare test data
        String fieldsJson = '{"First_Name": "John", "Last_Name": "Doe"}'; 
        BLN_MDMConfiguration.MDMParameters parameters = new BLN_MDMConfiguration.MDMParameters();
        parameters.eventType = 'create';
        parameters.accountId = acc.id;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        BLN_QueueMDMCallout queueable = new BLN_QueueMDMCallout(fieldsJson, parameters);
        queueable.execute(null); 
        Test.stopTest();
        System.assertEquals('{"First_Name": "John", "Last_Name": "Doe"}', queueable.fieldsJson,'Success');

  
    }

    //mock response
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if(req.getEndpoint() == 'callout:BLN_OktaAuthToken'){
                HttpResponse response = new HttpResponse();
                response.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"MockAccessToken123","scope":"read"}');
                response.setStatusCode(200);
                return response;      
            } else {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message": "Success"}');
            res.setStatusCode(200);
            return res;
        }

        }
    }
}