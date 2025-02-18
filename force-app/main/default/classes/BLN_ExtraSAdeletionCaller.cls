public class BLN_ExtraSAdeletionCaller implements Database.batchable<sObject>, Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        string query = 'SELECT Id, Status, ParentRecordId FROM ServiceAppointment WHERE Status = \'None\' AND BLN_IsForcedAppointment__c = False AND BLN_IsBookingFailed__c = False AND BLN_IsPrepDataCall__c = True AND BLN_RemedyJobId__c = NULL WITH SECURITY_ENFORCED';
        return Database.getQueryLocator(query);
    }    
    public void execute(Database.BatchableContext info, List<ServiceAppointment> scope){
        Set<Id> appointmentsToDelete = new Set<Id>();
        Set<Id> parentRecordId = new Set<Id>(); 
        Set<WorkOrderLineItem> woliIds = new Set<WorkOrderLineItem>(); 
        for(ServiceAppointment serviceApp : scope){
            appointmentsToDelete.add(serviceApp.Id);
            parentRecordId.add(serviceApp.ParentRecordId);
        }
        List<FSL__Time_Dependency__c> appointmentDependency = [Select Id from FSL__Time_Dependency__c where FSL__Service_Appointment_1__c =:appointmentsToDelete OR FSL__Service_Appointment_2__c =:appointmentsToDelete WITH SECURITY_ENFORCED];
        
        List<WorkOrderLineItem> workOrderLineItemList = [Select Id from WorkOrderLineItem where Id =:parentRecordId WITH SECURITY_ENFORCED];
        for(WorkOrderLineItem woli : workOrderLineItemList){
            woliIds.add(woli);
            
        }       
        // List<ProductRequired> productRequired = [Select Id from ProductRequired where ParentRecordId =: woliIds WITH SECURITY_ENFORCED];
        delete appointmentDependency;
        delete workOrderLineItemList;
        
    }     
    public void finish(Database.BatchableContext info){  
    } 
    public void execute(SchedulableContext ctx) {
        integer batchSize = 200;
        BLN_ExtraSAdeletionCaller p = new BLN_ExtraSAdeletionCaller();
        database.executeBatch(p,batchSize);
    }
}