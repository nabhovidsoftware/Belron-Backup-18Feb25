public with sharing class BLN_ShowVideoController {
    @AuraEnabled(cacheable=true)
    public static CaseWrapper getCaseRecord(String recordId , String windowLocation) {
        CaseWrapper result = new CaseWrapper();
        String sid = extractSidFromUrl(windowLocation);
        try {
            ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            ServiceAppointment.BLN_Case__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            Case caseRecord = [SELECT ID, BLN_ServiceType__c,  (SELECT Id, WorkTypeFormula__c FROM Service_Appointments__r where id=:sid) FROM Case  WHERE Id = :recordId];
            result.caseRecord = caseRecord;
            result.serviceAppointments = caseRecord.Service_Appointments__r;
        } catch(Exception e) {
           throw new AuraHandledException('Exception occurred in showVideo: ' +e.getMessage()+'--'+e.getLineNumber()+'=='+e.getCause()+'...'+e.getStackTraceString());
        }
        return result;
    }
    private static String extractSidFromUrl(String windowLocation) {
            String sid = windowLocation.right(18);
            return sid;
        }

    public class CaseWrapper {
        @AuraEnabled
        public Case caseRecord { get; set; }
        @AuraEnabled
        public List<ServiceAppointment> serviceAppointments { get; set; }
    }
}