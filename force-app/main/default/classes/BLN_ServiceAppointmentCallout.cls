/** @description : This Apex is called from flow 'Service Appointment Status Update' when Status or Assigned Resource of the SA is changed and calls OKTA to get Access Token of MuleSoft
*   @Story : FOUK-198, 679, 680, 681
*   @author: Kanchan Mishra (PwC)
*   @CreatedDate: 20/06/2023
*/
public without sharing class BLN_ServiceAppointmentCallout {
    @TestVisible private static String mockoktaToken;
    @TestVisible private static Boolean forTest = false;
    @TestVisible private static Boolean forCatch = false;
    @InvocableMethod(Label='ServiceAppointmentHTTPCalloutTest')
    public static void serviceAppointmentHTTPCallout(List<InputVariables> inputVariablelist) {
        List<Exception> exceptionList = new List<Exception>();
        List<List<ServiceAppointment>> serviceAppointmentsToProcess = new List<List<ServiceAppointment>>();
        List<String> singleRecord;
        List<List<String>> calloutBodyList = new List<List<String>>();
        AsyncOptions options = new AsyncOptions();
        BLN_CalloutSettings__c delayTime = BLN_CalloutSettings__c.getInstance();
        options.MinimumQueueableDelayInMinutes = Integer.valueOf(delayTime.BLN_MinutesOfDelay__c);

        try {
            List<ServiceAppointment> serviceApp;
            for (InputVariables inputVariables : inputVariablelist) {
                serviceApp = inputVariables.serviceAppointmentlist;
                serviceAppointmentsToProcess.add(serviceApp);
            }
            List<BLN_HTTPCallOutToMuleSoftHelper.ServiceAppointmentHelper> appBulkData = BLN_HTTPCallOutToMuleSoftHelper.prepareBulkData(serviceAppointmentsToProcess);
            for (BLN_HTTPCallOutToMuleSoftHelper.ServiceAppointmentHelper currentData : appBulkData) {
                singleRecord = new List<String>();
                singleRecord.add(JSON.serialize(BLN_HTTPCallOutToMuleSoft.createJsonBody(currentData)));
                singleRecord.add(currentData.Id);
                singleRecord.add(currentData.countryCode);
                singleRecord.add(currentData.newServiceAppointment.Status);
                calloutBodyList.add(singleRecord);
            }
            List<AggregateResult> queueableApexJobs = [
                    SELECT
                            Count(Id)
                    FROM
                            AsyncApexJob
                    WHERE
                            JobType = 'Queueable'
                            AND Status IN ('Queued', 'Preparing', 'Processing')];
            if(Integer.valueOf(queueableApexJobs.get(0).get('expr0')) < Integer.valueOf(delayTime.BLN_LimitOfQueueableJobs__c)) {
                System.enqueueJob(new BLN_HTTPCallOutToMuleSoft(calloutBodyList, false));
            } else {
                System.enqueueJob(new BLN_HTTPCallOutToMuleSoft(calloutBodyList, false), options);
            }
        } catch (DmlException dmlx) {
            // Store Exception Logger Record
            exceptionList.add(dmlx);
        } catch (Exception ex) {
            // Store Exception Logger Record
            exceptionList.add(ex);
        }
        if(serviceAppointmentsToProcess.size() > 0 && exceptionList != null && !exceptionList.isEmpty()){
            BLN_ExceptionLogger.LogException(exceptionList,serviceAppointmentsToProcess[0][0].Id);
        }
    }

    //Class is holding a list of ServiceAppointment
    public class InputVariables {
        @InvocableVariable
        public List<ServiceAppointment> serviceAppointmentlist;
    }
}