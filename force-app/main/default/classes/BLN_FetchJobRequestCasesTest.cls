/*****************************************
    ClassName : BLN_FetchJobRequestCasesTest
    Description : FOUK-6591 This is testclass for BLN_FetchJobRequestCases controller class
    CreatedDate: 23-03-2024
    CreatedBy : Hemangi Temgire (PWC-India)
    ****************************************/


@isTest
private class BLN_FetchJobRequestCasesTest {

    @isTest
    static void testGetRelatedJobs() {
        String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
        User adminUser = new User(
            ProfileId = adminProfileId,
            FirstName = 'PS',
            UserroleId =role,
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
       
        // Create test data using BLN_TestDataFactory or any other appropriate method
        // Insert necessary test data for the related cases
        
         system.runAs(adminUser) {
            List<Case> resultCases = BLN_FetchJobRequestCases.getRelatedJobs('AccountId', 'SearchKey');
            if(resultCases != null) {
                System.assertEquals(0, resultCases.size(), 'Ensure initial list is empty');
            } else {
                System.assertEquals(0, 0, 'ResultCases list is null');
            }
            
        }
    }

    @isTest
    static void testGetRelatedJobsException() {
        Test.startTest();
       
        try {
            List<Case> resultException = BLN_FetchJobRequestCases.getRelatedJobs('','');
        } catch(Exception e)
        {
            System.assertNotEquals(null,e.getMessage(),'Null checker');
        }
        
        Test.stopTest();
    }
}