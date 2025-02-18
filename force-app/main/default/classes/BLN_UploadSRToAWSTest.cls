@isTest
public class BLN_UploadSRToAWSTest {
    
    @isTest
    static void uploadFileToAWSTest() {
        Workorder wo = new WorkOrder();
        insert wo;
        
        ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',        
          PathOnClient = 'Penguins.jpg',        
          VersionData = Blob.valueOf('Test Content'),        
          IsMajorVersion = true        
        );        
        insert contentVersion;    
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        
        ContentDocumentLink cdl = New ContentDocumentLink();        
        cdl.LinkedEntityId = WO.id;        
        cdl.ContentDocumentId = documents[0].Id;        
        cdl.shareType = 'V';        
        insert cdl;
        
        ServiceReport sr = new ServiceReport();        
        //sr.ContentVersionDocumentId = documents[0].Id ;
        sr.DocumentBody = Blob.valueOf('Test Content') ;         
        sr.DocumentContentType ='application/pdf';        
        sr.DocumentName='Test';        
        sr.ParentId = WO.Id ;         
        insert sr ;
        
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        BLN_UploadSRToAWS.sendDatatoDocstore(new List<Id>{sr.Id});
        
        system.assert(sr.Id != null, 'sr successfully created');
    }
    
    private class MockResponseGenerator implements HttpCalloutMock {        

        public HTTPResponse respond(HTTPRequest req) {
            String jsonRes = '{"docStore":[{"associationId":"' + 'abc' + '","documentId":110}]}';
            if(req.getEndpoint() == 'callout:BLN_OktaAuthToken'){
                HttpResponse response = new HttpResponse();
                response.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"MockAccessToken123","scope":"read"}');
                response.setStatusCode(200);
                return response;      
            } else {
                HttpResponse response = new HttpResponse();
                response.setBody(jsonRes);
                response.setStatusCode(200);
                return response; 
            }
        }
    }

}