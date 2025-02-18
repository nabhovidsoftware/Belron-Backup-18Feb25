@isTest
public class LAD_RedirectReportingTest {
    
     
    @isTest
    static void testNotEligibleReporting() {
        // Create a test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            LAD_Not_eligible_for_Reporting__c = 'Yes' // or false, depending on your test case
        );
        insert testAccount;
        
        // Call the method
        Account result = LAD_RedirectReporting.NotEligibleReporting(testAccount.Id);
        
        // Validate the results
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assertEquals(testAccount.Id, result.Id, 'The account ID should match the inserted account');
        System.assertEquals(testAccount.LAD_Not_eligible_for_Reporting__c, result.LAD_Not_eligible_for_Reporting__c,
            'The LAD_Not_eligible_for_Reporting__c field should match');
    }
}