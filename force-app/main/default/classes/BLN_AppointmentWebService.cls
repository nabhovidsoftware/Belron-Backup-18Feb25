@RestResource(urlMapping='/appointmentWebService/*')
global with sharing class BLN_AppointmentWebService {

    @HttpPost
    global static void doPost() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
        try{
            RequestBodyWrapper requestBody = (RequestBodyWrapper)JSON.deserialize(req.requestBody.toString(), RequestBodyWrapper.class);
            if (requestBody != null) {
                String method = requestBody.method;
                String responseJSON;
                switch on method {
                    when 'getSlots' {
                        if (requestBody.jobAppointmentId != null) { // Check if jobAppointmentId is not null
                            responseJSON = getSlots(requestBody.jobAppointmentId);
                        } else {
                            responseJSON = '{"error": "jobAppointmentId is null"}';
                        }
                    }
                    when 'scheduleAppointment' {
                        if (requestBody.jobAppointmentId != null) { // Check if jobAppointmentId is not null
                            responseJSON = scheduleAppointment(requestBody.jobAppointmentId);
                        } 
                    }
                    when 'bookAppointment' {
                        if (requestBody.jobAppointmentId != null) { // Check if jobAppointmentId and slot are not null
                            String val1 = requestBody.slot.slotStart;
                            String val2 = requestBody.slot.slotFinish;
                            DateTime start = (DateTime)Json.deserialize('"'+val1+'"', DateTime.class);
                            DateTime finish = (DateTime)Json.deserialize('"'+val2+'"', DateTime.class);
                            responseJSON = bookAppointment(
                                    requestBody.jobAppointmentId, start, finish, requestBody.slot.isDropOff, requestBody.isForcedAppointment
                            );
                        } 
                    }
                    when 'createAppointmentData' {
                        if (requestBody.productList.size() > 0 && requestBody.caseId != null && requestBody.earliestAvailableDate != null && requestBody.locationId != null) {
                            responseJSON = createAppointmentData(
                                    requestBody.productList, requestBody.caseId, requestBody.earliestAvailableDate, requestBody.locationId
                            );
                        } 
                    }
                    when else {
                        responseJSON = '{"error": "Invalid method"}';
                    }
                }
                res.addHeader('Content-Type', 'application/json');
                res.responseBody = Blob.valueOf(responseJSON);
                res.statusCode = 200;
            } else {
                res.statusCode = 400;
                string jsonResponse = '{"response": {"status": "Failure", "message": Error: Empty or invalid request body}}';
                res.responseBody = Blob.valueOf(jsonResponse);
                //res.responseBody = Blob.valueOf('{"error": "Empty or invalid request body"}');
            }
        } catch(exception ex) {
            BLN_ExceptionLogger.captureException(ex);
            res.addHeader('Content-Type', 'application/json');
            res.statusCode = 400;
            string jsonResponse = '{"response": {"status": "Failure", "message": Error: ' + ex.getMessage() +'}}';
            res.responseBody = Blob.valueOf(jsonResponse);
            return;            
        }
    }
    /*
        @description : This method is used to return TimeSlotWrapper.
        @param : String orderId, String scmJson
        @retun : TimeSlotWrapper
    */
    public static String createAppointmentData(List<Object> productList, String caseId, DateTime earliestAvailableDate, String locationId){
        BLN_AppointmentDataCreationService.TimeSlotWrapper result = BLN_AppointmentCreateUpdate.prepData(productList, caseId, earliestAvailableDate, locationId);
        return JSON.serialize(result);
    }
    /*
        @description : This method is used to fetch slots from FSL.AppointmentBookingService API.
        @param : String appointmentId
        @retun : List<TimeSlotsWithProfile>
    */
    public static String getSlots(String appointmentId){
        ServiceTerritory serviceTerritory = BLN_HandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);
        if(serviceTerritory != null) {
            if(serviceTerritory.BLN_Type__c == System.Label.BLN_Mobile){
                List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile> slots = BLN_AppointmentCreateUpdate.getMobileSlots(appointmentId);
                return JSON.serialize(slots);
            } else {
                BLN_AppointmentDataCreationService.Slots slots = BLN_AppointmentCreateUpdate.getBranchSlots(appointmentId);
                return JSON.serialize(slots);
            }
        } else {
            BLN_AppointmentDataCreationService.Slots failureResponse = new BLN_AppointmentDataCreationService.Slots();
            failureResponse.waitingSlots = new List<BLN_AppointmentDataCreationService.SlotData>();
            failureResponse.dropOffSlots = new List<BLN_AppointmentDataCreationService.SlotData>();
            failureResponse.isSuceess = false;
            failureResponse.msg = 'Error: Appointment did not mapped with any Territory';
            return JSON.serialize(failureResponse);
        }
    }
    /*
        @description : This method is used to Update Service Appointment.
        @param : DateTime slotStart, DateTime slotFinish, String appointmentId
        @retun : String
    */
    public static String bookAppointment(String appointmentId, DateTime slotStart, DateTime slotFinish, Boolean isDropOff, Boolean isForcedAppointment){
        if(String.isNotBlank(appointmentId) && slotStart != null && slotFinish != null){
            return BLN_AppointmentBooking.bookAppointment(slotStart, slotFinish, appointmentId, isDropOff, isForcedAppointment);
            //return '{"appointmentId": ' + appId + '}';
        }
        else{
            BLN_AppointmentDataCreationService.BookingResponse bookingResponse = new BLN_AppointmentDataCreationService.BookingResponse();
            bookingResponse.appointmentId = appointmentId;
            bookingResponse.isSuccess = false;
            bookingResponse.message = 'Error: Invalid input.';
            return JSON.serialize(bookingResponse);
        }        
    }
    /*
        @description : This method is used to Schedule Service Appointment using FSL.ScheduleService.
        @param : String appointmentId
        @retun : String
    */
    public static String scheduleAppointment(String appointmentId){
        if(String.isNotBlank(appointmentId)){
            return BLN_AppointmentBooking.scheduleAppointment(appointmentId);
        }
        return null;
    }

    // Define a wrapper class to represent the structure of the request body
    public class RequestBodyWrapper {
        public List<BLN_AppointmentDataCreationService.ProductData> productList;
        public String caseId;
        public DateTime earliestAvailableDate;
        public String locationId;
        public String jobAppointmentId;
        public String method;
        public Boolean isForcedAppointment;
        public Slot slot;
    }
    public class Slot {
		public String slotStart;
		public String slotFinish;
        public boolean isDropOff;
	}
}