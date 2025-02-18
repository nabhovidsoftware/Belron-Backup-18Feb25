/** @description : This apex class is used for rescheduling Service Appointments (SA) on gantt when an appointment is either completed early/ not completed
*  @author:Akshay Chendake (PwC IN)
*  @createdDate: 06.07.2023
* @Story: FOUK-151
*/

public without sharing class BLN_EarlyFinishSchedulingRecipe {
    @InvocableMethod(label='Appointment Early Finish Scheduling Recipe' description='this class called from Optimize Schedule Of Cancelled Appointment flow')
    public static void calculateSchedule(List<ServiceAppointment> currentSA){
        List<Exception> exceptionList = new List<Exception>();
        DateTime previousEnd = currentSA[0].SchedEndTime; 
        List<ServiceAppointment> filteredListOfSA = new List<ServiceAppointment>();
        Set<Id> lstSA = new Set<Id>();
        ServiceAppointment passedSARecord = currentSA[0];
        Boolean firstIteration = true;
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
            AssignedResource assignedResourceRecord = [SELECT ServiceAppointmentId,ServiceResourceId FROM AssignedResource WHERE ServiceAppointmentId =: currentSA[0].Id AND ServiceResourceId != NULL WITH SECURITY_ENFORCED LIMIT 1 ];
            
            /*Get Service Resource assigned to current SA*/
            ServiceResource serviceResourceRecord = [SELECT Id,Name FROM ServiceResource WHERE Id =: assignedResourceRecord.ServiceResourceId AND IsActive = true WITH SECURITY_ENFORCED LIMIT 1];
            LIST<AssignedResource> assignedResourceList = [SELECT ServiceAppointmentId,ServiceResourceId FROM AssignedResource WHERE ServiceResourceId=:serviceResourceRecord.Id AND ServiceAppointmentId !=: currentSA[0].Id WITH SECURITY_ENFORCED];
            
            If(assignedResourceList.size() > 0){
                for(AssignedResource ar : assignedResourceList ){
                    lstSA.add(ar.ServiceAppointmentId);
                }
            }
            for(List<ServiceAppointment> lstOfSA : [SELECT Id, SchedStartTime, SchedEndTime,FSL__Duration_In_Minutes__c,Duration,Status,EarliestStartTime FROM ServiceAppointment WHERE Id IN : lstSA AND (Status=: ScheduledStatus OR Status=: DispatchedStatus) AND SchedStartTime >=: currentSAEndDate WITH SECURITY_ENFORCED ORDER BY SchedStartTime ASC ]){
                for(ServiceAppointment sa :lstOfSA ){                  
                    Date saDate = sa.SchedStartTime.Date();
                    if(saDate == currentSAStDate){
                        filteredListOfSA.add(sa);
                    }
                }
            }
        }
        catch(Exception qe){
            BLN_ExceptionLogger.captureException(qe); 
            //system.debug('Error occured while fetching service resource-->'+qe.getMessage());
        }
        
        /*Change schedule Start and scheduleEnd of all fetched SA records*/
        //for(ServiceAppointment fsa : filteredListOfSA){
            
            /* 1st Iteration */
            /*if(firstIteration == true){
                system.debug('currentSA[0] :'+currentSA[0]);
                DateTime newStart = currentSA[0].SchedEndTime;
                fsa.SchedStartTime = currentSA[0].SchedEndTime;
                if(newStart < fsa.EarliestStartTime){
                    fsa.SchedStartTime = fsa.EarliestStartTime;
                }
                fsa.SchedEndTime = fsa.SchedStartTime + ((fsa.FSL__Duration_In_Minutes__c)/1440);
                currentSA[0] = fsa;
                firstIteration = false;
            }*/
            /*from 2nd iteration it will execute*/
            /*if(firstIteration == false){
                DateTime newStart =  currentSA[0].SchedEndTime;
                fsa.SchedStartTime = currentSA[0].SchedEndTime;
                if(newStart <  fsa.EarliestStartTime){
                    fsa.SchedStartTime =  fsa.EarliestStartTime;
                }
                fsa.SchedEndTime = fsa.SchedStartTime + ((fsa.FSL__Duration_In_Minutes__c)/1440);
                currentSA[0] = fsa;
            }
        }*/
        for(ServiceAppointment fsa : filteredListOfSA){
            // Calculate new start time
            DateTime newStart = previousEnd;
            if(newStart < fsa.EarliestStartTime){
                newStart = fsa.EarliestStartTime;
            }
            // Calculate new end time
            DateTime newEnd = newStart.addMinutes((Integer)(fsa.FSL__Duration_In_Minutes__c));
            fsa.SchedStartTime = newStart;
            fsa.SchedEndTime = newEnd;
            previousEnd = newEnd;
        }
        try{
            if(filteredListOfSA.size()>0 && Schema.sObjectType.ServiceAppointment.isUpdateable()){
                update filteredListOfSA;
            }
        } catch (DmlException dmlx) {
            // Store Exception Logger Record
            //BLN_ExceptionLogger.captureException(dmlx); 
            exceptionList.add(dmlx);
        } catch (Exception ex) {
            // Store Exception Logger Record
            exceptionList.add(ex);
            //BLN_ExceptionLogger.captureException(ex);  
        }
        if(exceptionList!= null && !exceptionList.isEmpty()){
            BLN_ExceptionLogger.LogException(exceptionList, currentSA[0].Id);
        }
    }       
    
}