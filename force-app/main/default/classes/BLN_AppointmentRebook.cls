/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-06-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class BLN_AppointmentRebook {
    @AuraEnabled
    public static void appointmentRebook(List<Object> paramsForRebook) {
        List<RebookParams> rebookWrapper = new List<RebookParams>();
        List<RebookDetail> detailWrapper = new List<RebookDetail>();
        String caseId = '';
        
        if (paramsForRebook != null && !paramsForRebook.isEmpty()) {
            for (Object obj : paramsForRebook) {
                String jsonString = JSON.serialize(obj);
                RebookParams param = (RebookParams) JSON.deserialize(jsonString, RebookParams.class);
                if (param != null) {
                    rebookWrapper.add(param);
                }
            }
        }
        for(RebookParams param : rebookWrapper) {
            caseId = param.caseId;
            detailWrapper = param.rebookDetails;
        }
        BLN_AppointmentRebook.rebookAccordingToAction(detailWrapper);
    }

    public static void rebookAccordingToAction(List<RebookDetail> detailWrapper){
        Set<Id> saIdSetForUpdate = new Set<Id>();
        Map<String, String> oldAndNewSa = new Map<String, String>();
        for(RebookDetail rebook : detailWrapper) {
            if (rebook.action == 'New') {
                saIdSetForUpdate.add(rebook.saId);
                if(String.isNotBlank(rebook.oldSAId)){
                    oldAndNewSa.put(rebook.saId, rebook.oldSAId);
                }
                // String rebookResult = BLN_AppointmentBooking.scheduleAppointment(rebook.saId);
            } else if (rebook.action == 'Existing') {
                saIdSetForUpdate.add(rebook.saId);
                List<BLN_AppointmentDataCreationService.ProductData> wrapperList = new List<BLN_AppointmentDataCreationService.ProductData>();
                for(Object obj : rebook.productList){
                    BLN_AppointmentDataCreationService.ProductData prodWrapper = (BLN_AppointmentDataCreationService.ProductData) System.JSON.deserialize(JSON.serialize(obj),BLN_AppointmentDataCreationService.ProductData.class);
                    wrapperList.add(prodWrapper);
                }
                BLN_AppointmentRebook.updateProduct(rebook.saId, wrapperList);
            } else if (rebook.action == 'Cancel') {
                BLN_AppointmentRebook.cancelAppointment(rebook.oldSAId, rebook.cancellationReason, rebook.subReason);
            } else if (rebook.action == 'Delete') {
                BLN_AppointmentDataCreationService.deleteAppointment(rebook.saId);
            }
        }
        
        if(saIdSetForUpdate.size() > 0){
            List<ServiceAppointment> saList = new List<ServiceAppointment>();

            List<FSL__Time_Dependency__c> dependencyList = BLN_QueryHandlerWebservice.getTimeDependencyByAppointmentIdSet(saIdSetForUpdate);
            if(dependencyList != null) {
                for(FSL__Time_Dependency__c dependencyRec : dependencyList){
                    saIdSetForUpdate.add(dependencyRec.FSL__Service_Appointment_1__c);
                    saIdSetForUpdate.add(dependencyRec.FSL__Service_Appointment_2__c);
                }
            } 

            saList = BLN_QueryHandlerWebservice.getServiceAppointmentByIds(saIdSetForUpdate);
            if(saList != null && !saList.isEmpty()){
                BLN_AppointmentRebook.updateSAForRebook(saList, oldAndNewSa);
            }
        }
    }

    public static void updateSAForRebook(List<ServiceAppointment> saList, Map<String, String> oldAndNewSa){
        List<ServiceAppointment> rebookAppointments = new List<ServiceAppointment>();
        
        if(saList.size() > 0){
            for(ServiceAppointment saObj : saList){
                saObj.BLN_AppointmentRebook__c = true;
                if(oldAndNewSa.containsKey(saObj.Id)){
                    saObj.BLN_RebookedServiceAppointment__c = oldAndNewSa.get(saObj.Id);
                }
                rebookAppointments.add(saObj);
            }
        }

        if(rebookAppointments.size() > 0 && Schema.sObjectType.ServiceAppointment.isUpdateable()){
            UPDATE rebookAppointments;
        }
    }

    public static void updateProduct(String appointmentId, List<BLN_AppointmentDataCreationService.ProductData> productList){
        Set<String> productCodeSet = new Set<String>();
        Map<String, Decimal> productQuantityMap = new Map<String, Decimal>();
        Map<String, String> productOLIKeyMap = new Map<String, String>();
        
        if(String.isNotBlank(appointmentId)){            
            for (Integer i = 0; i < productList.size(); i++) {
                if(String.isNotBlank(productList[i].productCode)){
                    productQuantityMap.put(productList[i].productCode + '-' + i, productList[i].quantity);
                    productOLIKeyMap.put(productList[i].productCode + '-' + i, productList[i].productOLIKey);
                    productCodeSet.add(productList[i].productCode);
                }
            }
        }

        if(productCodeSet.size() > 0){
            List<Product2> productsList = BLN_HandlerWebservice.getProductByProductCode(productCodeSet);
            deleteAndReCreatePR(appointmentId, productsList, productQuantityMap, productOLIKeyMap);
        }
    }

    public static void deleteAndReCreatePR(String appointmentId, List<Product2> productsList, Map<String, Decimal> productQuantityMap, Map<String, String> productOLIKeyMap){
        ServiceAppointment serviceApp = BLN_QueryHandlerWebservice.getServiceAppointment(appointmentId);
        List<WorkOrderLineItem> woliList = BLN_QueryHandlerWebservice.getWoliFromWorkOrderId(serviceApp.BLN_WorkOrderNumber__c);
        WorkType workTypeObj = BLN_QueryHandlerWebservice.getWorkTypeFromWorkOrderId(serviceApp.BLN_WorkOrderNumber__c);
        ServiceTerritory serviceTerritory = BLN_QueryHandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);

        Set<String> woliIdSet = new Set<String>();
        for(WorkOrderLineItem woli : woliList){
            woliIdSet.add(woli.Id);
        }

        List<ProductRequired> productReqListToDelete = new List<ProductRequired>();
        productReqListToDelete = BLN_QueryHandlerWebservice.getPRListUsingWoliIdSet(woliIdSet);
        
        if(productReqListToDelete != null && productReqListToDelete.size() > 0 && Schema.sObjectType.ProductRequired.isDeletable()){
            DELETE productReqListToDelete;
        }

        List<ProductRequired> productReqList = new List<ProductRequired>();
        for(WorkOrderLineItem eachWoli : woliList){
            for (Integer i = 0; i < productsList.size(); i++) {
                productReqList.add(BLN_AppointmentDataCreationService.generateProductRequired(eachWoli, workTypeObj, productsList[i], workTypeObj, serviceTerritory, productQuantityMap, productOLIKeyMap, i));
            }
        }
        if(productReqList.size() > 0 && Schema.sObjectType.ProductRequired.isCreateable()){
            INSERT productReqList;
        }
    }

    public static void cancelAppointment(String appointmentId, String cancellationReason, String subReason) {
        Set<Id> appointmentIds = new Set<Id>();
        if(String.isNotBlank(appointmentId) && appointmentId != null){
            List<FSL__Time_Dependency__c> dependencyList = BLN_QueryHandlerWebservice.getTimeDependencyByAppointmentId(appointmentId);
            if(dependencyList != null) {
                for(FSL__Time_Dependency__c dependencyRec : dependencyList){
                    appointmentIds.add(dependencyRec.FSL__Service_Appointment_1__c);
                    appointmentIds.add(dependencyRec.FSL__Service_Appointment_2__c);
                }
            } else {
                appointmentIds.add(appointmentId);
            }
        }

        List<ServiceAppointment> appointmentToBeCancelled = new List<ServiceAppointment>();
        if(!appointmentIds.isEmpty() && appointmentIds.size() > 0){
            List<ServiceAppointment> appointmentList = BLN_QueryHandlerWebservice.getServiceAppointmentByIds(appointmentIds);
            for(ServiceAppointment serviceApp : appointmentList){
        serviceApp.BLN_FailureReason__c = cancellationReason;
        serviceApp.BLN_SubFailureReason__c = subReason;
        if(serviceApp.Status == 'Scheduled' || serviceApp.Status == 'None'){
            serviceApp.Status = 'Canceled';
        }

        if(serviceApp.Status == 'Dispatched'){
            serviceApp.Status = 'Failed Before Arrive';
        }
        
                appointmentToBeCancelled.add(serviceApp);
            }
        }

        if(!appointmentToBeCancelled.isEmpty() && appointmentToBeCancelled.size() > 0 && Schema.sObjectType.ServiceAppointment.isUpdateable()){
            UPDATE appointmentToBeCancelled;
        }
    }
    
    public class RebookParams {
        @AuraEnabled public String caseId;
        @AuraEnabled public List<RebookDetail> rebookDetails;
    }

    public class RebookDetail {
        @AuraEnabled public String saId;
        @AuraEnabled public String oldSAId;
        @AuraEnabled public DateTime slotStart;
        @AuraEnabled public DateTime slotFinish;
        // @AuraEnabled public Boolean isDropOff;
        @AuraEnabled public String cancellationReason;
        @AuraEnabled public String subReason;
        @AuraEnabled public String action;
        @AuraEnabled public List<BLN_AppointmentDataCreationService.ProductData> productList;
    }
}