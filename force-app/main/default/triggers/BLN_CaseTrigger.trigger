/** @description : The Apex trigger for BLN_CaseTriggerHandler
*   @Story : FOUK-5034
*   @author: Rahul Jain(PwC IN)
*   @CreatedDate: 19/06/2024
*/
trigger BLN_CaseTrigger on Case (Before update ,After update) {
    BLN_TriggerDispatcher.dispatch(new BLN_CaseTriggerHandler(), Trigger.operationType, System.Label.BLN_CaseObj);
}