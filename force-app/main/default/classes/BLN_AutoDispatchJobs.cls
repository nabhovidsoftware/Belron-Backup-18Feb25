/**@description : This batch class handle the service appointments to be dispatched to their assigned technician.
*  @author: Sapna Teltumade
*  @Story: FOUK-258
*  @CreatedDate: 19/02/2024
*/
global class BLN_AutoDispatchJobs implements Database.Batchable<sObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string status = System.label.BLN_ScheduledStatus;
        string srType = System.label.BLN_VirtualTech;
        datetime scheduledStartTime = system.now();
        datetime scheduledTimeNextTwoHours = system.now().addHours(2);
        String query = 'Select Id,Status,BLN_AssignedServiceResource__c, BLN_AssignedServiceResource__r.BLN_Type__c,  SchedStartTime from ServiceAppointment where Status = :status and SchedStartTime >= :scheduledStartTime and SchedStartTime <= :scheduledTimeNextTwoHours and BLN_AssignedServiceResource__r.BLN_Type__c != :srType ';
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext BC, List<ServiceAppointment> scope){
        System.debug('Scope data is '+scope);
        for(ServiceAppointment serviceApp : scope){
            serviceApp.status = System.label.BLN_DispatchedStatus;
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    global void execute(SchedulableContext ctx) {
        integer batchSize = 200;
        BLN_AutoDispatchJobs p = new BLN_AutoDispatchJobs();
        database.executeBatch(p,batchSize);
    }
}