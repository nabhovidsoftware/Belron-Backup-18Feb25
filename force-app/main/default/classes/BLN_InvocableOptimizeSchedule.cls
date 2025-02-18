/** @description : This apex class is used for rescheduling Service Appointments (SA) on gantt when an appointment is failed before arrival
*  @author:Akshay Chendake (PwC IN)
* @CreatedDate: 06.07.2023
* @Story: FOUK-150 (Only for FBA)
*/

public without sharing class BLN_InvocableOptimizeSchedule{
    @InvocableMethod(label='Appointment FBA Scheduling Recipe' description='this class called from Optimize Schedule Of Cancelled Appointment flow')
    public static void calculateSchedule(List<ServiceAppointment> currentSA){
        List<Exception> exceptionList = new List<Exception>();
        List<ServiceAppointment> filteredListOfSA = new List<ServiceAppointment>();
        Set<Id> lstSA = new Set<Id>();
        ServiceAppointment passedSARecord = currentSA[0];
        Date currentSAStDate;
        DateTime currentSAEndDate;
        Boolean firstIteration = true;
        String scheduledStatus = System.Label.BLN_ScheduledStatus;
        String dispatchedStatus = System.Label.BLN_DispatchedStatus;
        
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
            for(List<ServiceAppointment> lstOfSA : [SELECT Id, SchedStartTime, SchedEndTime,FSL__Duration_In_Minutes__c,Status,EarliestStartTime FROM ServiceAppointment WHERE Id IN : lstSA  AND (Status=: scheduledStatus OR Status=: dispatchedStatus) AND SchedStartTime >=: currentSAEndDate  WITH SECURITY_ENFORCED ORDER BY SchedStartTime ASC ]){
                for(ServiceAppointment sa :lstOfSA ){ 
                    Date saDate = sa.SchedStartTime.date();
                    if(saDate == currentSAStDate){
                        filteredListOfSA.add(sa);
                    }
                }
            }
        }
           catch(DmlException dmlEx){
            exceptionList.add(dmlEx);
            //system.debug('Error-->'+e.getMessage()+' '+e.getLineNumber());            
        } 
         catch (Exception e){
            exceptionList.add(e);
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
            if(firstIteration == false){
                DateTime newStart =  currentSA[0].SchedEndTime;
                fsa.SchedStartTime = currentSA[0].SchedEndTime;
                if(newStart <  fsa.EarliestStartTime){
                    fsa.SchedStartTime =  fsa.EarliestStartTime;
                }
                fsa.SchedEndTime = fsa.SchedStartTime + ((fsa.FSL__Duration_In_Minutes__c)/1440);
                currentSA[0] = fsa;
            }
        }
        try{
            if(!filteredListOfSA.isEmpty() && Schema.sObjectType.ServiceAppointment.isUpdateable()){
                update filteredListOfSA;
            }
        } catch(DmlException dmlEx){
            exceptionList.add(dmlEx); 
        } catch (Exception e){
            exceptionList.add(e);
        }
        if(exceptionList!= null && !exceptionList.isEmpty()){
            BLN_ExceptionLogger.LogException(exceptionList, currentSA[0].Id);
        }  
    }     
}