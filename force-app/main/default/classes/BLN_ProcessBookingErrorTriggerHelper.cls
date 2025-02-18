/**
 * Created by gciesielsk001 on 28.03.2024.
 */

public with sharing class BLN_ProcessBookingErrorTriggerHelper {

    public static void processBookingErrors(List<BLN_BookingFailed__e> newProcessBookingErrors) {
        Map<Id, ServiceAppointment> serviceAppointments2Update = new Map<Id, ServiceAppointment>();
        for (BLN_BookingFailed__e busEvent: newProcessBookingErrors) {
            List<Id> serviceAppointmentsIds = (List<Id>)JSON.deserialize(busEvent.ServiceAppointments__c, List<Id>.class);
            for (Id serviceAppointmentId :serviceAppointmentsIds) {
                if(!serviceAppointments2Update.containsKey(serviceAppointmentId)) {
                    serviceAppointments2Update.put(
                            serviceAppointmentId,
                            new ServiceAppointment(
                                    Id = serviceAppointmentId,
                                    BLN_IsBookingFailed__c = true
                            )
                    );
                }
            }
        }
        if(!serviceAppointments2Update.isEmpty()) {
            update serviceAppointments2Update.values();
        }
    }
}