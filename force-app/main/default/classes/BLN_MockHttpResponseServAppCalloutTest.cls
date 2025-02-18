@isTest
public class BLN_MockHttpResponseServAppCalloutTest {

    @isTest
    static void testMockHttpResponse() {
        // Step 1: Set up the mock response
        Test.setMock(HttpCalloutMock.class, new BLN_MockHttpResponseServAppCallout());

        // Step 2: Create the HTTPRequest object
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api');
        req.setMethod('GET');
		// Step 3: Make the HTTP request
        Http http = new Http();
        HTTPResponse res = http.send(req);

        // Step 4: Assert the response
        System.assertEquals(200, res.getStatusCode(), 'Status code should be 200');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Content-Type should be application/json');
        System.assertEquals('{"status": "success", "message": "Mock response"}', res.getBody(), 'Response body should match the mock response');
    }
}