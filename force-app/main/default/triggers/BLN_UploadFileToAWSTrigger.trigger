/** @description : The Apex trigger for BLN_UploadFileToAWSHandler
*   @Story : FOUK-7053
*   @author: Prashant Kumar Singh TPR
*   @CreatedDate: 25/06/2024
*/
trigger BLN_UploadFileToAWSTrigger on ContentVersion (after insert) {
    // if (Trigger.isAfter && Trigger.isInsert) {
    //     // Calling the handler method to process the inserted ContentVersion records
    //     system.debug(Trigger.new);
    //   BLN_UploadFileToAWSHandler.uploadFileToAWS(Trigger.newMap.keySet());
    // }
   // BLN_TriggerDispatcher.dispatch(new BLN_UploadFileToAWSHandler(), Trigger.operationType, System.Label.BLN_ContentVersionObj);

}