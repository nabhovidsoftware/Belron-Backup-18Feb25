trigger BLN_AlterNativeMDMTrigger on BLN_AccountAlternativeName__c (after insert, after update) {
    BLN_TriggerDispatcher.dispatch(new BLN_ChildMDMTriggerHandler(), Trigger.operationType, Trigger.new.getSObjectType().getDescribe().getName());

}