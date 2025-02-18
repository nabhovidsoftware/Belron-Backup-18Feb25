/** @description : Test Class for BLN_CancellationSchedulingRecipe
*  @author:Akshay Chendake (PwC IN)
* @CreatedDate: 06.07.2023
* @Story: FOUK-150
*/
@IsTest
public class BLN_CancellationSchedulingRecipeTest {
     /**
*@description : This method is used for testing BLN_CancellationSchedulingRecipe.calculateSchedule method
*/
    @IsTest
    public static void testSchedulingReceipe1(){
        // Create Service Appointment
        List<ServiceAppointment> listOfSARecords = BLN_TestDataFactory.creatSARecords('test names',true);
        System.assertNotEquals(listOfSARecords, null, 'Initial Service Appointments should not be null');
        BLN_CancellationSchedulingRecipe.forCatch = true;
        // Start Test Execution
        Test.startTest();
        BLN_CancellationSchedulingRecipe.firstIteration = false;
        BLN_CancellationSchedulingRecipe.calculateSchedule(listOfSARecords);
        // Stop Test Execution
        Test.stopTest();
        System.assertEquals('Scheduled', listOfSARecords[0].Status, 'Miss Match');
    } 

    @isTest
    public static void cancellationSchedulingRecipeTest(){
        // Create Service Appointment
        List<ServiceAppointment> listOfSARecords = new List<ServiceAppointment>();
        List<ServiceAppointment> listOfSARecord = BLN_TestDataFactory.creatSARecords('test names',true);
        AssignedResource ar = [select id from AssignedResource Limit 1];
        ar.ServiceResourceId = listOfSARecord[0].BLN_ServiceResourceID__c;
        update ar;
        listOfSARecords.addAll(listOfSARecord);
        ServiceAppointment listOfSARecord1 = BLN_TestDataFactory.createServiceAppointmentRecord('test names2',false);
        AssignedResource ar1 = [select id from AssignedResource Limit 1];
        ar1.ServiceResourceId = listOfSARecord1.BLN_ServiceResourceID__c;
        listOfSARecord1.SchedStartTime = system.now().AddHours(2);
        listOfSARecord1.SchedEndTime = system.now().AddHours(3);
        insert listOfSARecord1;
        listOfSARecords.add(listOfSARecord1);
        // Start Test Execution
        test.startTest();
        BLN_CancellationSchedulingRecipe.firstIteration = true;
        BLN_CancellationSchedulingRecipe.calculateSchedule(listOfSARecords);
        // Stop Test Execution
        test.stopTest();
        System.assertNotEquals(null,listOfSARecords , 'List should not be null');
    }
    
}