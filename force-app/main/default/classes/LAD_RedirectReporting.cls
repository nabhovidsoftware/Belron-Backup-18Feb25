public with sharing class LAD_RedirectReporting {
    @AuraEnabled
    public static Account NotEligibleReporting(Id recordId){
       
        return [SELECT Id ,LAD_Not_eligible_for_Reporting__c
        FROM Account where Id =: recordId
       ];
    }
}