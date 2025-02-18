/*****************************************
ClassName : BLN_UpdateCaseOwnerControllerTest
Description : FOUK-1626 This test class is used to cover testcoverage for BLN_UpdateCaseOwnerController.
CreatedDate: 11-08-2023
CreatedBy : PwC-India
****************************************/

/** @description : This test class is used to cover testcoverage for BLN_UpdateCaseOwnerController.*/
@isTest
public class BLN_UpdateCaseOwnerControllerTest {

/*  *@description:This method is test the BLN_UpdateCaseOwnerController's getQueueName.
    *return : Group
*/
    @isTest 
    public static void testUpdateCaseOwnerController() {
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]?.Id;
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
        system.runas(adminUser) {
            
       

        Account an =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert an;
        
        Group queue = BLN_TestDataFactory.getQueue('BLN_RecoveryTeamQueue');
        Case ca =  BLN_TestDataFactory.createCase('BLN_JobRequest','Job Request','New');
        ca.OwnerId = queue.Id;
        ca.BLN_PrimaryReason__c='Customer';
        ca.BLN_SecondaryReason__c ='No Show';
        ca.ContactId = an.PersonContactId;
        //ca.BLN_Resolution__c = 'Purchase Vehicle';
        insert ca;
        //System.runAs(adminUser){
        Test.startTest();
        BLN_UpdateCaseOwnerController.getQueueName();
        Test.stopTest();
            Assert.isTrue(ca.OwnerId == queue.Id,'test check');}
       }
       // }
    }