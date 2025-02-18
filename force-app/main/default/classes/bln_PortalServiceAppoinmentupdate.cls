/**@description : This Apex class used to update ServiceAppointment after Portal Rebook Journey.
*  @author: Vedita Kashi
*  @Story: FOUK-4342
*  @CreatedDate: 03/062024
*/
public without sharing class bln_PortalServiceAppoinmentupdate {
    public Static String updateSrId;
    // Method to update the service request with a new appointment
    @AuraEnabled
    public static String  updateServiceRequest(Id recordId, Id newAppointmentId, Date selectslotdate, String starttime,String endtime,String oldAppId) {

        // Retrieve the service request record to update
        try {
        String[] startimearray = starttime.split(':');
        String[] endtimearray = endtime.split(':');

        DateTime arrivalwindowstart = DateTime.newInstance(selectslotdate.year(), selectslotdate.month(), selectslotdate.day(), Integer.valueOf(startimearray[0]), Integer.valueOf(startimearray[1]), 0);
        DateTime arrivalwindowend = DateTime.newInstance(selectslotdate.year(), selectslotdate.month(), selectslotdate.day(), Integer.valueOf(endtimearray[0]), Integer.valueOf(endtimearray[1]), 0);
        // Query the Case and related Service_Appointment records
        Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        //List<Case> lstCase = [SELECT Id, (SELECT Id, ArrivalWindowStartTime, BLN_Case__c, Status, DueDate, ArrivalWindowEndTime, EarliestStartTime, BLN_StartTimeSlots__c, BLN_EndTimeSlots__c , BLN_RebookSource__c FROM Service_Appointments__r WHERE Id = :newAppointmentId) FROM Case WHERE Id = :recordId];
        ServiceAppointment sa=[SELECT ID,AccountId,ArrivalWindowStartTime,ArrivalWindowEndTime,
        BLN_Case__c,Status,DueDate,
        BLN_RebookSource__c FROM ServiceAppointment
        WHERE ID =: newAppointmentId AND BLN_Case__c =:recordId
      LIMIT 1 ];

        if(sa.Id != null){
            sa.Status = System.label.BLN_ScheduledStatus;
            sa.BLN_Case__c = recordId;
            
            sa.ArrivalWindowStartTime = arrivalwindowstart;
            sa.DueDate = arrivalwindowend;
            sa.BLN_RebookSource__c = System.label.BLN_PortalValue;
        }

        ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable();
        Database.SaveResult saveResult = Database.update(sa, false);
        // Check if the insert was successful
        if (saveResult.isSuccess()) {
            // Retrieve the newly created record's ID
            updateSrId= saveResult.getId();
            if(!String.isBlank(updateSrId)){
                bln_PortalServiceAppoinmentupdate.updateOldServiceRequest(oldAppId);
            }
        }
        return updateSrId;
        } catch (Exception e) {
       // System.debug('ERR---'+e.getMessage()+'--'+e.getLineNumber()+'=='+e.getCause()+'...'+e.getStackTraceString());
        throw new AuraHandledException(e.getMessage()+'--'+e.getLineNumber()+'=='+e.getCause()+'...'+e.getStackTraceString());
        }
    }

    // Method to update an old service request and its appointments
    @AuraEnabled
    public static void updateOldServiceRequest(String oldAppointmentId) {
        // Retrieve the old service request record
    ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable();
    ServiceAppointment sa=[SELECT ID,Status FROM ServiceAppointment WHERE ID =: oldAppointmentId  LIMIT 1];
    if(sa!=null){
    sa.Status=System.label.BLN_Canceled;
    }
    Database.update(sa, false);
    }
}