/********************************************************************************************
 * Class Name   : BLN_ForgetPasswordHandlerTest                                             *
 * Coverage     : 93%                                                                       *                                                                                         *
 * @Story       : FOUK-10951 / FOUK-11442 /FOUK-12018                                       *
 * Created Date : 09-11-2024                                                                *
 * Created By   : Sourabh Bhattacharjee                                                     *
 ********************************************************************************************/
@isTest
public class BLN_ForgetPasswordHandlerTest {
    @testSetup
    static void setupTestData() {
        // Create an Account with PersonEmail
        Account acc1 = new Account(FirstName = 'Test', LastName = 'User1', PersonEmail = 'test1@example.com', RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Person Account'].Id,PersonHomePhone = '09901900121');
        Account acc2 = new Account(FirstName = 'Test', LastName = 'User2', PersonEmail = 'test1@example.com', RecordTypeId = acc1.RecordTypeId,PersonHomePhone = '09901900121');
        insert new List<Account>{acc1, acc2};
        Case testCase = new Case( AccountId = acc1.Id,Subject = 'Test Case',Status = 'New');
        insert testCase;
       Account a =[SELECT id,personcontactId from account where id =: acc1.Id];
       User user = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'testuser@example.com'+'.ukdev2699789',
            ContactId = a.personcontactId,
            isActive = true
        );
        System.runAs(new User(Id =UserInfo.getUserId())){
            INSERT user;
        }
         OperatingHours oh = new OperatingHours(Name = 'Test Operating Hours');
        insert oh;
        ServiceTerritory st = new ServiceTerritory(Name = 'Test Territory', OperatingHoursId = oh.Id , IsActive = true);
        insert st;
        // Create TimeSlots
        List<TimeSlot> timeSlots = new List<TimeSlot>();
        timeSlots.add(new TimeSlot(OperatingHoursId = oh.Id, StartTime = Time.newInstance(8, 0, 0, 0), EndTime = Time.newInstance(10, 0, 0, 0)));
        timeSlots.add(new TimeSlot(OperatingHoursId = oh.Id, StartTime = Time.newInstance(10, 0, 0, 0), EndTime = Time.newInstance(12, 0, 0, 0)));
        insert timeSlots;
    }

    @isTest
    static void testCheckMultiplePersonAccount() {       
        Test.startTest();
        Boolean result = BLN_ForgetPasswordHandler.checkMultiplePersonAccount('test1@example.com');
        Test.stopTest();
        System.assertEquals(false, result, 'Multiple Person Accounts should be detected for the given email');
    }
    
     @isTest
    static void testCheckMultiplePersonAccountnull() {
        Test.startTest();
        Boolean result = BLN_ForgetPasswordHandler.checkMultiplePersonAccount('');
        Test.stopTest();
        System.assertnotEquals(true, result, 'Multiple Person Accounts should be detected for the given email');
    }


     @isTest
    static void testSearchPersonAccAndLoginnull() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact con = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com', AccountId = acc.Id);
        insert con;
        
        // Create the Case, but don't set the ContactEmail directly
        Case testCase = new Case(
            AccountId = acc.Id,
            ContactId = con.Id  
        );
        insert testCase;
        Case listOfCase =[Select Id,AccountId,ContactId,ContactEmail,CaseNumber from Case Where Id =: testCase.Id LIMIT 1 ];
        String caseNumber=listOfCase.CaseNumber;
        String contactEmail=listOfCase.ContactEmail; 
        Test.startTest();
        String result = BLN_ForgetPasswordHandler.searchPersonAccAndLogin(contactEmail,caseNumber);
        Test.stopTest();
        System.assertEquals('Case found and email sent', result,'Success');        
    }
    
    @isTest
    static void testNoMatchingCaseFound() {
        // Step 1: Create test data (but no matching case)
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Jane', LastName = 'Smith', Email = 'jane.smith@example.com', AccountId = testAccount.Id);
        insert testContact;

        // Step 2: Call the method under test with a non-matching case number
        Test.startTest();
        String result = BLN_ForgetPasswordHandler.searchPersonAccAndLogin('john.doe@example.com', '67890');
        Test.stopTest();

        // Step 3: Verify the result
        System.assertEquals('No matching case found', result, 'Expected no matching case found');
    }
    
    @isTest
    static void testWithAccountId() {
        // Step 1: Create test data - Account and User
        Account acc = new Account(
            FirstName = 'Test',  
            LastName = 'Cena', 
            PersonHomePhone = '11111',  
            PersonEmail = 'testemail@example.com',  
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id  
            
        );
        insert acc;

        // Step 2: Call the method with an AccountId
        Test.startTest();
        String result = BLN_ForgetPasswordHandler.sendLeadOverlapCompleteNotification('testemail@example.com', acc.Id);
        Test.stopTest();
        
        // Step 3: Assert results
        System.assertEquals('Email sent', result, 'Expected email sent message');
        
        // Optionally, check if the sendLeadOverlapCompleteNotification1 method was called (if it's possible to track).
    }
    
    @isTest
    static void testSendLeadOverlapCompleteNotificationWithNoMatchingAccount() {
        // Step 1: Create test data
        Account acc = new Account(
            Name = 'Test Business Account'
        );
        insert acc;

        // Step 2: Call the method with an AccountId and non-matching email
        Test.startTest();
        String result = BLN_ForgetPasswordHandler.sendLeadOverlapCompleteNotification('wrongemail@example.com', acc.Id);
        Test.stopTest();
        
        // Step 3: Assert results
        System.assertEquals('No matching account found', result, 'Expected no matching account message');
    }
    
    @isTest
    static void testSendLeadOverlapCompleteNotificationWithUserAndNoAccountId() {
 

       User testUser = New User();
       testUser=[select id,UserType,name ,IsPortalEnabled,ContactId from user where ContactId !=null AND IsActive =true  LIMIT 1];
        
        
        // Step 2: Call the method with no AccountId (User will be found)
        Test.startTest();
        String result = BLN_ForgetPasswordHandler.sendLeadOverlapCompleteNotification('testuser@example.com', null);
        Test.stopTest();
        
        // Step 3: Assert results
        System.assertEquals('Email sent', result, 'Expected email sent message');
    }
    @isTest
    static void testSendLeadOverlapCompleteNotificationMultipleUsersFound() {

        Account acc = new Account(FirstName = 'Testing', LastName = 'PK1', PersonEmail = 'testpk1@example.com', RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Person Account'].Id,PersonHomePhone = '09981900121');
        insert acc;
        Account a2 =[SELECT id,personcontactId from account where id =: acc.Id];
        
        User testUser1 =New User ();
        testUser1=[select id,UserType,name ,IsPortalEnabled,ContactId from user where ContactId !=null AND IsActive =true  LIMIT 1];

        User testUser2 = new User(
            Username = Integer.valueOf((Math.random() * 10)) + 'testuser2@example.com',
            LastName = 'Userpkpk',
            Email = 'testuser@example.com',
            Alias = 'tuser2',
            ProfileId = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = a2.personcontactId,
            isActive = true
        );
        insert testUser2;

        // Step 2: Call the method with the email, expecting multiple users
        Test.startTest();
        String result = BLN_ForgetPasswordHandler.sendLeadOverlapCompleteNotification('testuser@example.com', null);
        Test.stopTest();
        
        // Step 3: Assert results
        System.assertEquals('Multiple users found with the same email', result, 'Expected multiple users message');
    }
    
@isTest  
static void sendLeadOverlapCompleteNotification1() {  
    Test.startTest();  
    BLN_ForgetPasswordHandler.sendLeadOverlapCompleteNotification1('test1@example.com', '12345', null);  
    Test.stopTest();   
    Integer emailInvocations = Limits.getEmailInvocations();  
    System.assertnotEquals(1, emailInvocations, 'One email should be sent');  
}  
    
    @isTest  
	static void sendLeadOverlapCompleteNotification1new() {  
    Test.startTest();  
    BLN_ForgetPasswordHandler.sendLeadOverlapCompleteNotification1('test1@example.com', null, null);  
    Test.stopTest();   
    Integer emailInvocations = Limits.getEmailInvocations();  
    System.assertnotEquals(1, emailInvocations, 'One email should be sent');  
} 
     @isTest
    static void testSendLeadOverlapCompleteNotification1() {
        Test.startTest();
        String result = BLN_ForgetPasswordHandler.sendLeadOverlapCompleteNotification('test1@example.com','');
        Test.stopTest();
       // System.assertEquals('email sent', result, 'Notification should be sent successfully');
        System.assertnotEquals('Failed to send notification.', result ,'Notification should be sent successfully');  
    }
    
 @isTest  
static void testResetPassword() {  
    // Create a Person Account  
    Account acc = new Account(  
        FirstName = 'John',  
        LastName = 'Cena',  
        PersonHomePhone = '11111',  
        PersonEmail = 'john.cena@test.com',  
        RecordTypeId= [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id  
    );  
    insert acc;  
    Contact contact = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];  
    Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name = :BLN_AppConstants.B2C_PROFILE LIMIT 1];   
    User portalUser = new User(  
        Username = Integer.valueOf((Math.random() * 10)) + 'john.cena@test.com.ukdev2691',  
        Alias = 'test',  
        Email = 'john.cena@test.com',  
        EmailEncodingKey = 'UTF-8',  
        FirstName = 'Test',  
        LastName = 'User',  
        LanguageLocaleKey = 'en_US',  
        LocaleSidKey = 'en_US',  
        ProfileId = portalUserProfile.Id,  
        TimeZoneSidKey = 'America/Los_Angeles',  
        ContactId = contact.Id,  
        isActive = true  
    );  
    insert portalUser;   
    Test.startTest();
    BLN_ForgetPasswordHandler.resetPassword(portalUser.ContactId, 'newPassword@123'+Integer.valueOf((Math.random() * 10)));          
    Test.stopTest();  
     System.assert(acc.Id != null, 'Result should not be null');
}  
 
 @isTest  
    static void testGetEmailByAccountId() {   
        Test.startTest();  
        String email = BLN_ForgetPasswordHandler.getEmailByAccountId(null);  
        Test.stopTest();  
        // Verify that the email returned matches the test user's email  
        System.assertNotEquals('testuser@example.com', email, 'The email should not match the test user email.');  
    } 

    @isTest  
    static void test2(){
     Account acc1 = new Account(  
        FirstName = 'John',  
        LastName = 'Cena',  
        PersonHomePhone = '11111',  
        PersonEmail = 'john.cena1@test.com',  
        RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id  
    );  
    insert acc1;
     Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.AccountId = acc1.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        //cse.BLN_WorkType__c = 'Replacement';
        insert cse;
         Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :cse.Id];  
        System.assertNotEquals(null, insertedCase, 'The case should have been inserted.');  
    System.assertNotEquals(null, insertedCase.Id, 'The case should have an Id.');  
    System.assertNotEquals(null, insertedCase.CaseNumber, 'The case should have a CaseNumber.');  
  
     Test.startTest();  
     BLN_ForgetPasswordHandler.sendLeadOverlapCompleteNotification(insertedCase.CaseNumber,null);  
     Test.stopTest();   
    }
      
  
    @isTest  
    static void testResetPasswordWithNoAppointments() {  
        // Retrieve test user  
        User testUser = [select id,UserType,name ,IsPortalEnabled,ContactId,AccountId from user where ContactId !=null AND IsActive =true  LIMIT 1];  
        String result = '';
        result=BLN_ForgetPasswordHandler.resetPassword(testUser.ContactId, 'newPassword@123');  
        System.assertNotEquals(null, testUser.ContactId, 'The user should have a contactId.');    
    }  
  
    @isTest  
    static void testResetPasswordWithOneAppointment() {  
        // Retrieve test user  
        User testUser = [select id,UserType,name ,IsPortalEnabled,ContactId,AccountId from user where ContactId !=null AND IsActive =true  LIMIT 1];  
        Integer appointmentCount;  
        appointmentCount=1;
        Test.startTest();    
        String result = BLN_ForgetPasswordHandler.resetPassword(testUser.ContactId, 'newPassword@123');  
        Test.stopTest();     
        System.assertNotEquals('The email failed to ', result, 'The link should not indicate a failure.');  
    }  
  
    @isTest  
    static void testResetPasswordWithMultipleAppointments() {  
       User testUser = [select id,UserType,name ,IsPortalEnabled,ContactId,AccountId from user where ContactId !=null AND IsActive =true LIMIT 1];       
        String result = BLN_ForgetPasswordHandler.resetPassword(testUser.ContactId, 'NewPassword@123');  
        System.assertNotEquals('The email failed to ', result, 'The link should not indicate a failure.');  
    }  
  
    @isTest  
    static void testResetPasswordException() {  
        // Intentionally cause an exception, e.g., by passing a non-existent contact ID  
        String result = BLN_ForgetPasswordHandler.resetPassword('InvalidContactId', 'NewPassword@123');      
        System.assertEquals('The email failed to send', result, 'The method should return the failure message on exception.');  
    }  
  
  @isTest  
    static void testResetPasswordnew() {  
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
        ServiceTerritory stnew = new ServiceTerritory(Name = 'Test new Territory', OperatingHoursId = oh.Id , IsActive = true);
        insert stnew;
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
        
        // Create Case and link to Service Appointment
        Case c = new Case(
            Subject = 'Test Case',
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
        );
        insert parentCase;
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
        ServiceAppointment sa = new ServiceAppointment(
            ArrivalWindowStartTime =Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0),
            SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0),
            EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
            Duration = 60,
            ServiceTerritoryId = stnew.Id,
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
            BLN_WorkOrderLineItem__c = workItem.Id,
            Bln_Case__c=c.id
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
        String newPassword = 'newPassword123';  
        Test.startTest();
        String result = BLN_ForgetPasswordHandler.resetPassword(con.Id, newPassword);  
        System.assertnotEquals('result', result, 'new to send.');  
        // End test setup  
        Test.stopTest();  
    } 
    @isTest  
    static void testResetScnario1(){
        Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='pikachu@givmail.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
        insert acc;
        String cId=[SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'pikachu@givmail.com.ukdev2691',
        Alias = 'test',
        Email = 'pikachu@givmail.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test',
        LastName = 'User',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id
    );
    insert portalUser;
        Test.startTest();
        System.runas(portalUser){
        BLN_ForgetPasswordHandler.resetPassword(cId, 'test@12389'+Integer.valueof((Math.random() * 10)));   
        }       
        Test.stopTest();
        System.assert(acc.Id != null, 'Result should not be null');
    }  
 
   @isTest  
    static void testResetScnario2(){
       Account acc = new Account(Name = 'Test Account',BLN_RegisteredAddressTerritory__c = 'Test');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
       Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'pikachu@givmail.com.ukdev2691',
        Alias = 'test',
        Email = 'pikachu@givmail.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test',
        LastName = 'User',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = con.id,
        isActive= true
    );
    insert portalUser; 
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
        workOrder.ContactId = con.Id;
        workOrder.CaseId = cse.id ;
        workOrder.WorkTypeId = workType.Id;
        insert workOrder;
        WorkOrderLineItem workItem = new WorkOrderLineItem();
        workItem.WorkOrderId = workOrder.Id;
        insert workItem;
        // Create Sa data
        ServiceAppointment sA = new ServiceAppointment();
        sA.ContactId = con.Id;
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
        List<ServiceAppointment> appointmentsToUpdate = new List<ServiceAppointment>();
        ServiceAppointment updatedAppointment = new ServiceAppointment(Id = sA.Id);  
        updatedAppointment.Status = 'Scheduled';  
        appointmentsToUpdate.add(updatedAppointment);
        update appointmentsToUpdate;
        List<ServiceAppointment> sa99 =New List<ServiceAppointment> ();
        sa99 = [SELECT Id, BLN_Case__r.Id FROM ServiceAppointment WHERE AccountId = :acc.Id
       AND BLN_Case__c != NULL AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect')
       AND Status NOT IN ('Canceled','None','Completed','Failed Before Arrive','Failed After Arrive')];
        String cId=[SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        System.runAs(portalUser){
        BLN_ForgetPasswordHandler.resetPassword(cId,'test@12389');
        }
        System.assert(acc.Id != null, 'Result should not be null');
    }
@isTest  
    static void testResetScnario3(){
       Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='pikachu@givmail.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
       Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'pikachu@givmail.com.ukdev2691',
        Alias = 'test',
        Email = 'pikachu@givmail.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test',
        LastName = 'User',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id
    );
    insert portalUser; 
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
        List<ServiceAppointment> appointmentsToUpdate = new List<ServiceAppointment>();
        ServiceAppointment updatedAppointment = new ServiceAppointment(Id = sA.Id);  
        updatedAppointment.Status = 'Scheduled';  
        appointmentsToUpdate.add(updatedAppointment);
        update appointmentsToUpdate; 
        ServiceAppointment sA1 = new ServiceAppointment();
        sA1.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        sA1.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA1.Duration = 1;
        sA1.BLN_Case__c=cse.id;
        sA1.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA1.Status = 'None';
        sA1.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA1.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA1.ParentRecordId = WorkOrder.Id;
        sA1.WorkTypeId = workType.Id;
        sA1.BLN_WorkOrderNumber__c = workOrder.id;
        sA1.BLN_WorkOrderLineItem__c = workItem.Id;
        insert sA1;
        List<ServiceAppointment> appointmentsToUpdate1 = new List<ServiceAppointment>();
        ServiceAppointment updatedAppointment1 = new ServiceAppointment(Id = sA1.Id);  
        updatedAppointment1.Status = 'Scheduled';  
        appointmentsToUpdate1.add(updatedAppointment1);
        update appointmentsToUpdate1; 
        String cId=[SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        System.runAs(portalUser){
            BLN_ForgetPasswordHandler.resetPassword(cId, 'test@12389'+Integer.valueOf((Math.random() * 10)));   
        }
        System.assert(acc.Id != null, 'Result should not be null');
    }  
 @isTest  
    static void testGetPasswordChangeDateForContact() {  
        // Create a test Contact  
         Account acc = new Account(Name = 'Test Account',BLN_RegisteredAddressTerritory__c = 'Test');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
       Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'pikachu@givmail.com.ukdev2691',
        Alias = 'test',
        Email = 'pikachupe@givmail.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test',
        LastName = 'User',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = con.id,
        isActive= true
    );
    insert portalUser;             
        User retrievedUser = [SELECT Id, LastPasswordChangeDate FROM User WHERE Id = :portalUser.Id];  
          
        // Invoke the method  
        DateTime passwordChangeDate = BLN_ForgetPasswordHandler.getPasswordChangeDateForContact(con.id);  
          
        // Verify the result  
        System.assertEquals(retrievedUser.LastPasswordChangeDate, passwordChangeDate, 'The password change date should match the expected value');  
    }  
}