/*****************************************
ClassName : BLN_RecalculateTerritoryManagementRules
@description : FOUK-4467 This test  class is used to cover BLN_RecalculateTerritoryManagementRules.
CreatedDate: 28-12-2023
CreatedBy : PwC-India
****************************************/
@isTest
public class BLN_RecalculateTerritoryManagementTest {

    @TestSetup
    public static void setupTestData () {

        Account testAccount = BLN_TestDataFactory.createSalesAccount('TestMockB2BAccount1','Agriculture','Underwriter',1,'Insurance','GB123456779', 'AA161811','San Francisco', 'testStreet','12345' ,'GB','Blue Anchor' ,'Minehead',
                                                                     '7890' , 'United Kingdom','BLN_CustomerB2BAccount');
        insert testAccount;
        
    }

    /*****************************************
    *MethodName : handleAccountsForTerritoryManagementTest
    *@description : This method is used to test handleAccountsForTerritoryManagement.
    *@param  
    *CreatedDate: 28-12-2023
    *CreatedBy : Pwc-India
    *Change log :
    ****************************************/
    @isTest
    static void handleAccountsForTerritoryManagementTest() {
        
        // Set up a mock HTTP callout to simulate external API calls.
        Test.setMock(HttpCalloutMock.class, new BLN_RunTerritoryRulesQueueableMock());
        
        List<String> testAccountIds = new List<String>();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        testAccountIds.add(testAccount.Id);
        
        UserRole role = new UserRole(Name = 'Test Role');
        insert role;

        User testSalesPerson = BLN_TestDataFactory.createSalesTestUser('salesuser' + DateTime.now().getTime() + '@testorg.com', 'Sales Manager Profile', 'salesus', 'salesuser@testorg.com', 'Testing',
                                                                       'en_US', 'en_US', 'Europe/London', 'UTF-8');
        testSalesPerson.UserRoleId = role.id;
        Insert testSalesPerson;
        
        System.runAs(testSalesPerson) {    
            // start the test context.
            Test.startTest();     
            
            BLN_RecalculateTerritoryManagementRules.handleAccountsForTerritoryManagement(testAccountIds);
            
            List<AsyncApexJob> jobInfo  = [SELECT Status FROM AsyncApexJob Where ApexClass.Name = 'BLN_RunTerritoryRulesQueueable' LIMIT 50000];
            
            System.assertNotEquals(0, jobInfo.size(),'Job is Queued');
            System.assertEquals(1, jobInfo.size(),'Job is Queued');
            
            // Stop the test context.
            Test.stopTest();
        }
    }
    
    /*****************************************
    *MethodName : handleAccountsForTerritoryManagementTestExceptionCoverage
    *@description : This method is used to test handleAccountsForTerritoryManagementTestExceptionCoverage.
    *@param  
    *CreatedDate: 28-12-2023
    *CreatedBy : Pwc-India
    *Change log :
    ****************************************/
    @isTest
    static void handleAccountsForTerritoryManagementTestExceptionCoverage() {
        UserRole role = new UserRole(Name = 'Test Role');
        insert role;

        User testSalesPerson = BLN_TestDataFactory.createSalesTestUser('salesuser' + DateTime.now().getTime() + '@testorg.com', 'Sales Manager Profile', 'salesus', 'salesuser@testorg.com', 'Testing',
                                                                       'en_US', 'en_US', 'Europe/London', 'UTF-8');
        testSalesPerson.UserRoleId = role.id;
        Insert testSalesPerson;

        System.runAs(testSalesPerson) {    
            // start the test context.
            Test.startTest();     
            
            //passed null as a parameter to cover catch block
            BLN_RecalculateTerritoryManagementRules.handleAccountsForTerritoryManagement(null);
            
            List<AsyncApexJob> jobInfo  = [SELECT Status FROM AsyncApexJob Where ApexClass.Name = 'BLN_RunTerritoryRulesQueueable' LIMIT 50000];
            
            System.assertNotEquals(1, jobInfo.size(),'Job is not Queued');
            System.assertEquals(0, jobInfo.size(),'Job is not Queued');
            
            // Stop the test context.
            Test.stopTest();
        } 
    }
}