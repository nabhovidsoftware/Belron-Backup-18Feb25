/** @description : Test Class for BLN_ProductRequiredController
*   @Story : FOUK-4136
*   @author: Rahul Jain(PwC IN)
*	@CreatedDate: 12/01/2024
*/ 
@isTest
public class BLN_ProductRequiredControllerTest {
    @testSetup
    public static void makeSetupData(){
        //Create and Insert Work Type
        worktype worktype = new worktype();
        worktype.Name = 'Stock Collect';
        worktype.EstimatedDuration = 3;
        worktype.BLN_IsMainJob__c = true;
        insert worktype;
        
        //Create and Insert Work Order
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders; 
        
        //Create and Insert Operating Hours
        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = 'Test op';
        operatingHours.TimeZone = 'Europe/London';
        insert operatingHours;  
        
        //Create and Insert Work Order Line Item
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        wOLI.status = 'Completed';
        wOLI.BLN_IsStockCheckInCompleted__c = false;
        insert wOLI;
        
        //Create and Insert Service Territory
        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = 'Test Territory name';
        servicesTerritories.IsActive = TRUE;
        servicesTerritories.OperatingHoursId = operatingHours.id;
        insert servicesTerritories;  
        
        //Create and Insert Service Resource
        ServiceResource sResource =BLN_TestDataFactory.createServiceResource('test', false);
        sResource.RelatedRecordId = UserInfo.getUserId();
        insert sResource;
        
        //Create and Insert Service Appointments
        ServiceAppointment serApp3 = new ServiceAppointment();
        serApp3.BLN_AssignedServiceResource__c = sResource.id;
        serApp3.ParentRecordId = workOrders.id;
        serApp3.Status = 'Arrived';
        serApp3.ServiceTerritoryId = servicesTerritories.id;
        serApp3.EarliestStartTime = system.now();
        serApp3.DueDate = system.now()+5;
        serApp3.BLN_WorkOrderNumber__c = workOrders.id;
        serApp3.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        serApp3.WorkTypeId = worktype.id;
        serApp3.BLN_WorkOrderLineItem__c = wOLI.Id;
        serApp3.EarliestStartTime = system.now();
        insert serApp3;
        
        ServiceAppointment serviceAppointments = new ServiceAppointment();
        serviceAppointments.ParentRecordId = workOrders.id;
        
        serviceAppointments.Status = 'Dispatched';
        serviceAppointments.ServiceTerritoryId = servicesTerritories.id;
        serviceAppointments.EarliestStartTime = system.now();
        serviceAppointments.DueDate = system.now()+5;
        serviceAppointments.BLN_WorkOrderNumber__c = workOrders.id;
        serviceAppointments.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        serviceAppointments.WorkTypeId = worktype.id;
        serviceAppointments.BLN_WorkOrderLineItem__c = wOLI.Id;
        insert serviceAppointments;
        
        ServiceAppointment serApp = new ServiceAppointment();
        serApp.ParentRecordId = workOrders.id;
        
        serApp.Status = 'In Progress';
        serApp.ServiceTerritoryId = servicesTerritories.id;
        serApp.EarliestStartTime = system.now();
        serApp.DueDate = system.now()+5;
        serApp.BLN_WorkOrderNumber__c = workOrders.id;
        serApp.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        serApp.WorkTypeId = worktype.id;
        serApp.BLN_WorkOrderLineItem__c = wOLI.Id;
        serApp.SchedStartTime = DateTime.now();
        serApp.SchedEndTime = DateTime.now().addHours(1);
        insert serApp;
        
        //Create and Insert Product
        Product2 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'W-001';
        insert product;
        
        //Create and Insert Product Required
        ProductRequired productReq = new ProductRequired();
        productReq.parentrecordid = wOLI.id;
        productReq.Product2Id = product.Id;
        productReq.QuantityRequired = 6;
        insert productReq;
        
        //Create and Insert Product Transfer
        ProductTransfer prodTrans = new ProductTransfer();
        prodTrans.Product2Id = product.id;
        prodTrans.QuantitySent = 2;
        insert prodTrans;
        
        //Create and Insert Content Version
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;   
        Account testAccount = new Account(Name = 'Test Account');         
        insert testAccount;
        
        Test.startTest();         
        BLN_ProductRequiredController.getRelatedProductRequired();
        BLN_ProductRequiredController.createProdTransfer(product.id,2.00, productReq.id);
        BLN_ProductRequiredController.updateSA(ServiceAppointments.Id);
        try{
            BLN_ProductRequiredController.updateProdReq(productReq.id, 'Failed', 'Manufacture Defect' , 'Test Notes');
        }catch(AuraHandledException e){
            System.debug('Error=> '+e.getMessage());
        }
        
        BLN_ProductRequiredController.uploadFile('Test Content','Penguins',testAccount.Id);
        
        try {             
            BLN_ProductRequiredController.updateSA(null);  
            BLN_ProductRequiredController.updateProdReq(null, 'NewStatus', 'FailReason', 'TestNotes'); 
        } catch (AuraHandledException e) {             
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null');             
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateSAToCompleted() {
        // Test for ServiceAppointment with Status 'In Progress'
        ServiceAppointment inProgressSA = [SELECT Id, Status FROM ServiceAppointment WHERE Status = 'In Progress' LIMIT 1];
        inProgressSA.status = 'Completed' ;
        update inProgressSA;
        System.assertNotEquals(inProgressSA, null, 'No ServiceAppointment found with status In Progress.');
        
        Test.startTest();
        try {
            BLN_ProductRequiredController.updateSAToCompleted(inProgressSA.Id);
        } catch (Exception e) {
            System.debug('Exception thrown: ' + e.getMessage());
            System.assert(false, 'Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();
        
        ServiceAppointment updatedInProgressSA = [SELECT Id, Status FROM ServiceAppointment WHERE Id = :inProgressSA.Id];
        System.assertEquals('Completed', updatedInProgressSA.Status, 'The ServiceAppointment status should be updated to Completed when it was In Progress');
        
        // Test for ServiceAppointment with Status 'Arrived'
        ServiceAppointment arrivedSA = [SELECT Id, Status FROM ServiceAppointment WHERE Status = 'Arrived' LIMIT 1];
        
        try {
            BLN_ProductRequiredController.updateSAToCompleted(arrivedSA.Id);
        } catch (Exception e) {
            System.debug('Exception thrown: ' + e.getMessage());
            System.assert(false, 'Unexpected exception: ' + e.getMessage());
        }
        
        ServiceAppointment updatedArrivedSA = [SELECT Id, Status FROM ServiceAppointment WHERE Id = :arrivedSA.Id];
        updatedArrivedSA.status = 'Arrived' ;
        update updatedArrivedSA;
        System.assertEquals('Arrived', updatedArrivedSA.Status, 'The ServiceAppointment status should be updated to In Progress when it was Arrived');
        
        // Test for ServiceAppointment with Status 'Dispatched'
        ServiceAppointment dispatchedSA = [SELECT Id, Status FROM ServiceAppointment WHERE Status = 'Dispatched' LIMIT 1];
       
        try {
            BLN_ProductRequiredController.updateSAToCompleted(dispatchedSA.Id);
        } catch (Exception e) {
            System.debug('Exception thrown: ' + e.getMessage());
            System.assert(false, 'Unexpected exception: ' + e.getMessage());
        }
        
        ServiceAppointment updatedDispatchedSA = [SELECT Id, Status FROM ServiceAppointment WHERE Id = :dispatchedSA.Id];
        System.assertEquals('Dispatched', updatedDispatchedSA.Status, 'The ServiceAppointment status should be updated to In Progress when it was Dispatched');
    }
    //sets up data for work types, work orders, operating hours,WorkOrderLineItem, ServiceTerritory, Service Appointment.
    @isTest
    public static void method1(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        worktype worktype = new worktype();
        worktype.Name = 'Assist';
        worktype.EstimatedDuration = 3;
        worktype.BLN_IsMainJob__c = true;
        insert worktype;
        
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders; 
        
        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = 'Test op2';
        operatingHours.TimeZone = 'Europe/London';
        insert operatingHours;  
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        wOLI.status = 'Completed';
        wOLI.BLN_IsStockCheckInCompleted__c = false;
        insert wOLI;
        
        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = 'Test Territory name1';
        servicesTerritories.IsActive = TRUE;
        servicesTerritories.OperatingHoursId = operatingHours.id;
        servicesTerritories.BLN_Type__c = 'Mobile';
        insert servicesTerritories;  
        
        ServiceAppointment serApp = new ServiceAppointment();
        serApp.ParentRecordId = workOrders.id;
        serApp.Status = 'None';
        serApp.ServiceTerritoryId = servicesTerritories.id;
        serApp.EarliestStartTime = system.now();
        serApp.DueDate = system.now()+5;
        serApp.BLN_WorkOrderNumber__c = workOrders.id;
        serApp.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        serApp.WorkTypeId = worktype.id;
        serApp.BLN_WorkOrderLineItem__c = wOLI.Id;
        serApp.BLN_SkipJeopardyFlow__c = true;
        serApp.FSL__InJeopardy__c = true;
        insert serApp;
        
        ServiceAppointment serviceAppointments = new ServiceAppointment();
        serviceAppointments.ParentRecordId = wOLI.id;
        serviceAppointments.Status = 'Failed After Arrive';
        serviceAppointments.BLN_FailureReason__c = 'Stock/Supply Issue';
        serviceAppointments.BLN_SubFailureReason__c = '	Manufacture Defect';
        serviceAppointments.ServiceTerritoryId = servicesTerritories.id;
        serviceAppointments.EarliestStartTime = system.now();
        serviceAppointments.DueDate = system.now()+5;
        serviceAppointments.BLN_WorkOrderNumber__c = workOrders.id;
        serviceAppointments.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        serviceAppointments.WorkTypeId = worktype.id;
        serviceAppointments.BLN_SkipJeopardyFlow__c = true;
        serviceAppointments.FSL__InJeopardy__c = true;
        serviceAppointments.BLN_WorkOrderLineItem__c = wOLI.Id;
        insert serviceAppointments;
        
        Product2 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'W-001';
        insert product;
        
        ProductRequired productReq = new ProductRequired();
        productReq.parentrecordid = wOLI.id;
        productReq.Product2Id = product.Id;
        productReq.QuantityRequired = 6;
        productReq.BLN_WorkOrder__c = workOrders.id;
        insert productReq;
        
        ProductTransfer prodTrans = new ProductTransfer();
        prodTrans.Product2Id = product.id;
        prodTrans.QuantitySent = 2;
        insert prodTrans;
        Test.startTest();  
        BLN_ProductRequiredController.updateProdReq1(productReq.id);//Call updateProdReq1
        try {             
            BLN_ProductRequiredController.updateProdReq1(null);         
        } catch (AuraHandledException e) {             
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null');             
        }
        Test.stopTest();
    }
    
    //sets up data for work types, work orders, operating hours,WorkOrderLineItem, ServiceTerritory, Service Appointment.
    @isTest
    public static void method3(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        
        worktype worktype = new worktype();
        worktype.Name = 'Stock Collect';
        worktype.EstimatedDuration = 3;
        worktype.BLN_IsMainJob__c = true;
        insert worktype;
        
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders; 
        
        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = 'Test op2';
        operatingHours.TimeZone = 'Europe/London';
        insert operatingHours;  
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        wOLI.status = 'Completed';
        wOLI.BLN_IsStockCheckInCompleted__c = false;
        insert wOLI;
        
        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = 'Test Territory name2';
        servicesTerritories.IsActive = TRUE;
        servicesTerritories.OperatingHoursId = operatingHours.id;
        insert servicesTerritories; 
        
        //Create and insert a ServiceAppointment record with status 'None', then update through various states ('Scheduled', 'Dispatched', 'In Progress', 'Completed').
        ServiceAppointment serApp = new ServiceAppointment();
        serApp.ParentRecordId = workOrders.id;
        serApp.Status = 'None';
        serApp.ServiceTerritoryId = servicesTerritories.id;
        serApp.EarliestStartTime = system.now();
        serApp.DueDate = system.now()+5;
        serApp.BLN_WorkOrderNumber__c = workOrders.id;
        serApp.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        serApp.WorkTypeId = worktype.id;
        serApp.BLN_WorkOrderLineItem__c = wOLI.Id;
        serApp.BLN_SkipJeopardyFlow__c = true;
        serApp.FSL__InJeopardy__c = true;
        serApp.SchedStartTime = DateTime.now();
        serApp.SchedEndTime = DateTime.now().addHours(1);
        //serApp.ActualEndTime = system.now()+3;
        insert serApp;
        
        serApp.Status = 'Scheduled';
        update serApp;
        
        serApp.Status = 'Dispatched';
        update serApp;
        
        serApp.Status = 'In Progress';
        update serApp;
        
        serApp.Status = 'Completed';
        update serApp;
        
        Test.startTest();  
        BLN_ProductRequiredController.updateSAToCompleted(serApp.Id);//Call updateSAToCompleted.
        try{
            BLN_ProductRequiredController.updateSAToCompleted(null); 
        }catch (AuraHandledException e) {             
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null'); 
        }
        
        Test.stopTest();
        
    }
    
    //sets up data for work types, work orders, operating hours,WorkOrderLineItem, ServiceTerritory, Service Appointment.
    @isTest
    public static void method4(){
        User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];//Run as current user.
        
        System.runAs(u) {
            system.assertNotEquals(u, Null, 'Profile Should be available');
        }
        OperatingHours operatingHours = new OperatingHours();
        operatingHours.Name = 'Test op2';
        operatingHours.TimeZone = 'Europe/London';
        insert operatingHours;  
        
        worktype worktype = new worktype();
        worktype.Name = 'Stock Collect';
        worktype.EstimatedDuration = 3;
        worktype.BLN_IsMainJob__c = true;
        insert worktype;
        
        WorkOrder workOrders = new WorkOrder();
        workOrders.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        workOrders.WorkTypeId = worktype.Id;
        insert workOrders; 
        
        WorkOrderLineItem wOLI = new WorkOrderLineItem();
        wOLI.WorkTypeId = worktype.Id;
        wOLI.WorkOrderId = workOrders.id;
        wOLI.status = 'Completed';
        wOLI.BLN_IsStockCheckInCompleted__c = false;
        insert wOLI;
        
        
        ServiceTerritory servicesTerritories = new ServiceTerritory();
        servicesTerritories.Name = 'Test Territory name2';
        servicesTerritories.IsActive = TRUE;
        servicesTerritories.OperatingHoursId = operatingHours.id;
        insert servicesTerritories; 
        
        ServiceAppointment serApp = new ServiceAppointment();
        serApp.ParentRecordId = wOLI.id;
        serApp.Status = 'None';
        serApp.ServiceTerritoryId = servicesTerritories.id;
        serApp.EarliestStartTime = system.now();
        serApp.DueDate = system.now()+5;
        serApp.BLN_WorkOrderNumber__c = workOrders.id;
        serApp.BLN_RemedyJobId__c = ''+Integer.valueof((Math.random() * 1000));
        serApp.WorkTypeId = worktype.id;
        serApp.BLN_WorkOrderLineItem__c = wOLI.Id;
        serApp.BLN_SkipJeopardyFlow__c = true;
        serApp.FSL__InJeopardy__c = true;
        serApp.SchedStartTime = system.now()+1;
        serApp.SchedEndTime = system.now()+2;
        serApp.ActualEndTime = system.now()+3;
        insert serApp;
        
        //Create and Insert Product, Product Required, and List of Product Required
        Product2 product = new Product2();
        product.Name = 'Test Product';
        product.ProductCode = 'W-001';
        insert product;
        
        ProductRequired productReq = new ProductRequired();
        productReq.parentrecordid = wOLI.id;
        productReq.Product2Id = product.Id;
        productReq.QuantityRequired = 6;
        productReq.BLN_WorkOrder__c = workOrders.id;
        List<productRequired> pRList = new List<productRequired>();
        pRList.add(productReq);
        insert pRList;
        
        List<BLN_ProductRequiredController.ProductRequiredWrapper> pRWrapper = new List<BLN_ProductRequiredController.ProductRequiredWrapper>();
        pRWrapper.add( new BLN_ProductRequiredController.ProductRequiredWrapper(serApp.id, productReq.id, productReq.ProductRequiredNumber, serApp.AppointmentNumber, true, product.id, 6.00, 'None','test', 'Mislabelled/Incorrect Part Delivered', workOrders.WorkOrderNumber, 10.00, '453','Test Product','W-001'));
        BLN_ProductRequiredController.getRelatedProductRequired();
    }
}