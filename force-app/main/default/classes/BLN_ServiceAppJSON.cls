/** @description : This Wrapper class for BLN_HTTPCallOutToMuleSoft
*   @Story : FOUK-198
*   @author: Kanchan Mishra (PwC)
*   @CreatedDate: 08/08/2023*/
public class BLN_ServiceAppJSON {

    public String entityName='';
    public String entityID='';
    public String eventType='';
    public String sourceSystem='';
    public DateTime timestamp;
    public String initialisedSystem='';
    public Data data;
    public Object motoristSalesOpportunity;

	public class Data {
        public Previous previous;
		public Previous current;
	}

    public class Address {
        public String addressLineOne='';
        public String addressPostalCode='';
        public AddressExtended addressExtended;
        public City city;
        public Country country;
    }

    public class SalesOpportunity {
        public List<JobWorkOrder> jobWorkOrder;
    }

    public class TaskTypeHeritage {
        public String taskTypeName='';
    }

    public class AddressExtended {
        public String addressRegion='';
        public String addressDistrict='';
    }

    public class MotoristSalesOpportunity {
        public SalesOpportunity salesOpportunity;
    }

    public class Previous {
		public MotoristSalesOpportunity motoristSalesOpportunity;
	}

    public class City {
        public String cityName='';
    }

    public class WorkerShift {
        public Worker worker;
    }

    public class JobWorkOrderLineHeritage {
        public TaskTypeHeritage taskTypeHeritage;
    }

    public class JobAppointment {
        public List<JobAppointmentHeritage> jobAppointmentHeritage;
        public String jobAppointmentPriority='';
        public Decimal duration;
        public String jobAppointmentId='';
        public JobAppointmentStatus jobAppointmentStatus;
        public String failureReasonCodeId='';
        public String appointmentDateTime;
        public String earliestStartDateTime;
        public String latestCompletionDueDate;
        public String scheduledStartDateTime;
        public String scheduledCompletionDateTime;
        public String estimatedArrivalWindowStartDateTime;
        public String estimatedArrivalWindowEndDateTime;
        public Location location;
        public List<JobAppointmentWorkerAssignment> jobAppointmentWorkerAssignment;
    }

    public class JobAppointmentStatus {
        public String jobAppointmentStatusName='';
    }

    public class PartyIdentification {
        public String partyIdentificationId='';
    }

    public class PersonRole {
        public Person person;
    }

    public class JobWorkOrder {
        public String jobWorkOrderId='';
        public JobWorkOrderHeritage jobWorkOrderHeritage;
        public List<JobWorkOrderLine> jobWorkOrderLine;
    }

    public class Party {
        public List<PartyIdentification> partyIdentification;
    }

    public class JobAppointmentWorkerAssignment {
        public WorkerShift workerShift;
    }

    public class JobWorkOrderLine {
        public JobWorkOrderLineHeritage jobWorkOrderLineHeritage;
        public List<JobAppointment> jobAppointment;
    }

    public class LocationAddress {
        public Address address;
    }

    public class JobWorkOrderHeritage {
        public String remedyJobWorkOrderId='';
    }

    public class Country {
        public String countryName='';
    }

    public class Worker {
        public PersonRole personRole;
    }

    public class JobAppointmentHeritage {
        public String remedyJobAppointmentId='';
    }

    public class Person {
        public String firstName='';
        public String lastName='';
        public String salutation='';
        public Party party;
    }

    public class Location {
        public String companyNav='';
        public List<LocationAddress> locationAddress;
    }

    
    public static BLN_ServiceAppJSON parse(String json) {
        return (BLN_ServiceAppJSON) System.JSON.deserialize(json, BLN_ServiceAppJSON.class);
    }
}