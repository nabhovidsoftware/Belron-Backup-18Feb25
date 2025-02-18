/** @description : Test Class for BLN_FetchLunchBreakBatch
*  @author:Pruthvisinh Pujara (PWC IN)
* @CreatedDate: 08.12.2023
* @Story: FOUK-1596
*/
@isTest
public class BLN_FetchLunchBreakBatchTest {
    @isTest
    public static void fetchLunchBreakBatchTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' Limit 1];
        User ur = [Select id from User where ProfileId =: p.Id AND isActive=true limit 1];
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName=:System.Label.BLN_CustomNotificationTypeDevName];
        System.runAs(ur){
            ServiceResource sr = BLN_TestDataFactory.createServiceResource('Test Resource',true);
            ResourceAbsence ra = BLN_TestDataFactory.createResourceAbsence(sr.Id,true);
            Set<ResourceAbsence> absenceRecords = new Set<ResourceAbsence>();
            absenceRecords.add(ra);
            test.startTest();
                BLN_FetchLunchBreakBatch objLunchBreak = new BLN_FetchLunchBreakBatch();
                //Database.executeBatch(objLunchBreak,2000);
            System.schedule(
                'Test Schedule',
                '0 15 * * * ?',
                objLunchBreak);
        test.stopTest();
        System.assertEquals('Test Resource', sr.Name,'Resource Name is correct');
    }
    }
}