/**@description : This is the Apex Test Class for BLN_SendDocsForPrintBatch
*  @author: PwC India
*  @Story: FOUK-5770 (Create Bulk Customer Service Report File for Printing and Posting)
*  @CreatedDate: 29/04/2024
*/
@isTest
public class BLN_SendDocsForPrintBatchTest {
    public static String accessToken = '00D7a00000057BE!AR0AQL3GDzbly30diuDf7bL3MhSCjAcmRPrrKcG1hdWZpO8JU2yUytrpaiXfkQ50vab4vSOygl8.b9NIwnSCsCZHQk_xt18n';
    /*Description : It is used for test data for below methods*/
    @testSetup
    static void setup(){
        Id userid = UserInfo.getUserId();
        
        // Assert that the user ID is not null
        System.assertNotEquals(null, userid, 'User ID should not be null');
        
        WorkType workType = BLN_TestDataFactory.createWorkType('Replacement', 1.0, true, true);
        
        Case caseObj =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        insert caseObj;
        
        WorkOrder workOrder = BLN_TestDataFactory.createWorkOrder(false);
        workOrder.status = 'completed';
        workOrder.CaseId = caseObj.Id;
        insert workOrder;
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrder.id;
        wOLI.status = 'Completed';
        wOLI.BLN_IsStockCheckInCompleted__c = false;
        insert wOLI;        
        
        wOLI.Status = 'Completed';
        wOLI.BLN_PrintStatus__c = 'Ready For Print';
        wOLI.BLN_FinalSummaryReportDeliveryMethod__c = 'Post';
        update wOLI;

        ServiceAppointment servApp = BLN_TestDataFactory.createServiceAppntmnt('Replacement', True);
        servApp.BLN_WorkOrderLineItem__c = wOLI.Id;
        servApp.WorkTypeId = workType.Id;
        servApp.BLN_WorkOrderNumber__c = workOrder.Id;
        servApp.ArrivalWindowStartTime = System.now().addhours(1);
        update servApp;
        
    }
    /*Description : This method is used for checking Send Docs for print batch*/
    @isTest
    static void testMethod1() {
        List<WorkOrderLineItem> woliList = [SELECT Id FROM WorkOrderLineItem LIMIT 1];
        BLN_ExternalFileLinks__c link = new BLN_ExternalFileLinks__c();
        link.BLN_ParentId__c = woliList[0].Id;
        link.BLN_DocumentId__c = 'AWS-001';
        link.BLN_ParentObjectName__c = 'WorkOrderLineItem';
        link.BLN_FileType__c = 'PDF';
        link.BLN_FileCreationDate__c = System.now().addMinutes(-5);
        link.BLN_Category__c = 'Post-Inspection';
        insert link;
        Test.setMock(HttpCalloutMock.class, new BLN_MockHttpResponseHTTPCallOutToOkta());
        Test.startTest();
        BLN_SendDocsForPrintBatch job = new BLN_SendDocsForPrintBatch();
        String cronExpr = '0 0 2 * * ? *';
        System.schedule('BLN_SendDocsForPrintBatch', cronExpr, job);
        job.execute(null);
        Test.stopTest();
        System.assertEquals(1, woliList.size(), 'Appointment Should be only 1');
    }
     /*Description : This method is used for checking Send Docs for print batch based on WorkOrderLineItem */
    @isTest
    static void testMethod2() {
        List<WorkOrderLineItem> woliList = [SELECT Id FROM WorkOrderLineItem LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new BLN_MockHttpResponseHTTPCallOutToOkta());
        Test.startTest();
        BLN_SendDocsForPrintBatch job = new BLN_SendDocsForPrintBatch();
        String cronExpr = '0 0 2 * * ? *';
        System.schedule('BLN_SendDocsForPrintBatch', cronExpr, job);
        job.execute(null);
        Test.stopTest();
        System.assertEquals(1, woliList.size(), 'Appointment Should be only 1');
    }
}