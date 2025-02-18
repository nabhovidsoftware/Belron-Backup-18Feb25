/*****************************************
ClassName : BLN_UploadFileToAWSTriggerTest
@description : FOUK - 7053 This class is to test BLN_UploadFileToAWSTrigger.
@author: PwC
CreatedDate: 27-06-2024
CreatedBy : PwC-India
****************************************/
@isTest
public class BLN_UploadFileToAWSTriggerTest {

    private class MockResponseGenerator implements HttpCalloutMock {
        
        Id contactId;
        
        public MockResponseGenerator(Id contactIdAssociation){
            contactId = contactIdAssociation;
        }

        public HTTPResponse respond(HTTPRequest req) {
            String jsonRes = '{"docStore":[{"associationId":"' + contactId + '","documentId":110}]}';
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

    @isTest
    static void uploadFileToAWSTest() {

		WorkOrder wo = new WorkOrder();
        insert wo;
        
        WorkOrderLineItem woliRec = new WorkOrderLineItem();
        woliRec.WorkOrderId = wo.Id;
		insert woliRec;
        
        // Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document Pre-Inspection';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;

        Test.startTest();
        
        insert cv;        
        

        // Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        
        Pricebook2 stdPricebook = new Pricebook2(            
            Name = 'Standard Price Book',            
            IsActive = true            
        );        
        insert stdPricebook;
        
        
        // create product with standard price book   
        Product2 product = new Product2(            
            Name = 'PRODUCT_NAME',            
            ProductCode = 'PRODUCT_CODE',            
            IsActive = true            
        );        
        insert product;
        
        // add standard price book entry for the product
        
        PricebookEntry stdPricebookEntry = new PricebookEntry(            
            Pricebook2Id = stdPricebook.Id,            
            Product2Id = product.Id,            
            UnitPrice = 100.0,            
            IsActive = true            
        );
        System.assertEquals(100.0, stdPricebookEntry.UnitPrice, 'UnitPrice should be 100.0');
        
        ProductRequired prRec = new ProductRequired();
        prRec.Product2Id = product.Id;
        prRec.ParentRecordId = woliRec.Id;
        insert prRec;
        
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator(woliRec.Id));

        // Create ContentDocumentLink 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = prRec.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        insert cdl;
        
        Test.stopTest();
        
        List<BLN_ExternalFileLinks__c> externalFileLinks = [Select Id from BLN_ExternalFileLinks__c ];
        BLN_UploadFileToAWSHandler.afterUpdate(null,null);
        BLN_UploadFileToAWSHandler fileUpload = new BLN_UploadFileToAWSHandler();
        fileUpload.beforeUpdate(null,null);
        fileUpload.beforeDelete(null,null);
        fileUpload.afterDelete(null,null);
        fileUpload.afterUnDelete(null,null);
        system.assertEquals(externalFileLinks.size()>0, true, 'externalFileLinks inserted');
    }
    
}