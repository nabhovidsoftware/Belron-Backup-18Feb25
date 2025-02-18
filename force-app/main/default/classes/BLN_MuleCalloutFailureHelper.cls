/**
 * Created by gciesielsk001 on 19.12.2023.
 */

public without sharing class BLN_MuleCalloutFailureHelper {

    public static void addMuleCalloutFailure(ServiceAppointment serviceAppointment) {
        BLN_MuleCalloutFailure__e muleCalloutFailure = new BLN_MuleCalloutFailure__e ();
        Map<Id, ServiceAppointment> sA = new Map<Id,ServiceAppointment>();
        sA.put(serviceAppointment.Id, serviceAppointment);
        muleCalloutFailure.ServiceAppointments__c = JSON.serialize(sA.values());
        EventBus.publish(muleCalloutFailure);
    }

    public static void addMuleCalloutFailure(List<ServiceAppointment> serviceAppointments) {
        BLN_MuleCalloutFailure__e muleCalloutFailure = new BLN_MuleCalloutFailure__e ();
        Map<Id, ServiceAppointment> sA = new Map<Id,ServiceAppointment>();
        for(ServiceAppointment serviceAppointment : serviceAppointments) {
            if(!sA.containsKey(serviceAppointment.Id)) {
                sA.put(serviceAppointment.Id, new ServiceAppointment(Id = serviceAppointment.Id, Status = serviceAppointment.Status));
            }
        }
        muleCalloutFailure.ServiceAppointments__c = JSON.serialize(sA.values());
        EventBus.publish(muleCalloutFailure);
    }

    public static void addMuleCalloutFailure(String serviceAppointmentsJson) {
        BLN_MuleCalloutFailure__e muleCalloutFailure = new BLN_MuleCalloutFailure__e ();
        List<ServiceAppointment> serviceAppointments = (List<ServiceAppointment>)JSON.deserialize(serviceAppointmentsJson, List<ServiceAppointment>.class);
        Map<Id, ServiceAppointment> sA = new Map<Id, ServiceAppointment>();
        for(ServiceAppointment serviceAppointment : serviceAppointments) {
            if(!sA.containsKey(serviceAppointment.Id)) {
                sA.put(serviceAppointment.Id, new ServiceAppointment(Id = serviceAppointment.Id, Status = serviceAppointment.Status));
            }
        }
        muleCalloutFailure.ServiceAppointments__c = JSON.serialize(sA.values());
        EventBus.publish(muleCalloutFailure);
    }

    public static void MuleCalloutSuccess(String serviceAppointmentsJson) {
        List<ServiceAppointment> serviceAppointments = (List<ServiceAppointment>)JSON.deserialize(serviceAppointmentsJson, List<ServiceAppointment>.class);
        Map<Id, ServiceAppointment> sA = new Map<Id, ServiceAppointment>();
        for(ServiceAppointment serviceAppointment : serviceAppointments) {
            if(!sA.containsKey(serviceAppointment.Id)) {
                sA.put(serviceAppointment.Id, new ServiceAppointment(Id = serviceAppointment.Id,
                        BLN_MuleCalloutFailed__c = false,
                        BLN_MuleCalloutFailedInStatus__c = ''
                        ));
            }
        }
        update sA.values();
    }

    public static void MuleCalloutSuccess(List<ServiceAppointment> serviceAppointments) {
        Map<Id, ServiceAppointment> sA = new Map<Id,ServiceAppointment>();
        for(ServiceAppointment serviceAppointment : serviceAppointments) {
            if(!sA.containsKey(serviceAppointment.Id)) {
                sA.put(serviceAppointment.Id, new ServiceAppointment(Id = serviceAppointment.Id,
                        BLN_MuleCalloutFailed__c = false,
                        BLN_MuleCalloutFailedInStatus__c = ''
                ));
            }
        }
        update sA.values();
    }
}