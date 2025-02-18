@isTest
public class BLN_AuthorisationScreenControllerTest {

    @isTest
    static void testUpdateCaseRecord() {
        // Test data setup
        BLN_Vehicle__c vehicles = BLN_TestDataFactory.getVehicle();
        vehicles.BLN_SpecialVehicle__c = true;
        insert vehicles;

        BLN_Corporate__c corporate = new BLN_Corporate__c();
        corporate.BLN_OEAuthorizationRequired__c = false;
         corporate.BLN_Vehicle__c = vehicles.Id;
        insert corporate;
       
        Case cse = BLN_TestDataFactory.getCase('Job Request', 'New');
        cse.Type = 'Job Request';
        cse.Status = 'New';
        cse.BLN_SubType__c='Job Request';
        cse.BLN_Corporate__c = corporate.id;
        cse.BLN_ServiceGeolocation__latitude__s=46.22441984873406;
        cse.BLN_ServiceGeolocation__longitude__s=-89.02172505348693;
        
        cse.Priority = 'Medium';
        cse.BLN_MotoristTaxStatus__c = 'Yes';
        cse.BLN_TotalMotoristLiability__c = 6000 ;
        insert cse;
        

        Test.startTest();
        // Call the method under test
        boolean isCaseUpdated = BLN_AuthorisationScreenController.updateCaseRecord(corporate.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(true, isCaseUpdated, 'Case record should be updated successfully.');
    }
}