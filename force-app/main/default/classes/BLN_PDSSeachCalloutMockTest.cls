@isTest
public class BLN_PDSSeachCalloutMockTest {

    @isTest
    public static void testMockCallout_SuccessCase() {
        // Mock HTTPRequest setup
        Account A = new Account(
            Name = 'Test Account',
            BLN_MDMAccountID__c = '654321'
        );
        insert A;
        String AccId =A.Id;
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('callout:BLN_CreditsafeRequest/gbl/sfdc/v1/accounts/123/split-billings?accountMDMID=' + 
                         AccId + '&lossDate=2024-01-01');
        req.setMethod('GET');
        
        // Instantiate the mock callout controller
        BLN_PDSSeachCalloutControllerMockCallout mockCallout = new BLN_PDSSeachCalloutControllerMockCallout();
        
        // Call the respond method and capture the response
        HTTPResponse res = mockCallout.respond(req);
        
        // Assertions to verify the behavior
        System.assertEquals(200, res.getStatusCode(), 'Expected status code to be 200');
        System.assertEquals('application/x-www-form-urlencoded', res.getHeader('Content-Type'), 'Expected content type to be application/x-www-form-urlencoded');
        System.assert(res.getBody().contains('"policyNumber": "213131233"'), 'Response body should contain policy number');
    }
    
    @isTest
    public static void testMockCallout_FailureCase() {
        // Mock HTTPRequest setup
        Account A = new Account(
            Name = 'Test Account',
            BLN_MDMAccountID__c = '654321'
        );
        insert A;
        String AccId =A.Id;
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('BLN_CreditsafeRequest/gbl/sfdc/v1/accounts/123/split-billings?accountMDMID=' + 
                         AccId + '&lossDate=2024-01-01');
        req.setMethod('GET');
        
        // Instantiate the mock callout controller
        BLN_PDSSeachCalloutControllerMockCallout mockCallout = new BLN_PDSSeachCalloutControllerMockCallout();
        
        // Call the respond method and capture the response
        HTTPResponse res = mockCallout.respond(req);
        
        // Assertions to verify the behavior
        System.assertEquals(200, res.getStatusCode(), 'Expected status code to be 200');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Expected content type to be application/x-www-form-urlencoded');
        System.assert(res.getBody().contains('"message": "Mock response"'), 'Response body should contain mocked response');
                                             
    }

    
}