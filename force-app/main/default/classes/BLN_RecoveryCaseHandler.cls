/*****************************************
ClassName : BLN_RecoveryCaseHandler
Description : FOUK-6164 This class is used For Case Priority.
CreatedDate: 12-03-2024
CreatedBy : PwC-India
****************************************/


public with sharing class BLN_RecoveryCaseHandler {
    @InvocableMethod
    /*  *@Description : This method is used to get the records from BLN_RecCasePriority__mdt custom metadata. */
    public static void calculateRecoveryCasePriority(List<Case> caseList) {
        
        Map<String, String> recPriority = new Map<String, String>();
        List<BLN_RecCasePriority__mdt>getMetadata = BLN_RecCasePriority__mdt.getall().values();
        
        For(BLN_RecCasePriority__mdt priorityMetadata :getMetadata){
            
           /*  *@Description : This method is used to get the records from BLN_RecCasePriority__mdt custom metadata Where IsActive = true. */     
            If(priorityMetadata.BLN_Active__c ){                                        
                recPriority.put(priorityMetadata.BLN_FieldAPIName__c + priorityMetadata.BLN_FieldValue__c , priorityMetadata.BLN_Priority__c);
            }   
        }
        
        for (Case caseRec : caseList) {
            String priority = '';
            
            if (caseRec.BLN_ServiceType__c != null  && caseRec.BLN_Corporate__c == null &&  recPriority.containsKey(Label.BLN_RecCasePriorityField1 + caseRec.BLN_ServiceType__c )) {
                priority = recPriority.get(Label.BLN_RecCasePriorityField1 + caseRec.BLN_ServiceType__c);
                
            } else if (caseRec.BLN_ServiceType__c != null && caseRec.BLN_Corporate__c != null && recPriority.containsKey(Label.BLN_RecCasePriorityField1 + caseRec.BLN_ServiceType__c)) {
                
                priority = recPriority.get(Label.BLN_RecCasePriorityField1 + caseRec.BLN_ServiceType__c);
            } else if (recPriority.containsKey(Label.BLN_RecCasePriorityField2 + caseRec.BLN_SecondaryReason__c)) {
                
                priority = recPriority.get(Label.BLN_RecCasePriorityField2 + caseRec.BLN_SecondaryReason__c);
            }
            
            caseRec.Priority = priority;
            
            if(caseRec.BLN_Escalated__c)
            {
                caseRec.Priority = Label.BLN_CriticalPriority;
            }  
        }
        
            if(case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable() && Schema.sObjectType.Case.isUpdateable()){
        
        /*  *@Description : This method is used to Update Case records with calculated priority */
        update caseList;
        
            }
    }
    
}