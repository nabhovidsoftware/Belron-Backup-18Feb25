@isTest
private class BLN_GetServiceAppointmentHistoryTest {
    
    @isTest
    static void testGetServiceAppointmentHistory() {
        WorkOrder wo = New WorkOrder();
        wo.Subject = 'test subject';
        insert wo;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId = wo.Id;
        insert woli;
        
        ServiceAppointment sa = new ServiceAppointment();
        sa.parentrecordid = woli.id;
        insert sa;
        // Call the method to test
        List<String> result = BLN_GetServiceAppointmentHistory.getServiceAppointmentHistory(new List<String>{sa.Id});
        
        
    }

    @isTest
    static void testsetAppointmentHistory() {
        boolean doInsert = true;
        List<WorkType> workTypes = new List<WorkType>();
        WorkType worktype = new worktype();
        worktype.Name = 'Replacement';
        worktype.EstimatedDuration = 60;
        workTypes.add(worktype);
        worktype = new worktype();
        worktype.Name = 'Repair';
        worktype.EstimatedDuration = 60;
        workTypes.add(worktype);
        insert workTypes;

        Id serviceId = BLN_TestDataFactory.createServiceAppointment('Replacement',doInsert);
        ServiceAppointment oldSA = [
                SELECT
                        Id,
                        ParentRecordId,
                        ServiceTerritoryId,
                        BLN_RemedyTaskId__c,
                        BLN_RemedyJobId__c
                FROM
                        ServiceAppointment
                WHERE
                        id = :serviceId
        ];
        oldSA.WorkTypeId = workTypes[0].Id;
        update oldSA;

        ServiceAppointmentHistory saHistory = new ServiceAppointmentHistory(ServiceAppointmentId = oldSA.Id , Field = 'Status');
        insert saHistory;

        ServiceAppointment sa = BLN_TestDataFactory.createServiceAppointment(
                'Repair',
                oldSA.ParentRecordId,
                oldSA.ServiceTerritoryId,
                'TEMP_' + oldSA.BLN_RemedyTaskId__c,
                false);
        sa.BLN_RebookedServiceAppointment__c = oldSA.Id;
        sa.BLN_RemedyJobId__c = 'TEMP_' + oldSA.BLN_RemedyJobId__c;
        sa.WorkTypeId = workTypes[1].Id;
        insert sa;

        List<ServiceAppointment> appointments = new List<ServiceAppointment>();
        appointments.add(sa);

        test.startTest();
        System.assertNotEquals(null, BLN_GetServiceAppointmentHistory.setAppointmentHistory(appointments)[0].BLN_RebookHistory__c);
        test.stopTest();

        oldSA.BLN_RebookHistory__c = 'Some Text';
        update oldSA;
        saHistory = new ServiceAppointmentHistory(ServiceAppointmentId = oldSA.Id , Field = 'BLN_RebookHistory__c');
        insert saHistory;

        System.assertEquals(true, BLN_GetServiceAppointmentHistory.setAppointmentHistory(appointments)[0].BLN_RebookHistory__c.contains('Some Text'));
    }
}