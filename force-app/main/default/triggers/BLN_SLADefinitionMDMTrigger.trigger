trigger BLN_SLADefinitionMDMTrigger on BLN_SLADefinition__c (after update) {
    BLN_TriggerDispatcher.dispatch(new BLN_ChildMDMTriggerHandler(), Trigger.operationType, Trigger.new.getSObjectType().getDescribe().getName());
}