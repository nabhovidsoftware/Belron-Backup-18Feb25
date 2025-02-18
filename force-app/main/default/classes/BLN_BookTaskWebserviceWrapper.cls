/** @description : Wrapper class for Web Service Book Task Class used for parsing request body.
*  @author: Ayush Singh(PwC IN)
* @Story: FOUK-110
*@Created Date: 13/06/2023
*/
public class BLN_BookTaskWebserviceWrapper{
    public class RequestWrapper{
        public String jobAppointmentId='';
    }
	public class ResponseWrapper {        
        public String returnCode='';
        public JobWorkOrder jobWorkOrder;
        public List<JobAppointment> jobAppointment;
    }
    
    public class JobWorkOrder {
        public String remedyJobId='';
        public String taskType='';
    }
    public class JobAppointment {
        public String remedyTaskId='';
        public String jobAppointmentId='';
        public String serviceAppointmentStatus='';
        public String scheduledStartTime='';
        public String scheduledEndTime='';
        public String serviceResourceName='';
        public String serviceResourceDistrict='';
        public String serviceResourceEmployeeNumber='';
    }
    // Method used to parse request body.
	public static RequestWrapper parse(String reqBody){
		return (RequestWrapper) System.JSON.deserialize(reqBody, RequestWrapper.class);
	}
}