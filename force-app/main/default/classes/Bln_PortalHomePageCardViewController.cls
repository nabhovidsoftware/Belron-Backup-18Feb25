/**
 * @description       :
 * @author            : Sourabh Bhattacharjee
 * @story             : FOUK-10309
 * @last modified on  : 09-06-2024
 * @last modified by  : Sourabh Bhattacharjee
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   08-07-2024   Sourabh Bhattacharjee   Initial Version
**/
public without sharing class Bln_PortalHomePageCardViewController {
public static Integer serviceAppointmentCount { get; set; }
    /**
     * @description Fetches ServiceAppointments related to Cases for the current user's account.
     * @return List<ServiceAppointmentWrapper> - List of wrapped ServiceAppointment objects.
     */
    @AuraEnabled(cacheable=true)
    public static List<ServiceAppointmentWrapper> getServiceAppointments() {
       // serviceAppointmentCount = 0;
        Id userId = UserInfo.getUserId();
        User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        User currentUser = [SELECT AccountId FROM User WHERE Id = :userId];
        ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<ServiceAppointment> appointments = [SELECT Id, ArrivalWindowStartTime, BLN_Case__c, WorkTypeFormula__c, BLN_Case__r.CaseNumber, Status ,AccountId
                                                FROM ServiceAppointment WHERE BLN_Case__c != null
                                                AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect')
                                                AND Status NOT IN ('Canceled','Completed', 'Failed Before Arrive', 'Failed After Arrive')
                                                AND AccountId = :currentUser.AccountId
                                                AND BLN_IsPrepDataCall__c = false  
                                                ORDER BY ArrivalWindowStartTime ASC];
        /**FOUK-10309  
        List<ServiceAppointment> appointments = [SELECT Id, ArrivalWindowStartTime, BLN_Case__c, WorkTypeFormula__c, BLN_Case__r.CaseNumber, Status, AccountId, Account.Name, BLN_RebookedServiceAppointment__c
        FROM ServiceAppointment
        WHERE
      (
        BLN_Case__c != null
        AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect')
        AND Status NOT IN ('None', 'Completed', 'Canceled')
        AND AccountId =:currentUser.AccountId
        )
        OR
       (
        Status = 'Canceled'
        AND AccountId =:currentUser.AccountId
        AND (BLN_RebookedServiceAppointment__c = null OR BLN_RebookedServiceAppointment__c = '')
        AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect')
       )
        ORDER BY ArrivalWindowStartTime ASC];*/
        List<ServiceAppointmentWrapper> wrappedAppointments = new List<ServiceAppointmentWrapper>();
        for(ServiceAppointment app : appointments) {
            wrappedAppointments.add(new ServiceAppointmentWrapper(app));
        }        
        return wrappedAppointments;
    }
    
     // Method to get the account Id associated with the currently logged-in user
	@AuraEnabled(cacheable=true)
    public static Id getLoggedInUserAccount() { 
    try {
        User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
         return [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()].AccountId;
    }
    catch (Exception e) {
        // Handling the exceptions and log an error message
        BLN_ExceptionLogger.captureException(e);
        return null; // Return null or handle as per your application's error handling strategy
    }
    }
    
    /**
     * Wrapper class to format ServiceAppointment data for the UI.
     */
    public class ServiceAppointmentWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String arrivalWindowStartTime;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String workType;
        @AuraEnabled public String caseId;
        /**
         * Constructor to initialize the wrapper with ServiceAppointment data.
         * @param app - ServiceAppointment object to wrap.
         */
        public ServiceAppointmentWrapper(ServiceAppointment app) {
            this.id = app.Id;
            this.arrivalWindowStartTime = String.valueOf(app.ArrivalWindowStartTime); 
            this.caseNumber = app.BLN_Case__r.CaseNumber;
            this.workType = (app.WorkTypeFormula__c == 'Repair') ? 'repair' : 'replacement';
            this.caseId = app.BLN_Case__c;
        }
    }
    
    /**
     * @description Fetches the name of the account associated with the currently logged-in user.
     * @return String - Name of the Account associated with the current user.
     */
    @AuraEnabled(cacheable=true)
    public static String getCurrentUserAccountName() {
        Id userId = UserInfo.getUserId();
         User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        User currentUser = [SELECT contactId, Account.Name FROM User WHERE Id = :userId];          
           if(currentUser != null) {            
            return currentUser.Account != null ? currentUser.Account.Name : null;
        } else {
            return null;
        }      
    }

    @AuraEnabled(cacheable=true)
    public static Integer getAppointmentCount(String accId){
    serviceAppointmentCount=0;
    List<AggregateResult> groupedResults = [
            SELECT AccountId, COUNT(Id) serviceAppointmentCount
            FROM ServiceAppointment
            WHERE AccountId = :AccId AND BLN_Case__c != null AND WorkTypeFormula__c NOT IN ('Assist', 'Stock Collect')
            AND Status NOT IN ('Canceled','None','Completed', 'Failed Before Arrive', 'Failed After Arrive')
            GROUP BY AccountId
        ];

        if (!groupedResults.isEmpty()) {
            Integer count = (Integer)groupedResults[0].get('serviceAppointmentCount');
            serviceAppointmentCount = count > 0 ? count : 0;
        } else {
            serviceAppointmentCount = 0;
        }

        return serviceAppointmentCount;
    }

}