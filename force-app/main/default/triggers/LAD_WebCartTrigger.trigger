trigger LAD_WebCartTrigger on WebCart (before insert,before update,after insert, after update) {
    system.debug('in the cart trigger');

    if(Trigger.isAfter && Trigger.isUpdate && LAD_webCartTriggerHandler.isFirstTime){
        LAD_webCartTriggerHandler.isFirstTime = false;
        LAD_webCartTriggerHandler.clearMDCPreferenceRecords(Trigger.new);
        
     
    }
   
}