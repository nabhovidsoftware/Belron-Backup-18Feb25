trigger BLN_UpdateContentDocumentTitle on ContentDocumentLink (after insert) {
    List<ContentDocumentLink> cdListToSendToDocstore = new List<ContentDocumentLink>();
    List<Id> contDocId = new List<Id>();
    for(ContentDocumentLink cDLink: Trigger.new){
        contDocId.add(cDLink.ContentDocumentId);
    }
    List<ContentDocument> CDList = [Select id, title, IsArchived from ContentDocument where id in :contDocId];
    BLN_UpdateContentDocumentTitleHandler.updateFileNameOnFailedSA(CDList);
    
    for(ContentDocumentLink cDLink: Trigger.new){
        if(cDLink.LinkedEntityId.getSObjectType().getDescribe().getName() == 'ServiceAppointment'){
            cdListToSendToDocstore.add(cDLink);        	
        }
    }
    
    if(cdListToSendToDocstore != null && cdListToSendToDocstore.size() > 0){
        System.enqueueJob(new BLN_UploadFileToAWSQueueable(cdListToSendToDocstore));
    }
}