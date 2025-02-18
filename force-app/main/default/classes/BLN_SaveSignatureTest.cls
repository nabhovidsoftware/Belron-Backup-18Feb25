/** @description : Test Class for BLN_SaveSignature
*  @author:Pruthvisinh Pujara (PWC IN)
* @CreatedDate: 31.01.2024
* @Story: FOUK-4719
*/
@isTest
public with sharing class BLN_SaveSignatureTest {
    //create test records to check ServiceAppointment 
    @isTest
    public static void saveSignatureTest() {
        BLN_TestDataFactory.createServiceAppointment('TEst Name', true);
        String woliId = [select id from WorkOrderLineItem limit 1].Id;
        test.startTest();
            String result = BLN_SaveSignature.saveSignature('test', 'test', woliId);
        BLN_SaveSignature.checkSTRelease(woliId);
        BLN_SaveSignature.checkSTRelease(null);
        test.stopTest();
        System.assertEquals('Success', result, 'File saved successfully');
    }

    @isTest
    static void testGetSARecord(){

        WorkOrder wo = new WorkOrder(Subject = 'Test WorkOrder');
        insert wo;

        // Create a test ServiceAppointment associated with the WorkOrder
        ServiceAppointment sa = new ServiceAppointment(
            ParentRecordId = wo.Id,
            Status = 'Open' 
        );
        insert sa;

        Test.startTest();
        String serviceAppointmentId = BLN_SaveSignature.getSARecord(wo.Id);
        Test.stopTest();

          // Perform assertions
          System.assertEquals(sa.Id, serviceAppointmentId, 'Expected ServiceAppointment Id does not match');

    }

    @isTest
    static void testGetContentDocumentId() {
        // Create a test ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test_document.txt',
            VersionData = Blob.valueOf('Test Content')
        );
        insert cv;

         // Call the method under test with the ContentVersion Id
         Test.startTest();
         String contentDocumentId = BLN_SaveSignature.getContentDocumentId(cv.Id);
         BLN_SaveSignature.getCurrentDateTime();
         Test.stopTest();
         System.assertNotEquals(null, contentDocumentId, 'Expected contentDocumentId should not be null');

    }
}