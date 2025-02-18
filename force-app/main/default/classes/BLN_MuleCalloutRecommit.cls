/**
 * Created by gciesielsk001 on 19.12.2023.
 */

public with sharing class BLN_MuleCalloutRecommit implements Database.Batchable<SObject>, Schedulable{


    @TestVisible private static Boolean forTest = false;
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT ' +
                'Id,' +
                'BLN_MuleCalloutFailedInStatus__c, ' +
                'Status, ' +
                'street, ' +
                'postalCode, ' +
                'country, ' +
                'city, ' +
                'BLN_RemedyJobId__c, ' +
                'BLN_RemedyTaskId__c, ' +
                'Duration, ' +
                'BLN_RemedyOpenDate__c, ' +
                'EarliestStartTime, ' +
                'DueDate, ' +
                'SchedStartTime, ' +
                'SchedEndTime, ' +
                'ArrivalWindowStartTime, ' +
                'ArrivalWindowEndTime, ' +
                'BLN_WorkOrderNumber__c, ' +
                'BLN_AssignedServiceResource__c, ' +
                'BLN_ServiceResourceID__c ' +
                'FROM ' +
                'ServiceAppointment ' +
                'WHERE ' +
                'BLN_MuleCalloutFailed__c = true ' +
                'AND BLN_MuleCalloutFailedInStatus__c = \'' + System.Label.BLN_DispatchedStatus + '\' ' +
                'AND Status = \'' + System.Label.BLN_DispatchedStatus + '\' ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope){
        List<ServiceAppointment> serviceAppointments = (List<ServiceAppointment>) scope;
        List<BLN_ServiceAppointmentCallout.InputVariables> inputVariablelist = new List<BLN_ServiceAppointmentCallout.InputVariables>();
        BLN_ServiceAppointmentCallout.InputVariables inputVariables = new BLN_ServiceAppointmentCallout.InputVariables();

        for(ServiceAppointment serviceAppointment :serviceAppointments) {
            List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();
            if(serviceAppointment.BLN_MuleCalloutFailedInStatus__c == System.Label.BLN_DispatchedStatus
            && serviceAppointment.Status == System.Label.BLN_DispatchedStatus) {
                serviceAppointmentList.add(serviceAppointment);
                serviceAppointment.Status = System.Label.BLN_ScheduledStatus;
                serviceAppointmentList.add(serviceAppointment);
                inputVariables.ServiceAppointmentlist = serviceAppointmentList;
                inputVariablelist.add(inputVariables);
            } //else {
                //todo: implement solution for other statuses than dispatched
            //}
        }
        //inputVariables.ServiceAppointmentlist = serviceAppointments;
        //inputVariablelist.add(inputVariables);
        BLN_ServiceAppointmentCallout.serviceAppointmentHTTPCallout(inputVariablelist);

    }

    public void finish(Database.BatchableContext bc){
        string result = 'Finish';
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new BLN_MuleCalloutRecommit(),  1);
    }
}