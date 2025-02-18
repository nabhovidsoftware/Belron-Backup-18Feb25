/**@description : This Apex class used to Query BLN_PortalCancellationOptions__mdt metadeta.
*  @author: Vedita Kashi
*  @Story: FOUK-8452
*  @CreatedDate: 03/072024
*/
public without sharing class Bln_PortalCancellationOptions {
    /*@AuraEnabled(cacheable=true)
    public static List<BLN_PortalCancellationOptions__mdt> getPortalCancellationOptions() {
        return [SELECT MasterLabel,BLN_CancellationMethod__c FROM BLN_PortalCancellationOptions__mdt];
    }*/
    @AuraEnabled(cacheable=true)
    public static List<BLN_PortalCancellationOptions__mdt> getPortalCancellationOptions() {
        // Validate CRUD permissions before executing SOQL query
        String metadataTypeName = 'BLN_PortalCancellationOptions__mdt';
        
        // Check if the current user has read access to the MetadataType
        if (!Schema.getGlobalDescribe().get(metadataTypeName).getDescribe().isQueryable()) {throw new InsufficientPrivilegesException('Insufficient permissions to read ' + metadataTypeName);
        }
        
        // Perform SOQL query
        return [SELECT MasterLabel, BLN_CancellationMethod__c FROM BLN_PortalCancellationOptions__mdt];
    }
    
    // Custom exception class for insufficient privileges
    public class InsufficientPrivilegesException extends Exception {}
}