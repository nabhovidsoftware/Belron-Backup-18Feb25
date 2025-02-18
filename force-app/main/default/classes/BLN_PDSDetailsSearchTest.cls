@isTest
private class BLN_PDSDetailsSearchTest {
    
    @TestSetup
    static void setup() {
        BLN_Vehicle__c testVehicle = BLN_TestDataFactory.getVehicle();
        insert testVehicle;

        Case testCase = BLN_TestDataFactory.createCase(false);
        testCase.BLN_Vehicle__c = testVehicle.Id;
        insert testCase;
    }
    
    @isTest
    static void testBLNPDSsearchAPIPositive() {
        Case existingCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        List<Case> result = BLN_PDSDetailsSearch.blnPDSsearchAPI(existingCase.Id);
        Test.stopTest();
        Assert.isNotNull(result, 'The result should not be null.');
        Assert.areEqual(1, result.size(), 'The result should contain exactly one record.');
        Assert.areEqual(existingCase.Id, result[0].Id, 'The case Id should match the queried case Id.');
    }
    
    @isTest
    static void testBLNPDSsearchAPINegative() {
        String randomId = BLN_TestDataFactory.randomNumberGenerator() + 'TEST';
        Test.startTest();
        List<Case> result = BLN_PDSDetailsSearch.blnPDSsearchAPI(randomId);
        Test.stopTest();
        Assert.isTrue(result.isEmpty(), 'The result should be empty for an invalid case Id.');
    }
}