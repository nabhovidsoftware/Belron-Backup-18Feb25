/**@description : Test class covering bln_PortalCancellationOptions Apex class used to Query BLN_PortalCancellationOptions__mdt metadeta.
*  @author: Vedita Kashi
*  @Story: FOUK-8452
*  @CreatedDate: 03/072024
*/
@isTest
public class Bln_PortalCancellationOptionstest {

    // Test method to cover the getPortalCancellationOptions method
    @isTest
    static void testGetPortalCancellationOptions() {
        // Query existing metadata records (ensure records are created in your org or sandbox)
        List<BLN_PortalCancellationOptions__mdt> existingMetadata = [SELECT MasterLabel, BLN_CancellationMethod__c FROM BLN_PortalCancellationOptions__mdt LIMIT 1];
        
        // Call the method to be tested
        Test.startTest();
        List<BLN_PortalCancellationOptions__mdt> options = bln_PortalCancellationOptions.getPortalCancellationOptions();
        Test.stopTest();
        
        // Assertion to verify results
        System.assertEquals(1, options.size(), 'Expected one record');
        System.assertEquals(existingMetadata[0].MasterLabel, options[0].MasterLabel, 'MasterLabel assertion failed');
		System.assertEquals(existingMetadata[0].BLN_CancellationMethod__c, options[0].BLN_CancellationMethod__c, 'BLN_CancellationMethod__c assertion failed');
    }
}