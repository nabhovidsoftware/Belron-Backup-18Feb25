/*****************************************
ClassName : BLN_PushRefundtoGatewayMock 
Description :  FOUK-6359, Mock Class For BLN_PushRefundtoGatewayTest to test BLN_PushRefundtoGateway Apex Class
CreatedDate: 03-04-2024
Author: Ayush Kumar Singh (PwC India)
****************************************/
@isTest
public class BLN_PushRefundtoGatewayMock implements HttpCalloutMock {
     /*****************************************
    MethodName : respond
    @description : This method is used to provide mock response for callout
    @return response
    Input Parameter : HttpRequest
    Output Parameter : JSON response
    CreatedDate: 03-04-2024
    CreatedBy : Ayush Kumar Singh (PwC India)
    Change log :
    ****************************************/
    public HTTPResponse respond(HTTPRequest req) {
        BLN_APICalloutMapper__mdt apiCalloutmapperRec = BLN_APICalloutMapper__mdt.getInstance(System.Label.BLN_RefundAPICallName);
        String endPoint = apiCalloutmapperRec.BLN_NamedCredential__c + apiCalloutmapperRec.BLN_CalloutURL__c;
        // Condition for token response
        if(req.getEndpoint() == System.label.BLN_MelissaAccessTokenEndpoint){
            String contentType = 'application/x-www-form-urlencoded';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', contentType);
            res.setBody('{"access_token": "MockAccessToken123", "expires_in": 3600, "token_type": "Bearer","scope": "read"}');
            res.setStatusCode(200);
            return res;
        }
        //condition for successful response
        else if (req.getEndpoint()==endPoint)
        {
            String contentType = 'application/x-www-form-urlencoded';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', contentType);
            res.setBody('{"message": "success"}');
            res.setStatusCode(200);
            return res;  
        }
        return null;        
    }   
}