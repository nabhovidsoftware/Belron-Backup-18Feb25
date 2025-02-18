/** @description : The Apex trigger for BLN_AccountTriggerHandler
*   @Story : FOUK-5167
*   @author: Shubhangi (PwC IN)
*   @CreatedDate: 19/06/2024
*/
trigger BLN_AccountTrigger on Account (After insert, After update) {

    BLN_TriggerDispatcher.dispatch(new BLN_AccountTriggerHandler(), Trigger.operationType, System.Label.BLN_AccountObj);

	
}