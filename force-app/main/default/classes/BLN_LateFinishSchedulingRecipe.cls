/** @description : This apex class is used for rescheduling Service Appointments (SA) on gantt when an appointment is completed late and schedule overlapping records accordingly
*  @author: (akshay.chendake@pwc.com (IN))
* @Story: FOUK-142
*/

public without sharing class BLN_LateFinishSchedulingRecipe {
    @InvocableMethod(label='Appointment Late Finish Scheduling Recipe' description='this class called from Optimize Schedule Of Cancelled Appointment flow')
    public static void calculateSchedule(List<ServiceAppointment> currentSA){
        List<Exception> exceptionList = new List<Exception>();
        List<ServiceAppointment> filteredListOfSA = new List<ServiceAppointment>();
        DateTime previousEnd = currentSA[0].SchedEndTime;
        Set<Id> lstSA = new Set<Id>();
        ServiceAppointment passedSARecord = currentSA[0];
        Boolean firstIteration = true;
        Date currentSAStDate;
        DateTime currentSAEndDate;
        DateTime startDateOfCurrentSA;
        String scheduledStatus = system.Label.BLN_ScheduledStatus;
        String dispatchedStatus = system.Label.BLN_DispatchedStatus;
        if(currentSA[0].SchedStartTime != null && currentSA[0].SchedEndTime != null){
            currentSAStDate = currentSA[0].SchedStartTime.date();
            currentSAEndDate = currentSA[0].SchedEndTime;
            startDateOfCurrentSA = currentSA[0].SchedStartTime;
        }
        
        /*Get Assigned Resource*/
        try{
            AssignedResource assignedResourceRecord = [SELECT ServiceAppointmentId,ServiceResourceId FROM AssignedResource WHERE ServiceAppointmentId =: currentSA[0].Id AND ServiceResourceId != NULL WITH SECURITY_ENFORCED LIMIT 1 ];
            
            /*Get Service Resource assigned to current SA*/
            ServiceResource serviceResourceRecord = [SELECT Id,Name FROM ServiceResource WHERE Id =: assignedResourceRecord.ServiceResourceId AND IsActive = true WITH SECURITY_ENFORCED LIMIT 1];
            List<AssignedResource> assignedResourceList = [SELECT ServiceAppointmentId,ServiceResourceId FROM AssignedResource WHERE ServiceResourceId=:serviceResourceRecord.Id AND ServiceAppointmentId !=: currentSA[0].Id WITH SECURITY_ENFORCED];
            
            If(assignedResourceList.size() > 0){
                for(AssignedResource ar : assignedResourceList ){
                    lstSA.add(ar.ServiceAppointmentId);
                }
            }
            
            for(List<ServiceAppointment> lstOfSA : [SELECT Id, SchedStartTime, SchedEndTime,FSL__Duration_In_Minutes__c,Status,EarliestStartTime FROM ServiceAppointment WHERE Id IN : lstSA AND (Status=: ScheduledStatus OR Status=: DispatchedStatus) AND SchedStartTime >=: startDateOfCurrentSA WITH SECURITY_ENFORCED ORDER BY SchedStartTime ASC ]){
                for(ServiceAppointment sa :lstOfSA ){                  
                    Date saDate = sa.SchedStartTime.date();
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
                DateTime newStart = currentSA[0].SchedEndTime;
                fsa.SchedStartTime = currentSA[0].SchedEndTime;
                fsa.SchedEndTime = fsa.SchedStartTime + ((fsa.FSL__Duration_In_Minutes__c)/1440);
                currentSA[0] = fsa;
                firstIteration = false;
                
            }*/
            /*from 2nd iteration it will execute*/
            /*else{
                DateTime newStart =  currentSA[0].SchedEndTime;
                fsa.SchedStartTime = currentSA[0].SchedEndTime;
                fsa.SchedEndTime = fsa.SchedStartTime + ((fsa.FSL__Duration_In_Minutes__c)/1440);
                currentSA[0] = fsa;
            }
        }*/
        
        for(ServiceAppointment fsa : filteredListOfSA){
            // Calculate new start time
            DateTime newStart = previousEnd;
            // Calculate new end time
            DateTime newEnd = newStart.addMinutes((Integer)(fsa.FSL__Duration_In_Minutes__c));
            fsa.SchedStartTime = newStart;
            fsa.SchedEndTime = newEnd;
            previousEnd = newEnd;
        }
        
        try{
            if (Schema.sObjectType.ServiceAppointment.isUpdateable()) {
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