/**@description : This batch class will delete all the files which have been uploaded to AWS at 4 a.m. daily
*  @author: PwC India
*  @Story: FOUK-9309 (Document Storage - Periodical deletion of files from SF)
*  @CreatedDate: 04/07/2024
*/
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.EmptyStatementBlock')
global class BLN_DeleteFilesAfterAWSUpload implements Database.Batchable<sObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bC) {
        // Query ContentVersion records where BLN_IsUploadedToAWS__c = true
        return Database.getQueryLocator([SELECT Id, BLN_IsUploadedToAWS__c,ContentDocumentId FROM ContentVersion WHERE BLN_IsUploadedToAWS__c = TRUE]);
    }
    
    global void execute(Database.BatchableContext bC, List<ContentVersion> scope) {
        Set<Id> contentDocumentIdsToDelete = new Set<Id>();
        Set<Id> contentVersionCheckServiceReport = new Set<Id>();
        List<ContentDocument> contentDocumentsToDelete = new List<ContentDocument>();
        for (ContentVersion cv : scope) {
            if (cv.BLN_IsUploadedToAWS__c && cv.ContentDocumentId != null) {
                contentDocumentIdsToDelete.add(cv.ContentDocumentId);
                contentVersionCheckServiceReport.add(cv.Id);
            }
        }
        
        List<ServiceReport> serviceReports = [SELECT Id 
                                              FROM ServiceReport 
                                              WHERE ContentVersionDocumentId IN: contentVersionCheckServiceReport];
        
        if(serviceReports != null && serviceReports.size() > 0){
            delete serviceReports;
        }        
        
        if (!contentDocumentIdsToDelete.isEmpty()) {
            contentDocumentsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIdsToDelete];
        }
        if (!contentDocumentsToDelete.isEmpty()) {
            delete contentDocumentsToDelete;
        }
    }
    
    global void finish(Database.BatchableContext bC) {
        // Optional: Add any post-processing logic if needed
    }
    
    global void execute(SchedulableContext sC) {
        BLN_DeleteFilesAfterAWSUpload batch = new BLN_DeleteFilesAfterAWSUpload();
        Database.executeBatch(batch);
    }
}