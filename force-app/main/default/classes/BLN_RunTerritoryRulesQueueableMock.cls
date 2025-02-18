/*****************************************
*ClassName : BLN_RunTerritoryRulesQueueableMock
*@description :  FOUK-4467 This is the mock test class for BLN_RunTerritoryRulesQueueable.
*CreatedDate: 03-01-2024
*CreatedBy : PwC-India
****************************************/
@isTest
public class BLN_RunTerritoryRulesQueueableMock implements HttpCalloutMock {
     /*MethodName : respond
*@description : This method is used to create mock reponse for the BLN_RunTerritoryRulesQueueable class callout
*@return: mockresponse
*@param HTTPRequest
*Output Parameter : mock JSON
*CreatedDate: 14-12-2023
*CreatedBy : Pwc-India
*Change log :
****************************************/
    public HTTPResponse respond(HTTPRequest req) {
        String endpoint = System.URL.getOrgDomainURL().toExternalForm()+'/services/Soap/u/41.0/'+UserInfo.getOrganizationId();
        //condition for successful response
         if(req.getEndpoint() == endpoint){
            String contentType = 'text/xml;charset=UTF-8';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', contentType);
            res.setBody('{"access_token": "MockAccessToken123", "expires_in": 3600, "token_type": "Bearer","scope": "read"}');
            res.setStatusCode(200);
            return res;
        } return null;
        
    }
}