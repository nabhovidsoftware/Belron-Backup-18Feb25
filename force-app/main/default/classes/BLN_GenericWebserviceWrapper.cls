/** @description : The Wrapper class to parse the request from BLN_TaskCreateUpdateWebservice.
*   @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
*   @author: Rajat Rewri(PwC IN)
*    @CreatedDate: 31/05/2023
*/

public class BLN_GenericWebserviceWrapper {
    public class RequestWrapper {
        public String action='';
        public JobWorkOrder_CLS workOrder;
    }
    public class JobWorkOrder_CLS {
        public String remedyJobId='';
        public String remedyProfile='';
        public String ADASJob='';
        public List<JobWorkOrderLine_CLS> workOrderLineItem;                
        public Vehicle_CLS vehicle;
        public List<PersonAccount_CLS> personAccount;
    }
    public class JobWorkOrderLine_CLS {
        public JobAppointment_CLS serviceAppointment;        
        public String taskType='';
        public String taskPriority='';
        public List<RequiredSkills_CLS> taskRequiredSkill;
    }
    public class JobAppointment_CLS {
        public String remedyTaskId='';
        public String duration='';
        public String serviceAppointmentStatus='';
        public String isBranchAppointment='';
        public String remedyOpenDate='';
        public String failureReasonCodeId='';
        public String earliestStartTime='';
        public String arrivalWindowEndTime='';
        public String arrivalWindowStartTime='';
        public String updateTime='';
        public String dueDateTime='';
        public Location_CLS address;
        public ServiceTerritory_CLS serviceTerritory;
        public String actualArrivalDateTime='';		//FOUK-3341
        public String actualCompletionDateTime='';	//FOUK-3341
    }
    public class Location_CLS {
        public String street='';
        public String city='';
        public String postalCode='';
        public String countryID='';
    }
    public class ServiceTerritory_CLS {
        public String Region='';
        public String companyNav='';
        public String District='';
    }
    public class Vehicle_CLS {
        public String vehicleMake='';
        public String vehicleModel='';
        public String vehicleRegistration='';
    }
    public class PersonAccount_CLS {
        public String firstName='';
        public String lastName='';
        public String salutation='';
        public String contactPhoneNumber='';
        public String accountType='';
    } 
    public class RequiredSkills_CLS {
        public String skill='';
        public String SkillLevel='';
    }
    public class RemedyResponseWrapper{
        public String isSuccess{get;set;}
        public String isError{get;set;}
        public String errorMessage{get;set;}
        public String WorkOrder_BLN_RemedyJobId{get;set;}
        public String workOrder_Id{get;set;}
        public String ServiceAppointment_BLN_RemedyTaskId{get;set;}
        public String ServiceAppointment_Id{get;set;}
        public String ServiceAppointment_Status{get;set;}
    }
    public class RemedyResponseWrapper2{
        public String isSuccess{get;set;}
        public String isError{get;set;}
        public String errorMessage{get;set;}
        public String WorkOrder_BLN_RemedyJobId{get;set;}
        public List<sARemedyResponseWrapper> ServiceAppointments{get;set;}
    }
    public class RemedyResponseWrapper3{
        public String isSuccess{get;set;}
        public String isError{get;set;}
        public String errorMessage{get;set;}
        public String WorkOrder_BLN_RemedyJobId{get;set;}
        public List<sARemedyResponseWrapper2> ServiceAppointments{get;set;}
    }
    public class sARemedyResponseWrapper{        
        public String ServiceAppointment_BLN_RemedyTaskId{get;set;}
        public String ServiceAppointment_Status{get;set;}
    }
    public class sARemedyResponseWrapper2{        
        public String ServiceAppointment_BLN_RemedyTaskId{get;set;}
        public String ServiceAppointment_Status{get;set;}
    }
    /** @description : parse(String json) method to parse the json string into BLN_GenericWebserviceWrapper
	* @param : String json
	* @return : BLN_JSON_Wrapper
	*/
    public static RequestWrapper parse(String json){
        return (RequestWrapper) System.JSON.deserialize(json, RequestWrapper.class);
    }
}