/** @description : Test Class for BLN_FlowScheduler
*  @author:Pruthvisinh Pujara (PWC IN)
* @CreatedDate: 25.01.2024
* @Story: FOUK-1596
*/
@isTest
public class BLN_FlowSchedulerTest {
@isTest
    public static void flowSchedulerTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' Limit 1];
        User ur = [Select id from User where ProfileId =: p.Id AND isActive=true limit 1];
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName=:System.Label.BLN_CustomNotificationTypeDevName];
        
        ServiceResource sr = BLN_TestDataFactory.createServiceResource('Test Resource',true);
        ResourceAbsence ra = BLN_TestDataFactory.createResourceAbsence(sr.Id,true);
        ra = [select id,Start, End, ResourceId, Resource.RelatedRecordId from ResourceAbsence where id =:ra.Id Limit 1];
        Set<ResourceAbsence> absenceRecords = new Set<ResourceAbsence>();
        absenceRecords.add(ra);
        test.startTest();
        BLN_FlowScheduler flowScheduler = new BLN_FlowScheduler(absenceRecords,notificationType.Id);
        System.schedule(
            'Test flowScheduler',
            '0 15 * * * ?',
            flowScheduler);
        test.stopTest();
        
        System.runAs(ur){
            System.assertEquals('Test Resource', sr.Name,'Resource Name is correct');
        }
    }
}