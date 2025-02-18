/**@description : This is the Apex Test class for the Apex Classes BLN_SendBoschJobCardBatch And BLN_SendBoschJobCard
*  @author: PwC India
*  @Story: FOUK-5582
*  @CreatedDate: 13/03/2024
*/
@isTest
public class BLN_SendBoschJobCardBatchTest {
    
    /**
* @description Sets up test data for the test methods
*/
    @TestSetup
    static void setupTestData() {
        
        WorkType workType = BLN_TestDataFactory.createWorkType('Replacement', 1.0, true, true);
        WorkOrder workOrder = BLN_TestDataFactory.createWorkOrder(false);
        workOrder.status = 'Completed';
        insert workOrder;
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrder.id;
        wOLI.status = 'Completed';
        wOLI.BLN_IsStockCheckInCompleted__c = false;
        insert wOLI;  
        
        ServiceAppointment servApp = BLN_TestDataFactory.createServiceAppntmnt('Replacement', True);
        servApp.BLN_WorkOrderLineItem__c = wOLI.Id;
        servApp.WorkTypeId = workType.Id;
        servApp.BLN_WorkOrderNumber__c = workOrder.Id;
        servApp.ArrivalWindowStartTime = System.now().addhours(1);
        update servApp;
        
        Product2 prod1 = BLN_TestDataFactory.createTestProduct();
        insert prod1;
        
        ProductRequired prRq = new ProductRequired();
        prRq.Product2Id = prod1.Id;
        prRq.BLN_ProductRequiredTitle__c = 'Test PR';
        prRq.BLN_WorkOrder__c = servApp.BLN_WorkOrderNumber__c;
        prRq.BLN_WOLI__c = servApp.BLN_WorkOrderLineItem__c;
        prRq.ParentRecordId = servApp.BLN_WorkOrderLineItem__c;
        insert prRq;        
        
        BLN_RecalibrationJobCard__c recal1 = new BLN_RecalibrationJobCard__c();
        BLN_RecalibrationJobCard__c recal2 = new BLN_RecalibrationJobCard__c();
        
        recal1.BLN_SortOrder__c = 1;
        recal2.BLN_SortOrder__c = 2;
        recal1.BLN_TaskName__c = 'Task1';
        recal2.BLN_TaskName__c = 'Task2';
        recal1.BLN_Product__c = prod1.Id;
        recal2.BLN_Product__c = prod1.Id;
        insert recal1;
        insert recal2;        
        
    }
    
    /*
    *@description: This method is used to test execute method.
    *return : void
    */
    @isTest
    static void testCallout() {     
        
        ServiceAppointment saRecord = new ServiceAppointment();
        
        List<ServiceAppointment> serviceAppointList = new List<ServiceAppointment>();
        serviceAppointList.add(saRecord);
        List<ServiceAppointment> sAList2 = [Select Id, BLN_WorkOrderLineItem__c, BLN_Vehicle__c, BLN_Vehicle__r.BLN_VehicleRegNumber__c , BLN_Vehicle__r.BLN_MakeOfVehicle__c, BLN_Vehicle__r.BLN_ModelOfVehicle__c, BLN_Vehicle__r.BLN_VIN__c, AccountId, Account.FirstName, Account.LastName, BLN_IsBoschJobCardSent__c from ServiceAppointment];
        Id sAId = [Select Id from ServiceAppointment limit 1].id;
        List<Id> sAList = new List<Id>();
        sAList.add(sAId);
        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new BLN_MockHttpResponseHTTPCallOutToOkta());
        Test.startTest();
        BLN_SendBoschJobCard.sendBoschJobCardFromFlow(sAList);
        System.enqueueJob(new BLN_SendBoschJobCard(sAList2, null, true));
        Test.stopTest();
        System.assertEquals(1, serviceAppointList.size(), 'Appointment Should be only 1');
    }

    /*
    *@description: This method is used to test execute method.
    *return : void
    */
    @isTest
    static void testBatchexcution() {     
        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new BLN_MockHttpResponseHTTPCallOutToOkta());
        Test.startTest();
            integer batchSize = 200;
            BLN_SendBoschJobCardBatch p = new BLN_SendBoschJobCardBatch();
            Id batch = Database.executeBatch(p,batchSize);
        Test.stopTest();
        AsyncApexJob job = [SELECT Status FROM AsyncApexJob Where ID = :batch];
        System.assertNotEquals(job, null, 'Test');
    }
}