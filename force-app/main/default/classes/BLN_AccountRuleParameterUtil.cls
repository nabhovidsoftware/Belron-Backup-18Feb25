/*****************************************
*ClassName : BLN_AccountRuleParameterUtil
*@description : FOUK-5297 retrieve Account Rules Parameters within CRM
*CreatedDate: 19-01-2023
*CreatedBy : PwC-India
****************************************/
public with sharing class BLN_AccountRuleParameterUtil{
    /*MethodName : getAccountRuleParameters
	*@description: Retrieves Account Rule Parameters based on Account ID, Account Rule Parameter Record Type, and Date of the job.
    *@param :  Parameters:
     *     - accountId (Id): The ID of the Account.
     *     - arpRecordType (String): The RecordType.Name of the Account Rule Parameter.
     *     - jobDate (Date): The Date of the job.
    *@return List<BLN_AccountRuleParameter__c>
    ****************************************/
    @AuraEnabled //Made this method @AuraEnabled as a part of FOUK-3801
    
    public static List<BLN_AccountRuleParameter__c> getAccountRuleParameters(String arpRecordType, Id accountId, Date jobDate) {
        List<Id> allHierachyAccountList = new List<Id>();
        String fieldToQuery = 'Id, BLN_Account__c, BLN_IsActive__c, BLN_ActiveFrom__c, BLN_ActiveTo__c, BLN_ParameterUsageInstruction__c, RecordType.Name';
        List<BLN_AccountRuleParameter__c> accountRuleParameters = new List<BLN_AccountRuleParameter__c>();
        
        try {
            if(String.isEmpty(accountId)) {
               throw new BLN_CustomException(BLN_AppConstants.ACCOUNT_ID_MISSING);
           }
            
            BLN_ARPInheritanceBehaviour__mdt arpIbMtd = [SELECT Id, MasterLabel, BLN_InheritanceBehaviour__c, BLN_FieldList__c 
                                                          FROM BLN_ARPInheritanceBehaviour__mdt 
                                                          WHERE BLN_ARPRecordTypeName__c =: arpRecordType WITH SECURITY_ENFORCED];
            fieldToQuery += arpIbMtd.BLN_FieldList__c != null ? ', ' + arpIbMtd.BLN_FieldList__c : '';
            
            Account acc = [SELECT Id, ParentId, Parent.ParentId, BLN_Level__c, BLN_ClientType__c, Parent.BLN_Level__c, Parent.Parent.BLN_Level__c, Parent.BLN_ClientType__c
                           FROM Account
                           WHERE Id =: accountId
                           AND BLN_Status__c !=: BLN_AppConstants.STATUS_CLOSED
                           AND (RecordType.Name =: BLN_AppConstants.RECORD_TYPE_B2B OR RecordType.Name =: BLN_AppConstants.RECORD_TYPE_REFERRAL) WITH SECURITY_ENFORCED];
            
            //if (acc == null) {
                //throw new BLN_CustomException(BLN_AppConstants.ACCOUNT_BRANCH_UNAVAILABLE);
            //}
            
            String clientType = (acc.BLN_Level__c == BLN_AppConstants.SITE_ACCOUNT) ? acc.Parent.BLN_ClientType__c : acc.BLN_ClientType__c;

            List<BLN_AccountGroupRule__c> accRuleGrp = [SELECT Id FROM BLN_AccountGroupRule__c 
                                                            WHERE RecordType.Name =: BLN_AppConstants.RECORD_TYPE_CORPORATE_LEVEL 
                                                            AND BLN_CorporateType__c =: clientType WITH SECURITY_ENFORCED];
            
            if(arpIbMtd.BLN_InheritanceBehaviour__c == BLN_AppConstants.INHERITANCE_BEHAVIOUR_SUM || arpIbMtd.BLN_InheritanceBehaviour__c == BLN_AppConstants.INHERITANCE_BEHAVIOUR_SUM_LOWEST_LEVEL) {
                allHierachyAccountList.add(acc.Id);
                
                if(acc.ParentId != null) {
                    allHierachyAccountList.add(acc.ParentId);
                }
                
                if(acc.ParentId != null && acc.Parent.ParentId != null) {
                    allHierachyAccountList.add(acc.Parent.ParentId);
                }
                
                accountRuleParameters = queryAccountRuleParam(fieldToQuery, allHierachyAccountList, accRuleGrp, arpRecordType, jobDate);
                
            } else if(arpIbMtd.BLN_InheritanceBehaviour__c == BLN_AppConstants.INHERITANCE_BEHAVIOUR_LOWEST_LEVEL) {
                accountRuleParameters = queryAccountRuleParam(fieldToQuery, new List<Id> { accountId }, null, arpRecordType, jobDate);
                
                if(accountRuleParameters.IsEmpty() && acc.ParentId != null) {
                    accountRuleParameters = queryAccountRuleParam(fieldToQuery, new List<Id> { acc.ParentId }, null, arpRecordType, jobDate);
                }
                
                if(accountRuleParameters.IsEmpty() && acc.ParentId != null && acc.Parent.ParentId != null) {
                    accountRuleParameters = queryAccountRuleParam(fieldToQuery, new List<Id> { acc.Parent.ParentId }, null, arpRecordType, jobDate);
                }
                
                if(accountRuleParameters.IsEmpty()) {
                    accountRuleParameters = queryAccountRuleParam(fieldToQuery, null, accRuleGrp, arpRecordType, jobDate);
                }
            }
            
            // if (accountRuleParameters.isEmpty()) {
            //     // Handle scenario where no ARPs are found for the defined input args
            //     throw new BLN_CustomException(System.Label.Error_Message_No_ARP);
            // }
            
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        system.debug('accountRuleParameters'+accountRuleParameters);
        return accountRuleParameters.size() > 0 ? accountRuleParameters : null;
    }
    
    public static List<BLN_AccountRuleParameter__c> queryAccountRuleParam(String fieldToQuery, List<id> allHierachyAccountList, List<BLN_AccountGroupRule__c> accRuleGrp, String arpRecordType, Date jobDate) {
        Integer recordLimit = 0;
      
        // String whereClause = 'RecordType.Name =: arpRecordType AND BLN_ActiveFrom__c <=: jobDate AND BLN_ActiveTo__c >=: jobDate';
        String whereClause = 'RecordType.Name =: arpRecordType AND BLN_ActiveFrom__c <=: jobDate AND BLN_IsActive__c = true';
        
        if(allHierachyAccountList != null && accRuleGrp != null) {
            whereClause += ' AND (BLN_Account__c IN: allHierachyAccountList OR BLN_AccountRuleGroup__c IN: accRuleGrp)';
        } else if(allHierachyAccountList != null) {
            whereClause += ' AND BLN_Account__c IN: allHierachyAccountList';
        } else {
            whereClause += ' AND BLN_AccountRuleGroup__c IN: accRuleGrp';
        }

        String query = makeDynamicQuery(fieldToQuery, 'BLN_AccountRuleParameter__c', whereClause, recordLimit);
        return System.Database.query(query);
    }
    
    public static String makeDynamicQuery(String fieldsToQuery, String objectAPIName, String whereClause, Integer recordLimit) {
        String query = 'SELECT ' + fieldsToQuery + ' FROM ' + objectAPIName;
        query += whereClause != null ? ' WHERE ' + whereClause : '';
        query += recordLimit > 0 ? ' LIMIT ' + recordLimit : '';
        query += ' WITH SECURITY_ENFORCED';
        
        return query;
    }
    
    // Custom exception class
    public class BLN_CustomException extends Exception {}
}