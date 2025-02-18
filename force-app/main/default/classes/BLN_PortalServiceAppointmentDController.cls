/********************************************************************************************
* Class Name   : BLN_PortalServiceAppointmentDController(FOR PORTAL B2C)                    *
* Description  : This is used as controller for appointment detail page                     *
* Created By   : Dheeraj Sharma                                                             *
* Story        : FOUK-7607                                                                  *
********************************************************************************************/
public with sharing class BLN_PortalServiceAppointmentDController {

    @AuraEnabled(cacheable = true)
    public static String getCurrentUserAccountName() {
        Id userId = UserInfo.getUserId();
         User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        User currentUser = [SELECT contactId, Account.Name FROM User WHERE Id = :userId];          
           if(currentUser != null) {            
            return currentUser.Account != null ? currentUser.Account.Name : null;
        } else {    return null;
        }      
    }
    @AuraEnabled(cacheable = true)
    public static String fetchSArecord(String recordId, String windowLocation) {
        // Extract 'sid' parameter from the URL
        String sid = extractSidFromUrl(windowLocation);
        BLN_PortalCancellationOptions__mdt.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<BLN_PortalCancellationOptions__mdt> mtd =[SELECT ID, BLN_CancellationMethod__c FROM BLN_PortalCancellationOptions__mdt  LIMIT 1];
        if(mtd.isEmpty() || mtd[0].BLN_CancellationMethod__c == null) {  return null;
        }
        BLN_PortalStatusMappingSA__mdt.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<BLN_PortalStatusMappingSA__mdt> metadataRecords = [SELECT DeveloperName, MasterLabel,BLN_PortalStatus__c FROM BLN_PortalStatusMappingSA__mdt];
        Time stTime;
        Time etTime;
        ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        BLN_Vehicle__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        ServiceTerritory.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        OperatingHours.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<Case> lstCase = [SELECT ID, (SELECT ID,ServiceTerritory.OperatingHoursId,BLN_IsBranchAppointment__c,Status,ArrivalWindowStartTime,BLN_Dropoffby__c,ArrivalWindowEndTime,
        BLN_Collectby__c,DueDate,Duration,Street,City,State,Country,PostalCode,BLN_StartTimeSlots__c, BLN_EndTimeSlots__c,BLN_Product__c,WorkTypeFormula__c FROM Service_Appointments__r where id=:sid),
                                          BLN_Vehicle__r.BLN_Year__c,BLN_Vehicle__r.BLN_VehicleRegNumber__c, BLN_Vehicle__r.BLN_MakeOfVehicle__c,BLN_Vehicle__r.BLN_ModelOfVehicle__c,
                                           BLN_BookingStatus__c, casenumber FROM CASE where id=:recordId  ];
        String opID = lstCase[0].Service_Appointments__R[0].ServiceTerritory.OperatingHoursId;
        TimeSlot.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<TimeSlot> lstTmSlot = [SELECT ID, OperatingHoursId,EndTime,StartTime FROM TimeSlot WHERE OperatingHoursId=:opID ];
		//system.debug('lstTmSlot------------>'+lstTmSlot);
        Integer count = 0;
       // System.debug('lstTmSlot'+lstTmSlot);
        if(lstTmSlot.size() > 0) {
            do {
                TimeSlot tmSlot = lstTmSlot[count];
                if(count == 0) {
                    stTime = tmSlot.StartTime;
                    etTime = tmSlot.EndTime;
                } else {
                    if(stTime > tmSlot.StartTime) { stTime = tmSlot.StartTime;
                    }
                    if(etTime < tmSlot.EndTime) {
                        etTime = tmSlot.EndTime;
                    }
                }
                count++;
            } while (count < lstTmSlot.size());
        }
        orderItem.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<OrderItem> orderItems = [SELECT Id, BLN_StockStatus__c ,BLN_ServiceAppointment__c FROM OrderItem WHERE BLN_ServiceAppointment__c =:sid];

if (!lstCase.isEmpty() && !metadataRecords.isEmpty()) {
    // Get the first Service Appointment record (assuming only one is queried)
    ServiceAppointment serviceAppointment = lstCase[0].Service_Appointments__r.isEmpty() ? null : lstCase[0].Service_Appointments__r[0];
        String portalStatusName = null;
        // Map Service Appointment status to Portal Status name using metadataRecords
        for (BLN_PortalStatusMappingSA__mdt record : metadataRecords) {
        if ((serviceAppointment.Status == System.label.BLN_ScheduledStatus && record.DeveloperName == System.label.BLN_ScheduledStatus)||(serviceAppointment.Status == BLN_AppConstants.NONE && record.DeveloperName == System.label.BLN_OpenLabel)||(serviceAppointment.Status == BLN_AppConstants.PENDING && record.DeveloperName == BLN_AppConstants.PENDING)||(serviceAppointment.Status == System.label.BLN_DispatchedStatus && record.DeveloperName == System.label.BLN_DispatchedStatus)) {
                // Check if any OrderItem has 'received' stock status
          Boolean receivedStock = false;
           for (OrderItem oi : orderItems) {
           if (oi.BLN_StockStatus__c == BLN_AppConstants.RESERVED) {
           receivedStock = true;  
           break;
            }
                }
            //String glass = BLN_AppConstants.GLASS;
                portalStatusName = receivedStock ? 'Glass is on the way' : record.BLN_PortalStatus__c;
                break;
             } else if (serviceAppointment.Status == System.label.BLN_InProgress && record.DeveloperName == 'In_Progress') {
              portalStatusName = record.BLN_PortalStatus__c; break;
            } else if (serviceAppointment.Status == System.label.BLN_Completed && record.DeveloperName == System.label.BLN_Completed) { portalStatusName = record.BLN_PortalStatus__c;
                break;
            }  else if (serviceAppointment.Status == System.label.BLN_FBA && record.DeveloperName == 'Failed_Before_Arrive') { portalStatusName = record.BLN_PortalStatus__c; break;
            } else if (serviceAppointment.Status == BLN_AppConstants.TRAVEL && record.DeveloperName == BLN_AppConstants.TRAVEL) {  portalStatusName = record.BLN_PortalStatus__c; break;
            } else if (serviceAppointment.Status == BLN_AppConstants.ARRIVED && record.DeveloperName == BLN_AppConstants.ARRIVED) {  portalStatusName = record.BLN_PortalStatus__c; break;
            } else if (serviceAppointment.Status == System.label.BLN_FAA && record.DeveloperName == 'Failed_After_Arrive') { portalStatusName = record.BLN_PortalStatus__c; break;
            }else if (serviceAppointment.Status == System.label.BLN_Canceled && record.DeveloperName == 'Cancelled') {portalStatusName = record.BLN_PortalStatus__c;break;
            }
        }

        PortalServiceAppointmentWrapper wrappervar = new PortalServiceAppointmentWrapper();
        wrappervar.caseno = lstCase[0].casenumber;
        wrappervar.dueDat = lstCase[0].Service_Appointments__R[0].DueDate;
        wrappervar.bookingStat = lstCase[0].BLN_BookingStatus__c;
        // Constructing the address
        wrappervar.address = constructAddress(lstCase[0].Service_Appointments__R[0]);
        wrappervar.addressS = constructAddressS(lstCase[0].Service_Appointments__R[0]);
        wrappervar.addressC = constructAddressC(lstCase[0].Service_Appointments__R[0]);
        wrappervar.addressState = constructAddressState(lstCase[0].Service_Appointments__R[0]);
        wrappervar.addressP = constructAddressP(lstCase[0].Service_Appointments__R[0]);
        wrappervar.Vyear = lstCase[0].BLN_Vehicle__r.BLN_Year__c;
        wrappervar.Vrgnumber = lstCase[0].BLN_Vehicle__r.BLN_VehicleRegNumber__c;
        wrappervar.makeofV = lstCase[0].BLN_Vehicle__r.BLN_MakeOfVehicle__c;
        wrappervar.modeofv = lstCase[0].BLN_Vehicle__r.BLN_ModelOfVehicle__c;
        wrappervar.WTformula = lstCase[0].Service_Appointments__R[0].WorkTypeFormula__c;
       wrappervar.wTformulareplacement = lstCase[0].Service_Appointments__R[0].WorkTypeFormula__c;
        wrappervar.produc = lstCase[0].Service_Appointments__R[0].BLN_Product__c;
        wrappervar.ETslit = lstCase[0].Service_Appointments__R[0].BLN_EndTimeSlots__c;
        wrappervar.STsliot = lstCase[0].Service_Appointments__R[0].BLN_StartTimeSlots__c;
        wrappervar.dure = lstCase[0].Service_Appointments__R[0].Duration;
        wrappervar.aWstarttime = lstCase[0].Service_Appointments__R[0].ArrivalWindowStartTime;
        wrappervar.SAid = lstCase[0].Service_Appointments__R[0].Id;
        wrappervar.saStatus = lstCase[0].Service_Appointments__R[0].Status;
        wrappervar.AppointmentDateTextFormula =formatAppointmentDateText(wrappervar.aWstarttime);
        wrappervar.Collectby = lstCase[0].Service_Appointments__R[0].BLN_Collectby__c;
        wrappervar.Dropoffby = lstCase[0].Service_Appointments__R[0].BLN_Dropoffby__c;
       // wrappervar.Dropoffbynew = lstCase[0].Service_Appointments__R[0].ArrivalWindowEndTime;
        wrappervar.IsBranchApp = lstCase[0].Service_Appointments__R[0].BLN_IsBranchAppointment__c;
        wrappervar.userAccountName = getCurrentUserAccountName();
       wrappervar.portalStatusName = portalStatusName;
        wrappervar.UserAccountName = getCurrentUserAccountName(); 
        wrappervar.formatCollectedByMobile(lstCase[0].Service_Appointments__R[0].DueDate);
        // Format the arrival time in AM/PM format
        wrappervar.formatArrivalTime();
      //  System.debug('wrappervar'+wrappervar);
        String jsonString = JSON.serialize(wrappervar);
        return jsonString; }  return null; // Handle scenario where data is not retrieved or mapped correctly
    }
    
    private static String formatAppointmentDateText(Datetime inputDateTime) {
        if (inputDateTime != null) {
            String[] daysOfWeek = new String[]{'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'};
            Integer dayOfWeekIndex = Integer.valueOf(inputDateTime.format('u')); // Corrected the subtraction
            String dayOfWeek = daysOfWeek[dayOfWeekIndex];
            String dayOfMonth = String.valueOf(inputDateTime.day());
            String month = inputDateTime.format('MMM');
            return dayOfWeek + ' ' + dayOfMonth + ' ' + month; }    return null;
    }

    // Method to construct address string with null handling for blank fields
    private static String constructAddress(ServiceAppointment serviceAppointment) {
        String address = '';
        if (!String.isBlank(serviceAppointment.Street)) {
            address += serviceAppointment.Street + ' ';
        }
        if (!String.isBlank(serviceAppointment.City)) {
            address += serviceAppointment.City + ' ';
        }
        if (!String.isBlank(serviceAppointment.State)) {
            address += serviceAppointment.State + ' ';
        }
        if (!String.isBlank(serviceAppointment.Country)) {
            address += serviceAppointment.Country + ' ';
        }
        if (!String.isBlank(serviceAppointment.PostalCode)) {
            address += serviceAppointment.PostalCode;
        }
        // If address is still empty, set it to null
        if (String.isBlank(address.trim())) {    return null;
        }
        return address.trim();
    }


    private static String constructAddressS(ServiceAppointment serviceAppointment) {
        String addressS = '';
        if (!String.isBlank(serviceAppointment.Street)) {
            addressS += serviceAppointment.Street + ' ';
        }
        // If address is still empty, set it to null
        if (String.isBlank(addressS.trim())) {  return null;
        }
        return addressS.trim();
    }

    private static String constructAddressC(ServiceAppointment serviceAppointment) {
        String addressC = '';
        if (!String.isBlank(serviceAppointment.City)) {
            addressC += serviceAppointment.City.toUpperCase() + ' ';
        }
        // If address is still empty, set it to null
        if (String.isBlank(addressC.trim())) { return null;
        }
        return addressC.trim();
    }
    private static String constructAddressState(ServiceAppointment serviceAppointment) {
        String addressState = '';
       if (!String.isBlank(serviceAppointment.State)) {
            addressState += serviceAppointment.State + ' ';
        }
        if (String.isBlank(addressState.trim())) { return null;
        }
        return addressState.trim();
    }
    private static String constructAddressP(ServiceAppointment serviceAppointment) {
        String addressP = '';
        if (!String.isBlank(serviceAppointment.PostalCode)) {
            addressP += serviceAppointment.PostalCode;
        }
        if (String.isBlank(addressP.trim())) { return null;
        }
        return addressP.trim();
    }

    public class PortalServiceAppointmentWrapper {
        public String caseno { get; set; }
        public String address { get; set; }
        public String addressS { get; set; }
        public String addressC { get; set; }
        public String addressState { get; set; }
        public String addressP { get; set; }
        public String bookingStat { get; set; }
        public Decimal vyear { get; set; }
        public String vrgnumber { get; set; }
        public String makeofV { get; set; }
        public String modeofv { get; set; }
        //public String wTformula { get; set; }
        public String produc { get; set; }
        public String eTslit { get; set; }
        public String sTsliot { get; set; }
        public Decimal dure { get; set; }
        public Datetime aWstarttime { get; set; }
        public String saStatus { get; set; }
        public String portalStatusName { get; set; }
        public String sAid { get; set; }
        public String collectby { get; set; }
        public String dropoffby { get; set; }
        public String dropoffbynew { get; set; }
        public Datetime dueDat { get; set; }
        public String appointmentDateTextFormula { get; set; }
        public Boolean isBranchApp { get; set; }
        public String arrivalTimeFormatted { get; set; } // New field for formatted arrival time
        public String userAccountName { get; set; } // New field for user's account name
        public String collectedbymobail { get; set; }
        public String wTformulareplacement {
            get {
                return this.wTformulareplacement;
            }
            set {
                if (value == System.label.BLN_repair) {  this.wTformulareplacement = 'repair';
                } else {
                    this.wTformulareplacement = 'replacement';
                }
            }
        }

        public String wTformula {
            get {
                return this.wTformula;
            }
            set {
                if (value == System.label.BLN_repair) {  this.wTformula = 'repair';
                } else {
                    this.wTformula = 'replace';
                }
            }
        }

        // Method to format time in AM/PM format
                public void formatArrivalTime() {
                    if (aWstarttime != null) {
                        // Format the time with leading zeros
                        Integer hours = aWstarttime.hour();
                        Integer minutes = aWstarttime.minute();
                        String formattedHours = hours < 10 ? '0' + String.valueOf(hours) : String.valueOf(hours);
                        String formattedMinutes = minutes < 10 ? '0' + String.valueOf(minutes) : String.valueOf(minutes);
                        ArrivalTimeFormatted = formattedHours + ':' + formattedMinutes;
                    }
                }

  // Method to format collected by mobile time based on DueDate
  public void formatCollectedByMobile(Datetime dueDate) {
    if (dueDate != null) {
        Integer hours = dueDate.hour();
        Integer minutes = dueDate.minute();
        String formattedHours = hours < 10 ? '0' + String.valueOf(hours) : String.valueOf(hours);
        String formattedMinutes = minutes < 10 ? '0' + String.valueOf(minutes) : String.valueOf(minutes);
        collectedbymobail = formattedHours + ':' + formattedMinutes;
    }
}

    }
    private static String extractSidFromUrl(String windowLocation) {
        String sid = windowLocation.right(18);
        return sid;
    }
    /** START FOUK-FOUK-8026
     * Wrapper class to hold parent Case, child Cases, and summarized status.
     */
    public class CaseWrapper {
        @AuraEnabled public String parentId;
        @AuraEnabled public String parentStatus;
        @AuraEnabled public Integer childCaseCount;
        @AuraEnabled public List<ChildCaseWrapper> childCases;
        @AuraEnabled public String summarizedStatus;
        public CaseWrapper(String parentId, String parentStatus, Integer childCaseCount, List<ChildCaseWrapper> childCases, String summarizedStatus) {            this.parentId = parentId;  this.parentStatus = parentStatus; this.childCaseCount = childCaseCount; this.childCases = childCases; this.summarizedStatus = summarizedStatus;
        }
    }

    /**
     * Wrapper class for child Case details.
     */
    public class ChildCaseWrapper {
        @AuraEnabled public String caseId;
        @AuraEnabled public String subject;
        @AuraEnabled public String status;
        public ChildCaseWrapper(String caseId, String subject, String status) { this.caseId = caseId; this.subject = subject; this.status = status;
        }
    }

    /**
     * Fetches the parent Case, count of child Cases, details of child Cases, and summarized status based on child Case statuses.
     * @param recordId The Id of the Case for which to fetch parent Case and child Cases details.
     * @return JSON serialized string of the fetched data.
     */
    @AuraEnabled
    public static String fetchParentAndChildCases(String recordId) {
        try {
    Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
    Case childCasea = [SELECT ID, ParentId, Status FROM Case WHERE ID = :recordId];
    // Query to fetch parent Case and its child Cases
    Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
    Case parentCase = [ SELECT Id, ParentId, Status, (SELECT ID, Subject,Type,BLN_SubType__c, Status FROM Cases WHERE BLN_SubType__c =: System.label.BLN_Complaint) FROM Case WHERE Id = :childCasea.ParentId];
    // Check if parentCase is null
            // Creating wrapper for parent and child Cases
            List<ChildCaseWrapper> childCaseList = new List<ChildCaseWrapper>();
            for (Case childCase : parentCase.Cases) { ChildCaseWrapper childWrapper = new ChildCaseWrapper( childCase.Id, childCase.Subject,  childCase.Status
                );  childCaseList.add(childWrapper);
            }
            // Determine summarized status based on child Case statuses
     String summarizedStatus = determineSummarizedStatus(parentCase.Cases);
            // Creating parent Case wrapper
     CaseWrapper caseWrapper = new CaseWrapper(parentCase.ParentId,parentCase.Status,parentCase.Cases.size(),childCaseList,summarizedStatus);
            // Serialize wrapper to JSON
            String jsonString = JSON.serialize(caseWrapper); return jsonString;
        } catch (Exception e) {
            // Handle any exceptions gracefully
            return null; // or return appropriate error message
        }
    }
    //FOUK-11879-helper method to check unauthorized access
    @AuraEnabled
    public static Boolean checkAccess(String caseId,String appId){
    Boolean hasAccess = true;
    User.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
    Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
    ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
    User u =[SELECT ID,AccountId FROM USER WHERE ID =: userinfo.getUserId()];
    Case c =[SELECT ID,AccountId,Account.RecordType.Name FROM CASE WHERE ID =:caseId];
    ServiceAppointment sa =[SELECT ID,AccountId,Account.RecordType.Name FROM ServiceAppointment WHERE ID =:appId];
    if(c.AccountId == u.AccountId && sa.AccountId == u.AccountId){
    hasAccess = true;        
    }else{
    hasAccess= false;    
    }
    return hasAccess;   
    }
    private static String determineSummarizedStatus(List<Case> childCases) {
        Boolean hasInProgress = false;
        Boolean hasOpen = false; 
        Boolean hasClosed = false;
        // Iterate through child Cases to determine statuses
        for (Case childCase : childCases)
         { if (childCase.Status == System.label.BLN_New)
          {hasInProgress = true; } 
          else if
           (childCase.Status == System.label.BLN_OpenLabel || childCase.Status == BLN_AppConstants.IN_REVIEW)
           {hasOpen = true;}
            else if
             (childCase.Status == BLN_AppConstants.CLOSED)
              { hasClosed = true;
            }
        }
        // Apply logic based on determined statuses
        if (hasInProgress)
         { return 'New'; } 
        else if (hasOpen && !hasInProgress && !hasClosed)
         { return 'In Progress'; } 
         else if (hasOpen && !hasInProgress && !hasClosed)
         { return 'Closed'; } 
         else {   return null;
        }
    }
    //END FOUK-8026
}