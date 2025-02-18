public class BLN_GetServiceAppointmentHistory {
    
    @InvocableMethod(label='Get Service Appointment History')
    public static List<String> getServiceAppointmentHistory(List<String> serviceAppointmentIds) {
        List<String> result = new List<String>();
        String history = '';
        List<ServiceAppointmentHistory> historyList = [SELECT Id, Field, NewValue, OldValue, CreatedDate,CreatedBy.Name 
                                                       FROM ServiceAppointmentHistory
                                                       WHERE ServiceAppointmentId = :serviceAppointmentIds[0]
                                                       ORDER BY CreatedDate DESC];
        try {
            
            for(ServiceAppointmentHistory appHis : historyList){
                history = history+'['+appHis.createdDate+'] - '+appHis.Field+' changed to '+appHis.NewValue+' from '+appHis.OldValue+' by '+appHis.CreatedBy.Name+'<br/>';
            }
            result.add(history);
            
            
        } catch (Exception e) {
            // Handle any exceptions here
            System.debug('Exception: ' + e.getMessage());
        }
        return result;
        
    }

    /**
     * @description Methode used to set Rebooked Appointment History
     * @stories :  INC0419377
     * @param appointments Service Appointments to create History for
     * @return List of Service Appointments with updated History
     */
    public static List<ServiceAppointment> setAppointmentHistory (List<ServiceAppointment> appointments) {
        List<Id> appointmentToProcess = new List<Id>();

        for (ServiceAppointment appointment : appointments) {
            if (appointment.BLN_RebookedServiceAppointment__c != null) {
                appointmentToProcess.add(appointment.BLN_RebookedServiceAppointment__c);
            }
        }

        List<ServiceAppointmentHistory> historyList = [
                SELECT
                        Id,
                        Field,
                        NewValue,
                        OldValue,
                        CreatedDate,
                        CreatedBy.Name,
                        ServiceAppointment.BLN_RemedyJobId__c,
                        ServiceAppointment.BLN_RebookHistory__c,
                        ServiceAppointmentId
                FROM
                        ServiceAppointmentHistory
                WHERE
                        ServiceAppointmentId = :appointmentToProcess
                ORDER BY CreatedDate DESC
        ];

        Map<Id, String> historyByReebokServiceAppointemnt = new Map<Id, String>();
        Map<Id, String> oldHistoryByReebokServiceAppointemnt = new Map<Id, String>();
        String history;
        for (ServiceAppointmentHistory appointmentHistory : historyList) {
            if (!historyByReebokServiceAppointemnt.containsKey(appointmentHistory.ServiceAppointmentId)) {
                history = '<b>Appointment Ref: ' + appointmentHistory.ServiceAppointment.BLN_RemedyJobId__c + '</b><br><br>';
                history = appendHistory(history, appointmentHistory);
                historyByReebokServiceAppointemnt.put(appointmentHistory.ServiceAppointmentId, history);
                if (appointmentHistory.ServiceAppointment.BLN_RebookHistory__c != null && appointmentHistory.ServiceAppointment.BLN_RebookHistory__c != '') {
                    oldHistoryByReebokServiceAppointemnt.put(appointmentHistory.ServiceAppointmentId, appointmentHistory.ServiceAppointment.BLN_RebookHistory__c);
                }
            } else {
                history = appendHistory(historyByReebokServiceAppointemnt.get(appointmentHistory.ServiceAppointmentId), appointmentHistory);
                historyByReebokServiceAppointemnt.put(appointmentHistory.ServiceAppointmentId, history);
            }
        }

        for (ServiceAppointment appointment : appointments) {
            if(historyByReebokServiceAppointemnt.containsKey(appointment.BLN_RebookedServiceAppointment__c)) {
                String wholeHistory = historyByReebokServiceAppointemnt.get(appointment.BLN_RebookedServiceAppointment__c);
                if (oldHistoryByReebokServiceAppointemnt.get(appointment.BLN_RebookedServiceAppointment__c) != null) {
                    wholeHistory = wholeHistory + oldHistoryByReebokServiceAppointemnt.get(appointment.BLN_RebookedServiceAppointment__c);
                }
                appointment.BLN_RebookHistory__c = wholeHistory.left(131072);
            }
        }

        return appointments;
    }

    /**
     * @description Appends History
     * @stories :  INC0419377
     *
     * @param history String containing formated Service Appointment History
     * @param appointmentHistory Service Appointment History to add to history
     *
     * @return Appended Formated History
     */
    private static String appendHistory (String history, ServiceAppointmentHistory appointmentHistory) {
        String appendedHistory = history
                + '['
                + appointmentHistory.createdDate
                + '] - '
                + appointmentHistory.Field
                + ' changed to '
                + appointmentHistory.NewValue
                + ' from '
                + appointmentHistory.OldValue
                + ' by '
                + appointmentHistory.CreatedBy.Name
                + '<br/>';
        return appendedHistory;
    }
}