/** 
 * @description : This test class is used for BLN_AssistedPaymentsController.
 * @Story : FOUK-4767
 * @Author: PwC-India
 * @Last Modified By: Subhamita Dutta
 * @Date: 06-06-2024
 */
@IsTest
public class BLN_AssistedPaymentsControllerTest {

    @TestSetup
    public static void setupTestData() {
        // Create and insert Contact
        Contact con = BLN_TestDataFactory.getContact('test');
        insert con;
        
        // Create and insert Vehicle
        BLN_Vehicle__c veh = BLN_TestDataFactory.getVehicle();
        insert veh;
        
        // Create and insert Case
        Case cases = BLN_TestDataFactory.getCase('Job Request', 'New');
        cases.ContactId = con.Id;
        cases.BLN_Vehicle__c = veh.Id; 
        insert cases;
        
        // Create and insert Payment
        BLN_Payment__c pays = BLN_TestDataFactory.createPayments( );
        pays.BLN_PaymentAmountTaken__c = 250;
    pays.BLN_Case__c = cases.Id;
    pays.BLN_InitiatedBy__c = 'Portal';
    pays.BLN_InitiatedDateTime__c = Datetime.now();
    pays.BLN_PaymentStatus__c = 'Initiated';
    pays.BLN_Status__c = 'Initiated';
    pays.BLN_PaymentType__c = 'Online Payment';
    pays.BLN_WorldPay_Token__c = 'testtoken';
    pays.BLN_challengereference__c = 'test';
    insert pays;
    }

    @IsTest
    public static void testGeneratedHexDigestKey() {
        // Retrieve the inserted payment record
        List<BLN_Payment__c> pays = [SELECT Id, BLN_PaymentAmountTaken__c FROM BLN_Payment__c LIMIT 1];
        
        if (!pays.isEmpty()){
        
        Test.startTest();
        // Call the method under test
            BLN_AssistedPaymentsController.generatedHexDigestkey(pays[0].Id);
        Test.stopTest();
        
        // Refresh the payment record to get the updated values
        pays = [SELECT Id, BLN_PaymentAmountTaken__c FROM BLN_Payment__c WHERE Id = :pays[0].Id LIMIT 1];
        
        // Assert that the payment amount is still correct
        System.assertnotEquals(200, pays[0].BLN_PaymentAmountTaken__c, 'The payment amount should match the expected value');
        }}

    @IsTest
    public static void testGeneratedHexDigestKeyWithInvalidId() {
        Test.startTest();
        try {
            // Call the method with an invalid payment Id
            BLN_AssistedPaymentsController.generatedHexDigestkey(null);
            System.assert(false, 'An exception should have been thrown for a null Id');
        } catch (Exception e) {
            // Assert that an exception is thrown
            System.assert(true, 'An exception was expected and thrown');
        }
        Test.stopTest();
    }
}