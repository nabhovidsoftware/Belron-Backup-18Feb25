/*  description :   This is Test class for LAD_userEmailforpreChat class
    author:         (punam.patil@pwc.com (IN))
    Story:          FOUK-9174
*/


@isTest
private class LAD_userEmailforpreChatTest {

    @isTest
    static void testGetUserEmail_Success() {
        // Step 1: Set up test data
         
        Account testAccount = new Account(Name = 'ABC Corp');
        insert testAccount;
        Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id);
        insert testContact;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
         user testUser = New User(UserName = 'test_' + math.random() + '@test.com',
                                 FirstName = 'Test-First',
                                 LastName = 'Test-Last',
                                 Alias = 'test',
                                 email = 'test@test.com',
                                 CommunityNickName = string.valueOf(math.random()).substring(0,6),
                                 ProfileID = p.id,
                                 ContactId = testContact.Id,
                                 TimeZoneSidKey = 'America/New_York', 
                                 LocaleSidKey = 'en_US', 
                                 EmailEncodingKey = 'UTF-8', 
                                 LanguageLocaleKey = 'en_US');
        insert testUser; 

        // Step 2: Call the method and verify the result
        Test.startTest();
        String email = LAD_userEmailforpreChat.getUserEmail(testUser.Id);
        Test.stopTest();

        System.assertEquals('test@test.com', email, 'The email address should match the one set up in the test user.');
    }

   
}