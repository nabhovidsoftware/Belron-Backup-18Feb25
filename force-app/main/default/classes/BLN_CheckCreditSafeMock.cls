/*****************************************
*ClassName : BLN_CheckCreditSafeMock
*@description :This is the mock test class for BLN_CheckCreditSafeControllerTest.
*@Story: FOUK-602 
*CreatedDate: 07-12-2023
*CreatedBy : PwC-India
****************************************/
@isTest
public class BLN_CheckCreditSafeMock implements HttpCalloutMock {
    /*****************************************
MethodName : respond
@description : This method is used to provide mock response for callout
@return response
Input Parameter : HttpRequest
Output Parameter : JSON response
CreatedDate: 07-12-202
CreatedBy : Pwc-India
Change log :
****************************************/
    public HTTPResponse respond(HTTPRequest req) {
        // Condition for token response
        if(req.getEndpoint() == 'callout:BLN_OktaAuthToken'){
            HttpResponse res = new HttpResponse();
            res.setBody('{"access_token": "MockAccessToken123", "expires_in": 3600, "token_type": "Bearer","scope": "read"}');
            res.setStatusCode(200);
            return res;
        }
        //condition for successful response
        else 
        {
            String contentType = 'application/x-www-form-urlencoded';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', contentType);
            res.setBody('{"statusCompanyReportProcessing": "OK",  "muleCorrelationId": "12"}');
            res.setStatusCode(200);
            return res;  
        }
   
        
    }
}