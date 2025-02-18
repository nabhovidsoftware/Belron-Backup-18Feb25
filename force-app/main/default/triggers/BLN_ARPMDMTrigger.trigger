trigger BLN_ARPMDMTrigger on BLN_AccountRuleParameter__c (after insert, after update,before insert) {
    BLN_TriggerDispatcher.dispatch(new BLN_ChildMDMTriggerHandler(), Trigger.operationType, Trigger.new.getSObjectType().getDescribe().getName());
}