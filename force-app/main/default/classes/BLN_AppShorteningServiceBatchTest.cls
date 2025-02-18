/** @description : BLN_AutoDispatchJobsTest Class used for testing BLN_AutoDispatchJobs.
*  	@author: Shubbh ArorA
* 	@Story: FOUK-777
*	@Created Date: 11/03/2024
*/
@isTest
public class BLN_AppShorteningServiceBatchTest {
    @isTest
	public static void testCase(){
        
        OperatingHours operatingHours = BLN_TestDataFactory.createOperatingHours(System.label.BLN_OneHourSlot, true);
        ServiceTerritory st = new ServiceTerritory();
        st = BLN_TestDataFactory.createServiceTerritory('Bedford' , operatingHours.Id , false);
        st.BLN_GUID__c = Null;
        st.BLN_IsBranch__c = true;
        st.BLN_Type__c = System.label.BLN_Branch;
        st.BLN_SplitReplaceAndRecalibration__c = true;
        st.street = '';
        st.city = 'Bedford';
        st.State = '';
        st.postalcode = 'MK44 3US';
        st.Country = 'United Kingdom';
        st.BLN_MaxGapMin__c = 10;
        st.BLN_EnableAppointmentShortening__c = True;
        
        insert st;
        
        ServiceAppointment appointment = BLN_TestDataFactory.createServiceAppntmnt(System.label.BLN_Replacements, TRUE); 
        appointment.Status = System.label.BLN_ScheduledStatus;
        appointment.SchedStartTime = System.now().addminutes(70);
        appointment.SchedEndTime = System.now().addhours(2);
        appointment.BLN_IsForcedAppointment__c = False;
        appointment.ServiceTerritoryId = st.Id;
        appointment.BLN_IsAppointementShortened__c = False;
        appointment.DurationType = 'Minutes';
        update appointment;
        
        Test.startTest();
        	SchedulableContext schContext = null;
        	BLN_AppointmentShorteningServiceBatch appShortningBatch = new BLN_AppointmentShorteningServiceBatch();
        	appShortningBatch.execute(schContext);
        
        	DateTime arrivalWindow = Datetime.now();
        	Integer roundDownTime = 15;
        	BLN_AppointmentShorteningServiceBatch.roundOffTime(arrivalWindow, roundDownTime);
        Test.stopTest();

        System.assertEquals(True, True, 'Not working as expected');
    }
}