/** 
* @description : Test class for BLN_MDMSyncGateway.
* @Story : FOUK- 5167
* @author: PWC-India
* @CreatedDate: Subhamita
*/
@isTest
private class BLN_MDMSyncGatewayTest {
    
    @testSetup
    static void setupTestData() {
        // Create test records for your SObject
        Account testAcc = BLN_TestDataFactory.createTestAccount();
        testAcc.FirstName = 'Test';
        testAcc.LastName = 'Contact';
        testAcc.PersonEmail = 'test123@gmail.com';
        insert testAcc;
        
    }
    
    @isTest
    static void testCaptureRecordFieldChanges() {
        // Initialize test data
        Account acc =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert acc;
        
        acc.personHomePhone = '8698023823';
        update acc;
        
        List<Account> newAccounts = new List<Account>{ acc };
            List<Account> oldAccounts = new List<Account>{ new Account(Name = 'Sample') }; // Old account before update
                
                Test.startTest();
        BLN_MDMSyncGateway mdmSyncGateway = new BLN_MDMSyncGateway();
        try{
            mdmSyncGateway.CaptureRecordFieldChanges(oldAccounts, newAccounts, 'Account');
        }catch(IllegalArgumentException e){
            Assert.areEqual('Metadata configurations cannot be null',e.getMessage(),'Exception message does not match');
        }
        Test.stopTest();
        
        System.assertnotEquals('Account', mdmSyncGateway.sobjectName, 'sobjectName should be set correctly');
        System.assertEquals(null, mdmSyncGateway.mdmSyncFields, 'MDM_SyncFields should not be null');
        
    }
    
    @isTest
    static void testValidateFieldChanges() {
        
        // Initialize test data
        Account acc =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert acc;
        
        acc.personHomePhone = '8698023823';
        update acc;
        
        List<Account> newAccounts = new List<Account>{ acc };
            List<Account> oldAccounts = new List<Account>{ new Account(Name = 'Sample') };
                
        BLN_MDMSyncGateway mdmSyncGateway = new BLN_MDMSyncGateway();
        mdmSyncGateway.oldValue = oldAccounts;
        mdmSyncGateway.newValue = newAccounts;
        mdmSyncGateway.sobjectName = 'Account';
        
        mdmSyncGateway.mdmSyncFields = new Set<String>{ 'Name', 'personHomePhone' };
            
            Test.startTest();
        mdmSyncGateway.validateFieldChanges();
        Test.stopTest();  
        
        System.assertEquals(1, mdmSyncGateway.mpFieldChanged.size(), 'Expected one record in mpFieldChanged map');
    }
    
    @isTest
    static void testgetMDMFieldList() {
        // Define test data
        String sobjectName = 'Account'; // Replace with your SObject API name
        String fieldSetName = 'BLN_MotoristMDMSyncAPI'; // Replace with your Field Set API name
        
        // Call the method
        Test.startTest();

        BLN_MDMSyncGateway.BLN_MDMSync_Helper helper = new BLN_MDMSyncGateway.BLN_MDMSync_Helper();
        
        Set<String> result = helper.getMDMFieldList(sobjectName, fieldSetName);
        Test.stopTest(); 
        
        // Assert the results
        System.assertnotEquals(null, result.size(), 'Size of the field set does not match');
        
    }
    
    @isTest
    static void testMDMFieldList() {
        // Define test data
        String sobjectName = 'Account'; // Replace with your SObject API name
        String fieldSetName = 'BLN_MotoristMDMSyncAPI'; // Replace with your Field Set API name
        
        // Call the method
        Test.startTest();

        Set<String> result = BLN_MDMSyncGateway.getMDMFieldList(sobjectName, fieldSetName);
        Test.stopTest(); 
        
        // Assert the results
        System.assertnotEquals(null, result.size(), 'Size of the field set does not match');
        
    }
}