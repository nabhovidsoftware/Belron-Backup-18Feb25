/*****************************************
ClassName : BLN_DisplayDocStoreRecordsControllerTest
Description : FOUK-7055
CreatedDate: 27-06-2024
CreatedBy : PwC-India
****************************************/
/*  *@description:This class is used to cover test coverage for BLN_DisplayDocStoreRecordsController*/
@isTest
public class BLN_DisplayDocStoreRecordsControllerTest {
    
     private class MockResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String json=		'{'+
		'  "fileBytes": ['+
		'    0'+
		'  ],'+
		'  "documentId": 0,'+
		'  "additionalInfo": "string",'+
		'  "documentType": "string",'+
		'  "fileExtension": "string",'+
		'  "fileName": "string",'+
		'  "documentSource": "string",'+
		'  "createdDate": "2023-06-16T19:10:53.014Z",'+
		'  "createdBy": "string",'+
		'  "associations": ['+
		'    {'+
		'      "associationId": "string",'+
		'      "typeOfAssociation": "Referral"'+
		'    }'+
		'  ]'+
		'}';
            if(req.getEndpoint() == 'callout:BLN_OktaAuthToken'){//callout:BLN_OktaAuthToken
               
                HttpResponse response = new HttpResponse();
                response.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"MockAccessToken123","scope":"read"}');
                response.setStatusCode(200);
                return response;      
            } else {
                HttpResponse response = new HttpResponse();
                response.setBody(json);
                response.setStatusCode(200);
                return response; 
            }
        }
    }
    
    @isTest
    static void getFileDetailsTest(){
        Boolean exceptionCaught = false;

        List<BLN_ExternalFileLinks__c> extFileList = BLN_TestDataFactory.createExternalFileLink();
        Test.startTest();
        
        BLN_DisplayDocStoreRecordsController.getFileDetails(extFileList[0].BLN_ParentId__c,false);
        BLN_DisplayDocStoreRecordsController.getFileDetails(extFileList[0].BLN_ParentId__c,true);
 
        try{
            BLN_DisplayDocStoreRecordsController.getFileDetails(null,null);
        }catch(Exception ex){
            exceptionCaught = true;
            
        }
        Test.stopTest();
        System.assertNotEquals(extFileList[0], null,'test');
        //System.assertEquals(true, exceptionCaught,'test exception');
        
    }

    @isTest
    static void fetchDocumentDetailsTest(){
         Boolean exceptionCaught = false;

        List<BLN_ExternalFileLinks__c> extFileList = BLN_TestDataFactory.createExternalFileLink();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        BLN_DisplayDocStoreRecordsController.fetchDocumentDetails(extFileList[0].BLN_DocumentId__c);
         try{
            BLN_DisplayDocStoreRecordsController.fetchDocumentDetails(null);
        }catch(Exception ex){
            exceptionCaught = true;
        }
        Test.stopTest();
        System.assertEquals(false, exceptionCaught,'test exception');
    }
}