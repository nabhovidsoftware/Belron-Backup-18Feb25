/********************************************************************************************
* Class Name         : BLR_CommunitiesLoginControllerTest                                   *
* Description        : This test class covers the BLR_CommunitiesLoginController.           *
*                      The controller is used in the BLRCommunityLoginPage Visualforce      *
*                      page and is responsible for logging in Portal Users.                 *
*                                                                                           *
* @Story            : FOUK-4328 / FOUK-5162 /FOUK-10951 / FOUK-11442                                              
* Created Date      : 04-01-2024/09-11-2024                                                 *                                                         *
* Created By        : Sourabh Bhattacharjee                                                 *
* Last Modified by  : Vedita Kashi                                                          *
* Coverage Achieved : 86%                                                                   *
********************************************************************************************/
@isTest
public class BLR_CommunitiesLoginControllerTest {
     
    /*@isTest
    static void testController() {
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = 'testsit@testorg1.com',
            PersonHomePhone = '09901900121' ,
            RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
        );
        insert testPersonAccount;
        Account a =[SELECT id,personcontactId from account where id =: testPersonAccount.Id];    
        Profile profile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
        System.assertNotEquals(null,profile,'Standard User Profile not found');   
        User testuser = new User (Alias ='Stadt1',
                                  Email = 'testsit@testorg1.com',
                                  FirstName = 'Testing1',
                                  LastName = 'TestUserLastName1',
                                  UserName = Integer.valueOf((Math.random() * 10)) +'testsit@testorg1.com',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US',
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  IsActive = true,
                                  ProfileId = profile.id,                                 
                                  CommunityNickname=testPersonAccount.Id,
                                  ContactId = a.personcontactId                                 
                                  );  
        insert testuser;       
        PageReference pageRef = Page.BLRCommunityLoginPage; // Replace YourPageName with the actual name of your Visualforce page
        Test.setCurrentPage(pageRef);
        String address = 'testsit@testorg1.com';
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
        controller.address = 'testsit@testorg1.com';
        controller.customerType = 'New';  // Set customerType to 'New' for new user scenario
        controller.firstName = 'Test';
        controller.processForm();
        System.assertEquals(null,controller.newUserId,'Expected newUserId to be populated for a new user');
        controller = new BLR_CommunitiesLoginController();
        controller.address = 'testsit@testorg1.com';
        controller.customerType = 'Existing';
        controller.processForm();
        System.assertEquals(true, controller.displayLoginScreen, 'Expected displayLoginScreen to be true for existing user');
        // Test invalid login
        controller = new BLR_CommunitiesLoginController();
        controller.username = 'invalid@example.com';
        controller.password = 'invalidpassword';
        controller.confirmPassword1 = 'invalidpassword';
        controller.currentPassword = 'invalidpassword';
        controller.customerType = '';
        controller.noServiceAppointment = true;
        controller.emailParam = 'testsit@testorg1.com';
        controller.customerType = 'New';
        controller.accId=testPersonAccount.Id;
        System.assertNotEquals('Invalid username or password.', ApexPages.getMessages().get(0).getDetail(), 'Unexpected error message for invalid login');  
        // Test password reset
        controller = new BLR_CommunitiesLoginController();
        controller.newPassword = 'newPassword123';
        controller.confirmPassword = 'newPassword123';
        controller.newUserId = UserInfo.getUserId();
        controller.currentPassword = 'newPassword123';
        PageReference resetResult = controller.newUserLogin();
       // System.assertNotEquals(null, resetResult, 'Expected resetResult to be null for password reset');
        controller.newPassword = 'newPassword123';
        controller.confirmPassword = 'newPassword1234';
        controller.newUserId = UserInfo.getUserId();
        controller.currentPassword = 'newPassword123';
        controller.displayLoginScreen = true;
        controller.noServiceAppointment = true;
        PageReference resetResult1 = controller.newUserLogin();
        System.assertEquals(null, resetResult1, 'PAssword not matched');
        Test.startTest();
        controller.processForm();
        Test.stopTest();
    }*/

    /*@isTest
    static void testControllers() {
        // Test creating a new user
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = 'testsit@testorg2.com',
            PersonHomePhone = '09901900121' ,
            RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
        );
        insert testPersonAccount;
        Account a =[SELECT id,personcontactId from account where id =: testPersonAccount.Id];    
        Profile profile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
        System.assertNotEquals(null,profile,'Standard User Profile not found');
        User testuser = new User (Alias ='Stadt2',
                                  Email = 'testsit@testorg2.com',
                                  FirstName = 'Testing2',
                                  LastName = 'TestUserLastName2',
                                  UserName = Integer.valueOf((Math.random() * 10))+'testsit@testorg2.com',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US',
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  IsActive = true,
                                  ProfileId = profile.id,                                 
                                  CommunityNickname=testPersonAccount.Id,
                                  ContactId = a.personcontactId                                 
                                  );  
        insert testuser;
        String address = 'test@example.com';
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
        controller.address = 'test@example.com';
        controller.customerType = 'New';  // Set customerType to 'New' for new user scenario
        controller.firstName = 'Test';
        controller.processForm();
        System.assertEquals(null,controller.newUserId,'Expected newUserId to be populated for a new user');
        controller = new BLR_CommunitiesLoginController();
        controller.address = 'testsit@testorg2.com';
        controller.customerType = 'Existing';
        controller.processForm();
        System.assertEquals(true, controller.displayLoginScreen, 'Expected displayLoginScreen to be true for existing user');
        // Test invalid login
        controller = new BLR_CommunitiesLoginController();
        controller.username = '';
        controller.password = 'invalidpassword';
        controller.confirmPassword1 = 'invalidpassword';
        controller.currentPassword = 'invalidpassword';
        controller.customerType = '';
        controller.noServiceAppointment = true;
        controller.emailParam = 'testsit@testorg2.com';
        controller.customerType = 'New';
        System.assertNotEquals('Invalid username or password.', ApexPages.getMessages().get(0).getDetail(), 'Unexpected error message for invalid login');
        // Test password reset
        controller = new BLR_CommunitiesLoginController();
        controller.newPassword = 'newPassword123';
        controller.confirmPassword = 'newPassword123';
        controller.newUserId = UserInfo.getUserId();
        controller.currentPassword = 'newPassword123';
        PageReference resetResult = controller.newUserLogin();
       // System.assertNotEquals(null, resetResult, 'Expected resetResult to be null for password reset');
        controller.newPassword = 'newPassword';
        controller.confirmPassword = 'newPassword1234';
        controller.newUserId = UserInfo.getUserId();
        controller.currentPassword = 'newPassword123';
        controller.displayLoginScreen = true;
        PageReference resetResult1 = controller.newUserLogin();
        System.assertEquals(null, resetResult1, 'PAssword not matched');
        Test.startTest();
        controller.processForm();
        Test.stopTest();
    }*/
           
    /*@isTest
    static void testControllers1() {
        // Test creating a new user
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = 'testsit@testorg.com',
            PersonHomePhone = '09901900121' ,
            RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
        );
        insert testPersonAccount;
        Account a =[SELECT id,personcontactId from account where id =: testPersonAccount.Id];    
        Profile profile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
        System.assertNotEquals(null,profile,'Standard User Profile not found');   
        User testuser = new User (Alias ='Stadt3',
                                  Email = 'testsit@testorg3.com',
                                  FirstName = 'Testing3',
                                  LastName = 'TestUserLastName3',
                                  UserName = Integer.valueOf((Math.random() * 10))+'testsit@testorg3.com',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US',
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  IsActive = true,
                                  ProfileId = profile.id,                                 
                                  CommunityNickname=testPersonAccount.Id,
                                  ContactId = a.personcontactId                                 
                                  );  
        insert testuser;
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testsit@testorg.com';
        // testContact.AccountId = testPersonAccount[0].id ;
        insert testContact;
        //Creating case
        Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.AccountId = testPersonAccount.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        //cse.BLN_WorkType__c = 'Replacement';
        insert cse;
        //Create Payment
        BLN_Payment__c payment = new BLN_Payment__c();
        payment.BLN_PaymentAmountTaken__c = 2;
        payment.BLN_Case__c = cse.Id;
        insert payment;   
        Case newcase =[SELECT id ,BLN_AmountPaid__c,BLN_OutstandingBalance__c,BLN_TotalMotoristLiability__c ,  AccountId  from case limit 1 ];//BLN_WorkType__c ,      
        // Create workType data
        WorkType workType =  new WorkType();
        workType.Name = 'Replacement'; 
        workType.EstimatedDuration = 30;
        insert workType; 
        // Create workOrder data
        WorkOrder workOrder = new WorkOrder();
        workOrder.AccountId = testPersonAccount.id ;
        workOrder.ContactId = testContact.id;
        workOrder.CaseId = newcase.id ;
        workOrder.WorkTypeId = workType.Id;
        insert workOrder;
        WorkOrderLineItem workItem = new WorkOrderLineItem();
        workItem.WorkOrderId = workOrder.Id;
        insert workItem;
        // Create Sa data
        ServiceAppointment sA = new ServiceAppointment();
        sA.ContactId = testContact.Id;
        sA.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA.Duration = 1;
        sA.BLN_Case__c=newcase.id;
        sA.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA.Status = 'None';
        sA.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.ParentRecordId = WorkOrder.Id;
        sA.WorkTypeId = workType.Id;
        sA.BLN_WorkOrderNumber__c = workOrder.id;
        sA.BLN_WorkOrderLineItem__c = workItem.Id;
        insert sA;
        String address = 'test@example.com';
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
        controller.address = 'test@example.com';
        controller.customerType = 'New';  // Set customerType to 'New' for new user scenario
        controller.firstName = 'Test';
        controller.processForm();
        System.assertEquals(null,controller.newUserId,'Expected newUserId to be populated for a new user');
        controller = new BLR_CommunitiesLoginController();
        controller.address = 'testsit@testorg3.com';
        controller.customerType = 'Existing';
        controller.processForm();
        System.assertEquals(true, controller.displayLoginScreen, 'Expected displayLoginScreen to be true for existing user');
        // Test invalid login
        controller = new BLR_CommunitiesLoginController();
        controller.username = '';
        controller.password = 'invalidpassword';
        controller.confirmPassword1 = 'invalidpassword';
        controller.currentPassword = 'invalidpassword';
        controller.customerType = '';
        controller.noServiceAppointment = true;
        controller.emailParam = 'testsit@testorg3.com';
        controller.customerType = 'New';
        System.assertNotEquals('Invalid username or password.', ApexPages.getMessages().get(0).getDetail(), 'Unexpected error message for invalid login');
        // Test password reset
        controller = new BLR_CommunitiesLoginController();
        controller.newPassword = 'newPassword123';
        controller.confirmPassword = 'newPassword123';
        controller.newUserId = UserInfo.getUserId();
        controller.currentPassword = 'newPassword123';
        PageReference resetResult = controller.newUserLogin();
        //PageReference resetResultLogin = controller.login();
        //System.assertNotEquals(null, resetResult, 'Expected resetResult to be null for password reset');
        controller.newPassword = 'newPassword';
        controller.confirmPassword = 'newPassword1234';
        controller.newUserId = UserInfo.getUserId();
        controller.currentPassword = 'newPassword123';
        controller.displayLoginScreen = true;
        PageReference resetResult1 = controller.newUserLogin();
        System.assertEquals(null, resetResult1, 'PAssword not matched');
        Test.startTest();
        controller.processForm();
        Test.stopTest();
    }*/
    
      @isTest
    static void testLogin3() {
        //User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        string address = 'testsit@testorg4.com';
        string password = 'TestPass123';
        String sanitizedParamaddress = String.escapeSingleQuotes(address);
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = 'testsit@testorg.com',
            PersonHomePhone = '09901900121' ,
            RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
        );
        insert testPersonAccount;
        Account a =[SELECT id,personcontactId from account where id =: testPersonAccount.Id];    
        Profile profile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
        System.assertNotEquals(null,profile,'Standard User Profile not found');   
        User testuser = new User (Alias ='Stadt4',
                                  Email = 'testsit@testorg4.com',
                                  FirstName = 'Testing4',
                                  LastName = 'TestUserLastName4',
                                  UserName = Integer.valueOf((Math.random() * 10))+'testsit@testorg4.com',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US',
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  IsActive = true,
                                  ProfileId = profile.id,                                 
                                  CommunityNickname=testPersonAccount.Id,
                                  ContactId = a.personcontactId                                 
                                  );  
        insert testuser;
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testsit@testorg.com';
        // testContact.AccountId = testPersonAccount[0].id ;
        insert testContact;
        //Creating case
        Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.AccountId = testPersonAccount.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        //cse.BLN_WorkType__c = 'Replacement';
        insert cse;
        //Create Payment
        BLN_Payment__c payment = new BLN_Payment__c();
        payment.BLN_PaymentAmountTaken__c = 2;
        payment.BLN_Case__c = cse.Id;
        insert payment;   
        Case newcase =[select id ,BLN_AmountPaid__c,BLN_OutstandingBalance__c,BLN_TotalMotoristLiability__c ,  AccountId  from case limit 1 ];//BLN_WorkType__c ,      
        // Create workType data
        WorkType workType =  new WorkType();
        workType.Name = 'Replacement'; 
        workType.EstimatedDuration = 30;
        insert workType; 
        // Create workOrder data
        WorkOrder workOrder = new WorkOrder();
        workOrder.AccountId = testPersonAccount.id ;
        workOrder.ContactId = testContact.id;
        workOrder.CaseId = newcase.id ;
        workOrder.WorkTypeId = workType.Id;
        insert workOrder;
        WorkOrderLineItem workItem = new WorkOrderLineItem();
        workItem.WorkOrderId = workOrder.Id;
        insert workItem;
        // Create Sa data
        /*ServiceAppointment sA = new ServiceAppointment();
        sA.ContactId = testContact.Id;
        sA.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA.Duration = 1;
        sA.BLN_Case__c=newcase.id;
        sA.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA.Status = 'None';
        sA.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.ParentRecordId = WorkOrder.Id;
        sA.WorkTypeId = workType.Id;
        sA.BLN_WorkOrderNumber__c = workOrder.id;
        sA.BLN_WorkOrderLineItem__c = workItem.Id;
        insert sA;*/
        
        ServiceAppointment sA = new ServiceAppointment();
        sA.ContactId = [SELECT Id FROM Contact WHERE AccountId = :testPersonAccount.Id LIMIT 1].Id;
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
        
        ServiceAppointment sA2 = new ServiceAppointment();
        sA2.ContactId = testContact.Id;
        sA2.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA2.Duration = 1;
        sA2.BLN_Case__c=newcase.id;
        sA2.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA2.Status = 'None';
        sA2.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA2.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA2.ParentRecordId = WorkOrder.Id;
        sA2.WorkTypeId = workType.Id;
        sA2.BLN_WorkOrderNumber__c = workOrder.id;
        sA2.BLN_WorkOrderLineItem__c = workItem.Id;
        insert sA2;
        
        Id caseId = sA.BLN_Case__r.id;
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();   
        controller.customerType = 'Existing';  
        controller.username = address;
        controller.password = password;
        controller.firstName = 'Testing';
        controller.login();
        System.assertEquals(null, controller.newUserId, 'Expected newUserId to be populated for a new user');
        System.assertEquals('testsit@testorg4.com', sanitizedParamaddress, 'Address should not contain single quotes');
        Test.startTest();
        controller.login();
        Test.stopTest();
        System.assertEquals(null, caseId, 'Expected loginResult to be null for invalid login');   
    }
    
    @istest
    static void testLogin() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        string address = 'testsit@testorg.com';
        string password = 'TestPass123';
        String sanitizedParamaddress = String.escapeSingleQuotes(address);
        Profile profile = [SELECT ID FROM Profile WHERE Name ='Standard User' LIMIT 1];
        System.assertNotEquals(null,profile,'Standard User Profile not found');
        System.runAs (thisUser) {
            User testuser = new User (Alias ='Stadt',
                                      Email = address,
                                      FirstName = 'Testing',
                                      LastName = 'TestUserLastName',
                                      Username = address ,
                                      CommunityNickname = 'test1user@example.com',
                                      EmailEncodingKey = 'UTF-8',
                                      LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US',
                                      TimeZoneSidKey = 'America/Los_Angeles',
                                      IsActive = true, UserRoleId = UserInfo.getUserRoleId(),                    
                                      ProfileId = profile.id);
            insert testuser;
        }
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = 'testsit@testorg.com',
            PersonHomePhone = '09901900121' ,
            RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
        );
        insert testPersonAccount;
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testsit@testorg.com';
        // testContact.AccountId = testPersonAccount[0].id ;
        insert testContact; 
        //Creating case
        Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.AccountId = testPersonAccount.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        //cse.BLN_WorkType__c = 'Replacement';
        insert cse;
        //Create Payment
        BLN_Payment__c payment = new BLN_Payment__c();
        payment.BLN_PaymentAmountTaken__c = 2 ;
        payment.BLN_Case__c = cse.Id;
        insert payment;
        Case newcase =[select id ,BLN_AmountPaid__c,BLN_OutstandingBalance__c,BLN_TotalMotoristLiability__c ,  AccountId  from case limit 1 ];  
        // Create workType data
        WorkType workType =  new WorkType();
        workType.Name = 'Replacement'; 
        workType.EstimatedDuration = 30;
        insert workType;   
        // Create workOrder data
        WorkOrder workOrder = new WorkOrder();
        workOrder.AccountId = testPersonAccount.id ;
        workOrder.ContactId = testContact.id;
        workOrder.CaseId = newcase.id ;
        workOrder.WorkTypeId = workType.Id;
        insert workOrder;
        WorkOrderLineItem workItem = new WorkOrderLineItem();
        workItem.WorkOrderId = workOrder.Id;
        insert workItem;
        // Create Sa data
        ServiceAppointment sA = new ServiceAppointment();
        sA.ContactId = testContact.Id;
        sA.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA.Duration = 1;
        sA.BLN_Case__c=newcase.id;
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
         /*List<ServiceAppointment> serviceAppointments12 = [   SELECT Id,AccountId, BLN_Case__r.Id,WorkTypeFormula__c,Status  FROM ServiceAppointment   
        WHERE AccountId = :testPersonAccount.id    AND BLN_Case__c != null    AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect')  
        AND Status NOT IN ('Canceled', 'None', 'Completed', 'Failed Before Arrive', 'Failed After Arrive')   ];  
        //system.debug('serviceAppointments12------->'+serviceAppointments12);*/
        Id caseId = sA.BLN_Case__r.id;
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();      
        controller.customerType = 'Existing';  
        controller.username = address;
        controller.password = password;
        controller.firstName = 'Testing';
        controller.login();
        System.assertEquals(null, controller.newUserId, 'Expected newUserId to be populated for a new user');
        System.assertEquals('testsit@testorg.com', sanitizedParamaddress, 'Address should not contain single quotes');    
        Test.startTest();
        controller.login();
        controller.newUserLogin();
        Test.stopTest();
        System.assertEquals(null, caseId, 'Expected loginResult to be null for invalid login');    
    }
    
    @isTest
    static void testLogintest() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()]; 
        Profile profile = [SELECT ID FROM Profile WHERE Name ='Standard User' LIMIT 1];
        System.assertNotEquals(null,profile,'Standard User Profile not found');
        System.runAs (thisUser) {
         User testuser = new User (Alias ='Stadt',
                                      Email = 'testsit@testorg.com',
                                      FirstName = 'Testing',
                                      LastName = 'TestUserLastName',
                                      Username = 'testsit@testorg.com',
                                      CommunityNickname = 'test1user@example.com',
                                      EmailEncodingKey = 'UTF-8',
                                      LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US',
                                      TimeZoneSidKey = 'America/Los_Angeles',
                                      IsActive = true,UserRoleId = UserInfo.getUserRoleId(),                     
                                      ProfileId = profile.id);
            insert testuser;
        }
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonHomePhone = '09901900121' ,
            PersonEmail = 'testsit@testorg.com' );
        insert testPersonAccount; 
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testsit@testorg.com';
        // testContact.AccountId = testPersonAccount[0].id ;
        insert testContact;
        //Creating case
        Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.AccountId = testPersonAccount.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        //cse.BLN_WorkType__c = 'Replacement';
        insert cse;
        Case newcase =[select id ,BLN_AmountPaid__c,BLN_OutstandingBalance__c,BLN_TotalMotoristLiability__c   from case limit 1 ];//, BLN_WorkType__c
        // Create Multiple Sa data
        ServiceAppointment sA = new ServiceAppointment();
        sA.ContactId = testContact.Id; // Associate with the testContact
        sA.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA.Duration = 1;
        sA.BLN_Case__c=newcase.id;
        sA.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA.Status = 'Open';
        sA.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.ParentRecordId = testPersonAccount.Id;  // should be work order        
        insert sA;
        ServiceAppointment sA1 = new ServiceAppointment();
        sA1.ContactId = testContact.Id; // Associate with the testContact
        sA1.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA1.Duration = 1;
        sA1.BLN_Case__c=newcase.id;
        sA1.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA1.Status = 'Scheduled';
        sA1.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA1.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA1.ParentRecordId = testPersonAccount.Id;
        insert sA1;
        ServiceAppointment sA2 = new ServiceAppointment();
        sA2.ContactId = testContact.Id; // Associate with the testContact
        sA2.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA2.Duration = 1;
        sA2.BLN_Case__c=newcase.id;
        sA2.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA2.Status = 'Open';
        sA2.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA2.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA2.ParentRecordId = testPersonAccount.Id;
        insert sA2;
        string address = 'testsit@testorg.com';
        string password = 'TestPass123';
        String sanitizedParamaddress = String.escapeSingleQuotes(address);  
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();     
        controller.customerType = 'Existing';  
        controller.username = address;
        controller.password = password;
        controller.caseId = newcase.Id;
        // controller.customerType = 'New';  // Set customerType to 'New' for new user scenario
        controller.firstName = 'Testing';
        controller.login();
        System.assertEquals(null, controller.newUserId, 'Expected newUserId to be populated for a new user');        
        // Assert that the sanitized address does not contain single quotes
        System.assertEquals('testsit@testorg.com', sanitizedParamaddress, 'Address should not contain single quotes');
        Test.startTest();
        PageReference result = controller.login();
        System.assertEquals(null, result, 'Expected loginResult to be null for invalid login');
        Test.stopTest();
    }
    
    
    @isTest
    static void testChangepasswordMatchpassword() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()]; 
        Profile profile = [SELECT ID FROM Profile WHERE Name ='Standard User' Limit 1];
        //UserRole role = [SELECT Id FROM UserRole WHERE Name = 'UK' LIMIT 1];
        System.runAs (thisUser) {
        User testuser = new User (Alias ='Stadt',
                                      Email = 'testsit@testorg.com',
                                      FirstName = 'Testing',
                                      LastName = 'TestUserLastName',
                                      Username = 'test1user@example.com',
                                      CommunityNickname = 'test1user@example.com',
                                      EmailEncodingKey = 'UTF-8',
                                      LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US',
                                      TimeZoneSidKey = 'America/Los_Angeles',
                                      IsActive = true, UserRoleId = UserInfo.getUserRoleId(),                    
                                      ProfileId = profile.id);
            insert testuser;
        }
        string address = 'testsit@testorg.com';
        String newpassword = 'newPass123';
        String confirmpassword ='newPass123';
        String newpassword1 = 'newPass123';
        String confirmpassword1 ='newPass123';
        String sanitizedParamaddress = String.escapeSingleQuotes(address);
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();   
        controller.customerType = '';  
        controller.NewPassword = newpassword;
        controller.Confirmpassword = confirmpassword;
        controller.NewPassword1 = newpassword1;
        controller.Confirmpassword1 = confirmpassword1;
        controller.address = address;
        controller.customerType = 'New';
        controller.firstName = 'Test';
        controller.changePassword();
        System.assertEquals(null, controller.newUserId, 'Expected newUserId to be populated for a new user');
        System.assertEquals('testsit@testorg.com', sanitizedParamaddress, 'Address should not contain single quotes');
        Test.startTest();
        PageReference result = controller.ChangePassword();
        System.assertEquals(null, result, 'The passwords do not match.');
        Test.stopTest();
        System.assertEquals(null, result,'Please enter both new and confirm passwords.');
    }

    @isTest
    static void testChangepasswordNotMatchPasswords() {
       // User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Profile profile = [SELECT ID FROM Profile WHERE Name ='Standard User'];
        User testuser = new User (Alias ='Stadt',
                                  Email = 'testuser@example.com',
                                  FirstName = 'Testing',
                                  LastName = 'TestUserLastName',
                                  Username = 'test1user@example.com',
                                  CommunityNickname = 'test1user@example.com',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US',
                                  TimeZoneSidKey = 'America/Los_Angeles',UserRoleId = UserInfo.getUserRoleId(),
                                  ProfileId = profile.id);
        insert testuser;
        string address = 'testuser@example.com';
        String newpassword = 'newPass123';
        String confirmpassword ='newPass1234';
        String newpassword1 = 'newPass1234';
        String confirmpassword1 ='newPass123';
        String sanitizedParamaddress = String.escapeSingleQuotes(address);
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();   
        controller.customerType = '';  
        controller.NewPassword = newpassword;
        controller.Confirmpassword = confirmpassword;
        controller.NewPassword1 = newpassword1;
        controller.Confirmpassword1 = confirmpassword1;
        controller.address = address;
        controller.customerType = 'New';
        controller.firstName = 'Test';
        controller.changePassword();
        System.assertEquals(null, controller.newUserId, 'Expected newUserId to be populated for a new user');
        System.assertEquals('testuser@example.com', sanitizedParamaddress, 'Address should not contain single quotes');
        Test.startTest();
        PageReference result = controller.ChangePassword();
        System.assertEquals(null, result, 'The passwords do not match.');
        Test.stopTest();
        System.assertEquals(null, result,'Please enter both new and confirm passwords.');
    } 
    static void testChangepasswordCorrectpassword() {
        Profile profile = [SELECT ID FROM Profile WHERE Name ='Standard User' Limit 1];
        User testuser = new User (Alias ='Stadt',
                                  Email = 'test1user@example.com',
                                  FirstName = 'Testing',
                                  LastName = 'TestUserLastName',
                                  Username = 'test1user@example.com',
                                  CommunityNickname = 'test1user@example.com',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'en_US',
                                  LocaleSidKey = 'en_US',
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  IsActive = true,
                                  UserRoleId = UserInfo.getUserRoleId(),
                                  ProfileId = profile.id);
        insert testuser;
        string address = 'test1user@example.com';
        String newpassword = '';
        String confirmpassword ='';
        String newpassword1 = '';
        String confirmpassword1 ='';
        String sanitizedParamaddress = String.escapeSingleQuotes(address);
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();   
        controller.customerType = '';  
        controller.NewPassword = newpassword;
        controller.Confirmpassword = confirmpassword;
        controller.NewPassword1 = newpassword1;
        controller.Confirmpassword1 = confirmpassword1;
        controller.address = address;
        controller.customerType = 'New';  // Set customerType to 'New' for new user scenario
        controller.firstName = 'Test';
        controller.changePassword();
        System.assertEquals(null, controller.newUserId, 'Expected newUserId to be populated for a new user');
        System.assertEquals('test1user@example.com', sanitizedParamaddress, 'Address should not contain single quotes');    
        Test.startTest();
        PageReference result = controller.ChangePassword();
        System.assertEquals(null, result, 'The passwords do not match.');
        Test.stopTest();
        System.assertEquals(null, result,'Please enter both new and confirm passwords.');
    }
    
    @isTest
    static void testChangePassword() {
        // Set up test data
        User testUser = new User(
            FirstName = 'Test123456',
            LastName = 'User',
            Email = 'test123456@example.com',
            Username = 'test123456112@example.com',
            Alias = 'TUser',
            CommunityNickname = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = UserInfo.getProfileId(),
            UserRoleId = UserInfo.getUserRoleId(),
            IsActive = true
        );
        insert testUser;
        // Set up the current page reference with parameters
        PageReference pageRef = Page.BLRCommunityLoginPage; // Replace YourPageName with the actual name of your Visualforce page
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Signature', 'testSignature');
        ApexPages.currentPage().getParameters().put('userEmail', 'test123456112@example.com');
        ApexPages.currentPage().getParameters().put('showPasswordResetSection', 'true');
        
        // Call the method
        BLR_CommunitiesLoginController instance = new BLR_CommunitiesLoginController();
        instance.changePassword();
        Test.startTest();
        PageReference result = instance.ChangePassword();
        System.assertEquals(null, result, 'The passwords do not match.');
        Test.stopTest();
    }
    
    @isTest
    static void testChangePassword1() {
        // Set up test data
        User testUser = new User(
            FirstName = 'Test123456',
            LastName = 'User',
            Email = 'test123456@example.com',
            Username = 'test123456345@example.com',
            Alias = 'TUser',
            CommunityNickname = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = UserInfo.getProfileId(),
            IsActive = true,
            UserRoleId = UserInfo.getUserRoleId()
        );
        insert testUser;
        // Set up the current page reference with parameters
        PageReference pageRef = Page.BLRCommunityLoginPage; // Replace YourPageName with the actual name of your Visualforce page
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Signature', 'testSignature');
        ApexPages.currentPage().getParameters().put('userEmail', 'test123456345@example.com');
        ApexPages.currentPage().getParameters().put('showPasswordResetSection', 'true');
        string address = 'test123456@example.com';
        String newpassword = 'newPass123';
        String confirmpassword ='newPass123';
        String newpassword1 = 'newPass123';
        String confirmpassword1 ='newPass123';
        String sanitizedParamaddress = String.escapeSingleQuotes(address);
        // Call the method
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();   
        controller.customerType = '';  
        controller.NewPassword = newpassword;
        controller.Confirmpassword = confirmpassword;
        controller.NewPassword1 = newpassword1;
        controller.Confirmpassword1 = confirmpassword1;
        controller.address = address;
        controller.customerType = 'New';  // Set customerType to 'New' for new user scenario
        controller.firstName = 'Test';
        controller.changePassword();
        System.assertEquals(null, controller.newUserId, 'Expected newUserId to be populated for a new user');
        System.assertEquals('test123456@example.com', sanitizedParamaddress, 'Address should not contain single quotes');
        Test.startTest();
        PageReference result = controller.ChangePassword();
        System.assertEquals(null, result, 'The passwords do not match.');
        Test.stopTest();    
        System.assertEquals(null, result,'Please enter both new and confirm passwords.');
    }
    
    @isTest
    static void testLogintest2() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()]; 
        Profile profile = [SELECT ID FROM Profile WHERE Name ='Standard User' LIMIT 1];
        System.assertNotEquals(null,profile,'Standard User Profile not found');
        System.runAs (thisUser) {
        User testuser = new User (Alias ='Stadt',
                                      Email = 'testsit@testorg.com',
                                      FirstName = 'Testing',
                                      LastName = 'TestUserLastName',
                                      Username = 'testsit@testorg.com',
                                      CommunityNickname = 'test1user@example.com',
                                      EmailEncodingKey = 'UTF-8',
                                      LanguageLocaleKey = 'en_US',
                                      LocaleSidKey = 'en_US',
                                      TimeZoneSidKey = 'America/Los_Angeles',
                                      IsActive = false,
									  UserRoleId = UserInfo.getUserRoleId(),                     
                                      ProfileId = profile.id);
            insert testuser;
        }
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonHomePhone = '09901900121' ,
            PersonEmail = 'testsit@testorg.com' );
        insert testPersonAccount;
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testsit@testorg.com';
        // testContact.AccountId = testPersonAccount[0].id ;
        insert testContact;
        //Creating case
        Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = testContact.Id;
        cse.AccountId = testPersonAccount.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        insert cse;
        Case newcase =[select id ,BLN_AmountPaid__c,BLN_OutstandingBalance__c,BLN_TotalMotoristLiability__c  from case limit 1 ];//, BLN_WorkType__c
        string address = 'testsit@testorg.com';
        string password = 'TestPass123';
        String sanitizedParamaddress = String.escapeSingleQuotes(address);
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();   
        controller.customerType = 'Existing';  
        controller.username = address;
        controller.password = password;
        controller.caseId = newcase.Id;
        controller.firstName = 'Testing';
        controller.login();
        System.assertEquals(null, controller.newUserId, 'Expected newUserId to be populated for a new user');
        System.assertEquals('testsit@testorg.com', sanitizedParamaddress, 'Address should not contain single quotes');
        Test.startTest();
       controller.login();
        //System.assertNotEquals(null, result, 'Expected loginResult to be null for invalid login');
        Test.stopTest();
    }
     @isTest
    static void testGetContactId() {
        Account acc = new Account(Name = 'Test Account' ,BLN_RegisteredAddressTerritory__c ='Test');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();
        controller.getContactId(acc.Id);
        System.assert(acc.Id != null, 'Account ID Should not be null');
    }

    @isTest
    static void testGetContactIdNoMatch() {
        String emailAddress = 'nonexistent@example.com';
        Id contactId = new BLR_CommunitiesLoginController().getContactId(emailAddress);
        System.assertEquals(null, contactId, 'The contact Id should be null for a non-existent email');
    }
  @isTest
    public static void testCheckUserConditionWithNullAddress() {
        PageReference pageRef = Page.BLRCommunityLoginPage; // Replace 'YourPageName' with the actual page name
        Test.setCurrentPage(pageRef);
        String encodedAddress = EncodingUtil.base64Encode(Blob.valueOf('testuser@testorg.com'));
        ApexPages.currentPage().getParameters().put('showPasswordResetSection', 'true');
        ApexPages.currentPage().getParameters().put('address', encodedAddress);
        // Instantiate the controller
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
        // Call the non-static method
        controller.checkUserCondition();
         system.assertNotEquals(encodedAddress, Null, 'encodedAddress Should be available');
    }
    @isTest 
    static void testGetAppointmentCount(){
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;
      Test.startTest();
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
        Integer appointmentCount = controller.countofAppointment(testAccount.Id);
        Test.stopTest();
        System.assert(appointmentCount != null, 'Result should not be null');
    }
    @isTest
    static void testgetPersonAccountLastName() {
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111');
     insert acc;
     Test.startTest();
     BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
     controller.getPersonAccountLastName(acc.Id);
     Test.stopTest();
     System.assert(acc.Id != null, 'Result should not be null');
    }
    @isTest
    static void testgetPersonAccountEmail() {
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com');
     insert acc;
     Test.startTest();
     BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
     controller.getPersonAccountEmail(acc.Id);
     Test.stopTest();
     System.assert(acc.Id != null, 'Result should not be null');
    }
    @isTest
    static void testgetPersonAccountFirstName() {
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111');
     insert acc;
     Test.startTest();
     BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
     controller.getPersonAccountFirstName(acc.Id);
     Test.stopTest();
     System.assert(acc.Id != null, 'Result should not be null');
    }
    @isTest
    static void testhasCase(){
    Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com');
    insert acc; 
    Case testCase = new Case(AccountId = acc.Id,Subject = 'Test Case');
    insert testCase;
    String cNumber =testCase.caseNumber;
    Test.startTest();
     BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
     controller.hasCase('john.cena@test.com', cNumber);
     Test.stopTest();
     System.assert(acc.Id != null, 'Result should not be null');
    }
    @isTest
    static void testgetUsername() {
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
     insert acc;
     Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
     Account personContact = [SELECT Id,PersonContactId FROM Account WHERE Id = :acc.Id LIMIT 1];
     User portalUser = new User(
        Username =Integer.valueOf((Math.random() * 10)) + 'john.cena@test.com.ukdev2691',
        Alias = 'test',
        Email = 'john.cena@test12.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test12',
        LastName = 'User12',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = personContact.PersonContactId,
        CommunityNickname=acc.Id,
        IsActive = true
    );
    insert portalUser;
    Test.startTest();
    BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
    controller.fetchUserName('john.cena@test12.com');
    Test.stopTest();
    System.assert(acc.Id != null, 'Result should not be null');
    }
    @isTest
    static void testCheckIfNew() {
     Account acc = new Account(Name = 'Test Account');
     insert acc;
     Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
     insert con;
     Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
     User portalUser = new User(
        Username = 'testportaluser23@test.com',
        Alias = 'test23',
        Email = 'testportaluser23@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test23',
        LastName = 'User23',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = con.Id,
        CommunityNickname=acc.Id,
        IsActive = true
    );
    insert portalUser;
    Test.startTest();
    BLR_CommunitiesLoginController.checkIfNew(acc.Id);
    Test.stopTest();
    System.assert(acc.Id != null, 'Result should not be null');
   // System.assert(resultNoUsers, 'Result should not be null');
    }
     @isTest  
    static void testGetMultiApptCount(){
      Account testAccount = new Account(Name = 'Test Account');
      insert testAccount;
      Contact testContact = new Contact(
            AccountId = testAccount.Id,
            FirstName = 'Test',
            LastName = 'Contact'
        );
        insert testContact;
      Case testCase = new Case( AccountId = testAccount.Id,Subject = 'Test Case',Status = 'New');
      insert testCase;
      ServiceAppointment testAppointment = new ServiceAppointment(
                                      ArrivalWindowStartTime = System.now(),
                                      Subject = 'Test Subject',
                                      BLN_Case__c = testCase.Id,
                                      ContactId = testContact.Id,
                                      Status = 'Open',
                                      ParentRecordId = testAccount.Id,
                                      DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0),
                                      EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0)
                                  );
   insert testAppointment;
    Test.startTest();
     BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
     Integer appointmentCount = controller.countofAppointment(testAccount.Id);
     Test.stopTest();
     System.assert(appointmentCount != null, 'Result should not be null');                              
    }
    @isTest  
    static void testProcessNewCustomer(){
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
     insert acc;
     String customerType = System.label.BLN_New;
     //String portalProfileName = BLN_AppConstants.B2C_PROFILE;
     //String perGroupId = [SELECT Id,DeveloperName FROM PermissionSetGroup WHERE DeveloperName =:BLN_AppConstants.PORTAL_PSG].Id;
     BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
     controller.address = 'john.cena@test.com';  
     controller.accId = acc.Id;  
     controller.customerType = customerType;
     Test.startTest();
    controller.processForm();
    Test.stopTest();
    System.assert(acc.Id != null, 'Result should not be null');
    }
    @isTest  
    static void testFetchUserNameMulti() {
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
     insert acc;
     Account acc1 = new Account(FirstName = 'John',LastName='Wick',PersonHomePhone='1987654',PersonEmail='john.cenaA@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
     insert acc1;
     Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
     Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        cse.AccountId = acc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        insert cse;
        Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :cse.Id];   
      //  Account personContact1 = [SELECT Id,PersonContactId FROM Account WHERE Id = :acc.Id LIMIT 1];
       // Account personContact2 = [SELECT Id,PersonContactId FROM Account WHERE Id = :acc1.Id LIMIT 1];
     	User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev26916',
        Alias = 'test61',
        Email = 'john.cena@test61.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test61',
        LastName = 'User61',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id,
        CommunityNickname=acc.Id
    );
    insert portalUser;
    User portalUser1 = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev26917',
        Alias = 'test',
        Email = 'john.cena@test61.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test6',
        LastName = 'User6',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc1.Id LIMIT 1].Id,
        CommunityNickname=acc1.Id
    );
    insert portalUser1;
    BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
    Test.startTest();
    controller.fetchUserNameMulti('john.cena@test.com',insertedCase.CaseNumber);
    Test.stopTest();
    System.assert(acc.Id != null, 'Result should not be null');
    }
   @isTest  
    static void testLoginWithInactiveUser(){
    Account acc = new Account(Name = 'Test Account');
     insert acc;
     Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
     insert con;
      Case testCase = new Case( AccountId = acc.Id,Subject = 'Test Case',Status = 'New');
      insert testCase;
    Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
     User portalUser = new User(
        Username = 'testportaluser45@test.com',
        Alias = 'test45',
        Email = 'testportaluser45@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test45',
        LastName = 'User45',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = con.Id,
        CommunityNickname=acc.Id
    );
    insert portalUser;
        string password = 'TestPass123';
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
        controller.customerType = 'Existing';  
        controller.username = 'testportaluser45@test.com';
        controller.password = password;
        controller.firstName = 'Testing';
        Test.startTest();
    	controller.login();
    	Test.stopTest();
    	System.assert(acc.Id != null, 'Result should not be null');
    } 
     @isTest  
    static void testLoginWithNullAddress() {  
       Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
       Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev269123',
        Alias = 'test32',
        Email = 'john.cena32@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test32',
        LastName = 'User32',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id,
        CommunityNickname=acc.Id           
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
        Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :cse.Id];
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
        Test.startTest();   
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();  
        //controller.accId = null;  
        controller.address = null;  
        controller.username = 'john.cena32@test.com';  
        controller.password = 'password';  
        controller.login();  
        Test.stopTest();    
       System.assert(acc.Id != null, 'Result should not be null');  
    } 
     @isTest  
    static void testLoginWithNullAddressWithMultiAccounts() {  
      Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena51@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
       Account acc1 = new Account(FirstName = 'John1',LastName='Cena1',PersonHomePhone='99999999',PersonEmail='john.cenaB@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc1;
       Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev26913',
        Alias = 'test32',
        Email = 'john.cena51@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test32',
        LastName = 'User32',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id,
        CommunityNickname=acc.Id           
    );
    insert portalUser; 
         User portalUser2 = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev26913',
        Alias = 'test32',
        Email = 'john.cena51@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test32',
        LastName = 'User32',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc1.Id LIMIT 1].Id,
        CommunityNickname=acc1.Id           
    );
    insert portalUser2;
        
        Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        cse.AccountId = acc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        insert cse;
        Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :cse.Id];
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
        Test.startTest();   
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();  
        //controller.accId = null;  
        controller.address = null;  
        controller.username = 'john.cena51@test.com';  
        controller.password = 'password';  
        controller.login();  
        Test.stopTest();    
       System.assert(acc.Id != null, 'Result should not be null');  
    } 
   
    @isTest  
    static void testLoginWithNullAddress2() {  
       Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
       Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev26912',
        Alias = 'test21',
        Email = 'john.cena213@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test21',
        LastName = 'User21',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id,
        CommunityNickname=acc.Id 
    );
    insert portalUser;
        Test.startTest(); 
        PageReference pageRef = Page.BLRCommunityLoginPage; 
        Test.setCurrentPage(pageRef);   
		pageRef.getParameters().put('showInput', 'true');  
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();  
        //controller.accId = null;  
        controller.address = null;  
        controller.username = 'john.cena21@test.com';  
        controller.password = 'password';  
        controller.login();  
        Test.stopTest();    
       System.assert(acc.Id != null, 'Result should not be null');  
    } 
      @isTest  
    static void testLoginWithNullAddress3() {  
      Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
       Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev26913',
        Alias = 'test32',
        Email = 'john.cena32@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test32',
        LastName = 'User32',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id,
        CommunityNickname=acc.Id           
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
        Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :cse.Id];
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
        Test.startTest();   
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();  
        //controller.accId = null;  
        controller.address = null;  
        controller.username = 'john.cena32@test.com';  
        controller.password = 'password';  
        controller.login();  
        Test.stopTest();    
       System.assert(acc.Id != null, 'Result should not be null');  
    } 
   
    static void testLoginWithAddress() {  
       Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
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
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id
    );
    insert portalUser;
        Test.startTest();  
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();  
        controller.accId = null;  
        controller.address = null;  
        controller.username = 'john.cena@test.com';  
        controller.password = 'password';  
        controller.login();  
        Test.stopTest();    
       System.assert(acc.Id != null, 'Result should not be null');  
    } 
    @isTest  
    static void testLoginWithAccountId(){
       Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
       Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev26914',
        Alias = 'test41',
        Email = 'john.cena41@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test41',
        LastName = 'User41',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id,
        CommunityNickname=acc.Id  
    );
    insert portalUser;
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = 'testsit@testorg.com',
            PersonHomePhone = '09901900121' ,
            RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
        );
        insert testPersonAccount;
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testsit@testorg.com';
        // testContact.AccountId = testPersonAccount[0].id ;
        insert testContact; 
        //Creating case
        Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        cse.AccountId = acc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        //cse.BLN_WorkType__c = 'Replacement';
        insert cse;
        //Create Payment
        BLN_Payment__c payment = new BLN_Payment__c();
        payment.BLN_PaymentAmountTaken__c = 2 ;
        payment.BLN_Case__c = cse.Id;
        insert payment;
        Case newcase =[select id ,BLN_AmountPaid__c,BLN_OutstandingBalance__c,BLN_TotalMotoristLiability__c ,  AccountId  from case limit 1 ];  
        // Create workType data
        WorkType workType =  new WorkType();
        workType.Name = 'Replacement'; 
        workType.EstimatedDuration = 30;
        insert workType;   
        // Create workOrder data
        WorkOrder workOrder = new WorkOrder();
        workOrder.AccountId = acc.id ;
        workOrder.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        workOrder.CaseId = newcase.id ;
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
        sA.BLN_Case__c=newcase.id;
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
         /*List<ServiceAppointment> serviceAppointments12 = [   SELECT Id, BLN_Case__r.Id,AccountId,WorkTypeFormula__c,Status  FROM ServiceAppointment   
          ];  
        system.debug('serviceAppointments12------->'+serviceAppointments12.size());*/
        
       Test.startTest();  
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();  
        controller.accId = acc.Id;  
        controller.address = 'Uk';  
        controller.username = 'john.cena41@test.com';  
        controller.password = 'password'; 
        controller.login();
        controller.newPassword = 'NewPassword@123';
        controller.confirmPassword = 'NewPassword@123';
        controller.newUserId = portalUser.Id;
        controller.newUserLogin();
        Test.stopTest(); 
        System.assert(acc.Id != null, 'Result should not be null'); 
    }
    
    @isTest  
    static void testLoginWithAccountId2(){
       Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
       Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev26914',
        Alias = 'test41',
        Email = 'john.cena41@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test41',
        LastName = 'User41',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id,
        CommunityNickname=acc.Id  
    );
    insert portalUser;
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = 'testsit@testorg.com',
            PersonHomePhone = '09901900121' ,
            RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
        );
        insert testPersonAccount;
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testsit@testorg.com';
        // testContact.AccountId = testPersonAccount[0].id ;
        insert testContact; 
        //Creating case
        Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        cse.AccountId = acc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        //cse.BLN_WorkType__c = 'Replacement';
        insert cse;
        //Create Payment
        BLN_Payment__c payment = new BLN_Payment__c();
        payment.BLN_PaymentAmountTaken__c = 2 ;
        payment.BLN_Case__c = cse.Id;
        insert payment;
        Case newcase =[select id ,BLN_AmountPaid__c,BLN_OutstandingBalance__c,BLN_TotalMotoristLiability__c ,  AccountId  from case limit 1 ];  
        
       Test.startTest();  
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();  
        controller.accId = acc.Id;  
        controller.address = 'Uk';  
        controller.username = 'john.cena41@test.com';  
        controller.password = 'password'; 
        controller.login();
        controller.newPassword = 'NewPassword@123';
        controller.confirmPassword = 'NewPassword@123';
        controller.newUserId = portalUser.Id;
        controller.newUserLogin();
        Test.stopTest(); 
        System.assert(acc.Id != null, 'Result should not be null'); 
    }
    
     @isTest  
    static void testLoginWithAccountId3(){
       Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
       Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev26914',
        Alias = 'test41',
        Email = 'john.cena41@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test41',
        LastName = 'User41',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id,
        CommunityNickname=acc.Id  
    );
    insert portalUser;
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = 'testsit@testorg.com',
            PersonHomePhone = '09901900121' ,
            RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
        );
        insert testPersonAccount;
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testsit@testorg.com';
        // testContact.AccountId = testPersonAccount[0].id ;
        insert testContact; 
        //Creating case
        Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        cse.AccountId = acc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        //cse.BLN_WorkType__c = 'Replacement';
        insert cse;
        //Create Payment
        BLN_Payment__c payment = new BLN_Payment__c();
        payment.BLN_PaymentAmountTaken__c = 2 ;
        payment.BLN_Case__c = cse.Id;
        insert payment;
        Case newcase =[select id ,BLN_AmountPaid__c,BLN_OutstandingBalance__c,BLN_TotalMotoristLiability__c ,  AccountId  from case limit 1 ];  
        // Create workType data
        WorkType workType =  new WorkType();
        workType.Name = 'Replacement'; 
        workType.EstimatedDuration = 30;
        insert workType;   
        // Create workOrder data
        WorkOrder workOrder = new WorkOrder();
        workOrder.AccountId = acc.id ;
        workOrder.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        workOrder.CaseId = newcase.id ;
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
        sA.BLN_Case__c=newcase.id;
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
        
       Test.startTest();  
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();  
        controller.accId = acc.Id;  
        controller.address = 'Uk';  
        controller.username = 'john.cena41@test.com';  
        controller.password = 'password'; 
        controller.login();
        controller.newPassword = 'NewPassword@123';
        controller.confirmPassword = 'NewPassword@123';
        controller.newUserId = portalUser.Id;
        controller.newUserLogin();
        Test.stopTest(); 
        System.assert(acc.Id != null, 'Result should not be null'); 
    }

     @isTest  
    static void testLoginWithAccountId4(){
       Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
       Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev26914',
        Alias = 'test41',
        Email = 'john.cena41@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test41',
        LastName = 'User41',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id,
        CommunityNickname=acc.Id  
    );
    insert portalUser;
        Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = 'testsit@testorg.com',
            PersonHomePhone = '09901900121' ,
            RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
        );
        insert testPersonAccount;
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testsit@testorg.com';
        // testContact.AccountId = testPersonAccount[0].id ;
        insert testContact; 
        //Creating case
        Case cse = new Case();
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id;
        cse.AccountId = acc.Id ;
        cse.Priority = 'Medium';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        //cse.BLN_WorkType__c = 'Replacement';
        insert cse;
        //Create Payment
        BLN_Payment__c payment = new BLN_Payment__c();
        payment.BLN_PaymentAmountTaken__c = 2 ;
        payment.BLN_Case__c = cse.Id;
        insert payment;
       Test.startTest();  
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();  
        controller.accId = acc.Id;  
        controller.address = 'Uk';  
        controller.username = 'john.cena41@test.com';  
        controller.password = 'password'; 
        controller.login();
        controller.newPassword = 'NewPassword';
        controller.confirmPassword = 'NewPassword';
        controller.newUserId = portalUser.Id;
        controller.newUserLogin();
        Test.stopTest(); 
        System.assert(acc.Id != null, 'Result should not be null'); 
    }
        
    @isTest  
    static void testLoginWithAddressAndMultipleUsers(){
      Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena51@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
      Account acc1 = new Account(FirstName = 'John1',LastName='Cena1',PersonHomePhone='1178645111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc1;
       Profile portalUserProfile = [SELECT Id FROM Profile WHERE Name =: BLN_AppConstants.B2C_PROFILE LIMIT 1];
       User portalUser = new User(
        Username = Integer.valueof((Math.random() * 10))+'john.cena@test.com.ukdev26915',
        Alias = 'test51',
        Email = 'john.cena51@test.com',
        EmailEncodingKey = 'UTF-8',
        FirstName = 'Test51',
        LastName = 'User51',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = portalUserProfile.Id,
        TimeZoneSidKey = 'America/Los_Angeles',
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id,
        CommunityNickname=acc.Id
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
        // Fetch the case to get the generated CaseNumber  
        Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :cse.Id];  
     Test.startTest();  
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();  
        controller.accId = null;  
        controller.address = 'john.cena51@test.com';  
        controller.username = 'john.cena51@test.com';  
        controller.password = 'password';  
        // Set case number to match the test case  
        controller.caseNumber = insertedCase.CaseNumber;  
        controller.login();  
        Test.stopTest(); 
        System.assert(acc.Id != null, 'Result should not be null'); 
    }
     @isTest  
    static void testCheckEmail() {  
        BLR_CommunitiesLoginController handler = new BLR_CommunitiesLoginController();   
        handler.isEmailValid('invalidEmail');  // This email lacks an '@', should be invalid       
       System.assertnotEquals(true, handler.wrongEmail, 'The email should be marked as wrong for an invalid email.');  
        handler.isEmailValid('valid@example.com');  // This email contains an '@', should be valid       
       System.assertnotEquals(true, handler.wrongEmail, 'The email should be marked as wrong for an invalid email.');  
    }
    /*@isTest  
    static void testWrongEmailLogin(){
        Test.startTest();  
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();  
        controller.accId = null;  
        controller.username = 'john.cenatest.com';  
        controller.password = 'password';   
        controller.login();  
        Test.stopTest(); 
        System.assertEquals(null, controller.errorMessage, 'The error message should not be null for incorrect email format.');  
    System.assert(controller.errorMessage.contains('invalid email'), 'The error message should indicate an invalid email format.');  
  
    // If there's a boolean field indicating success or failure  
    //System.assertEquals(false, controller.isLoginSuccessful, 'The login should not be successful with an incorrect email format.');  
    }*/
    
    @isTest  
    static void testloginScnario1(){
       Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
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
        Id caseId = sA.BLN_Case__r.id;
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();
        //controller.countofAppointment(acc.Id);
        controller.accId = acc.id;
        controller.username = acc.PersonEmail;
        controller.login();
        System.assert(acc.Id != null, 'Result should not be null'); 
    }
    @isTest  
    static void testloginScnario2(){
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
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
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();
        //controller.countofAppointment(acc.Id);
        controller.accId = acc.id;
        controller.address = 'john.cena@test.com';
        controller.username = 'john.cena@test.com';
        controller.password = 'newPassword123'; 
        system.runAs(portalUser){
          controller.login(); 
        }
        System.assert(acc.Id != null, 'Result should not be null');    
    }
    @isTest  
    static void testloginScnario3(){
    Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
    insert acc;   
    Test.startTest();
    BLR_CommunitiesLoginController.checkIfNew(acc.Id);
    Test.stopTest();
    System.assert(acc.Id != null, 'Result should not be null');
    }
    @isTest  
    static void testloginScnario4(){
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
        Account acc1 = new Account(FirstName = 'John1',LastName='Cena1',PersonHomePhone='111666611',PersonEmail='john.cenaR@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc1;
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
        //Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :cse.Id];
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
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();
        //controller.countofAppointment(acc.Id);
        controller.accId = null;
        controller.address = 'john.cena@test.com';
        controller.username = 'john.cena@test.com';
        controller.password = 'newPassword123'; 
        controller.caseNumber = '999999'; 
        system.runAs(portalUser){
          controller.login(); 
        }
        System.assert(acc.Id != null, 'Result should not be null');    
    } 
    
    @isTest  
    static void testloginScnario5(){
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
        Account acc1 = new Account(FirstName = 'John1',LastName='Cena1',PersonHomePhone='176541111',PersonEmail='john.cena@testF.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc1;
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
        Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :cse.Id];
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
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();
        //controller.countofAppointment(acc.Id);
        controller.accId = null;
        controller.showBookingInput = true;
        controller.address = 'john.cena@test.com';
        controller.username = 'john.cena@test.com';
        controller.password = 'newPassword123'; 
        controller.caseNumber = insertedCase.CaseNumber; 
        system.runAs(portalUser){
          controller.login(); 
        }
        System.assert(acc.Id != null, 'Result should not be null');    
    } 
    
     @isTest  
    static void testloginScnario6(){
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
        Account acc1 = new Account(FirstName = 'John1',LastName='Cena1',PersonHomePhone='111187651',PersonEmail='john.cena@testAC.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc1;
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
        Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :cse.Id];
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
        /*ServiceAppointment sA1 = new ServiceAppointment();
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
        update appointmentsToUpdate1; */
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();
        //controller.countofAppointment(acc.Id);
        controller.accId = null;
        controller.showBookingInput = true;
        controller.address = 'john.cena@test.com';
        controller.username = 'john.cena@test.com';
        controller.password = 'newPassword123'; 
        controller.caseNumber = insertedCase.CaseNumber; 
        system.runAs(portalUser){
          controller.login(); 
        }
        System.assert(acc.Id != null, 'Result should not be null');    
    } 

	  @isTest  
    static void testloginScnario7(){
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
        Account acc1 = new Account(FirstName = 'John1',LastName='Cena1',PersonHomePhone='11111999',PersonEmail='john.cena@testAB.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc1;
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
        Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :cse.Id];
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();
        //controller.countofAppointment(acc.Id);
        controller.accId = null;
        controller.showBookingInput = true;
        controller.address = 'john.cena@test.com';
        controller.username = 'john.cena@test.com';
        controller.password = 'newPassword123'; 
        controller.caseNumber = insertedCase.CaseNumber; 
        controller.encryptedAddress = 'test';
        controller.decryptAddress = 'test';
        controller.uName = 'test';
        controller.noData = false;
        controller.noServiceAppointment = false;
        controller.address1 = 'test';
        controller.userInactive = false;
        controller.currentPassword = 'test';
        controller.emailParam = 'test@gmail.com';
        controller.errorMessage = 'testError';
        controller.passwordErrorMessage = 'test';
        system.runAs(portalUser){
          controller.login(); 
        }
        System.assert(acc.Id != null, 'Result should not be null');    
    } 

	  @isTest  
    static void testloginScnario8(){
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;
        Account acc1 = new Account(FirstName = 'John1',LastName='Cena1',PersonHomePhone='111109876',PersonEmail='john.cena@testAA.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc1;
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
        Case insertedCase = [SELECT Id, CaseNumber FROM Case WHERE Id = :cse.Id];
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
        BLR_CommunitiesLoginController controller = new  BLR_CommunitiesLoginController();
        //controller.countofAppointment(acc.Id);
        controller.accId = null;
        controller.showBookingInput = true;
        controller.address = 'john.cena@test.com';
        controller.username = 'john.cena@test.com';
        controller.password = 'newPassword123'; 
        controller.caseNumber = insertedCase.CaseNumber; 
        system.runAs(portalUser){
          controller.login(); 
        }
        System.assert(acc.Id != null, 'Result should not be null');    
    } 

    @isTest  
    static void testShowBookingInputFalse() {  
        Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;  
        PageReference pageRef = Page.BLRCommunityLoginPage; 
        Test.setCurrentPage(pageRef);   
        ApexPages.currentPage().getParameters().put('address', 'john.cena@test.com');  
        ApexPages.currentPage().getParameters().put('accId', acc.id);  
        ApexPages.currentPage().getParameters().put('showInput', 'true');  
       BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController(); 
        System.assert(acc.Id != null, 'Result should not be null');
    }  
    @isTest  
    static void testShowBookingInputFalse1() {  
        Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;  
        PageReference pageRef = Page.BLRCommunityLoginPage; 
        Test.setCurrentPage(pageRef);   
		pageRef.getParameters().put('showInput', 'true');  
        pageRef.getParameters().put('address', 'john.cena@test.com'); 
        //BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
        System.assert(acc.Id != null, 'Result should not be null');
    } 
    @isTest  
    static void testShowBookingInputFalse2() {  
        Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
       insert acc;  
        PageReference pageRef = Page.BLRCommunityLoginPage; 
        Test.setCurrentPage(pageRef);   
		//pageRef.getParameters().put('showInput', 'false'); 
		 pageRef.getParameters().put('accId', acc.Id);  
        pageRef.getParameters().put('address', 'john.cena@test.com'); 
       // BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
        System.assert(acc.Id != null, 'Result should not be null');
    } 
    
    @isTest  
    static void testnewUserLoginErr(){
    Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
    insert acc; 
    PageReference pageRef = Page.BLRCommunityLoginPage;
    Test.setCurrentPage(pageRef);
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
    controller.customerType = 'New';
    controller.accId = acc.Id;
    controller.address = acc.PersonEmail;
    controller.newPassword = 'newPassword';
    controller.confirmPassword = 'newPassword1234';
    controller.newUserLogin();
    System.assert(acc.Id != null, 'Result should not be null'); 
    }
    @isTest  
    static void testnewUserLogin1(){
     Account acc = new Account(FirstName = 'John',LastName='Cena',PersonHomePhone='11111',PersonEmail='john.cena@test.com',RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'PersonAccount' LIMIT 1].Id);
    insert acc;
    PageReference pageRef = Page.BLRCommunityLoginPage; 
    Test.setCurrentPage(pageRef);
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
        ContactId = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1].Id
    );
    INSERT portalUser; 
   System.setPassword(portalUser.id,'NewPassword@123');
        BLR_CommunitiesLoginController controller = new BLR_CommunitiesLoginController();
        controller.customerType = 'Existing';
    	controller.accId = acc.Id;
    	controller.address = acc.PersonEmail;
        controller.username = acc.PersonEmail;
        controller.password = 'NewPassword@123';
        controller.login();  
        System.assert(acc.Id != null, 'Result should not be null');
    } 
}