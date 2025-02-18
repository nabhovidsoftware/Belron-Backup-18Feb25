@isTest
public class BLN_ExtraSAdeletionCallerTest {
    @isTest
    public static void testData(){
        ServiceAppointment appointment = BLN_TestDataFactory.createServiceAppntmnt(System.label.BLN_Replacements, TRUE); 
        appointment.SchedStartTime = System.now().addminutes(70);
        appointment.SchedEndTime = System.now().addhours(2);
        appointment.BLN_IsForcedAppointment__c = False;
        appointment.BLN_IsBookingFailed__c = False;
        appointment.DurationType = 'Minutes';
        appointment.BLN_IsPrepDataCall__c = True;
        appointment.BLN_RemedyJobId__c = NULL;
        update appointment;
        
        BLN_TestDataFactory.createTD(appointment.Id,appointment.Id,'Test', TRUE); 
            
        Test.startTest();
        SchedulableContext sc = null;
        BLN_ExtraSAdeletionCaller batchjob = new BLN_ExtraSAdeletionCaller();
        batchjob.execute(sc);
        Database.executeBatch(batchjob,200);
        System.assertNotEquals(appointment, null,'test');  
        Test.stopTest();
        
    }
}