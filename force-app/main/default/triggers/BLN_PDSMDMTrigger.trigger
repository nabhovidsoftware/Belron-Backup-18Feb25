trigger BLN_PDSMDMTrigger on BLN_PDSCode__c (after insert,after update) {
    BLN_TriggerDispatcher.dispatch(new BLN_ChildMDMTriggerHandler(), Trigger.operationType, Trigger.new.getSObjectType().getDescribe().getName());
}