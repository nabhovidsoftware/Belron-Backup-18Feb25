/**
 * An apex page controller that exposes the change password functionality*/
 
@IsTest public with sharing class ChangePasswordControllerTest {
   
   
    @IsTest
    public static void testChangePasswordControllerexception() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = 'Test@12345';
        controller.newPassword = 'Testing@12345'; 
        controller.verifyNewPassword = 'q'; 
        //controller.userName= 'Testinguser@pwc.com';
        //controller.sanitizedParamaddress='';
        
			Test.startTest();
         PageReference  pr =   controller.changePassword();  
         //PageReference homepage = null;
       System.assertEquals(null, pr, 'The passwords do not match.');
        //controller.navigatePortal();
        //PageReference caseDetailPageUrl = null;
        PageReference result = controller.ChangePassword();
        //PageReference result1 = controller.navigatePortal();
        Test.stopTest();
        System.assertEquals(null, pr,'Please enter both new and confirm passwords.');
                 //System.assertEquals(controller.changePassword(),null);                           
    } 
 
    @isTest
    static void testChangepasswordMatchPasswords() {
        Profile profile = [SELECT ID FROM Profile WHERE Name ='Standard User'];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
 System.runAs (thisUser) {
        User testuser = new User (Alias ='Stadt',
                                  Email = 'test1user@example.com',
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
}
        //system.runas(testuser)
        //{
        
         Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = UserInfo.getUserName(),//'test1user@example.com',
            PersonHomePhone = '09901900121' ,
            RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
        );
        insert testPersonAccount;
       // system.debug('Account created---------->'+testPersonAccount);
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testsit@testorg.com';
        // testContact.AccountId = testPersonAccount[0].id ;
        insert testContact;
       // system.debug('testContact created---------->'+testContact);
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
        
        Case newcase =[select id ,BLN_AmountPaid__c,BLN_OutstandingBalance__c,BLN_TotalMotoristLiability__c ,  AccountId  from case limit 1 ];//BLN_WorkType__c ,
       // system.debug('newcase testclass--->'+newcase);
        
        // Create workType data
        WorkType workType =  new WorkType();
        workType.Name = 'Replacement'; 
        workType.EstimatedDuration = 30;
        insert workType; 
       // system.debug('workType testclass--->'+workType);
        
        // Create workOrder data
        WorkOrder workOrder = new WorkOrder();
        workOrder.AccountId = testPersonAccount.id ;
        workOrder.ContactId = testContact.id;
        workOrder.CaseId = newcase.id ;
        workOrder.WorkTypeId = workType.Id;
        insert workOrder;
     //  system.debug('workOrder testclass--->'+workOrder);
       // system.debug('workOrder Account testclass--->'+workOrder.AccountId);
        
        WorkOrderLineItem workItem = new WorkOrderLineItem();
        workItem.WorkOrderId = workOrder.Id;
        insert workItem;
        // system.debug('workOrder Item testclass--->'+workItem);
        // Create Sa data
        ServiceAppointment sA = new ServiceAppointment();
        sA.ContactId = testContact.Id;
        sA.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA.Duration = 1;
        sA.BLN_Case__c=newcase.id;
        sA.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA.Status = 'Open';
        sA.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.ParentRecordId = WorkOrder.Id;
        sA.WorkTypeId = workType.Id;
        sA.BLN_WorkOrderNumber__c = workOrder.id;
        sA.BLN_WorkOrderLineItem__c = workItem.Id;
        insert sA;
//system.debug('Service appointment in method 1------>'+sA);
       ChangePasswordController controller = new ChangePasswordController();
       controller.oldPassword = '12345678';
        controller.newPassword = 'newpass123' ; 
        controller.verifyNewPassword = 'newpass123' ; 
        //controller.userName= 'test1user@example.com';
        //controller.sanitizedParamaddress='test1user@example.com';
        //String loginCustomLabel = System.Label.SiteLoginUrl ;   
        Test.startTest();
        //PageReference homepage = null;
        PageReference result = controller.ChangePassword();
        PageReference result1 = controller.navigatePortal();
            System.assertNOTEquals(null, result, 'The passwords do not match.');
            Test.stopTest(); //}
        //System.assertEquals(null, result1,'Please enter both new and confirm passwords.');
        } 
    
      @isTest
    static void testChangepasswordNotMatchPasswordsMultipleSa() {
        Profile profile = [SELECT ID FROM Profile WHERE Name ='Standard User'];
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
System.runAs (thisUser) {
        User testuser = new User (Alias ='Stadt',
                                  Email = 'test1user@example.com',
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
}
       //system.runas(testuser)
        //{
        
        //System.debug('testuser'+testuser.Email);
        
         Account testPersonAccount = new Account(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = UserInfo.getUserName(),//'test1user@example.com',
            PersonHomePhone = '09901900121' ,
            RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1]
        );
        insert testPersonAccount;
        //system.debug('Account created---------->'+testPersonAccount);
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'testsit@testorg.com';
        // testContact.AccountId = testPersonAccount[0].id ;
        insert testContact;
        //system.debug('testContact created---------->'+testContact);
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
        
        Case newcase =[select id ,BLN_AmountPaid__c,BLN_OutstandingBalance__c,BLN_TotalMotoristLiability__c , AccountId  from case limit 1 ];// BLN_WorkType__c ,
        //system.debug('newcase testclass--->'+newcase);
        
        // Create workType data
        WorkType workType =  new WorkType();
        workType.Name = 'Replacement'; 
        workType.EstimatedDuration = 30;
        insert workType; 
       // system.debug('workType testclass--->'+workType);
        
        // Create workOrder data
        WorkOrder workOrder = new WorkOrder();
        workOrder.AccountId = testPersonAccount.id ;
        workOrder.ContactId = testContact.id;
        workOrder.CaseId = newcase.id ;
        workOrder.WorkTypeId = workType.Id;
        insert workOrder;
      // system.debug('workOrder testclass--->'+workOrder);
        //system.debug('workOrder Account testclass--->'+workOrder.AccountId);
        
        WorkOrderLineItem workItem = new WorkOrderLineItem();
        workItem.WorkOrderId = workOrder.Id;
        insert workItem;
        //system.debug('workOrder Item testclass--->'+workItem);
        // Create Sa data
        ServiceAppointment sA = new ServiceAppointment();
        sA.ContactId = testContact.Id;
        sA.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA.Duration = 1;
        sA.BLN_Case__c=newcase.id;
        sA.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA.Status = 'Open';
        sA.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA.ParentRecordId = WorkOrder.Id;
        sA.WorkTypeId = workType.Id;
        sA.BLN_WorkOrderNumber__c = workOrder.id;
        sA.BLN_WorkOrderLineItem__c = workItem.Id;
        insert sA;
        //system.debug('Service appointment in method 1------>'+sA);
        
        ServiceAppointment sA1 = new ServiceAppointment();
        sA1.ContactId = testContact.Id;
        sA1.SchedStartTime = Datetime.newInstanceGmt(2024, 1, 18, 12, 0, 0);
        sA1.Duration = 1;
        sA1.BLN_Case__c=newcase.id;
        sA1.SchedEndTime = Datetime.newInstanceGmt(2024, 1, 31, 12, 0, 0);
        sA1.Status = 'Open';
        sA1.DueDate = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA1.EarliestStartTime = Datetime.newInstanceGmt(2024, 1, 27, 12, 0, 0);
        sA1.ParentRecordId = WorkOrder.Id;
        sA1.WorkTypeId = workType.Id;
        sA1.BLN_WorkOrderNumber__c = workOrder.id;
        sA1.BLN_WorkOrderLineItem__c = workItem.Id;
        insert sA1;
            
        
       // system.debug('Multiple Sa-->'+sA1);
       ChangePasswordController controller = new ChangePasswordController();
       controller.oldPassword = '12345678';
        controller.newPassword = 'newpass123' ; 
        controller.verifyNewPassword = 'newpass123' ; 
        //controller.userName= 'test1user@example.com';
        //controller.sanitizedParamaddress='test1user@example.com';
        //String loginCustomLabel = System.Label.SiteLoginUrl ;   
        Test.startTest();
        //PageReference homepage = null;
        PageReference result = controller.ChangePassword();
        PageReference result1 = controller.navigatePortal();
        System.assertNOTEquals(null, result, 'The passwords do not match.');
        Test.stopTest();
        System.assertNOTEquals(null, result1,'Please enter both new and confirm passwords.');
    
    }
    /*static void testChangepasswordInCorrectpassword() {
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
                                  ProfileId = profile.id);
        insert testuser;
        string address = 'test1user@example.com';
        String newpassword = '';
        String confirmpassword ='';
        String newpassword1 = '';
        String confirmpassword1 ='';
        String sanitizedParamaddress = String.escapeSingleQuotes(address);
        List<User> testUsers1 = new List<User>{ Testuser };
            ChangePasswordController controller = new ChangePasswordController();
       controller.oldPassword = '12345678';
        controller.newPassword = '' ; 
        controller.verifyNewPassword = '' ; 
        controller.userName= 'test1user@example.com';
        controller.sanitizedParamaddress='test1user@example.com';
          
        Test.startTest();
        PageReference result = controller.ChangePassword();
        //PageReference result1 = controller.updateUserSignature(string address ,String Test12345 );
        System.assertEquals(null, result, 'The passwords do not match.');
        Test.stopTest();
        System.assertEquals(null, result,'Please enter both new and confirm passwords.');
    }*/
    
   /* @isTest
    static void testChangePassword() {
        // Set up test data
        User testUser = new User(
            FirstName = 'Test123456',
            LastName = 'User',
            Email = 'test123456@example.com',
            Username = 'test123456@example.com',
            Alias = 'TUser',
            CommunityNickname = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = UserInfo.getProfileId(),
            IsActive = true
        );
        insert testUser;

        // Set up the current page reference with parameters
        PageReference pageRef = Page.ChangePassword; // Replace YourPageName with the actual name of your Visualforce page
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Signature', 'testSignature');
        ApexPages.currentPage().getParameters().put('userEmail', 'test123456@example.com');
        ApexPages.currentPage().getParameters().put('showPasswordResetSection', 'true');
		
        string address = 'test123456@example.com';
        string userEmail = 'test123456@example.com';
        String newpassword = 'Pass123';//---
        String confirmpassword ='newPass123';
        String newpassword1 = 'newPass124';//--
        String confirmpassword1 ='newPass123';
        //String sanitizedParamaddress = String.escapeSingleQuotes(address);
        // Call the method
        BLR_CommunitiesLoginController instance = new BLR_CommunitiesLoginController();
        instance.changePassword();
		 Test.startTest();
        PageReference result = instance.ChangePassword();
        System.assertEquals(null, result, 'The passwords do not match.');
        Test.stopTest();

        // Verify the logic in the method
        // Add assertions here to verify the behavior of the method based on the provided parameters
        //System.assertEquals('test123456@example.com', ApexPages.currentPage().getParameters().get('address'), 'Email parameter should be sanitized in test context');
        // Add more assertions as needed
    }*/
   /* 
    @isTest
    static void testChangePassword1() {
        // Set up test data
        User testUser = new User(
            FirstName = 'Test123456',
            LastName = 'User',
            Email = 'test123456@example.com',
            Username = 'test123456@example.com',
            Alias = 'TUser',
            CommunityNickname = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = UserInfo.getProfileId(),
            IsActive = true
        );
        insert testUser;

        // Set up the current page reference with parameters
        PageReference pageRef = Page.BLRCommunityLoginPage; // Replace YourPageName with the actual name of your Visualforce page
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Signature', 'testSignature');
        ApexPages.currentPage().getParameters().put('userEmail', 'test123456@example.com');
        ApexPages.currentPage().getParameters().put('showPasswordResetSection', 'true');
		
        
        
        string address = 'test123456@example.com';
        string userEmail = 'test123456@example.com';
        String newpassword = 'newPass124';
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
        //  /* Test.startTest();
        //  PageReference Result = new BLR_CommunitiesLoginController().ChangePassword();
        Test.startTest();
        //PageReference result = controller.ChangePassword();
        //System.assertEquals(null, result, 'The passwords do not match.');
        Test.stopTest();
        // Test.stopTest();
        
        //System.assertEquals(null, result,'Please enter both new and confirm passwords.');

        
    }*/
 
    
}