/**@description : This is the Apex Test Class for BLN_DeleteFilesAfterAWSUpload
*  @author: PwC India
*  @Story: FOUK-9309 (Document Storage - Periodical deletion of files from SF)
*  @CreatedDate: 04/07/2024
*/
@isTest
public without sharing class BLN_DeleteFilesAfterAWSUploadTest {
    /*Description : It is used for test data for below methods*/
    @testSetup
    static void setup(){
        Id userid = UserInfo.getUserId();
        System.assertNotEquals(null, userid, 'User ID should not be null');
        
        WorkType workType = BLN_TestDataFactory.createWorkType('Replacement', 1.0, true, true);
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        insert caseObj;
        
        WorkOrder workOrder = BLN_TestDataFactory.createWorkOrder(FALSE);
        workOrder.status = 'New';
        workOrder.CaseId = caseObj.Id;
        insert workOrder;
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrder.id;
        wOLI.status = 'New';
        insert wOLI;

        ServiceAppointment servApp = BLN_TestDataFactory.createServiceAppntmnt('Replacement', TRUE);
        servApp.BLN_WorkOrderLineItem__c = wOLI.Id;
        servApp.WorkTypeId = workType.Id;
        servApp.BLN_WorkOrderNumber__c = workOrder.Id;
        servApp.ArrivalWindowStartTime = System.now().addhours(1);
        update servApp;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Final Service Report';
        cv.PathOnClient = 'testFinalServiceReport.pdf';
        cv.VersionData = Blob.valueOf('Sample Test Final Service Report');
        cv.BLN_IsUploadedToAWS__c = FALSE;
        insert cv;

        Id contentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = wOLI.Id;
        cdl.ContentDocumentId = contentDocumentId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'InternalUsers';
        insert cdl;
        
    }
    /*Description : This method is used for testing BLN_DeleteFilesAfterAWSUpload*/
    @isTest
    static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new BLN_MockHttpResponseHTTPCallOutToOkta());
        List<ContentVersion> cvList = [SELECT Id, BLN_IsUploadedToAWS__c,ContentDocumentId FROM ContentVersion LIMIT 1];
        cvList[0].BLN_IsUploadedToAWS__c = TRUE;
        update cvList;
        Test.startTest();
        BLN_DeleteFilesAfterAWSUpload job = new BLN_DeleteFilesAfterAWSUpload();
        String cronExpr = '0 0 4 * * ? *';
        //System.schedule('BLN_DeleteFilesAfterAWSUpload', cronExpr, job);
        job.execute(null);
        Test.stopTest();
        Assert.areEqual(1, cvList.size(), 'ContentVersion Record Should Only Be 1');
    }
}