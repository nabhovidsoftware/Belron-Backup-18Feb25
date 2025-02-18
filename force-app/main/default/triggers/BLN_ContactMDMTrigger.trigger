trigger BLN_ContactMDMTrigger on Contact (after insert,after update) {
    BLN_TriggerDispatcher.dispatch(new BLN_ChildMDMTriggerHandler(), Trigger.operationType, Trigger.new.getSObjectType().getDescribe().getName());
}