trigger BLN_AGRMDMTrigger on BLN_AccountGroupRule__c (after update) {
    BLN_TriggerDispatcher.dispatch(new BLN_ChildMDMTriggerHandler(), Trigger.operationType, Trigger.new.getSObjectType().getDescribe().getName());
}