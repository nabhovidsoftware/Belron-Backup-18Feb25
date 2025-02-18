/** @description : The Apex trigger for BLN_UploadFileToAWSHandler
*   @Story : FOUK-7053
*   @author: Prashant Kumar Singh TPR
*   @CreatedDate: 25/06/2024
*/
trigger BLN_UploadCdlToAWSTrigger on ContentDocumentLink (after insert) {
    BLN_TriggerDispatcher.dispatch(new BLN_UploadFileToAWSHandler(), Trigger.operationType, 'ContentDocumentLink');
}