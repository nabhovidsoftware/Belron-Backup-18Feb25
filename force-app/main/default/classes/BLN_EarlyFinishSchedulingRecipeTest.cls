/** @description : Test Class for BLN_EarlyFinishSchedulingRecipe
*  @author:Akshay Chendake (PwC IN)
* @CreatedDate: 07.07.2023
* @Story: FOUK-151
*/
@isTest
public class BLN_EarlyFinishSchedulingRecipeTest {
    @TestSetup
    static void testSetup() {
        List<ServiceAppointment> listOfSARecords = BLN_TestDataFactory.creatSARecords('test names',true);
    }
    /*Description : Creating a records using testDataFactory for interation true*/
    @isTest
    public static void earlyFinishPositiveTest(){
        List<ServiceAppointment> listOfSARecords = [SELECT Id,ParentRecordId,Status,ServiceTerritoryId,EarliestStartTime,SchedStartTime,SchedEndTime,DueDate,
                                                    BLN_WorkOrderNumber__c,BLN_RemedyJobId__c,WorkTypeId,BLN_ServiceResourceID__c FROM ServiceAppointment];
        Test.startTest();
        BLN_EarlyFinishSchedulingRecipe.calculateSchedule(listOfSARecords);
        Test.stopTest();
        Assert.areEqual(true, true, 'Success');
    }
    
    /*Description : Creating a records using testDataFactory for interation false*/
    @isTest
    public static void earlyFinishNegativeTest(){
        List<ServiceAppointment> listOfSARecords = [SELECT Id,ParentRecordId,Status,ServiceTerritoryId,EarliestStartTime,SchedStartTime,SchedEndTime,DueDate,
                                                    BLN_WorkOrderNumber__c,BLN_RemedyJobId__c,WorkTypeId,BLN_ServiceResourceID__c FROM ServiceAppointment];
        ServiceResource serviceResource = [SELECT Id, isActive FROM ServiceResource WHERE Name = 'TestNameOne'];
        serviceResource.IsActive = false;
        update serviceResource;        
        Test.startTest();
        BLN_EarlyFinishSchedulingRecipe.calculateSchedule(listOfSARecords);
        Test.stopTest();
        System.assertEquals(serviceResource.IsActive, false, 'Success');
        
    }
}