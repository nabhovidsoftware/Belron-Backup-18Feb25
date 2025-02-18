public with sharing class BLN_TimeLineController {
    @AuraEnabled
    public static List<BLN_WrapperStore.InitiativeWrapper> getInitiatives(String recId) {
        List<BLN_WrapperStore.InitiativeWrapper> intWrapList = new List<BLN_WrapperStore.InitiativeWrapper>();
        
        for(BLN_Initiative__c initiative : [SELECT Id, Name, BLN_Status__c, BLN_EndDate__c, BLN_StartDate__c 
                                            FROM BLN_Initiative__c 
                                            WHERE BLN_AccountPlanName__c = :recId WITH SECURITY_ENFORCED]) {
            String className;
            
            switch on initiative.BLN_Status__c {
                when 'In Progress' {
                    className = 'blue';
                    if(initiative.BLN_EndDate__c < System.today()) {
                        className = 'red';
                    }
                }
                when 'Completed' {
                    className = 'green';
                }
                when 'Aborted' {
                    className = 'red';
                }
                when else {
                    if(initiative.BLN_EndDate__c < System.today()) {
                        className = 'red';
                    } else {
                        className = 'yellow';
                    }
                }
            }
             
            intWrapList.add(new BLN_WrapperStore.InitiativeWrapper(String.valueOf(initiative.Id), initiative.Name, String.valueOf(initiative.BLN_StartDate__c), String.valueOf(initiative.BLN_EndDate__c), className));
        }
        
        return intWrapList;
    }
}