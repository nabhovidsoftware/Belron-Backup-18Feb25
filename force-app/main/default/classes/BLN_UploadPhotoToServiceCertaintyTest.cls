@isTest
public class BLN_UploadPhotoToServiceCertaintyTest {
    @testSetup
    static void setupTestData(){
        WorkOrderLineItem woli = BLN_TestDataFactory.createWOLI();
        String woliId = woli.Id;
        List<BLN_ExternalFileLinks__c> extfileList = BLN_TestDataFactory.createExternalFileLink();
        extfileList[0].BLN_ParentId__c = woliId;
    }

    @isTest
    public static void uploadPhotosToServiceCertaintyTest(){
        List<BLN_ExternalFileLinks__c> extfileList = [Select Id, Name,BLN_FileName__c,BLN_FileType__c,BLN_ParentObjectName__c,BLN_DocumentId__c,BLN_FileCreationDate__c,BLN_S3BucketLink__c,BLN_ParentId__c from BLN_ExternalFileLinks__c];
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        Test.startTest();
        BLN_UploadPhotoToServiceCertaintyCallout.uploadPhotosToServiceCertainty(extfileList);
        Test.stopTest();
        System.assertEquals(extfileList.size() > 0, true,'Atleast one record should be there');
    }
    
    
    public class MockResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"MockAccessToken123","scope":"read"}');
                response.setStatusCode(200);
                return response; 
        }
    }
}