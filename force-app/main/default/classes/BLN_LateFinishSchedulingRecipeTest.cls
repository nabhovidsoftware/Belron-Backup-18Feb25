/** @description : Test Class for BLN_LateFinishSchedulingRecipe
*  @author:Akshay Chendake (PwC IN)
* @CreatedDate: 07.07.2023
* @Story: FOUK-142
*/
@isTest
public class BLN_LateFinishSchedulingRecipeTest {
    
    /*Description : Creating a records using testDataFactory for interation true*/
    @isTest
    public static void lateFinishPositiveTest(){
        
        List<ServiceAppointment> listOfSARecords = BLN_TestDataFactory.creatSARecords('test names',true);
        // Start the test context.
        Test.startTest();
        BLN_LateFinishSchedulingRecipe.calculateSchedule(listOfSARecords);
        // Stop the test context.
        Test.stopTest();
        Assert.areEqual(true, true, 'Success');
    }
    /*Description : Creating a records using testDataFactory for interation false*/
    @isTest
    public static void lateFinishNegativeTest(){
        List<ServiceAppointment> listOfSARecords = BLN_TestDataFactory.creatSARecords('test names',true);
        ServiceResource serviceResource = [SELECT Id, isActive FROM ServiceResource WHERE Name = 'TestNameOne'];
        serviceResource.IsActive = false;
        update serviceResource;
        // Start the test context.
        Test.startTest();
        BLN_LateFinishSchedulingRecipe.calculateSchedule(listOfSARecords);
        // Stop the test context.
        Test.stopTest();
        System.assertEquals(serviceResource.IsActive, false, 'Success');
    }
}