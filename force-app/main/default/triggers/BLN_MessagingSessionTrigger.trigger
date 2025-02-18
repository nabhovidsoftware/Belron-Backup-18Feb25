/** @description : The Apex trigger for BLN_MessagingSessionTriggerHandler
*   @Story :
*   @author: (PwC IN)
*   @CreatedDate: 19/06/2024
*/
trigger BLN_MessagingSessionTrigger on MessagingSession (After insert, After update) {
        BLN_TriggerDispatcher.dispatch(new BLN_MessagingSessionTriggerHandler(), Trigger.operationType, System.Label.BLN_MessagingSessionObj);
}