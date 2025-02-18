/*****************************************
    ClassName : BLN_InboundCustomerDetailsControllerTest
    Description : FOUK-3964 This test is used to cover testcoverage for BLN_InboundCustomerDetailsController class 
    CreatedDate: 18-12-2023
    CreatedBy : Hemangi Temgire (PWC-India)
    ****************************************/
/*  *@description: This method is used to test BLN_InboundCustomerDetailsController getPersonAccounts class.
        *@return : void
    */
@isTest
private  class BLN_InboundCustomerDetailsControllerTest {

    @isTest
    static void testGetPersonAccounts() {
         Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
        String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        User adminUser = new User(
            UserroleId =role,
            ProfileId = adminProfileId,
            FirstName = 'PS',
            LastName = 'Test User',
            UserName = System.now().getTime() + '@test.demo',
            Alias = 'pstes',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true); 
        insert adminUser;
        system.runAS(adminUser){
        // Create test data using BLN_TestDataFactory
        Account testAccount = BLN_TestDataFactory.createTestAccount();
        insert testAccount;
        system.runAS(adminUser){
       List<Account> resultAccounts = BLN_InboundCustomerDetailsController.getPersonAccounts('1234567890');
        System.assertEquals(1, resultAccounts.size(), 'There should be one record in the result list');
        Account retrievedAccount = resultAccounts[0];
        System.assertEquals('John', retrievedAccount.FirstName, 'First name should be John');
        System.assertEquals('Doe', retrievedAccount.LastName, 'Last name should be Doe');
        }  }}
    
    @isTest
    static void testGetPersonAccounts2() {
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;        
        String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        User adminUser = new User(
            UserroleId =role,
            ProfileId = adminProfileId,
            FirstName = 'PS',
            LastName = 'Test User',
            UserName = System.now().getTime() + '@test.demo',
            Alias = 'pstes',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true); 
        insert adminUser;
    
       system.runAS(adminUser){
        // Create test data using BLN_TestDataFactory
        Account testAccount = BLN_TestDataFactory.createTestAccount();
        insert testAccount;
       List<Account> resultAccounts = BLN_InboundCustomerDetailsController.getPersonAccounts('1234567890');      
           System.assertEquals(resultAccounts[0].PersonMobilePhone, testAccount.PersonMobilePhone, 'PersonMobilePhone should be same');
       }
    }
       
    @isTest
    static void testGetPersonAccounts3() {
      
        Test.startTest();
       
        try{
            List<Account> resultexception= BLN_InboundCustomerDetailsController.getPersonAccounts('');
        }
        
        catch(Exception e)
        {
            System.assertNotEquals(null,e.getMessage(),'Null checker');
        }
        Test.stopTest();
        }
        }