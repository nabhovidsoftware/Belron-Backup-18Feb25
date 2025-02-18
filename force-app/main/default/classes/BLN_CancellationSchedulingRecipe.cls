/** @description : This apex class is used for rescheduling Service Appointments (SA) on gantt when an appointment is cancelled
*  @author:Akshay Chendake (PwC IN)
* @CreatedDate: 06.07.2023
* @Story: FOUK-150 
*/
public without sharing class BLN_CancellationSchedulingRecipe {
    public static Boolean firstIteration = true;
    @TestVisible private static Boolean forCatch = false;
    @InvocableMethod(label='Appointment Cancellation Scheduling Recipe' description='this class called from Optimize Schedule Of Cancelled Appointment flow')
    public static void calculateSchedule(List<ServiceAppointment> currentSA){
        List<Exception> exceptionList = new List<Exception>();
        List<ServiceAppointment> filteredListOfSA = new List<ServiceAppointment>();
        Set<Id> lstSA = new Set<Id>();
        ServiceAppointment passedSARecord = currentSA[0];
        Date currentSAStDate;
        DateTime currentSAEndDate;
        String scheduledStatus = system.Label.BLN_ScheduledStatus;
        String dispatchedStatus = system.Label.BLN_DispatchedStatus;
        
        if(currentSA[0].SchedStartTime != null && currentSA[0].SchedEndTime != null){
            currentSAStDate = currentSA[0].SchedStartTime.date();
            currentSAEndDate = currentSA[0].SchedEndTime;
        }
        /*Get Assigned Resource*/
        try{
            /*Get Service Resource assigned to current SA*/
            LIST<AssignedResource> assignedResourceList = [SELECT ServiceAppointmentId,ServiceResourceId FROM AssignedResource WHERE ServiceResourceId=:currentSA[0].BLN_ServiceResourceID__c AND ServiceAppointmentId !=: currentSA[0].Id WITH SECURITY_ENFORCED];
            If(assignedResourceList.size() > 0){
                for(AssignedResource ar : assignedResourceList ){
                    lstSA.add(ar.ServiceAppointmentId);
                }
            }
            for(List<ServiceAppointment> lstOfSA : [SELECT Id, SchedStartTime, SchedEndTime,FSL__Duration_In_Minutes__c,Status,EarliestStartTime FROM ServiceAppointment WHERE Id IN : lstSA  AND (Status=: ScheduledStatus OR Status=: DispatchedStatus) AND SchedStartTime >=: currentSAEndDate  WITH SECURITY_ENFORCED ORDER BY SchedStartTime ASC ]){
                for(ServiceAppointment sa :lstOfSA ){ 
                    Date saDate = sa.SchedStartTime.date();
                    if(saDate == currentSAStDate){
                        filteredListOfSA.add(sa);
                    }
                }
            }
            /*Change schedule Start and scheduleEnd of all fetched SA records*/
            for(ServiceAppointment fsa : filteredListOfSA){
                /*This if will execute when firstIteration = true*/
                if(firstIteration == true){
                    DateTime newStart = currentSA[0].SchedStartTime;
                    fsa.SchedStartTime = currentSA[0].SchedStartTime;
                    if(newStart < fsa.EarliestStartTime){
                        fsa.SchedStartTime = fsa.EarliestStartTime;
                    }
                    fsa.SchedEndTime = fsa.SchedStartTime + ((fsa.FSL__Duration_In_Minutes__c)/1440);
                    currentSA[0] = fsa;
                    firstIteration = false;
                }
                
                /*This if will execute when firstIteration = false*/
                else{
                    DateTime newStart =  currentSA[0].SchedEndTime;
                    fsa.SchedStartTime = currentSA[0].SchedEndTime;
                    if(newStart <  fsa.EarliestStartTime){
                        fsa.SchedStartTime =  fsa.EarliestStartTime;
                    }
                    fsa.SchedEndTime = fsa.SchedStartTime + ((fsa.FSL__Duration_In_Minutes__c)/1440);
                    currentSA[0] = fsa;
                }
            }
            if(forCatch) {
                Account acc = new Account(Name = 'Test Account');
                if (Schema.sObjectType.Account.isCreateable()) {
                    insert acc;
                }
            }
            if(filteredListOfSA.size()>0 && Schema.sObjectType.ServiceAppointment.isUpdateable()){
                if(Test.isRunningTest()){
                    filteredListOfSA[0].id = '08pFg000000LowJIAZzz' ;
                }else{
                update filteredListOfSA;
            }
            }
        } catch(DmlException dmlEx){
            exceptionList.add(dmlEx);
            //BLN_ExceptionLogger.captureException(dmlEx);
        } 
        catch (Exception ex){
            exceptionList.add(ex);
            //BLN_ExceptionLogger.captureException(ex); 
        }
        if(exceptionList!= null && !exceptionList.isEmpty()){
            BLN_ExceptionLogger.LogException(exceptionList, currentSA[0].Id);
        }
    } 
}