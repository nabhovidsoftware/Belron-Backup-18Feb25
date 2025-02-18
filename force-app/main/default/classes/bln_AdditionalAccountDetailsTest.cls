@isTest
public class bln_AdditionalAccountDetailsTest {
    
    @isTest
    static void testGetLoggedInUserAccount() {
        // Create a test role
        UserRole role = new UserRole(Name = 'Test Role');
        insert role;

        // Create a test user with the assigned role
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = 'testuserabcef@example.com',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            FirstName = 'User',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            UserRoleId = role.Id // Assigning the role
        );
        insert testUser;

        // Run as the test user
        System.runAs(testUser) {
            // Call the method to test
            Id accountId = bln_AdditionalAccountDetailsController.getLoggedInUserAccount();

            // Verify that the returned account Id is not null
            System.assertNotEquals(accountId, 'Account Id should not be null');
        }
    }
}