/**@description : The Apex class Generate file name
*  @author: Wasim Akram
*  @Story: FOUK-4520
*  @CreatedDate: 30/01/2024
*/
public with sharing class BLN_ImageCapture {
    @AuraEnabled(cacheable=true)
    public static WrapperClass populateFileName(String recordId){
        WorkOrderLineItem woli = [SELECT Id, LineItemNumber, WorkOrderId, WorkOrder.WorkOrderNumber FROM WorkOrderLineItem WHERE Id =: recordId WITH SECURITY_ENFORCED LIMIT 1];
        ServiceAppointment serviceApp = [SELECT Id, AppointmentNumber FROM ServiceAppointment WHERE ParentRecordId =: recordId WITH SECURITY_ENFORCED LIMIT 1];
        User usr = new User();
        Id userId = UserInfo.getUserId();
        usr = [Select Id,TimeZoneSidKey From User Where Id =: userId WITH SECURITY_ENFORCED LIMIT 1];
        Datetime gmtDateTime = System.now();
        String strConvertedDate = ''; 
        strConvertedDate = gmtDateTime.format('yyyy-MM-dd-HH:mm:ss', usr.TimeZoneSidKey);
        WrapperClass wrapperObj = new WrapperClass();
        if(String.isNotBlank(woli.WorkOrderId) && String.isNotBlank(woli.WorkOrder.WorkOrderNumber) && String.isNotBlank(serviceApp.AppointmentNumber)){
            wrapperObj.workOrderNumber = woli.WorkOrder.WorkOrderNumber;
            wrapperObj.serviceAppNumber = serviceApp.AppointmentNumber;
            wrapperObj.currentDateTime = strConvertedDate;
        }
        return wrapperObj;
    }

    @AuraEnabled
    public static Boolean checkSTRelease(String woliID){
        try {
            WorkOrderLineItem woli = [SELECT Id, ServiceTerritory.BLN_ConsiderforR1__c FROM WorkOrderLineItem WHERE Id = :woliID WITH SECURITY_ENFORCED];
            return woli.ServiceTerritory.BLN_ConsiderforR1__c;
            
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return false;
    }

    public class WrapperClass {
        @AuraEnabled public String workOrderNumber;
        @AuraEnabled public String serviceAppNumber;
        @AuraEnabled public String currentDateTime;
    }
}