public with sharing class BLN_ShowProcedures {

/* MethodName : getProceduresArp
Description : This method is used to get procedures accountRuleParamater :
Input Parameter : accountId
Output Parameter : 
CreatedDate: 31-05-2024
CreatedBy : Pwc-India
Change log :
****************************************/
    /*  *@description:FOUK-5079 This method is used to get procedures accountRuleParamater */
    
    @InvocableMethod(label='getProceduresArp')
    public static List<List<BLN_AccountRuleParameterWrapper>> getProceduresArp(List<List<String>> accountIds){
        List<BLN_AccountRuleParameter__c> arpList1 = new List<BLN_AccountRuleParameter__c>();
        List<BLN_AccountRuleParameter__c> arpList2 = new List<BLN_AccountRuleParameter__c>();
        List<BLN_AccountRuleParameter__c> arpList = new List<BLN_AccountRuleParameter__c>();
        Set<String> accountIdSetARP = new Set<String>();
        Map<Id, String> mapAccountIdVsName = new Map<Id, String>();
        List<BLN_AccountRuleParameterWrapper> listArp = new List<BLN_AccountRuleParameterWrapper>();
        List<BLN_AccountRuleParameterWrapper> arpWrapperList;

        try{
            // List<BLN_AccountRuleParameter__c> arpList = new List<BLN_AccountRuleParameter__c>();
             Set<String> accountIdSet = new Set<String>();
             for(List<String> accIds : accountIds){
                 for(String accId : accIds){
                     accountIdSet.add(accId);
                 }
             }
             List<string> accountIdList =  new List<String>(accountIdSet);
            if(BLN_AccountRuleParameter__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                if(accountIdList.size() > 1){
                    arpList1 = BLN_AccountRuleParameterUtil.getAccountRuleParameters('Procedure',accountIdList[0],date.today());
                    arpList2 = BLN_AccountRuleParameterUtil.getAccountRuleParameters('Procedure',accountIdList[1],date.today());
                }
                else if(accountIdList.size() == 1){
                    arpList1 = BLN_AccountRuleParameterUtil.getAccountRuleParameters('Procedure',accountIdList[0],date.today());
                }
            }
            if(arpList1 !=null && !arpList1.isEmpty()){
                arpList.addAll(arpList1);
            }
            if(arpList2 !=null && !arpList2.isEmpty()){
                arpList.addAll(arpList2);
            }
        
            if(!arpList.isEmpty() || arpList != Null){
                for(BLN_AccountRuleParameter__c objARPList : arpList){
                    accountIdSetARP.add(objARPList.BLN_Account__c);
                }
            }
            
            for(Account objAccount : [Select Id, Name 
                                      From Account 
                                      Where Id IN: accountIdSetARP]){
                mapAccountIdVsName.put(objAccount.Id, objAccount.Name);
            }

            for(BLN_AccountRuleParameter__c objARPList : arpList){
                BLN_AccountRuleParameterWrapper arpWrapper = new BLN_AccountRuleParameterWrapper();
                if(mapAccountIdVsName.ContainsKey(objARPList.BLN_Account__c)){
                    arpWrapper.accountName = mapAccountIdVsName.get(objARPList.BLN_Account__c);
                    arpWrapper.objARP = objARPList;

                    arpWrapperList = new List<BLN_AccountRuleParameterWrapper>();
                    arpWrapperList.add(arpWrapper);
                    
                    listArp.addAll(arpWrapperList);
                }
            }
        }
        catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
        }
        //return  !arpList.isEmpty() ? new List<List<BLN_AccountRuleParameter__c>>{arpList}: new List<List<BLN_AccountRuleParameter__c>>();
        return !listArp.isEmpty() ? new List<List<BLN_AccountRuleParameterWrapper>>{listArp} : new List<List<BLN_AccountRuleParameterWrapper>>();
    }
}