/**@description : The Apex class handle Task Creation and Updation Used in portal 
*  @author: Dheeraj sharma  & Vedita Kashi
*  @Story: FOUK 4342
*  @CreatedDate: 15/06/2024
*/
public without sharing class BLN_PortalAppointmentCreateUpdate {

    public static BLN_PortalAppointmentDataCreationService.TimeSlotWrapper slotWrapper = new BLN_PortalAppointmentDataCreationService.TimeSlotWrapper();
    public static BLN_PortalAppointmentDataCreationService.Slots branchSlots = new BLN_PortalAppointmentDataCreationService.Slots();
    public static List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile> mobileSlots = new List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile>();

    /*
        @description : This method is used to return TimeSlotWrapper.
        @param : List<ProductData> productList, String caseId, DateTime earliestAvailableDate, String locationId
        @retun : TimeSlotWrapper
    */
    @auraEnabled
    public static BLN_PortalAppointmentDataCreationService.TimeSlotWrapper prepData(List<Object> productList, String caseId, DateTime earliestAvailableDate, String locationId) {
        
        List<BLN_PortalAppointmentDataCreationService.ProductData> wrapperList = new List<BLN_PortalAppointmentDataCreationService.ProductData>();
        for(Object obj : productList){ 
            BLN_PortalAppointmentDataCreationService.ProductData prodWrapper = (BLN_PortalAppointmentDataCreationService.ProductData) System.JSON.deserialize(JSON.serialize(obj),BLN_PortalAppointmentDataCreationService.ProductData.class);
            wrapperList.add(prodWrapper);
        }
        slotWrapper = BLN_PortalAppointmentDataCreationService.prepData(wrapperList, caseId, earliestAvailableDate, locationId);
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
        String status = BLN_PortalAppointmentDataCreationService.deleteAppointment(appointmentId);
        return status;
    }

    /*
        @description : This method is used to Update Appointments according to Drop Off and Collection window.
        @param : String appointmentId
        @retun : String
    */
    @AuraEnabled
    public static String updateAppointment(String appointmentId, Date arrivalStartAndEndDate,Date startDate, Integer interval){
        String serviceAppId = BLN_PortalAppointmentSlots.updateAppointment(appointmentId, arrivalStartAndEndDate,startDate,interval);
        return serviceAppId;
    }

    /*
        @description : This method is used to fetch slots from FSL.AppointmentBookingService API.
        @param : String appointmentId
        @retun : List<TimeSlotsWithProfile>
    */
    @AuraEnabled
    public static BLN_PortalAppointmentDataCreationService.Slots getBranchSlots(String appointmentId){
        branchSlots = BLN_PortalAppointmentSlots.getBranchSlots(appointmentId);
        return branchSlots;
    }

    /*
        @description : This method is used to fetch slots from FSL.AppointmentBookingService API.
        @param : String appointmentId
        @retun : List<TimeSlotsWithProfile>
    */
    @AuraEnabled
    public static List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile> getMobileSlots(String appointmentId){
        mobileSlots = BLN_PortalAppointmentSlots.getMobileSlots(appointmentId);
        return mobileSlots;
    }
}