/** @description : The Apex Class we are using in LWC to display list of service appointment with product required
*   @Story : FOUK-4136
*   @author: Rahul Jain(PwC IN)
*	@CreatedDate: 20/12/2023
*/ 
public with sharing class BLN_ProductRequiredController {
    @AuraEnabled(cacheable=false)
    public static List<ProductRequiredWrapper> getRelatedProductRequired() {
        List<ProductRequiredWrapper> prWrapperList = new List<ProductRequiredWrapper>();
        Id loggedInUserId = UserInfo.getUserId();
        Set<Id> woliIdSet = new Set<Id>();
        
        // Fetch appointments with the same WorkOrderNumber
        List<ServiceAppointment> listSA = [
            SELECT Id, BLN_WorkOrderLineItem__r.Id, AppointmentNumber, WorkType.Name, WorkType.BLN_IsMainJob__c, BLN_WorkOrderLineItem__c, Status,BLN_WorkOrderNumber__c,BLN_WorkOrderNumber__r.WorkOrderNumber,BLN_AssignedServiceResource__r.RelatedRecordId,EarliestStartTime
            FROM ServiceAppointment
            WHERE BLN_WorkOrderNumber__c != null WITH SECURITY_ENFORCED
        ];
        
        // Filter appointments based on WorkType and Status
        List<ServiceAppointment> stockCollectAppointments = new List<ServiceAppointment>();
        Set<String> validStatuses = new Set<String>{'Arrived', 'In Progress','Dispatched'};
            
            for (ServiceAppointment saObj : listSA) {
                if (saObj.WorkType.Name == 'Stock Collect' &&
                    validStatuses.contains(saObj.Status)) {
                        stockCollectAppointments.add(saObj);
                    }
            }
        
        // Ensure there is at least one Stock Collect appointment
        if (!stockCollectAppointments.isEmpty()) {
            List<String> objArray = new List<String>();
            
            for (ServiceAppointment obj : stockCollectAppointments) {
                if (obj.BLN_WorkOrderNumber__c != null) {
                    objArray.add(obj.BLN_WorkOrderNumber__c);
                }
            }
            
            // Show appointments with WorkType.BLN_IsMainJob__c equals true
            for (ServiceAppointment saObj : listSA) {
                if (saObj.WorkType.BLN_IsMainJob__c == true && objArray.contains(saObj.BLN_WorkOrderNumber__c)) {
                    woliIdSet.add(saObj.BLN_WorkOrderLineItem__r.Id);
                }
            }
            Map<Id, List<ProductRequired>> prMap = new Map<Id, List<ProductRequired>>();
            List<ProductRequired> prList = [
                SELECT Id, ProductRequiredNumber, BLN_IsWMSTracked__c, Product2.Name,QuantityRequired,ParentRecordId,BLN_Status__c,BLN_FailureReason__c,BLN_Notes__c,Product2.ProductCode,Product2.BLN_BelronFittingTime__c
                FROM ProductRequired
                WHERE ParentRecordId IN :woliIdSet AND BLN_Status__c = null WITH SECURITY_ENFORCED
            ];
            for (ProductRequired pr : prList) {
                if (!prMap.containsKey(pr.ParentRecordId)) {
                    prMap.put(pr.ParentRecordId, new List<ProductRequired>());
                }
                prMap.get(pr.ParentRecordId).add(pr);
            }
            List<ServiceAppointment> mainJobAppointments = [
                SELECT Id, BLN_WorkOrderLineItem__r.Id, AppointmentNumber, WorkType.BLN_IsMainJob__c, BLN_WorkOrderLineItem__c,Status,BLN_WorkOrderNumber__c,BLN_WorkOrderNumber__r.WorkOrderNumber,BLN_AssignedServiceResource__r.RelatedRecordId
                FROM ServiceAppointment
                WHERE BLN_WorkOrderLineItem__c IN :woliIdSet AND BLN_AssignedServiceResource__r.RelatedRecordId = :loggedInUserId AND EarliestStartTime = TODAY WITH SECURITY_ENFORCED
            ];
            
            for (ServiceAppointment saObj : mainJobAppointments) {
                List<ProductRequired> filteredPrList = prMap.get(saObj.BLN_WorkOrderLineItem__r.Id);
                if (filteredPrList != null) {
                    for (ProductRequired pr : filteredPrList) {
                        prWrapperList.add(new ProductRequiredWrapper(
                            saObj.Id, pr.Id, pr.ProductRequiredNumber, saObj.AppointmentNumber, pr.BLN_IsWMSTracked__c, pr.Product2Id, pr.QuantityRequired,saObj.Status,pr.BLN_Notes__c,pr.BLN_FailureReason__c,saObj.BLN_WorkOrderNumber__r.WorkOrderNumber,pr.Product2.BLN_BelronFittingTime__c,saObj.BLN_WorkOrderNumber__c,pr.Product2.Name, pr.Product2.ProductCode
                        ));
                    }
                }
            }
        }
        return prWrapperList;
    }
    public class ProductRequiredWrapper  {
        @AuraEnabled public Id serviceAppointmentId;
        @AuraEnabled public Id prodReqId;
        @AuraEnabled public String productRequiredNumber;
        @AuraEnabled public String appointmentNumber;
        @AuraEnabled public boolean isWMSTracked;
        @AuraEnabled public String prodId;
        @AuraEnabled public Decimal quantityReq;
        @AuraEnabled public String serviceAppointmentStatus;
        @AuraEnabled public String prodReqNotes;
        @AuraEnabled public String prodReqFailureReason;
        @AuraEnabled public String workOrderNumber;
        @AuraEnabled public Decimal productTime;
        @AuraEnabled public String servAppWorkOrderNumber;
        @AuraEnabled public String productName;
        @AuraEnabled public String productCode;
        
        
        public ProductRequiredWrapper(Id serviceAppointmentId, Id prodReqId,String productRequiredNumber,String appointmentNumber, Boolean isWMSTracked,String prodId, Decimal quantityReq,String serviceAppointmentStatus, String prodReqNotes, String prodReqFailureReason,String workOrderNumber, Decimal productTime, String servAppWorkOrderNumber, String productName, String productCode) {
            this.serviceAppointmentId = serviceAppointmentId;
            this.prodReqId = prodReqId;
            this.productRequiredNumber = productRequiredNumber;
            this.appointmentNumber = appointmentNumber;
            this.isWMSTracked = isWMSTracked;
            this.prodId = prodId;
            this.quantityReq = quantityReq;
            this.serviceAppointmentStatus = serviceAppointmentStatus;
            this.prodReqNotes = prodReqNotes;
            this.prodReqFailureReason = prodReqFailureReason;
            this.workOrderNumber = workOrderNumber;
            this.productTime = productTime;
            this.servAppWorkOrderNumber = servAppWorkOrderNumber;
            this.productName = productName;
            this.productCode = productCode;
            
        }
    }
    
    @AuraEnabled
    public static void createProdTransfer(String prodId, Decimal quantReq,String prodReqId){
        try {
            ProductTransfer newPT = new ProductTransfer(
                QuantitySent = quantReq, Product2Id = prodId,QuantityUnitOfMeasure = 'Each', QuantityReceived = quantReq, IsReceived = true,BLN_ProductRequired__c = prodReqId
            );
            if(Schema.sObjectType.ProductTransfer.isCreateable()){
                insert newPT;
            }
            if (prodReqId != null) {
                ProductRequired prodReq = [SELECT Id, BLN_Status__c FROM ProductRequired WHERE Id = :prodReqId WITH SECURITY_ENFORCED LIMIT 1];
                if (prodReq != null && prodReq.BLN_Status__c == null) {
                    prodReq.BLN_Status__c = 'Success';
                }
                if(Schema.sObjectType.ProductRequired.isUpdateable()){
                    update prodReq;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error creating ProductTransfer record: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateSA(Id serviceAppId){
        try {
            Id saId;
            ServiceAppointment sA = [Select Id,BLN_WorkOrderNumber__c From ServiceAppointment Where Id =:serviceAppId WITH SECURITY_ENFORCED];
            List<ServiceAppointment> listSA = [Select Id,BLN_WorkOrderNumber__c,WorkType.Name From ServiceAppointment Where BLN_WorkOrderNumber__c =:SA.BLN_WorkOrderNumber__c WITH SECURITY_ENFORCED];
            for(ServiceAppointment eachSA : listSA){
                if(eachSA.WorkType.Name == 'Stock Collect'){
                    saId = eachSA.Id;
                }
            }
            ServiceAppointment sAUpdate = [Select Id,Status From ServiceAppointment Where Id =:saId WITH SECURITY_ENFORCED];
                if(SAUpdate.Status == 'In Progress'){
                    update SAUpdate;
                }else if(SAUpdate.Status == 'Arrived' || SAUpdate.Status == 'Dispatched'){
                    SAUpdate.Status = 'In Progress';
                }
            if(Schema.sObjectType.ServiceAppointment.isUpdateable()){
                update SAUpdate;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateSAToCompleted(Id serviceAppId){
        try {
            Id saId;
            ServiceAppointment sA = [Select Id,BLN_WorkOrderNumber__c From ServiceAppointment Where Id =:serviceAppId WITH SECURITY_ENFORCED];
            List<ServiceAppointment> listSA = [Select Id,BLN_WorkOrderNumber__c,WorkType.Name From ServiceAppointment Where BLN_WorkOrderNumber__c =:SA.BLN_WorkOrderNumber__c WITH SECURITY_ENFORCED];
            for(ServiceAppointment eachSA : listSA){
                if(eachSA.WorkType.Name == 'Stock Collect'){
                    saId = eachSA.Id;
                }
            }
            ServiceAppointment sAUpdate = [Select Id,Status From ServiceAppointment Where Id =:saId WITH SECURITY_ENFORCED];
            if(SAUpdate.Status == 'In Progress'){
                SAUpdate.Status = 'Completed';
            }
            if(Schema.sObjectType.ServiceAppointment.isUpdateable()){
                update SAUpdate;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
    @AuraEnabled
    public static void checkTimeSheetRecords(){
    Id loggedInUserId = UserInfo.getUserId();
    List<TimeSheet> lstTimeSheet = [Select Id,ServiceResource.RelatedRecordId from TimeSheet Where ServiceResource.RelatedRecordId = :loggedInUserId AND StartDate = TODAY];
    }
    */
    @AuraEnabled
    public static void updateProdReq(String prodReqId, String prodReqStatus, String prodReqFailReason, String prodReqNotes){
        try {
            ProductRequired prodReq = [Select Id,BLN_Status__c,BLN_FailureReason__c,BLN_Notes__c,BLN_WorkOrder__c From ProductRequired Where Id =:prodReqId WITH SECURITY_ENFORCED];
            prodReq.BLN_Status__c = prodReqStatus;
            prodReq.BLN_FailureReason__c = prodReqFailReason;
            prodReq.BLN_Notes__c = prodReqNotes;
            if(Schema.sObjectType.ProductRequired.isUpdateable()){
                update prodReq;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error creating ProductTransfer record: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static void updateProdReq1(String prodReqId){
        try {
            ProductRequired prodReq = [Select Id,BLN_Status__c,BLN_FailureReason__c,BLN_Notes__c,BLN_WorkOrder__c From ProductRequired Where Id =:prodReqId WITH SECURITY_ENFORCED];
            List<WorkOrderLineItem> woliList = [Select Id,WorkOrderId, WorkType.Name From WorkOrderLineItem Where WorkOrderId !=null AND WorkOrderId =:prodReq.BLN_WorkOrder__c WITH SECURITY_ENFORCED];
            Set<Id> woliIdSet = new Set<Id>();
            for(WorkOrderLineItem eachWOLI : woliList){
                woliIdSet.add(eachWOLI.Id);
            }
            List<ServiceAppointment> saList = [Select Id,WorkType.Name,Status,ActualEndTime,BLN_FailureReason__c From ServiceAppointment Where ParentRecordId IN :woliIdSet AND WorkTypeId != null WITH SECURITY_ENFORCED];
            List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
            
            for(ServiceAppointment eachSA : saList){
                ServiceAppointment sa = new ServiceAppointment();
                if(eachSA.WorkType.Name == 'Stock Collect'){
                    sa.Status = 'Failed After Arrive';
                    sa.ActualEndTime = System.now();
                    sa.BLN_FailureReason__c = 'Stock/Supply Issue';
                    sa.Id = eachSA.Id;
                    saToUpdate.add(sa);
                }
                else{
                    sa.BLN_SkipJeopardyFlow__c = true;
                    sa.FSL__InJeopardy__c = true;
                    sa.Id = eachSA.Id;
                    saToUpdate.add(sa);
                }
            }
            if(saToUpdate != null && Schema.sObjectType.ServiceAppointment.isUpdateable()){
                update saToUpdate;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
    }
    
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            if(Schema.sObjectType.ContentVersion.isCreateable()){
                insert cv;
            }
            return cv;
        } catch(DMLException e) {
            return null;
        }
    }
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
            if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
                insert cdl;
            }
            return cdl;
        } catch(DMLException e) {
            return null;
        }
    }
}