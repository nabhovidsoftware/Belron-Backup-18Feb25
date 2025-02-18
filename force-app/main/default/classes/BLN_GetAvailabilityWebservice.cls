/** @description : The Apex Webservice class using getAvailbility to fetch the slots
*   @Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107
*   @author: Rahul Jain(PwC IN)
*  @CreatedDate: 31/05/2023
*/ 
@RestResource(urlMapping='/remedyGetSlots/*')
global without sharing class BLN_GetAvailabilityWebservice {
    
    /*description: getAvailbility POST method In this method we are parsing requestBody and getting a slots based on jobAppointmentId*/
    @HttpPost
    global static void getAvailbility() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<Exception> exceptionList = new List<Exception>();
        BLN_IntegrationLogger__c integrat = new BLN_IntegrationLogger__c();
        List<String> serializedIntLogList = new List<String>();
        
        Datetime startTime = System.Now();
        BLN_GetAvailabilityWebserviceWrapper.GetSlotsRequestWrapper wrapperObj = new BLN_GetAvailabilityWebserviceWrapper.GetSlotsRequestWrapper();
        String requestBody = req.requestBody.toString();
            
        
        try {
            if(String.isNotBlank(requestBody)){
                wrapperObj = BLN_GetAvailabilityWebserviceWrapper.GetSlotsRequestWrapper.parse(requestBody);
            }
            List<BLN_GetAvailabilityWebserviceWrapper.SlotWrapper> slotWrapperList = new List<BLN_GetAvailabilityWebserviceWrapper.SlotWrapper>();
            if(wrapperObj != null && String.isNotBlank(wrapperObj.jobAppointmentId)){
                slotWrapperList = getSlots(wrapperObj.jobAppointmentId);
            } 
            
            BLN_GetAvailabilityWebserviceWrapper.GetSlotsResponseWrapper responseWrapper = new BLN_GetAvailabilityWebserviceWrapper.GetSlotsResponseWrapper();
            responseWrapper.isSuccess = 'true';
            responseWrapper.isError = 'false';
            responseWrapper.slots = slotWrapperList;
            

            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
            res.statusCode = 200;

            Datetime endTime = System.Now();
            String apiCallDurationInSeconds = BLN_FSLUtility.calculateDiffBetTime(startTime, endTime);
            integrat.BLN_APICallInSeconds__c = BLN_FSLUtility.calculateDiffBetTime(startTime, endTime);
            integrat.BLN_RecordId__c = wrapperObj.jobAppointmentId; // Map to remedyJobId
            integrat.BLN_RequestBody__c = requestBody;
            integrat.BLN_RequestEndPoint__c = 'getABSlots';            
            integrat.BLN_RequestIssuedBy__c = UserInfo.getUserId(); 
            integrat.BLN_RequestSent__c = System.Now();
            integrat.BLN_ResponseBody__c = res.responseBody.toString();
            integrat.BLN_ResponseReceived__c = System.Now();
            integrat.BLN_ResponseStatus__c = String.valueof(res.statusCode);
            integrat.BLN_ResponseStatusCode__c = ''+res.statusCode;
            integrat.BLN_TargetSystem__c = System.label.BLN_TargetSystemSalesforce;
            
            String serializedIntegrat = JSON.serialize(integrat);
            serializedIntLogList.add(serializedIntegrat);        
            if (serializedIntLogList.size() > 0) {
                String serializedIntLogListJSON = '[' + String.join(serializedIntLogList, ',') + ']';
                BLN_IntegrationLoggerFuture.processIntegrationLogger(serializedIntLogListJSON);
            }

        }catch (FieldException fieldEx) {
            exceptionList.add(fieldEx);
            BLN_ExceptionLogger.LogExceptionRequest(exceptionList, requestBody, wrapperObj.jobAppointmentId);
            handleFieldException(fieldEx, res);
            
        } catch (Exception ex) {
            exceptionList.add(ex);
            BLN_ExceptionLogger.LogExceptionRequest(exceptionList, requestBody, wrapperObj.jobAppointmentId);   
            handleException(ex, res);
        }
    }
    
    /*description: getSlots method to fetch the slots based on Service appointment Id
    *@param : String jobAppointmentId
    *return : slotWrapperList
    */
    @testVisible
    private static List<BLN_GetAvailabilityWebserviceWrapper.SlotWrapper> getSlots(String jobAppointmentId) {
        List<BLN_GetAvailabilityWebserviceWrapper.SlotWrapper> slotWrapperList = new List<BLN_GetAvailabilityWebserviceWrapper.SlotWrapper>();
        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();
        //Fetch ServiceAppointment basedfrom  on jobAppointmentId
        if(String.isNotBlank(jobAppointmentId)){
            serviceAppointmentList = BLN_QueryHandlerWebservice.getServiceAppointments(jobAppointmentId);
        }
        if (serviceAppointmentList != null && !serviceAppointmentList.isEmpty()) {
            
            //Timezone tz = UserInfo.getTimeZone();
            String operatingHourName;
            // Fetch the Scheduling Policy Id
            Id schedulingPolicyId = BLN_QueryHandlerWebservice.getSchedulingPolicyId(label.BLN_BUKSchedulingPolicy);
            OperatingHours op= new OperatingHours();
            
            // Fetch the IsBranch from ServiceTerritory
            //Boolean isBranch = serviceAppointmentList[0].ServiceTerritory.BLN_IsBranch__c;
            Boolean isBranch = serviceAppointmentList[0].BLN_isbranchappointment__c;
            
            List<String> allDayProfiles = label.BLN_All_Day_Slot_Profiles.split(',');
            if(serviceAppointmentList[0].BLN_RemedyProfile__c != null
                && allDayProfiles.contains(serviceAppointmentList[0].BLN_RemedyProfile__c)){

                operatingHourName = serviceAppointmentList[0].ServiceTerritory.OperatingHours.Name;
                    
            } 
            else if (serviceAppointmentList[0].BLN_RemedyProfile__c != null) {
                operatingHourName = isBranch ? label.BLN_30MinutesSlot: label.BLN_OneHourSlot;
            }            
            else {
                throw new FieldException('Remedy Profile label is not specified.');
            }
            
            op= BLN_QueryHandlerWebservice.getOperatingHours(operatingHourName);
            TimeZone tz = TimeZone.getTimezone(op.Timezone);
            
            // Fetch the slots
            FSL.ABSlotsResponse abSlots = FSL.AppointmentBookingService.getABSlots(serviceAppointmentList[0].Id, schedulingPolicyId, op, tz,'SORT_BY_DATE', false);
            
            List<FSL.AppointmentBookingSlot> slots = abSlots.Slots;
            // Process the slots and create the response
            slotWrapperList = processSlots(slots, serviceAppointmentList[0], op, 15);
        }
        return slotWrapperList;
    }
    
    /*description: processSlots method to processing the slots from GMT to UTC
    *@param : List<FSL.AppointmentBookingSlot> slots,ServiceAppointment serviceAppointment,OperatingHours op, Integer maxSlotsCount
    */
    @testVisible
    private static List<BLN_GetAvailabilityWebserviceWrapper.SlotWrapper> processSlots(List<FSL.AppointmentBookingSlot> slots, ServiceAppointment serviceAppointment, OperatingHours op, Integer maxSlotsCount) {
        List<BLN_GetAvailabilityWebserviceWrapper.SlotWrapper> slotWrapperList = new List<BLN_GetAvailabilityWebserviceWrapper.SlotWrapper>();
        
        // Fetch the IsBranch from ServiceTerritory
        Boolean isBranch = serviceAppointment.BLN_IsBranchAppointment__c ;
        String startUtcString;
        String finishUtcString;
        Decimal formattedGrade = 0.00;
        Decimal noOfHours = 0.00;
        Integer noOfMinInt = 0;
        Datetime newDateAfterHourAdd=null;
        Datetime newDateAfterNthSlot=null;
        Map<String, Decimal> mapGetSlotsMapping = getNumberOfHours();
        // Fetch the slots
        for (Integer i = 0; i < slots.size(); i++) {
            if (i >= maxSlotsCount){
                break;
            }
            
            FSL.AppointmentBookingSlot slot = slots[i];
            // label = "All Day Slot,All Day Slot Minus 30,All Day Slot Minus 60"
            List<String> allDayProfiles = label.BLN_All_Day_Slot_Profiles.split(',');
            if (!allDayProfiles.contains(serviceAppointment.BLN_RemedyProfile__c) && !isBranch) {

                noOfHours = mapGetSlotsMapping.get(serviceAppointment.BLN_RemedyProfile__c);
                String noOfHoursString = String.valueOf(noOfHours);
                if(noOfHoursString.contains('.5')){
                    newDateAfterHourAdd = slot.Interval.Start.addHours((noOfHours-0.5).intValue());
                    //newDateAfterHourAdd = slot.Interval.Start.addMinutes(30);
                    newDateAfterHourAdd = newDateAfterHourAdd.addMinutes(30);
                }
                else{
                    newDateAfterHourAdd = slot.Interval.Start.addHours(noOfHours.intValue());
                }
                if (newDateAfterHourAdd <= serviceAppointment.DueDate) {
                    slot.Interval.Finish = newDateAfterHourAdd;
                } else {
                    break;
                }

                //RS:06-Oct-2023 FOUK-3340 Start
                //if Branch appointment profile for granular slot contains Minus 30/60 then Finsh time will be same as Start time
            }
            else if(isBranch && serviceAppointment.BLN_RemedyProfile__c.contains('Minus')){
                slot.Interval.Finish = slot.Interval.Start;
            }
            /*FOUK-3472 Start */
            //BLN_AllDaySlotMinus60
            else if(serviceAppointment.BLN_RemedyProfile__c.equalsIgnorecase(label.BLN_AllDaySlotMinus30)){
                slot.Interval.Finish = slot.Interval.Finish.addMinutes(-30);
            }
            //BLN_AllDaySlotMinus60
            else if(serviceAppointment.BLN_RemedyProfile__c.equalsIgnorecase(label.BLN_AllDaySlotMinus60)){
                slot.Interval.Finish = slot.Interval.Finish.addMinutes(-60);
            }
            /*FOUK-3472 End */

            // Format Start and Finish times as strings
            startUtcString = BLN_FSLUtility.convertDateTimeToUTC(slot.Interval.Start, op.TimeZone);
            finishUtcString = BLN_FSLUtility.convertDateTimeToUTC(slot.Interval.Finish, op.TimeZone);
            formattedGrade = slot.Grade.setScale(2);
            
            // Create slot wrapper and add to the list
            BLN_GetAvailabilityWebserviceWrapper.SlotWrapper slotWrapper = new BLN_GetAvailabilityWebserviceWrapper.SlotWrapper();
            slotWrapper.timeIntervalStart = startUtcString;
            slotWrapper.timeIntervalFinish = finishUtcString;
            slotWrapper.grade = formattedGrade;
            slotWrapperList.add(slotWrapper);
        }
        
        return slotWrapperList;
    }
    
    /*description: getNumberOfHours method to fetch the BLN_Profile__c from custom metadata BLN_GetSlotsMapping__mdt*/
    @testVisible
    private static Map<String, Decimal> getNumberOfHours() {
        List<BLN_GetSlotsMapping__mdt> getSlotsmdtList = [SELECT BLN_Profile__c,BLN_NumberOfHours__c FROM BLN_GetSlotsMapping__mdt];
        Map<String, Decimal> mapGetSlotsMapping = new Map<String, Decimal>();
        for (BLN_GetSlotsMapping__mdt nHour : getSlotsmdtList) {
            if (nHour.BLN_Profile__c!=null && nHour.BLN_NumberOfHours__c!=null) {
                mapGetSlotsMapping.put(nHour.BLN_Profile__c, nHour.BLN_NumberOfHours__c.setScale(2));
            }
        }
        return mapGetSlotsMapping;
    }
    
    public class ResponseWrapper {
        public String status;
        public String message;
        public Boolean isSuccess;
        public Boolean isError;
    }
    
    // Field-specific exception class
    public class FieldException extends Exception {}
    
    // Field-specific exception handler
    @testVisible
    private static void handleFieldException(FieldException ex, RestResponse res) {
        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 400;
        ResponseWrapper responseWrapper = new ResponseWrapper();
        responseWrapper.status = 'Failure';
        responseWrapper.message = ex.getMessage();
        responseWrapper.isSuccess = false;
        responseWrapper.isError = true;        
        res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
    }
    
    @testVisible
    private static void handleException(Exception ex, RestResponse res) {
        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 400;
        ResponseWrapper responseWrapper = new ResponseWrapper();
        responseWrapper.status = 'Failure';
        responseWrapper.message = ex.getMessage() + ' (Line: ' + ex.getLineNumber() + ')';
        responseWrapper.isSuccess = false;
        responseWrapper.isError = true;        
        res.responseBody = Blob.valueOf(JSON.serialize(responseWrapper));
    }
}