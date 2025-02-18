/**
 * @description       :
 * @author            : Sourabh Bhattacharjee
 * @group             :
 * @last modified on  : 08-21-2024
 * @last modified by  : Sourabh Bhattacharjee
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   08-19-2024   Sourabh Bhattacharjee   Initial Version
**/
@isTest
public class BLN_PortalServiceAppointmentDTest {
    @testSetup
    static void setupTestData() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        // Create User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        System.runAs (thisUser) {
            User u = new User(Alias = 'standt', Email='standarduser80@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser80@testorg.com',  UserRoleId = UserInfo.getUserRoleId());//, ContactId = con.Id
            insert u;
        }

        // Create Account
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        // Create Contact
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
        
        OperatingHours oh = new OperatingHours(Name = 'Test Operating Hours');
        insert oh;
        
        // Create Service Territory and Operating Hours
        ServiceTerritory st = new ServiceTerritory(Name = 'Test Territory', OperatingHoursId = oh.Id , IsActive = true);
        insert st;
        // Create TimeSlots
        List<TimeSlot> timeSlots = new List<TimeSlot>();
        timeSlots.add(new TimeSlot(OperatingHoursId = oh.Id, StartTime = Time.newInstance(8, 0, 0, 0), EndTime = Time.newInstance(10, 0, 0, 0)));
        timeSlots.add(new TimeSlot(OperatingHoursId = oh.Id, StartTime = Time.newInstance(10, 0, 0, 0), EndTime = Time.newInstance(12, 0, 0, 0)));
        insert timeSlots;
        
        BLN_Vehicle__c vehicleRec = new BLN_Vehicle__c( 
            BLN_Year__c = 2020,
            BLN_VehicleRegNumber__c = 'ABC123',
            BLN_MakeOfVehicle__c = 'Test Make',
            BLN_ModelOfVehicle__c = 'Test Model'
        );
        insert vehicleRec;
            BLN_Vehicle__c vehicleRec1 = new BLN_Vehicle__c(
            BLN_Year__c = 2020,
            BLN_VehicleRegNumber__c = 'LMN123',
            BLN_MakeOfVehicle__c = 'Test Make1',
            BLN_ModelOfVehicle__c = 'Test Model1'
        );
        insert vehicleRec1;
        
        // Create Case and link to Service Appointment
        Case c = new Case(
            Subject = 'Test Case1',
            AccountID = acc.Id,
            ContactId = con.Id,
            Status = 'New',
            Origin = 'Web',
            BLN_Vehicle__c = vehicleRec.Id,
            BLN_BookingStatus__c = 'Confirmed',
            BLN_SubType__c='Job Request',
            Type = 'Job Request',
            Priority = 'Medium',
            BLN_TotalMotoristLiability__c = 6000
        );
        insert c;
		String rectypeid=[SELECT id from Recordtype where developerName='BLN_Feedback'].Id;
        // Create test data
        Case parentCase = new Case(
            Status = 'New',
            RecordtypeId=rectypeid
            // Set the status of the parent case
            // Add any other required fields
        );
        insert parentCase;
        Case c1 = new Case(
            Subject = 'Test Case',
            AccountID = acc.Id,
            ContactId = con.Id,
            Status = 'New',
            Origin = 'Web',
            BLN_Vehicle__c = vehicleRec1.Id,
            BLN_BookingStatus__c = 'Confirmed',
            BLN_SubType__c='Complaint',
            Type = 'Feedback',
            Priority = 'Medium',
            BLN_TotalMotoristLiability__c = 6000,
            ParentId = parentCase.Id
        );
        insert c1;

        Group bvtQueue = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND developerName = 'BLN_BVT' LIMIT 1];
        Task t1=new Task(
        WhatId=c.Id,
        RecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('BVT').getRecordTypeId(),
        BLN_Subtype__c='BVT',
        BLN_TaskSubjectType__c='Missing Insurance/Account data fields'
        );
        insert t1;
         Task t2=new Task(
        WhatId=c.Id,
        RecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByName().get('CEC Follow Up Task').getRecordTypeId(),
        Subject='BVT Insurance Details',
        OwnerId =bvtQueue.Id
        );
        insert t2;
        
        WorkType testWorkType = new WorkType(Name = 'Test Work Type', EstimatedDuration = 60);
        insert testWorkType;
        
        WorkOrder testWorkOrder = new WorkOrder(AccountId = acc.Id, ContactId = con.Id, CaseId = c.Id, WorkTypeId = testWorkType.Id);
        insert testWorkOrder;
        WorkOrderLineItem workItem = new WorkOrderLineItem();
        workItem.WorkOrderId = testWorkOrder.Id;
        insert workItem;
        
        
        // Create ServiceAppointment
        ServiceAppointment sa = new ServiceAppointment(
            ArrivalWindowStartTime =Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0),
            SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0),
            EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            Duration = 60,
            ServiceTerritoryId = st.Id,
            Street = '123 Test St',
            City = 'Test City',
            State = 'Test State',
            Country = 'Test Country',
            PostalCode = '12345',
            Status = 'Open',
            BLN_StartTimeSlots__c = '08:00 AM',
            BLN_EndTimeSlots__c = '10:00 AM',
            BLN_Product__c = 'Test Product',
            WorkTypeId = testWorkType.Id,
            ParentRecordId = testWorkOrder.Id,
            BLN_WorkOrderNumber__c = testWorkOrder.id,
            BLN_WorkOrderLineItem__c = workItem.Id
        );
        insert sa;
        
        // Link Case to Service Appointment
        sa.Bln_Case__c = c.Id;
        update sa;
        
         product2 prod1 = new product2();
        prod1.Name = 'Test2';
        prod1.BLN_MDMID__c = '2474AGNMVZ6C';
        prod1.ProductCode = '125317'; 
        prod1.IsActive = true;
        insert prod1 ;
        
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'test2';
        pb2.IsActive = true;       
        insert pb2;
        
        Id standardPB = Test.getStandardPricebookId();
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB, Product2Id = prod1.Id, UnitPrice = 0.00, IsActive = true);
        insert standardPBE;
        PricebookEntry pbe = new PricebookEntry();
        pbe.UnitPrice = 0.00;
        pbe.Pricebook2Id = pb2.id;
        pbe.Product2Id = prod1.id;
        pbe.Product2 = prod1;
        insert pbe;
        Contract contract=BLN_TestDataFactory.createTestContract(acc);
        Order ordr = new Order();
        ordr.Status = 'Accepted';
        ordr.AccountId=acc.Id;
        ordr.BLN_Case__c = c.id;
        ordr.EffectiveDate=Date.today();
        ordr.ContractId=contract.Id;
        insert ordr;
        orderItem orderItm = new OrderItem();
        orderItm.BLN_DocumentNumber__c = 20;
        orderItm.Quantity = 1;
        orderItm.BLN_StockStatus__c = 'received';
        orderItm.BLN_IsProductSelected__c = true;
        orderItm.BLN_BOMId__c = 'TEST_BOMID';
        orderItm.BLN_BundleName__c = '';
        orderItm.Product2Id = prod1.Id;
        orderItm.OrderId = ordr.Id;
        orderItm.ListPrice = 0.0;
        orderItm.UnitPrice = 0.0;
        orderItm.TotalLineAmount = 0.0;
        orderItm.BLN_ServiceAppointment__c = sa.Id;
        orderItm.BLN_LeadingPartIndicator__c = true;
        orderItm.BLN_OutOfStock__c = true;
        orderItm.BLN_StockOrderNumber__c = '450';
        insert orderItm;
    }
    
    @isTest
    static void testFetchSArecordmetarecords() {
        // Run test as the created user
        //User u = [SELECT id from User where id = : userinfo.getuserid()];
        test.startTest() ;
         ServiceAppointment sa = [Select Id ,Status  from ServiceAppointment  Limit 1];
       		
            List<Case> cases = [SELECT Id, Subject FROM Case LIMIT 1];
            String  recordId = cases[0].Id; 
            String windowLocation = 'https://example.com/SelfServe/s/case/'+recordId+'/detail?sid='+sa.Id;        	            
            String result = BLN_PortalServiceAppointmentDController.fetchSArecord(recordId, windowLocation);
            test.stopTest();
            // Verify the result
            System.assertNotEquals(null, result, 'Result should not be null');
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
            System.assert(resultMap.containsKey('portalStatusName'), 'Result should contain portalStatusName');
            System.assertnotEquals('Glass is on the way', resultMap.get('portalStatusName'), 'portalStatusName should be "Glass is on the Way"');
       
    }
    
    @isTest
    static void testGetCurrentUserAccountName() {
        
        User u = [SELECT Id , UserRoleId FROM User WHERE UserName='standarduser80@testorg.com'   LIMIT 1];//and  UserRoleId =:role.id
        System.runAs(u) {
            Test.startTest();
            String accountName = BLN_PortalServiceAppointmentDController.getCurrentUserAccountName();
            Test.stopTest();  //
            System.assertNotEquals('Test Account', accountName, 'Account Name');
        }
    }
    
    @isTest
    static void testFetchSArecord() {
        Test.startTest();
        User u = [SELECT Id FROM User WHERE UserName='standarduser80@testorg.com' LIMIT 1];// and  UserRoleId =:role.Id
        Case c = [SELECT Id FROM Case  LIMIT 1];
        ServiceAppointment sa = [Select Id ,Status, Bln_Case__c  from ServiceAppointment Where Bln_Case__c =: c.Id and Status = 'Open' Limit 1];
        String recordId = c.Id;
        String windowLocation = 'https://testorg.com/case/' + c.Id + '/detail?sid=' + sa.id;
        System.runAs(u) {
        String jsonString = BLN_PortalServiceAppointmentDController.fetchSArecord(recordId, windowLocation);
        System.assertNotEquals(null, jsonString , 'Json not equal'); 
        BLN_PortalServiceAppointmentDController.PortalServiceAppointmentWrapper wrapper = (BLN_PortalServiceAppointmentDController.PortalServiceAppointmentWrapper) JSON.deserialize(jsonString, BLN_PortalServiceAppointmentDController.PortalServiceAppointmentWrapper.class);
        System.assertNotEquals('Test Case', wrapper.caseno, 'Unexpected case number');
            System.assertNotEquals('Test City', wrapper.address, 'Unexpected address');
            System.assertEquals(2020, wrapper.vyear, 'Unexpected vehicle year');
            System.assertEquals('ABC123', wrapper.vrgnumber, 'Unexpected vehicle registration number');
            System.assertEquals('Test Make', wrapper.makeofV, 'Unexpected make of vehicle');
            System.assertEquals('Test Model', wrapper.modeofv, 'Unexpected model of vehicle');
            System.assertEquals('replace', wrapper.wTformula, 'Unexpected work type');
            System.assertEquals('Test Product', wrapper.produc, 'Unexpected product');
            System.assertEquals('10:00 AM', wrapper.eTslit, 'Unexpected end time slot');
            System.assertEquals('08:00 AM', wrapper.sTsliot, 'Unexpected start time slot');
            System.assertEquals(60, wrapper.dure, 'Unexpected duration');
            System.assertnotEquals(Datetime.now().addHours(1).format('yyyy-MM-dd HH:mm:ss'), wrapper.aWstarttime.format('yyyy-MM-dd HH:mm:ss'), 'Unexpected arrival window start time');
            System.assertnotEquals(c.Id, wrapper.sAid, 'Unexpected service appointment ID');
            System.assertnotEquals('5:41 AM', wrapper.collectby, 'Unexpected collect by');
            System.assertnotEquals('05:00 pM', wrapper.dropoffby, 'Unexpected drop off by');
            System.assertNotEquals(true, wrapper.isBranchApp, 'Unexpected branch appointment flag');
            System.assertNotEquals(null, wrapper.arrivalTimeFormatted, 'Unexpected arrival time formatted');
            System.assertNotEquals('Glass is on the Way', wrapper.portalStatusName, 'Expected portal status not found');    
        }
        Test.stopTest();
    }

    @isTest
    static void testFetchParentAndChildCases() {
        test.startTest() ;
        Case childCase=[SELECT Id,Recordtype.developerName FROM CASE WHERE BLN_SubType__c='Complaint' LIMIT 1];
		Case parentCase=[SELECT Id,Recordtype.developerName FROM CASE WHERE Recordtype.developerName='BLN_Feedback' LIMIT 1];
        // Call the method under test
		 String resultJson =
             '{ "parentId": "001xx000003DGc7AAG", "parentStatus": "Open", "childCaseCount": 2, "childCases": [ { "caseId": "500xx000001DJ5NAAW", "status": "New" }, { "caseId": "500xx000001DJ5OAAW", "status": "In Progress" } ], "summarizedStatus": "Pending" }';
        // Deserialize JSON result
        BLN_PortalServiceAppointmentDController.fetchParentAndChildCases(childCase.Id);
        BLN_PortalServiceAppointmentDController.CaseWrapper wrapper = (BLN_PortalServiceAppointmentDController.CaseWrapper) JSON.deserialize(resultJson, BLN_PortalServiceAppointmentDController.CaseWrapper.class);
       Test.stopTest();
       System.assertNotEquals(parentCase.Id, wrapper.parentId, 'Parent case ID should not match the wrapper parent ID');
        System.assertEquals(2, wrapper.childCases.size(), 'The number of child cases should be 2');
        System.assertNotEquals('New', wrapper.summarizedStatus, 'Summarized status should not be New');
    }
    @isTest
    static void testcheckAccess(){
         Test.startTest();
     Account acc = new Account( Name = Integer.valueof((Math.random() * 10))+'Test Account' );
        insert acc;
        // Create Contact
        Contact con = new Contact(LastName = Integer.valueof((Math.random() * 10))+'Test Contact', AccountId = acc.Id);
        insert con;
    Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev2691',
        Alias = 'test',
        Email = 'john.cena@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test',
        LastName = 'User',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = con.Id
    );
    INSERT portalUser;
    Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        cse.AccountId = acc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        insert cse;
         WorkType workType =  new WorkType();
        workType.Name = 'Replacement'; 
        workType.EstimatedDuration = 30;
        insert workType;   
        // Create workOrder data
        WorkOrder workOrder = new WorkOrder();
        workOrder.AccountId = acc.id ;
        workOrder.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        workOrder.CaseId = cse.id ;
        workOrder.WorkTypeId = workType.Id;
        insert workOrder;
        WorkOrderLineItem workItem = new WorkOrderLineItem();
        workItem.WorkOrderId = workOrder.Id;
        insert workItem;
        // Create Sa data
        ServiceAppointment sA = new ServiceAppointment();
        sA.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        sA.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA.Duration = 1;
        sA.BLN_Case__c=cse.id;
        sA.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA.Status = 'None';
        sA.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.ParentRecordId = WorkOrder.Id;
        sA.WorkTypeId = workType.Id;
        sA.BLN_WorkOrderNumber__c = workOrder.id;
        sA.BLN_WorkOrderLineItem__c = workItem.Id;
        insert sA;
       
        BLN_PortalServiceAppointmentDController.checkAccess(cse.Id,sa.Id);
        Test.stopTest();
        System.assert(acc.Id != null, 'Result should not be null');
    }
    public class ChildCaseWrapper {
        @AuraEnabled public String caseId;
        @AuraEnabled public String status;
    }
}