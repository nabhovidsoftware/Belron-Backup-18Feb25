/**
 * Created by gciesielsk001 on 28.03.2024.
 */

public with sharing class BLN_MuleCalloutFailureTriggerHelper {

    public static void processCalloutFailures(List<BLN_MuleCalloutFailure__e> newBlnMuleCalloutFailures) {
        Map<Id, ServiceAppointment> serviceAppointments2Update = new Map<Id, ServiceAppointment>();
        for (BLN_MuleCalloutFailure__e busEvent : newBlnMuleCalloutFailures) {
            List<ServiceAppointment> serviceAppointmentsIds = (List<ServiceAppointment>) JSON.deserialize(busEvent.ServiceAppointments__c, List<ServiceAppointment>.class);
            for (ServiceAppointment serviceAppointment : serviceAppointmentsIds) {
                if (!serviceAppointments2Update.containsKey(serviceAppointment.Id)) {
                    serviceAppointment.BLN_MuleCalloutFailed__c = true;
                    serviceAppointment.BLN_MuleCalloutFailedInStatus__c = serviceAppointment.status;
                    serviceAppointment.status = null;
                    serviceAppointments2Update.put(
                            serviceAppointment.Id,
                            new ServiceAppointment(
                                    Id = serviceAppointment.Id,
                                    BLN_MuleCalloutFailed__c = serviceAppointment.BLN_MuleCalloutFailed__c,
                                    BLN_MuleCalloutFailedInStatus__c = serviceAppointment.BLN_MuleCalloutFailedInStatus__c
                            )
                    );
                }
            }
        }
        if (!serviceAppointments2Update.isEmpty()) {
            update serviceAppointments2Update.values();
        }
    }

}