/*****************************************
ClassName : BLN_UploadFileToAWSHandler
Description : FOUK-7053
CreatedDate: 25-06-2024
CreatedBy : PwC-India
****************************************/


/*  *@description:This class is used to upload file to AWS*/
public with sharing class BLN_UploadFileToAWSHandler implements BLN_TriggerInterface{
    public static Boolean stopExecution = false;

    /**
*@description:This method is used to check trigger executed or not.
*@return boolean
*/
public Boolean stopDispatch(){
    return stopExecution;
}

/**
*@description:This method is used in interface so declare in class..
*@return void
*/
public void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {

    stopExecution = true;
   
}

/**
*@description:This method is used in interface so declare in class..
*@return void
*/
public static void beforeInsert(List<SObject> newList) {

    stopExecution=true;
}
/**
*@description:This method is used in interface so declare in class..
*@return void
*/
public static void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {

    stopExecution=true;
}

/**
*@description:Once ContentDocumentLink inserted method will pass below parameters for next execution.
*@return void
*/
public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {

    List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
    List<ContentDocumentLink> cdLinkWoli = new List<ContentDocumentLink>();
    List<ContentDocument> cdTitleToUpdate = new List<ContentDocument>();
    Map<Id, ContentDocumentLink> cdlIdVsCDL = new Map<Id, ContentDocumentLink>();
    Map<Id, Id> cdlIdVsLinkedEntityId =  new Map<Id, Id>();
    Map<Id, Id> linkedEntityIdVsWoliId =  new Map<Id, Id>();
    Map<Id, ServiceAppointment> saWoliIdVsSARec = new Map<Id, ServiceAppointment>();

    Set<Id> documentId = new set<Id>();
    for (ContentDocumentLink cdl : (List<ContentDocumentLink>)newList) {
        documentId.add(cdl.ContentDocumentId);
        if (cdl.LinkedEntityId.getSObjectType().getDescribe().getName()!='User'
           		&& cdl.LinkedEntityId.getSObjectType().getDescribe().getName()!='ProductRequired'
           		&& cdl.LinkedEntityId.getSObjectType().getDescribe().getName()!='ServiceAppointment') {
            cdlList.add(cdl);
        }
        
        //link the content to WOLI along with ProductRequired
        else if(cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'ProductRequired' || cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'ServiceAppointment'){
            cdlIdVsLinkedEntityId.put(cdl.Id, cdl.LinkedEntityId);
            cdlIdVsCDL.put(cdl.Id, cdl);
        }
    }
    
    if(cdlIdVsLinkedEntityId != null && cdlIdVsLinkedEntityId.size() > 0){
        List<ProductRequired> prList = [Select Id, ParentRecordId, BLN_WorkOrder__r.WorkOrderNumber
                                        FROM ProductRequired
                                       	WHERE Id IN: cdlIdVsLinkedEntityId.values() WITH SECURITY_ENFORCED];
                
        List<ServiceAppointment> srList = [Select Id, ParentRecordId 
                                        FROM ServiceAppointment
                                       	WHERE Id IN: cdlIdVsLinkedEntityId.values() WITH SECURITY_ENFORCED];
                
        
        if(prList != null && prList.size() > 0){
            for(ProductRequired prRec: prList){
            	linkedEntityIdVsWoliId.put(prRec.Id, prRec.ParentRecordId);
            }
        }else if(srList != null && srList.size() > 0){
             for(ServiceAppointment srRec: srList){
            	linkedEntityIdVsWoliId.put(srRec.Id, srRec.ParentRecordId);
            }
        }
        
        List<ServiceAppointment> saList= [SELECT id, AppointmentNumber, ParentRecordId, BLN_WorkOrderNumber__r.WorkOrderNumber FROM ServiceAppointment 
                                            WHERE ParentRecordId IN: linkedEntityIdVsWoliId.values() WITH SECURITY_ENFORCED];
        
        if(saList != null && saList.size() > 0){
            for(ServiceAppointment saRec: saList){
                saWoliIdVsSARec.put(saRec.ParentRecordId, saRec);
            }
        }
        
        for(Id cdlId : cdlIdVsLinkedEntityId.keyset()){
            String woNumber = '';
            String saNumber = '';
            
            ContentDocumentlink cdLink = new ContentDocumentlink();
            cdLink.LinkedEntityId = linkedEntityIdVsWoliId.get(cdlIdVsLinkedEntityId.get(cdlId));
        	cdLink.ContentDocumentId = cdlIdVsCDL.get(cdlId).ContentDocumentId;
            cdLinkWoli.add(cdLink);            

            ContentDocument cdRec = new ContentDocument(Id=cdlIdVsCDL.get(cdlId).ContentDocumentId);
            if(saWoliIdVsSARec != null && saWoliIdVsSARec.size() > 0){
            	woNumber = saWoliIdVsSARec.get(cdLink.LinkedEntityId).BLN_WorkOrderNumber__r.WorkOrderNumber;
            	saNumber = saWoliIdVsSARec.get(cdLink.LinkedEntityId).AppointmentNumber;    
            }
            
            cdRec.Title = woNumber + '-' + saNumber + '-' + cdlIdVsCDL.get(cdlId).SystemModstamp + '-' +'StockCollection';
            cdTitleToUpdate.add(cdRec); 
            
        }
        
    }
    
    if(cdTitleToUpdate != null && cdTitleToUpdate.size() > 0 && Schema.sObjectType.ContentDocument.isUpdateable()){
        update cdTitleToUpdate;
    }    
   
    if(cdLinkWoli != null && cdLinkWoli.size() > 0 && Schema.sObjectType.ContentDocumentLink.isCreateable()){
        insert cdLinkWoli;
    }    
   
    // for(ContentVersion cdl:cdlList ){
    //     System.enqueueJob(new BLN_UploadFileToAWSQueueable(new List<ContentVersion>{cdl}));
    // }
    if(!cdlList.isEmpty()){
        System.enqueueJob(new BLN_UploadFileToAWSQueueable(cdlList));
    }
}

public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    stopExecution = true;
 }
 
 public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
     stopExecution = true;
 }
 
 
 public void afterUnDelete(List<SObject> newList, Map<Id, SObject> newMap) {
     stopExecution = true;
 }

}