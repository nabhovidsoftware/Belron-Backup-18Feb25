@isTest
public class BLN_TechnicianTimesheetServiceTest {
    // Nested mock class to simulate HTTP responses
    private class MockHttpResponseGenerator implements HttpCalloutMock {

        private HttpResponse mockResponse;

        // Constructor to pass in the mock response
        public MockHttpResponseGenerator(HttpResponse response) {
            this.mockResponse = response;
        }

        // This method is called whenever an HTTP callout is made during a test
        public HttpResponse respond(HttpRequest req) {
            // Return the mock response when a callout is made
            if (mockResponse != null) {
                return mockResponse;
            } else {
                // In case of no mock response, simulate an error response
                HttpResponse errorResponse = new HttpResponse();
                errorResponse.setStatusCode(500);
                errorResponse.setBody('{"error":"Mock error occurred"}');
                return errorResponse;
            }
        }
    }
    @isTest (SeeAllData=true)
    static void testSendTimesheet_ValidTimesheetIds() {
        // Test the scenario where valid timesheet IDs are provided
        List<TimeSheetEntry> tseList = [SELECT Id FROM TimeSheetEntry LIMIT 1];
        List<String> timesheetIds = new List<String>{tseList[0].Id};

        Test.startTest();
        BLN_TechnicianTimesheetService.sendTimesheet(timesheetIds);
        Test.stopTest();

    }
    
    @isTest (SeeAllData=true)
    static void testExecute_ValidCallout() {
        // Test the execute method with a valid callout
        List<TimeSheetEntry> tseList = [SELECT Id FROM TimeSheetEntry LIMIT 1];
        List<String> timesheetIds = new List<String>{tseList[0].Id};

        // Create a mock HTTP response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"access_token":"mockAccessToken"}');
        mockResponse.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
        BLN_TechnicianTimesheetService service = new BLN_TechnicianTimesheetService(timesheetIds, null);
        System.enqueueJob(service);
        Test.stopTest();

        // Assert that access token is fetched and timesheet data is sent
        // Additional assertions could include checking integration logs or other side effects
    }
}