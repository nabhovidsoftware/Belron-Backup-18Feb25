/*****************************************
ClassName : BLN_QueueMSGSessionCallout
Description : 
CreatedDate: 12-07-2024
CreatedBy : PwC-India
****************************************/
@IsTest
public class BLN_QueueMSGSessionCalloutTest {
    static String payload = '{ "key":"value" }';

    //This test method is created to test the positive scenarios for the method of BLN_QueueMSGSessionCallout class.
    @IsTest
    static void testExecutePositive() {
        Test.startTest();
        BLN_QueueMSGSessionCallout testClass = new BLN_QueueMSGSessionCallout(payload);
        try {
            Test.setMock(HttpCalloutMock.class, new BLN_QueueMSGSessionCalloutMock(201, 'Created'));
            testClass.execute(null);
        } catch (Exception e) {
            Assert.fail('Unexpected exception occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }

    //This test method is created to test the negative scenarios for the method of BLN_QueueMSGSessionCallout class.
    @IsTest
    static void testExecuteNegative() {
        Test.startTest();
        BLN_QueueMSGSessionCallout testClass = new BLN_QueueMSGSessionCallout(payload);
        try {
            Test.setMock(HttpCalloutMock.class, new BLN_QueueMSGSessionCalloutMock(401, 'Unauthorized'));
            testClass.execute(null);
        } catch (Exception e) {
            Assert.fail('Unexpected exception occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
     //Http callout mock class and methods

    private class BLN_QueueMSGSessionCalloutMock implements HttpCalloutMock {
        Integer code;
        String status;
        
        BLN_QueueMSGSessionCalloutMock(Integer code, String status) {
            this.code = code;
            this.status = status;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{' +
                        '  "some_property": "some_value"' +
                        '}');
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            return res;
        }
    }
}