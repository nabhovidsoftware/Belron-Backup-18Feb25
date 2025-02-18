/*****************************************
    ClassName : BLN_FetchJobRequestCases
    Description : FOUK-6591 This controller class is used in Bln_Customlookup lwc.
    CreatedDate: 23-03-2024
    CreatedBy : Hemangi Temgire (PWC-India)
    ****************************************/

public with sharing class BLN_FetchJobRequestCases {
    @AuraEnabled(cacheable=true)
    public static List<Case> getRelatedJobs(String accountId, String searchKey) {
        List<Case> relatedCases = new List<Case>();
        if (Schema.sObjectType.Case.isAccessible()) {
        try {
            if(!String.isBlank(accountId) || !String.isBlank(searchKey)) {
                String sWildCardText = '%' + searchKey + '%';
                
                relatedCases = [SELECT Id, CaseNumber, BLN_OutstandingBalance__c, BLN_TotalMotoristLiability__c 
                                FROM Case 
                                WHERE CaseNumber Like :sWildCardText 
                                AND AccountId = :accountId 
                                AND Type = 'Job Request' WITH SECURITY_ENFORCED];
                
            }
             
        } catch (Exception e) {BLN_ExceptionLogger.captureException(e);
        }
        }
        return relatedCases;
      
    }
}