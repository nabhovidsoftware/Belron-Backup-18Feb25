/** @description : BLN_AutoDispatchJobsTest Class used for testing BLN_AutoDispatchJobs.
*  	@author: Sapna Teltumade
* 	@Story: FOUK-258
*	@Created Date: 19/02/2024
*/
@isTest
public class BLN_AutoDispatchJobsTest {
    public TestMethod static void testData(){        
        ServiceAppointment appointment = BLN_TestDataFactory.createServiceAppntmnt(System.label.BLN_Replacements, TRUE); 
        appointment.Status = System.label.BLN_ScheduledStatus;
        appointment.SchedStartTime = system.now().addminutes(70);
        appointment.SchedEndTime = system.now().addhours(2);
        update appointment;
        Test.startTest();
        SchedulableContext sc = null;
        BLN_AutoDispatchJobs tsc = new BLN_AutoDispatchJobs();
        tsc.execute(sc);
        Test.stopTest();
    }
}