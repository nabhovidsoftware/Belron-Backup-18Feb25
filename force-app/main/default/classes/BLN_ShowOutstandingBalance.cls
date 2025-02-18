/*
ClassName : BLN_ShowOutstandingBalance
Description :	BLN_ShowOutstandingBalance Created to Show the Outstanding Balance.
@Story : FOUK-5777
CreatedDate: 31/01/2024
LastModified date : 09/07/2024
CreatedBy : Sourabh Bhattacharjee
*/
public without sharing class BLN_ShowOutstandingBalance {
    @AuraEnabled(cacheable=true)
     // Method to get the outstanding balance for a given case record by its Id
    public static String getBal(String recordId) {
        String bal;
        try {
            // Ensure Case object and fields are accessible
            Schema.sObjectType.Case.fields.BLN_OutstandingBalance__c.isAccessible();
            Schema.sObjectType.Case.fields.BLN_BookingStatus__c.isAccessible();
            Case caseRecord = [SELECT Id, BLN_OutstandingBalance__c, BLN_BookingStatus__c FROM Case WHERE Id = :recordId LIMIT 1];

            if (caseRecord != null && caseRecord.BLN_OutstandingBalance__c != null) {
               // outstandingBalance = caseRecord.BLN_OutstandingBalance__c;
                if(caseRecord.BLN_OutstandingBalance__c >= 2.99){
                    bal = String.valueof(caseRecord.BLN_OutstandingBalance__c);
                }else if(caseRecord.BLN_OutstandingBalance__c < 2.99 && caseRecord.BLN_BookingStatus__c == System.label.BLN_ProvisionalValue){
                    bal = 'To be confirmed';
                }
                else if(caseRecord.BLN_OutstandingBalance__c < 2.99 && caseRecord.BLN_BookingStatus__c != System.label.BLN_ProvisionalValue){
                    bal = '0';
                }
            }
        } catch (Exception e) {
            // Handle any exceptions gracefully
            throw new AuraHandledException('Exception occurred in getOutstandingBalance: ' +e.getMessage()+'--'+e.getLineNumber()+'=='+e.getCause()+'...'+e.getStackTraceString());
        }
        return bal;
    }
}