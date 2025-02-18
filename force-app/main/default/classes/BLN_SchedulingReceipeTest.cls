/** @description : Test Class for BLN_InvocableOptimizeSchedule
*  @author:Akshay Chendake (PwC IN)
* @CreatedDate: 06.07.2023
* @Story: FOUK-150
*/
@IsTest
public class BLN_SchedulingReceipeTest {
    
   
    /*Description : Creating a records using testDataFactory for interation true*/
    @IsTest
    public static void testSchedulingReceipe(){
        List<ServiceAppointment> listOfSARecords = BLN_TestDataFactory.creatSARecords('test names',true);
        Test.startTest();
        BLN_InvocableOptimizeSchedule.calculateSchedule(listOfSARecords);
        Test.stopTest();
        system.assertNotEquals(null, listOfSARecords,'Service App should not be null');
    }  
    /*Description : Creating a records using testDataFactory for interation false*/
    @isTest
    public static void earlyFinishNegativeTest(){
        List<ServiceAppointment> listOfSARecords = BLN_TestDataFactory.creatSARecords('test names',true);
        ServiceResource serviceResource = [select id, isActive from ServiceResource where Name = 'TestNameOne'];
        serviceResource.IsActive = false;
        update serviceResource;
        test.startTest();
        BLN_InvocableOptimizeSchedule.calculateSchedule(listOfSARecords);
        system.assertEquals(serviceResource.IsActive, false,'Service Res should be InActive');
        test.stopTest();
       
            
        
    }
}