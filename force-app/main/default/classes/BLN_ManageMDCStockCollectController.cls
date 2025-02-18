/**
 * @description       : This class is use to create MDC Stock collect record
 * @author            : Wasim
 * @group             : 
 * @Created on        : 09-07-2024
**/
public with sharing class BLN_ManageMDCStockCollectController {
    
    public static String generateMDCStock(Id appointmentId, String locationId){

        ServiceAppointment mainAppointment = BLN_QueryHandlerWebservice.getServiceAppointment(appointmentId);
        List<FSL__Time_Dependency__c> dependencies = BLN_QueryHandlerWebservice.getTimeDependencyByAppointmentId(mainAppointment.Id);
        WorkOrder workOrderObj = BLN_QueryHandlerWebservice.getWorkOrderById(mainAppointment.BLN_WorkOrderNumber__c);
        Set<String> workTypeName = new Set<String>();
        workTypeName.add(System.label.BLN_StockCollect);
        List<WorkType> workTypeList = BLN_QueryHandlerWebservice.getWorkType(workTypeName);
        // ServiceTerritory serviceTerritory = BLN_HandlerWebservice.getServiceTerritoryFromGUID(locationId);
        ServiceTerritory serviceTerritory = BLN_QueryHandlerWebservice.getServiceTerritoryFromOrgID(locationId);
        List<Case> caseList = BLN_QueryHandlerWebservice.getCaseRecordById(mainAppointment.BLN_Case__c);
        ServiceTerritory territory = BLN_QueryHandlerWebservice.getServiceTerritoryByAppointmentId(mainAppointment.Id);
        
        List<ServiceAppointment> appointmentList = new List<ServiceAppointment>();
        Set<Id> appointmentIds = new Set<Id>();
        Boolean isStockAlreadyAvailable = false;
        ServiceAppointment existingStockAppointment = new ServiceAppointment();

        Schema.Location locationObj = new Schema.Location();
        if(String.isNotBlank(locationId)){
            // locationObj = BLN_QueryHandlerWebservice.getLocationByGuid(locationId);
            locationObj = BLN_QueryHandlerWebservice.getLocationByOrgid(locationId);
        }

        if(dependencies != null && dependencies.size() > 0) {
            for(FSL__Time_Dependency__c dependencyRec : dependencies){
                appointmentIds.add(dependencyRec.FSL__Service_Appointment_2__c);
            }
            appointmentList = BLN_QueryHandlerWebservice.getServiceAppointmentByIds(appointmentIds);
            
            for(ServiceAppointment dependentSa : appointmentList){
                if(dependentSa.WorkType.Name == System.label.BLN_StockCollect){
                    isStockAlreadyAvailable = true;
                    existingStockAppointment = dependentSa;
                }
            }
        }

        if(isStockAlreadyAvailable && String.isNotBlank(locationObj.VisitorAddressId)) {
            existingStockAppointment.BLN_IsForcedAppointment__c = true;
            existingStockAppointment.Street = locationObj.VisitorAddress.Street;
            existingStockAppointment.City = locationObj.VisitorAddress.City;
            existingStockAppointment.State = locationObj.VisitorAddress.State;
            existingStockAppointment.PostalCode = locationObj.VisitorAddress.PostalCode;
            existingStockAppointment.Country = locationObj.VisitorAddress.Country;

            if(Schema.sObjectType.ServiceAppointment.isUpdateable()){
                UPDATE existingStockAppointment;
            }
            return existingStockAppointment.id;
        } else if(locationObj != null && String.isNotBlank(locationObj.VisitorAddressId)) {
            WorkOrderLineItem woLi = new WorkOrderLineItem();
            woLi.Street = locationObj.VisitorAddress.Street;
            woLi.City = locationObj.VisitorAddress.City;
            woLi.State = locationObj.VisitorAddress.State;
            woLi.PostalCode = locationObj.VisitorAddress.PostalCode;
            woLi.Country = locationObj.VisitorAddress.Country;
            woLi.WorkTypeId = String.isNotBlank(workTypeList[0].Id) ? workTypeList[0].Id : Null;
            woLi.ServiceTerritoryId = String.isNotBlank(serviceTerritory.Id) ? serviceTerritory.Id : Null;
            woLi.WorkOrderId = workOrderObj.Id;
            woLi.Status = System.label.BLN_New;
            woLi.Subject = System.label.BLN_WorkOrderLineItemForText + ' ' + System.label.BLN_StockCollect;
            woLi.Description = System.label.BLN_WorkOrderLineItemForText + ' ' + System.label.BLN_StockCollect;
            woLi.Priority = System.label.BLN_Critical;
            ServiceReportLayout sRLayout = new ServiceReportLayout();
            sRLayout = BLN_HandlerWebservice.getServiceReportLayoutByName(System.Label.BLN_PreInspectionSRLName);
            woli.ServiceReportTemplateId = sRLayout.Id;

            if(Schema.sObjectType.WorkOrderLineItem.isCreateable()){
                INSERT woLi;
            }

            BLN_AppointmentDataCreationService.caseObj = caseList != null ? caseList[0] : null;
            BLN_AppointmentDataCreationService.serviceTerritory = territory;
            BLN_AppointmentDataCreationService.earliestStartTime = System.now();
            BLN_AppointmentDataCreationService.workTypeMap.put(workTypeList[0].Id, workTypeList[0]);
            BLN_AppointmentDataCreationService.bumetadata = BLN_HandlerWebservice.getBUMetadata(System.label.BLN_UnitedKingdom);

            ServiceAppointment newStockAppointment = BLN_AppointmentDataCreationService.generateSA(woLi, 0, workOrderObj.WorkType.Name, false);
            newStockAppointment.BLN_IsForcedAppointment__c = true;

            if(Schema.sObjectType.ServiceAppointment.isCreateable()){
                newStockAppointment.BLN_IsPrepDataCall__c = False;
                INSERT newStockAppointment;
                BLN_AppointmentDataCreationService.mainAndStockOrAssistSADependency(mainAppointment.Id, newStockAppointment.Id, True, System.label.BLN_StartAfterFinishAndSameDay);
            }
            if(String.isNotBlank(newStockAppointment.id))
            {
                BLN_AppointmentBooking.scheduleAppointment(newStockAppointment.id);
            }
            return String.isNotBlank(newStockAppointment.id) ? newStockAppointment.id : 'Unable to create Stock Appointment.';
        } else {
            return 'No Address Available on the given location.';
        }
    }
}