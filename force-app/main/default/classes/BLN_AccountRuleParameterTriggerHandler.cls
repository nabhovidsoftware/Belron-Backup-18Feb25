/*****************************************
*ClassName : BLN_AccountRuleParameterTriggerHandler
*@description : FOUK-6076 fill Inheritance Behaviour from custom metadata
*CreatedDate: 11-03-2024
*CreatedBy : PwC-India
****************************************/
public with sharing class BLN_AccountRuleParameterTriggerHandler {
    public static void beforeInsert(List<BLN_AccountRuleParameter__c> arpList) {
        List<BLN_AccountRuleParameter__c> slAarpList = new List<BLN_AccountRuleParameter__c>();
        String arpRecordTypeIdSla = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('SLA').getRecordTypeId();
        for(BLN_AccountRuleParameter__c arp : arpList) {
            if(arp.RecordTypeId == arpRecordTypeIdSla){
                slAarpList.add(arp);
            }
        }
        if(slAarpList != null && slAarpList.size() > 0){
            Set<Id> arpRecordTypeIdSet = new Set<Id>();
            Map<Id, String> arpRecordTypeMap = new Map<Id, String>();
            Map<String, String> arpIbMap = new Map<String, String>();
            
            // for(BLN_AccountRuleParameter__c arp : arpList) {
            for(BLN_AccountRuleParameter__c arp : slAarpList) {
                arpRecordTypeIdSet.add(arp.RecordTypeId);
            }
            
            for(RecordType rt : [SELECT Name FROM RecordType WHERE Id IN: arpRecordTypeIdSet WITH SECURITY_ENFORCED]) {
                arpRecordTypeMap.put(rt.Id, rt.Name);
            }
            
            for(BLN_ARPInheritanceBehaviour__mdt arpIbMtd : [SELECT Id, BLN_ARPRecordTypeName__c, BLN_InheritanceBehaviour__c 
                                                            FROM BLN_ARPInheritanceBehaviour__mdt 
                                                            WHERE BLN_ARPRecordTypeName__c IN: arpRecordTypeMap.values() WITH SECURITY_ENFORCED]) {
                                                                arpIbMap.put(arpIbMtd.BLN_ARPRecordTypeName__c, arpIbMtd.BLN_InheritanceBehaviour__c);
                                                            }
            
            for(BLN_AccountRuleParameter__c arp : arpList) {
                arp.BLN_InheritanceBehaviour__c = arpIbMap.get(arpRecordTypeMap.get(arp.RecordTypeId));
            }
            matchStandardSla(slAarpList, arpRecordTypeMap);
        }
    }
    
    public static void matchStandardSla(List<BLN_AccountRuleParameter__c> arpList, Map<Id, String> arpRecordTypeMap) {
        List<BLN_AccountRuleParameter__c> slaArpList = new List<BLN_AccountRuleParameter__c>();
        Set<Id> contractIdSet = new Set<Id>();
        Map<Id, String> contractClientTypeMap = new Map<Id, String>();
        
        for(BLN_AccountRuleParameter__c arp : arpList) {
            if(arpRecordTypeMap.get(arp.RecordTypeId) == BLN_AppConstants.RECORD_TYPE_SLA) {
                slaArpList.add(arp);
                contractIdSet.add(arp.BLN_Contract__c);
            }
        }
        
        for(Contract contractRec : [SELECT Id, Account.BLN_ClientType__c FROM Contract 
                                    WHERE Id IN: contractIdSet WITH SECURITY_ENFORCED]) {
                                        contractClientTypeMap.put(contractRec.Id, contractRec.Account.BLN_ClientType__c);
                                    }
                
        Map<String, List<BLN_AccountRuleParameter__c>> accRuleGrpMap = new Map<String, List<BLN_AccountRuleParameter__c>>();
        
        for(BLN_AccountGroupRule__c accRuleGrp : [SELECT Id, BLN_CorporateType__c, (SELECT Id, BLN_ThresholdValue__c, BLN_SLAType__c, BLN_SLAType__r.BLN_ThresholdOperator__c FROM Account_Rule_Parameters__r WHERE RecordType.Name =: BLN_AppConstants.RECORD_TYPE_SLA) 
                                                  FROM BLN_AccountGroupRule__c 
                                                  WHERE RecordType.Name =: BLN_AppConstants.RECORD_TYPE_CORPORATE_LEVEL 
                                                  AND BLN_CorporateType__c in: contractClientTypeMap.values() WITH SECURITY_ENFORCED ]) {
            if(accRuleGrpMap.get(accRuleGrp.BLN_CorporateType__c) == null) {
                accRuleGrpMap.put(accRuleGrp.BLN_CorporateType__c, new List<BLN_AccountRuleParameter__c>());
            }
                                                      List<BLN_AccountRuleParameter__c> tempArp = accRuleGrpMap.get(accRuleGrp.BLN_CorporateType__c);
                                                      tempArp.addAll(accRuleGrp.Account_Rule_Parameters__r);
            accRuleGrpMap.put(accRuleGrp.BLN_CorporateType__c, tempArp);
        }
        
        
        for(BLN_AccountRuleParameter__c arp : slaArpList) {
            if(arp.BLN_Contract__c != NULL && accRuleGrpMap.containsKey(contractClientTypeMap.get(arp.BLN_Contract__c))) {  
                String accountClientType = contractClientTypeMap.get(arp.BLN_Contract__c);
                for (BLN_AccountRuleParameter__c stndrdArp : accRuleGrpMap.get(accountClientType)) {
                    if(stndrdArp.BLN_SLAType__c == arp.BLN_SLAType__c) {
                        Boolean flag = false;
                        if(arp.BLN_ThresholdValue__c != null && stndrdArp.BLN_ThresholdValue__c != null) {
                            switch on stndrdArp.BLN_SLAType__r.BLN_ThresholdOperator__c {
                                when 'Greater Than (>)' {
                                    if(arp.BLN_ThresholdValue__c > stndrdArp.BLN_ThresholdValue__c) {
                                        flag = true;
                                    }
                                }
                                when 'Lesser Than (<)' {
                                    if(arp.BLN_ThresholdValue__c < stndrdArp.BLN_ThresholdValue__c) {
                                        flag = true;
                                    }
                                }
                                when 'Equal (=)' {
                                    if(arp.BLN_ThresholdValue__c == stndrdArp.BLN_ThresholdValue__c) {
                                        flag = true;
                                    }
                                }
                                when 'Greater Than or Equal (>=)' {
                                    if(arp.BLN_ThresholdValue__c >= stndrdArp.BLN_ThresholdValue__c) {
                                        flag = true;
                                    }
                                }
                                when 'Lesser Than or Equal (<=)' {
                                    if(arp.BLN_ThresholdValue__c <= stndrdArp.BLN_ThresholdValue__c) {
                                        flag = true;
                                    }
                                }
                            }
                        }
                        
                        if(flag == true) {
                            arp.BLN_SLAApproved__c = true;
                            arp.BLN_InLineWithStandardSLA__c = true;
                        } else {
                            arp.BLN_SLAApproved__c = false;
                            arp.BLN_InLineWithStandardSLA__c = false;
                        }
                    }
                }
            }    
        }
    }  
}