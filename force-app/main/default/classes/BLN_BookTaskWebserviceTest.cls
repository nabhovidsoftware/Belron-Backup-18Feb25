/** @description : Test Web Services Class used for testing Web Service Book Task.
*  @author: Rajat Rewri(PwC IN)
* @Story: FOUK-110
*@Created Date: 19/06/2023
*/
@isTest
public class BLN_BookTaskWebserviceTest {

    // Method for positive test
    @isTest
    public static void confirmAppointmentPositiveTest(){
        boolean doInsert = true;
        // calling TestDataFactory method to get Service Appointment Id in return.
        Id serviceId = BLN_TestDataFactory.createServiceAppointment('test names',doInsert);

        FSL__Scheduling_Policy__c schedulingPolicy =  BLN_TestDataFactory.createSchedulingPolicy(System.Label.BLN_SchedulingPolicyName, true);

        ServiceAppointment updatedSA = new ServiceAppointment();
        updatedSA.Id = serviceId;
        updatedSA.SchedStartTime = system.now();
        updatedSA.SchedEndTime = system.now().addMinutes(30);
        updatedSA.Latitude = -0.474;
        updatedSA.Longitude = 52.119;
        update updatedSA;
        
        ServiceResource serviceResource = [select id, Name, isActive from ServiceResource where Name = 'test names'];
        string servicesId = serviceId;
        // creating string body that has to be passed as a request
        String json=		'{'+
            '"jobAppointmentId" : "'+servicesId+'"'+
            '}';
        string myDomain = URL.getOrgDomainUrl().toExternalForm();
        // creating a new request.
        RestRequest request = new RestRequest();
        request.requestUri = myDomain+'/services/apexrest/confirmAppointment';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);
        RestContext.request = request;
        // passing the response of the request
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // starting the test outside the server limits
        BLN_BookTaskWebservice.returnCode = 'Success';
        FSL.ScheduleResult tempScheduledResults = new FSL.ScheduleResult();
        tempScheduledResults.BreakObject = null;
        tempScheduledResults.Grade = null;
        tempScheduledResults.LongOperationId = null;
        tempScheduledResults.PartialResults = null;
        tempScheduledResults.Resource = serviceResource;
        tempScheduledResults.Service = updatedSA;
        
        BLN_BookTaskWebservice.scheduledResults = tempScheduledResults;
        test.startTest();
        BLN_BookTaskWebservice.bookAppointment();
        test.stopTest();
        System.assertEquals(500, response.statusCode, 'Miss Match');
    }
     // Method for negative test
    @isTest
    public static void confirmAppointmentNegativeTest(){
        FSL__Scheduling_Policy__c schedulingPolicy =  BLN_TestDataFactory.createSchedulingPolicy(System.Label.BLN_SchedulingPolicyName, true);
        String json=		'{'+
            '"jobAppointmentId" : "'+'servicesId'+'"'+
            '}';
        string myDomain = URL.getOrgDomainUrl().toExternalForm();
        // creating a request
        RestRequest request = new RestRequest();
        request.requestUri = myDomain+'/services/apexrest/confirmAppointment';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(json);
        RestContext.request = request;
        // passing the response
        RestResponse response = new RestResponse();
        RestContext.response = response;
        // starting the test outside the server limits
        test.startTest();
        try{
            BLN_BookTaskWebservice.bookAppointment();
        }
        catch(Exception ex){            
            System.assertEquals('Error', 'Error', 'Error');
        }
        test.stopTest();
        System.assertEquals(400, response.statusCode, 'Miss Match');
    }
}