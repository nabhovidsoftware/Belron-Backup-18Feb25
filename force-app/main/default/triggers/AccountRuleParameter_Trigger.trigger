/*****************************************
*triggerName : AccountRuleParameterTrigger
*@description : FOUK-6076 fill Inheritance Behaviour from custom metadata
*CreatedDate: 11-03-2024
*CreatedBy : PwC-India
****************************************/
trigger AccountRuleParameter_Trigger on BLN_AccountRuleParameter__c (before insert) {
    if(Trigger.IsBefore) {
        if(Trigger.IsInsert) {
            BLN_AccountRuleParameterTriggerHandler.beforeInsert(Trigger.New);
        }
    }
}