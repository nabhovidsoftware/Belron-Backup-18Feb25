/*
ClassName : BLN_CustomButtonCommunityController
Description :	BLN_CustomButtonCommunityController Created for Appointment Cancellation form.
@Story : FOUK-7756
CreatedDate: 26/02/2024
LastModified date : 09/07/2024
CreatedBy : Namrata Sharma
*/
public with sharing class BLN_CustomButtonCommunityController {
     // Method to update Case and ServiceAppointment records based on the provided reason
     @AuraEnabled
    public static void updateCase(String reason, Id caseId, Id serviceAppointment){
        try {
        Group.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        Group recoveryQueue = [SELECT Id, Name,DeveloperName  FROM Group WHERE Type = 'Queue' AND developerName = 'BLN_RecoveryTeamQueue' LIMIT 1];
        Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        Case caseToUpdate = [SELECT Id, BLN_PrimaryReason__c, BLN_SecondaryReason__c, BLN_BillingMethod__c FROM Case WHERE Id = :caseId Limit 1];
        Boolean isServiceAppointmentAccessible = Schema.SObjectType.ServiceAppointment.isAccessible();    
        ServiceAppointment serviceApp = [SELECT Id, BLN_CancellationSource__c, Status from ServiceAppointment Where Id =: serviceAppointment Limit 1];
            
        // Update the Case record based on the reason
        if (reason == 'time') {
            caseToUpdate.BLN_PrimaryReason__c = System.Label.BLN_CustomerValue;
            caseToUpdate.BLN_SecondaryReason__c= System.Label.BLN_UnsureOfAvailability;
            //FOUK-9684
            caseToUpdate.OwnerId=recoveryQueue.Id;
        } else if (reason == 'location') {
            caseToUpdate.BLN_PrimaryReason__c = System.Label.BLN_CustomerValue;
            caseToUpdate.BLN_SecondaryReason__c = System.Label.BLN_UnsureOfLocation;
            //FOUK-9684
            caseToUpdate.OwnerId=recoveryQueue.Id;
        } else if (reason == 'expense') {
            if (caseToUpdate.BLN_BillingMethod__c == System.Label.BLN_CashValue) {
                caseToUpdate.BLN_PrimaryReason__c = System.Label.BLN_PriceValue;
                caseToUpdate.BLN_SecondaryReason__c = System.Label.BLN_TPFT;
                //FOUK-9684
            caseToUpdate.OwnerId=recoveryQueue.Id;
            } else if (caseToUpdate.BLN_BillingMethod__c == System.Label.BLN_InsuranceAccount) {
                caseToUpdate.BLN_PrimaryReason__c = System.Label.BLN_InsuranceValue;
                caseToUpdate.BLN_SecondaryReason__c = System.Label.BLN_Express;
                //FOUK-9684
            caseToUpdate.OwnerId=recoveryQueue.Id;
            }
        }
        Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable();    
        update caseToUpdate;
        if(serviceApp.id != Null){
            serviceApp.BLN_CancellationSource__c = System.Label.BLN_PortalValue;
            serviceApp.Status = System.Label.BLN_CanceledValue;
        }
        Boolean isServiceAppointmentAccessible1 = Schema.SObjectType.ServiceAppointment.isUpdateable();    
        Update serviceApp;
           
        
      } catch (Exception e) {
            // Handle any exceptions and provide meaningful error messages
            throw new CustomException('An error occurred while updating the records: ' + e.getMessage());
        }
    }
    // Custom exception class for handling errors
	public class CustomException extends Exception {}
}