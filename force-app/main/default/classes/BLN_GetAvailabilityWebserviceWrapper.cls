/**@description : Wrapper Class for BLN_WebserviceGetAvailability
*  @Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107
*  @author: Rahul Jain(PwC IN)
*  @CreatedDate: 20/06/2023
*/
public class BLN_GetAvailabilityWebserviceWrapper {
    public class SlotWrapper {
        public String timeIntervalStart;
        public String timeIntervalFinish;
        public Decimal grade;
    }
    
    public class GetSlotsResponseWrapper {
        public String isSuccess { get; set; }
        public String isError { get; set; }
        public List<SlotWrapper> slots { get; set; }
    }
    
    public class GetSlotsRequestWrapper {
        public String jobAppointmentId { get; set; }
    }
    
    public static GetSlotsRequestWrapper parse(String json) {
        return (GetSlotsRequestWrapper) System.JSON.deserialize(json, GetSlotsRequestWrapper.class);
    }
}