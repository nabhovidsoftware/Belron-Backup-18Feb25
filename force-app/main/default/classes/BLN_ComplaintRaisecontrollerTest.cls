/*
ClassName : BLN_ComplaintRaisecontroller having test class BLN_ComplaintRaisecontrollerTest
Description :	
@Story : FOUK-7476
CreatedDate: 30/04/2024
LastModified date : 30/04/2024
CreatedBy : Vedita Kashi
*/
@isTest
private class BLN_ComplaintRaisecontrollerTest {

    @isTest
    static void testIsVRNRegistered() {
        // Test scenario when vehicle is registered
        BLN_Vehicle__c testVehicle = new BLN_Vehicle__c(BLN_VehicleRegNumber__c = 'TestVRN');
        insert testVehicle;

        String vehicleId = BLN_ComplaintRaisecontroller.isVRNRegistered('TestVRN');
        System.assertNotEquals(null, vehicleId, 'Expected vehicle ID');

        // Test scenario when vehicle is not registered
        String nonExistentVRN = 'NonExistentVRN';
        String nonExistentVehicleId = BLN_ComplaintRaisecontroller.isVRNRegistered(nonExistentVRN);
        System.assertEquals(null, nonExistentVehicleId, 'Expected null vehicle ID');
    }

    @isTest
    static void testCreateCaseRecordWithValidInput() {
         Map<String,String> caseRecordMap = new Map<String,String>();
        // Test case creation with valid input
        Case testCase = new Case(
            Subject = 'Test Subject',
            Description = 'Test Description'
        );

        String caseId;

        Test.startTest();
        try {
             caseRecordMap = BLN_ComplaintRaisecontroller.createCaseRecord(testCase, 'base64Data', 'testFile.txt');
        } catch (Exception e) {
            System.assert(false, 'Exception thrown: ' + e.getMessage());
        }
        Test.stopTest();

        System.assertNotEquals(true, caseRecordMap.size()>0, 'Expected Map');
    }

    @isTest
    static void testCreateCaseRecordWithInvalidRecordType() {
        Map<String,String> caseRecordMap = new Map<String,String>();
        // Test case creation with invalid RecordType
        Case testCase = new Case(
            Subject = 'Test Subject',
            Description = 'Test Description'
        );
        testCase.RecordTypeId = null;

        String caseId;

        Test.startTest();
        try {
            caseRecordMap = BLN_ComplaintRaisecontroller.createCaseRecord(testCase, 'base64Data', 'testFile.txt');
            System.assert(false, 'Exception expected');
        } catch (AuraHandledException e) {
            System.assertEquals('Invalid Record Type', e.getMessage(), 'Expected error message for invalid RecordType');
        }
        Test.stopTest();

        System.assertNotEquals(true, caseRecordMap.size()>0, 'Expected Map');
    }
}