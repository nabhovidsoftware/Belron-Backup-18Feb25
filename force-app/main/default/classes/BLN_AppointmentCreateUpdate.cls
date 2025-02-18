/**@description : The Apex class handle Task Creation and Updation
*  @author: Wasim Akram & Shubbh Arora
*  @Story: 
*  @CreatedDate: 27/11/2023
*/
public with sharing class BLN_AppointmentCreateUpdate {

    public static BLN_AppointmentDataCreationService.TimeSlotWrapper slotWrapper = new BLN_AppointmentDataCreationService.TimeSlotWrapper();
    public static BLN_AppointmentDataCreationService.Slots branchSlots = new BLN_AppointmentDataCreationService.Slots();
    public static List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile> mobileSlots = new List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile>();

    /*
        @description : This method is used to return TimeSlotWrapper.
        @param : List<ProductData> productList, String caseId, DateTime earliestAvailableDate, String locationId
        @retun : TimeSlotWrapper
    */
    @auraEnabled
    public static BLN_AppointmentDataCreationService.TimeSlotWrapper prepData(List<Object> productList, String caseId, DateTime earliestAvailableDate, String locationId) {
        List<BLN_AppointmentDataCreationService.ProductData> wrapperList = new List<BLN_AppointmentDataCreationService.ProductData>();
        for(Object obj : productList){
            BLN_AppointmentDataCreationService.ProductData prodWrapper = (BLN_AppointmentDataCreationService.ProductData) System.JSON.deserialize(JSON.serialize(obj),BLN_AppointmentDataCreationService.ProductData.class);
            wrapperList.add(prodWrapper);
        }
        slotWrapper = BLN_AppointmentDataCreationService.prepData(wrapperList, caseId, earliestAvailableDate, locationId);
        return slotWrapper;
    }

    /*
        @description : This method is used to return TimeSlotWrapper.
        @param : String orderId, String scmJson
        @retun : TimeSlotWrapper
    */
    @auraEnabled
    public static String createAppointmentData(String orderId, String scmJson) {
        return 'Updated to New UI';
    }

    /*
        @description : This method is used to delete Appointments.
        @param : String appointmentId
        @retun : String
    */
    @AuraEnabled
    public static String deleteAppointment(String appointmentId){
        String status = BLN_AppointmentDataCreationService.deleteAppointment(appointmentId);
        return status;
    }

    /*
        @description : This method is used to Update Appointments according to Drop Off and Collection window.
        @param : String appointmentId
        @retun : String
    */
    @AuraEnabled
    public static String updateAppointment(String appointmentId, Date arrivalStartAndEndDate, Boolean isDropOff){
        String serviceAppId = BLN_AppointmentSlots.updateAppointment(appointmentId, arrivalStartAndEndDate, isDropOff);
        return serviceAppId;
    }

    /*
        @description : This method is used to fetch slots from FSL.AppointmentBookingService API.
        @param : String appointmentId
        @retun : List<TimeSlotsWithProfile>
    */
    @AuraEnabled
    public static BLN_AppointmentDataCreationService.Slots getBranchSlots(String appointmentId){
        branchSlots = BLN_AppointmentSlots.getBranchSlots(appointmentId);
        return branchSlots;
    }

    /*
        @description : This method is used to fetch slots from FSL.AppointmentBookingService API.
        @param : String appointmentId
        @retun : List<TimeSlotsWithProfile>
    */
    @AuraEnabled
    public static List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile> getMobileSlots(String appointmentId){
        mobileSlots = BLN_AppointmentSlots.getMobileSlots(appointmentId);
        return mobileSlots;
    }
}