/** @description : The Web Services Class used for booking and confirming Appointments
*  @author: Ayush Singh(PwC IN)
* @Story: FOUK-110
*@Created Date: 13/06/2023
*/
@RestResource(urlMapping='/confirmAppointment/*')
global without sharing class BLN_BookTaskWebservice {
    public static String returnCode = '';
    public static FSL.ScheduleResult scheduledResults;
    @HttpPost
    global static void bookAppointment(){
        List<Exception> exceptionList = new List<Exception>();
        BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
        List<String> serializedIntLogList = new List<String>();

        RestRequest req = RestContext.request;
        RestResponse res= RestContext.response;
        BLN_BookTaskWebserviceWrapper.RequestWrapper parserReq = BLN_BookTaskWebserviceWrapper.parse(req.requestBody.toString());

        try{
            ServiceAppointment serviceApp;
            Id schedulingPolicyId = BLN_QueryHandlerWebservice.getSchedulingPolicyId(System.Label.BLN_BUKSchedulingPolicy);
            List<ServiceAppointment> serviceAppList = new List<ServiceAppointment>();
            ServiceAppointment servApp = new ServiceAppointment();
            //String returnCode = '';
            String servResourceId = '';
            String servResourceOracleId ='';
            Datetime assignedScheduledStartTime;
            Datetime assignedScheduledEndTime;
            string assignedServiceResourceName = '';
            Boolean isGeolocationPopulated = true;
            if (String.isNotBlank(parserReq.jobAppointmentId)) {
                serviceApp = BLN_QueryHandlerWebservice.getServiceAppointment(parserReq.jobAppointmentId);
            }

            //Skip scheduling if the job is forced
            if (!serviceApp.BLN_IsForcedAppointment__c) {
                if (serviceApp.BLN_IsBranchAppointment__c || (serviceApp.Latitude != null && serviceApp.Longitude != null) && !test.isRunningTest()) {
                    scheduledResults = FSL.ScheduleService.schedule(SchedulingPolicyId, parserReq.jobAppointmentId);
                    isGeolocationPopulated = true;
                } else {
                    isGeolocationPopulated = false;
                }
                if (scheduledResults != null) {
                    servResourceId = (ScheduledResults.Resource != null) ? ScheduledResults.Resource.Id : '';
                    servResourceOracleId = servResourceId != null ? [SELECT Id, BLN_OracleEmployeeId__c FROM ServiceResource WHERE Id = :servResourceId].BLN_OracleEmployeeId__c : '';
                    assignedServiceResourceName = (ScheduledResults.Resource.Name != null) ? ScheduledResults.Resource.Name : '';
                    assignedScheduledStartTime = scheduledResults.Service.SchedStartTime;
                    assignedScheduledEndTime = scheduledResults.Service.SchedEndTime;
                    returnCode = 'Success';
                    servApp = BLN_QueryHandlerWebservice.getServiceAppointment(ScheduledResults.Service.id);
                } else {
                    returnCode = 'Fail';
                    }
            }
            serviceAppList.add(serviceApp);
            BLN_BookTaskWebserviceWrapper.JobWorkOrder jWo = new BLN_BookTaskWebserviceWrapper.JobWorkOrder();
            jWo.remedyJobId = (servApp.BLN_RemedyJobId__c!=null) ? servApp.BLN_RemedyJobId__c : '';
            jWo.taskType = (servApp.WorkType.Name!=null) ? servApp.WorkType.Name : '';
            List<BLN_BookTaskWebserviceWrapper.JobAppointment> jobAppList = new List<BLN_BookTaskWebserviceWrapper.JobAppointment>();
            if(servApp!=null && returnCode == 'Success'){
                for(ServiceAppointment serviceAppointment : serviceAppList){
                    if(serviceAppointment !=null){
                        BLN_BookTaskWebserviceWrapper.JobAppointment jobApp = new BLN_BookTaskWebserviceWrapper.JobAppointment();
                        jobApp.remedyTaskId = (serviceApp.BLN_RemedyTaskId__c!=null)?serviceApp.BLN_RemedyTaskId__c : '';
                        jobApp.jobAppointmentId = (parserReq.jobAppointmentId!=null) ? parserReq.jobAppointmentId :'';
                        jobApp.serviceAppointmentStatus = (servApp.Status!=null) ? servApp.Status :'';
                        jobApp.scheduledStartTime = BLN_FSLUtility.formatGMT(assignedScheduledStartTime);
                        jobApp.scheduledEndTime = BLN_FSLUtility.formatGMT(assignedScheduledEndTime);
                        jobApp.serviceResourceName = assignedServiceResourceName;
                        jobApp.serviceResourceDistrict = (serviceApp.ServiceTerritory.Name!=null) ? serviceApp.ServiceTerritory.Name :'';
                        jobApp.serviceResourceEmployeeNumber = servResourceOracleId;
                        jobAppList.add(jobApp);
                    }
                }
            }else{
                        BLN_BookTaskWebserviceWrapper.JobAppointment jobApp = new BLN_BookTaskWebserviceWrapper.JobAppointment();
                        jobApp.serviceAppointmentStatus = 'Open';
                        jobAppList.add(jobApp);
            }
            BLN_BookTaskWebserviceWrapper.ResponseWrapper rW = new BLN_BookTaskWebserviceWrapper.ResponseWrapper();
            rW.returnCode = returnCode;
            rW.jobWorkOrder = jWo;
            rW.jobAppointment = jobAppList;

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeObject(rW);
            String jsonData = gen.getAsString();
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(jsonData);
            res.statusCode = (returnCode != 'Fail' && isGeolocationPopulated) ? 200 : Integer.valueOf(System.Label.BLN_SchedulingError);

            Datetime endTime = System.Now();

            integrat.BLN_RecordId__c = parserReq.jobAppointmentId;//wrapperObj.jobAppointmentId; // Map to remedyJobId
            integrat.BLN_RequestBody__c = req.requestBody.toString();//requestBody;
            integrat.BLN_RequestEndPoint__c = 'bookTask';
            integrat.BLN_RequestIssuedBy__c = UserInfo.getUserId();
            integrat.BLN_RequestSent__c = System.Now();
            integrat.BLN_ResponseBody__c = res.responseBody.toString();
            integrat.BLN_ResponseReceived__c = System.Now();
            integrat.BLN_ResponseStatus__c = String.valueof(res.statusCode);
            integrat.BLN_ResponseStatusCode__c = String.valueof(res.statusCode);
            integrat.BLN_TargetSystem__c = System.label.BLN_TargetSystemSalesforce;

            String serializedIntegrat = JSON.serialize(integrat);
            serializedIntLogList.add(serializedIntegrat);
            if (serializedIntLogList.size() > 0) {
                String serializedIntLogListJSON = '[' + String.join(serializedIntLogList, ',') + ']';
                BLN_IntegrationLoggerFuture.processIntegrationLogger(serializedIntLogListJSON);
            }


        } catch(exception ex) {
            exceptionList.add(ex);
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 400;
            string jsonResponse = '{"response": {"status": "Failure", "error message": "' + ex.getMessage() + '-' +ex.getLineNumber()+'","reason": "' + ex.getMessage() + '-' +ex.getLineNumber()+'"}}';
            res.responseBody = blob.valueOf(jsonResponse);
            BLN_ExceptionLogger.LogExceptionRequest(exceptionList, jsonResponse, parserReq.jobAppointmentId);
            return ;
        }
    }
}