/*****************************************
ClassName: BLN_AuthorisationScreenController
Description: FOUK-3177 This controller class is used in LWC.
CreatedDate: 29-05-2024
CreatedBy: PwC-India
****************************************/
public with sharing class BLN_AuthorisationScreenController {

    /* MethodName: getCaseRecord
    Description: This method is used to get case record against corporateId.
    Input Parameter: recordId
    Output Parameter: Case record
    CreatedDate: 29-05-2024
    CreatedBy: PwC-India
    Change log:
    ****************************************/
    
    /** @description FOUK-3177 This method is used to get case record against corporateId*/
    @AuraEnabled
    public static boolean updateCaseRecord(String recordId){
        boolean  isCaseUpdate = false;
        try{
            List<Case> caseList = new List<Case>();
             if(Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                caseList = [SELECT Id,BLN_IsForceReprice__c FROM Case WHERE BLN_Corporate__c  =:recordId WITH SECURITY_ENFORCED LIMIT 1];
             }
             if(!caseList.isEmpty()){
                caseList[0].BLN_IsForceReprice__c = true;
                if(Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
                    update caseList;
                    isCaseUpdate = true;
                 }

             }
             
        }
        catch (Exception e){
            BLN_ExceptionLogger.captureException(e);
        }
        return isCaseUpdate;
    }
}