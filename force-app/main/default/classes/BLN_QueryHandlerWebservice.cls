/**@description : The Handler class for Remedy Webservice
*  @author: Ayush Singh(PwC IN)
*  @Story: FOUK-110,FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107,FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
*  @CreatedDate: 31/05/2023
*/
public without sharing class BLN_QueryHandlerWebservice { 
      
    /** @description : selectByNameOrNumber method to get the records of the given sObjectName, matchingNameorNumber
    * @param : String sObjectName, String matchingNameorNumber
    * @return : List<sObject>
    * @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
    */    
    public static List<sObject> selectByNameOrNumber(String sObjectName, String matchingNameorNumber){
        
        return selectByNameOrNumber(sObjectName, new Set<String>{matchingNameorNumber}, null,1);
        
    }
    
    /** @description : selectByNameOrNumber method to get the records of the given sObjectName, matchingNameorNumber
    * @param : String sObjectName,  Set<String> matchingNameorNumber
    * @return : List<sObject>
    * @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
    */    
    public static List<sObject> selectByNameOrNumber(String sObjectName,  Set<String> matchingNameorNumberSet){
        return selectByNameOrNumber(sObjectName, matchingNameorNumberSet, null,null);
    }
    /** @description : selectByNameOrNumber method to get the records of the given sObjectName, matchingNameorNumber, fieldSet, recLimit
    * @param : String sObjectName, String matchingNameorNumber, Set<String> fieldSet, Integer recLimit
    * @return : List<sObject>
    * @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
    */    
    public static List<sObject> selectByNameOrNumber(String sObjectName, Set<String> matchingNameorNumberSet, Set<String> fieldSet, Integer recLimit){
        List<String> idAndMatchingField = new List<String>{'Id'};
        String perAcc = 'Person Account';
        String matchingField;
        if(sObjectName.equalsIgnoreCase('WorkOrder')){
            matchingField = 'WorkOrderNumber';
        }
        else if(sObjectName.equalsIgnoreCase('WorkOrderLineItem')){
            matchingField = 'LineItemNumber';
        }
        else if(sObjectName.equalsIgnoreCase('ServiceAppointment')){
            matchingField = 'AppointmentNumber';
        }
        else{
            matchingField = 'Name';
        }
        IdAndMatchingField.add(matchingField);
        List<String> fieldList = new List<String>();        
        if(fieldSet!=null && fieldSet.size()>0){
            fieldSet.removeAll(IdAndMatchingField);                
            fieldList.addAll(fieldSet);
        }
        fieldList.addAll(IdAndMatchingField);
        String fields = String.join(fieldList, ',');
        String query = 'SELECT ';
        query += fields;
        query += ' FROM '+sObjectName;
        query += ' WHERE ' + matchingField + ' IN:matchingNameorNumberSet';
        if(sObjectName.equalsIgnoreCase('Account')){
            query += ' AND RecordType.Name=:perAcc';
        }
        if(recLimit!=null && recLimit>0){
            query += ' LIMIT '+recLimit;
        }
        return Database.query(String.escapeSingleQuotes(query));
    }
    
    /** @description : getServiceTerritoryByType method to get the records of ServiceTerritory by name and Type
    * @param : String name, String sAType
    * @return : List<ServiceTerritory>
    * @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
    */ 
    public static List<ServiceTerritory> getServiceTerritoryByType(Set<String> names, String sAType){
        List<ServiceTerritory> sAList = new List<ServiceTerritory>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
     //   system.debug('isPortalUser value '+isPortalUser);
        If(isPortalUser){
             ServiceTerritory.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
             sAList = [SELECT Id, Name, BLN_MeetAndGreetTime__c, OperatingHoursId, OperatingHours.TimeZone, BLN_Type__c, IsActive FROM ServiceTerritory 
                       WHERE Name IN:names AND IsActive=true ];
        }
        else{
            sAList = [SELECT Id, Name, BLN_MeetAndGreetTime__c, OperatingHoursId, OperatingHours.TimeZone, BLN_Type__c, IsActive FROM ServiceTerritory 
                      WHERE Name IN:names AND IsActive=true];
        }
        
        if(sAList!=null && sAList.size() > 0) {
            return sAList;
        } else {
            return null;
        }
    }
    
    /** @description : getWOByRemedyJobId method to get the records of WorkOrder by remedyJobId
    * @param : String remedyJobId
    * @return : List<WorkOrder>
    * @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
    */    
    public static List<WorkOrder> getWOByRemedyJobId(String remedyJobId){
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
             WorkOrder.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
             workOrderList = [SELECT Id, WorkOrderNumber, Status,ParentWorkOrderId,BLN_RemedyJobId__c, CaseId, 
                                         Case.AccountId, BLN_ADASJob__c, BLN_AppointmentFailureCount__c,BLN_AppointmentFailureReasonHistory__c 
                                         FROM WorkOrder
                                         WHERE BLN_RemedyJobId__c = :remedyJobId Order By LastModifiedDate DESC LIMIT 1];
        }
        else{
            workOrderList = [SELECT Id, WorkOrderNumber, Status,ParentWorkOrderId,BLN_RemedyJobId__c, CaseId, 
                                         Case.AccountId, BLN_ADASJob__c, BLN_AppointmentFailureCount__c,BLN_AppointmentFailureReasonHistory__c 
                                         FROM WorkOrder
                                         WHERE BLN_RemedyJobId__c = :remedyJobId Order By LastModifiedDate DESC LIMIT 1];
        }
        
        if(workOrderList!=null && workOrderList.size()>0){
            return workOrderList;
        }
        else{
            return null;
        }
    }
    
    /** @description : getWOByLikeRemedyJobId method to get the records of WorkOrder by remedyJobId
    * @param : String remedyJobId
    * @return : List<WorkOrder>
    * @Story : 
    */    
   public static List<WorkOrder> getWOByLikeRemedyJobId(String remedyJobId){
        String newSearchText = '%'+remedyJobId;
        List<WorkOrder> workOrderList = new List<WorkOrder>();
       //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            workOrderList = [
                SELECT
                    Id,
                    WorkOrderNumber,
                    Status,
                    ParentWorkOrderId,
                    BLN_RemedyJobId__c,
                    CaseId,
                    Case.AccountId,
                    BLN_ADASJob__c,
                    BLN_AppointmentFailureCount__c,
                    BLN_AppointmentFailureReasonHistory__c,
                    ServiceTerritory.BLN_TerritoryBuffer__c
                FROM
                    WorkOrder
                WHERE
                    BLN_RemedyJobId__c LIKE :newSearchText
                    Order By WorkOrderNumber DESC LIMIT 1];
        }
        else{
            workOrderList = [
                SELECT
                    Id,
                    WorkOrderNumber,
                    Status,
                    ParentWorkOrderId,
                    BLN_RemedyJobId__c,
                    CaseId,
                    Case.AccountId,
                    BLN_ADASJob__c,
                    BLN_AppointmentFailureCount__c,
                    BLN_AppointmentFailureReasonHistory__c,
                    ServiceTerritory.BLN_TerritoryBuffer__c
                FROM
                    WorkOrder
                WHERE
                        BLN_RemedyJobId__c LIKE :newSearchText
               
                    Order By WorkOrderNumber DESC LIMIT 1];
        }
       
        if(workOrderList != null && workOrderList.size() > 0){
            return workOrderList;
        } else {
            return null;
        }
    }
    
    /** @description : getWorkOrderLineItemById method to get the records of WorkOrderLineItem by Id
    * @param : Set<Id> setOfIds
    * @return : List<WorkOrderLineItem>
    * @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
    */     
    public static List<WorkOrderLineItem> getWorkOrderLineItemById(Set<Id> setOfIds){
        List<WorkOrderLineItem> wOLIList = new List<WorkOrderLineItem>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
            WorkOrderLineItem.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            wOLIList = [SELECT Id, LineItemNumber, BLN_RemedyTaskId__c, WorkTypeId, WorkType.Name, WorkType.BLN_IsMainJob__c, WorkOrderId FROM WorkOrderLineItem WHERE Id IN : setOfIds ];
       	}
       	else{
           wOLIList = [SELECT Id, LineItemNumber, BLN_RemedyTaskId__c, WorkTypeId, WorkType.Name, WorkType.BLN_IsMainJob__c, WorkOrderId FROM WorkOrderLineItem WHERE Id IN : setOfIds];
        }
        
        if(wOLIList!=null && wOLIList.size()>0){
            return wOLIList;
        }
        else{
            return null;   
        }
    }
    
    /** @description : getSAByRemedyTaskId method to get the records of ServiceAppointment by remedyTaskId
    * @param : Set<String> remedyTaskIds
    * @return : List<ServiceAppointment>
    * @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
    */     
    public static List<ServiceAppointment> getSAByRemedyTaskId(Set<String> remedyTaskIds){
        List<ServiceAppointment> sAList = new List<ServiceAppointment>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            sAList = [SELECT Id, ParentRecordId, AppointmentNumber, WorkTypeId, 
                                           WorkType.Name,WorkType.BLN_IsMainJob__c,SchedStartTime, SchedEndTime,FSL__Duration_In_Minutes__c,
                                           BLN_RemedyTaskId__c, Status, EarliestStartTime, ArrivalWindowStartTime,
                                           ArrivalWindowEndTime, BLN_IsBranchAppointment__c, 
                                           BLN_AppointmentCreatedFromRemedy__c, BLN_AppointmentRebook__c FROM ServiceAppointment 
                                           WHERE BLN_RemedyTaskId__c IN : remedyTaskIds ];           
        }
        else{
            sAList = [SELECT Id, ParentRecordId, AppointmentNumber, WorkTypeId, 
                                           WorkType.Name,WorkType.BLN_IsMainJob__c,SchedStartTime, SchedEndTime,FSL__Duration_In_Minutes__c,
                                           BLN_RemedyTaskId__c, Status, EarliestStartTime, ArrivalWindowStartTime,
                                           ArrivalWindowEndTime, BLN_IsBranchAppointment__c, 
                                           BLN_AppointmentCreatedFromRemedy__c, BLN_AppointmentRebook__c FROM ServiceAppointment 
                      WHERE BLN_RemedyTaskId__c IN : remedyTaskIds];
        }
        
        if(sAList!=null && sAList.size()>0){
            return sAList;
        }
        else{
            return null;   
        }
    }
    
     /** @description : getSAByWorkTypeName method to get the records of ServiceAppointment by workTypeName
    * @param : Set<String> workTypeNames
    * @return : List<ServiceAppointment>
    * @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
    */     
    public static List<ServiceAppointment> getSAByWorkTypeName(String remedyJobId, Set<String> workTypeNames){
        List<ServiceAppointment> sAList = new List<ServiceAppointment>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            sAList = [SELECT Id, ParentRecordId, AppointmentNumber, WorkTypeId, 
                                           WorkType.Name, BLN_RemedyTaskType__c, WorkType.BLN_IsMainJob__c,
                                           BLN_RemedyTaskId__c, Status, EarliestStartTime, ArrivalWindowStartTime,
                                           BLN_IsBranchAppointment__c,BLN_AppointmentRebook__c,BLN_IsBookingFailed__c,
                                           ArrivalWindowEndTime,BLN_RemedyJobId__c,BLN_AppointmentCreatedFromRemedy__c
                                           FROM ServiceAppointment 
                                           WHERE WorkType.Name IN:workTypeNames AND BLN_RemedyJobId__c =:remedyJobId ];
        }
        else{
            sAList = [SELECT Id, ParentRecordId, AppointmentNumber, WorkTypeId, 
                                           WorkType.Name, BLN_RemedyTaskType__c, WorkType.BLN_IsMainJob__c,
                                           BLN_RemedyTaskId__c, Status, EarliestStartTime, ArrivalWindowStartTime,
                                           BLN_IsBranchAppointment__c,BLN_AppointmentRebook__c,BLN_IsBookingFailed__c,
                                           ArrivalWindowEndTime,BLN_RemedyJobId__c,BLN_AppointmentCreatedFromRemedy__c
                                           FROM ServiceAppointment 
                      WHERE WorkType.Name IN:workTypeNames AND BLN_RemedyJobId__c =:remedyJobId];
        }
        
        if(sAList!=null && sAList.size()>0){
            return sAList;
        }
        else{
            return null;   
        }
    }
    
    /** @description : getVehicleByRegNum method to get the records of Vehicle__c by BLN_VehicleRegNumber__c
    * @param : String regNumber
    * @return : List<Vehicle__c>
    * @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
    */    
   public static List<BLN_Vehicle__c> getVehicleByRegNum(String regNumber){
        List<BLN_Vehicle__c> vehicleList = new List<BLN_Vehicle__c>();
       //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            BLN_Vehicle__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            vehicleList = [SELECT Id, Name, BLN_MakeOfVehicle__c, BLN_ModelOfVehicle__c, BLN_VehicleRegNumber__c 
                                          FROM BLN_Vehicle__c WHERE BLN_VehicleRegNumber__c =: regNumber LIMIT 1];
        }
        else{
            vehicleList = [SELECT Id, Name, BLN_MakeOfVehicle__c, BLN_ModelOfVehicle__c, BLN_VehicleRegNumber__c 
                           FROM BLN_Vehicle__c WHERE BLN_VehicleRegNumber__c =: regNumber LIMIT 1];
        }
       
        if(vehicleList!=null && vehicleList.size()>0){
            return vehicleList;
        }else{
            return null;
        }
    } 
    
    /** @description : getAccountByIdAndType method to get the records of PersonAccount by Name and Role
    * @param : Set<Id> idSet
    * @return : List<Account>
    */     
    public static List<Account> getAccountByIdAndType(Set<Id> idSet){
        List<Account> accountList = new List<Account>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            accountList = [SELECT Id, FirstName, LastName, Name, personContactId, BLN_PersonAccountType__c, Salutation, Phone FROM Account 
                                     WHERE Id IN : idSet ];
        }
        else{
            accountList = [SELECT Id, FirstName, LastName, Name, personContactId, BLN_PersonAccountType__c, Salutation, Phone FROM Account 
                           WHERE Id IN : idSet];
        }
        
        if(accountList!=null && accountList.size() > 0){
            return accountList;
        }else{
            return null;   
        }
    }
    
    /** @description : getAccountByPersonConId method to get the records of PersonAccount by Name and Role
    * @param : Set<Id> personConIds
    * @return : List<Account>
    */     
    public static List<Account> getAccountByPersonConId(Set<Id> personConIds){
        List<Account> accountList = new List<Account>(); 
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            accountList = [SELECT Id, FirstName, LastName, Name, personContactId, BLN_PersonAccountType__c,PersonMobilePhone,PersonHomePhone,PersonOtherPhone,BLN_PrimaryContactNumber__c, Salutation, Phone FROM Account 
                           WHERE                               personContactId IN : personConIds ];
        }
        else{
            accountList = [SELECT Id, FirstName, LastName, Name, personContactId, BLN_PersonAccountType__c,PersonMobilePhone,PersonHomePhone,PersonOtherPhone,BLN_PrimaryContactNumber__c, Salutation, Phone FROM Account 
                           WHERE personContactId IN : personConIds];
        }
        
        if(accountList!=null && accountList.size() > 0){
            return accountList;
        }else{
            return null;   
        }
    }
    
    public static List<Case> getCaseRecordById(String caseId){
        List<Case> caseList = new List<Case>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            caseList = [SELECT Id, CaseNumber, ContactId, AccountId, BLN_Vehicle__c, Priority,RecordTypeId, RecordType.Name, BLN_Vehicle__r.BLN_SpecialVehicle__c, BLN_ServiceCounty__c, BLN_ServiceCountry__c, BLN_ServiceGeolocation__c, BLN_ServicePostCode__c, BLN_ServiceStreet__c, BLN_ServiceTown__c, BLN_SubType__c,BLN_BufferDays__c, BLN_Vehicle__r.BLN_ModelOfVehicle__c, BLN_Vehicle__r.BLN_MakeOfVehicle__c FROM Case
                        WHERE Id =: caseId  LIMIT 1];   
        }
        else{
            caseList = [SELECT Id, CaseNumber, ContactId, AccountId, BLN_Vehicle__c, Priority, RecordTypeId, RecordType.Name, BLN_Vehicle__r.BLN_SpecialVehicle__c, BLN_ServiceCounty__c, BLN_ServiceCountry__c, BLN_ServiceGeolocation__c, BLN_ServicePostCode__c, BLN_ServiceStreet__c, BLN_ServiceTown__c, BLN_SubType__c,BLN_BufferDays__c, BLN_Vehicle__r.BLN_ModelOfVehicle__c, BLN_Vehicle__r.BLN_MakeOfVehicle__c FROM Case 
                               WHERE Id =: caseId LIMIT 1];       
        }
       
        if(caseList!=null && caseList.size()>0){
            return caseList;
        }else{
            return null;   
        }
    }
    
    /**@description : getServiceAppointments method to get the records of ServiceAppointment by Id
     *@param : String jobAppointmentId
     *@Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107
     *@return : List<ServiceAppointment>    
    */
    public static List<ServiceAppointment> getServiceAppointments(String jobAppointmentId) {
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            saList = [
           SELECT Id, 
           BLN_RemedyTaskId__c, 
           BLN_RemedyProfile__c, 
           DueDate, 
           Duration,
           BLN_IsBranchAppointment__c,
           WorkType.BLN_IsMainJob__c,
           ServiceTerritory.BLN_IsBranch__c,
           ServiceTerritory.OperatingHoursId,
           ServiceTerritory.OperatingHours.Name,
           Status,
           BLN_WorkOrderNumber__c,
           BLN_AssignedServiceResource__c,
           BLN_AssignedServiceResource__r.Name,
           BLN_IsForcedAppointment__c
           FROM ServiceAppointment
           WHERE Id = :jobAppointmentId AND WorkType.BLN_IsMainJob__c = true];
           }
        else{
        saList = [
           SELECT Id, 
           BLN_RemedyTaskId__c, 
           BLN_RemedyProfile__c, 
           DueDate, 
           Duration,
           BLN_IsBranchAppointment__c,
           WorkType.BLN_IsMainJob__c,
           ServiceTerritory.BLN_IsBranch__c,
           ServiceTerritory.OperatingHoursId,
           ServiceTerritory.OperatingHours.Name,
           Status,
           BLN_WorkOrderNumber__c,
           BLN_AssignedServiceResource__c,
           BLN_AssignedServiceResource__r.Name,
           BLN_IsForcedAppointment__c
           FROM ServiceAppointment
           WHERE Id = :jobAppointmentId AND WorkType.BLN_IsMainJob__c = true
                ];
       }
       
       if(!saList.isEmpty() && saList.size() > 0){
            return saList;
       } else {
            return null;
       }
   }
    
    /** @description : getSchedulingPolicyId method to get the records of FSL__Scheduling_Policy__c by Name
    *@param : String name @return Id
    *@Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107
    */
    public static Id getSchedulingPolicyId(String name) {
        FSL__Scheduling_Policy__c policy = new FSL__Scheduling_Policy__c();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            FSL__Scheduling_Policy__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            policy = [SELECT Id FROM FSL__Scheduling_Policy__c WHERE Name = : name LIMIT 1];
        }
        else{
            policy = [SELECT Id FROM FSL__Scheduling_Policy__c WHERE Name = : name LIMIT 1];
        }
       
        if(policy != null && String.isNotBlank(policy.Id)){
            return policy.Id;
        } else {
            return '';
        }
   }
    
    /** @description : getOperatingHourId method to get the records of OperatingHours by Name
    *@param : String name @return OperatingHours
    *@Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107
    */
    public static OperatingHours getOperatingHours(String name) {
        List<OperatingHours> opHours = new List<OperatingHours>();
        opHours = [SELECT Id, Name,TimeZone, (SELECT EndTime, StartTime, Type, DayOfWeek FROM TimeSlots) FROM OperatingHours WHERE Name = : name LIMIT 1];
        if(!opHours.isEmpty() && opHours.size() > 0){
            return opHours[0];
        } else {
            return null;
        }
   }
    
    /** @description : getServiceAppointment method to get the records of ServiceAppointment by jobAppointmentId
    *@param : String jobAppointmentId @return ServiceAppointment
    *@Story : FOUK-110
    */
    public static ServiceAppointment getServiceAppointment(string jobAppointmentId){
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           saList = [SELECT Id, 
                BLN_RemedyJobId__c, 
                WorkTypeId, 
                WorkType.Name, 
                Status,
                BLN_Case__c,
                BLN_AssignedServiceResource__c,
                BLN_AssignedServiceResource__r.Name,
                BLN_RemedyTaskId__c,
                ServiceTerritoryId ,
                ArrivalWindowStartTime,
                ArrivalWindowEndTime,
                ServiceTerritory.Name,
                SchedStartTime ,
                BLN_WorkOrderNumber__c,
                BLN_WorkOrderNumber__r.BLN_Order__c,
                Duration,
                DueDate,
                SchedEndTime,
                ParentRecordId,
                BLN_IsForcedAppointment__c,
                Longitude,
                Latitude,
                BLN_DropOffAppointment__c,
                BLN_IsBookingFailed__c,
                BLN_IsBranchAppointment__c
                FROM ServiceAppointment 
                Where Id =: jobAppointmentId limit 1];
       	}
       	else{
        saList = [SELECT Id, 
                BLN_RemedyJobId__c, 
                WorkTypeId, 
                WorkType.Name, 
                Status,
                BLN_Case__c,
                BLN_AssignedServiceResource__c,
                BLN_AssignedServiceResource__r.Name,
                BLN_RemedyTaskId__c,
                ServiceTerritoryId ,
                ArrivalWindowStartTime,
                ArrivalWindowEndTime,
                ServiceTerritory.Name,
                SchedStartTime ,
                BLN_WorkOrderNumber__c,
                BLN_WorkOrderNumber__r.BLN_Order__c,
                Duration,
                DueDate,
                SchedEndTime,
                ParentRecordId,
                BLN_IsForcedAppointment__c,
                Longitude,
                Latitude,
                BLN_DropOffAppointment__c,
                BLN_IsBookingFailed__c,
                BLN_IsBranchAppointment__c
                FROM ServiceAppointment 
                Where Id =: jobAppointmentId limit 1];

		}              
        
        if(!saList.isEmpty() && saList.size() > 0){
            return saList[0];
        } else {
            return null;
        }
    }
    
    /** @description : getServiceAppointmentForUpdate method to get the records of ServiceAppointment by jobAppointmentId
    *@param : String jobAppointmentId @return ServiceAppointment
    *@Story : FOUK-110
    */
    public static ServiceAppointment getServiceAppointmentForUpdate(string jobAppointmentId){
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        saList = [SELECT Id, 
                BLN_RemedyJobId__c, 
                WorkTypeId, 
                WorkType.Name, 
                Status,
                BLN_Case__c,
                BLN_AssignedServiceResource__c,
                BLN_AssignedServiceResource__r.Name,
                BLN_RemedyTaskId__c,
                ServiceTerritoryId ,
                ArrivalWindowStartTime,
                ArrivalWindowEndTime,
                ServiceTerritory.Name,
                SchedStartTime ,
                BLN_WorkOrderNumber__c,
                BLN_WorkOrderNumber__r.BLN_Order__c,
                Duration,
                DueDate,
                SchedEndTime,
                ParentRecordId,
                BLN_IsForcedAppointment__c,
                Longitude,
                Latitude,
                BLN_DropOffAppointment__c,
                BLN_IsBookingFailed__c,
                BLN_IsBranchAppointment__c
                FROM ServiceAppointment 
                Where Id =: jobAppointmentId limit 1];

        if(!saList.isEmpty() && saList.size() > 0){
            return saList[0];
        } else {
            return null;
        }
    }

    
    
    /** @description : getServiceAppointmentByIds method to get the records of ServiceAppointment by Id
    * @param : Set<Id> setOfIds
    * @return : List<ServiceAppointment>
    * @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
    */     
    public static List<ServiceAppointment> getServiceAppointmentByIds(Set<Id> setOfIds){
        List<ServiceAppointment> sAList = [SELECT Id,
                                           AppointmentNumber,
                                           Status,
                                           ParentRecordId,
                                           BLN_AppointmentRebook__c,
                                           BLN_RebookedServiceAppointment__c,
                                           BLN_RemedyTaskId__c, 
                                           WorkTypeId, 
                                           Duration,
                                           WorkType.Name,
                                           ServiceTerritory.Name,
                                           WorkType.BLN_IsMainJob__c FROM ServiceAppointment WHERE Id IN:setOfIds];        
        if(sAList!=null && sAList.size()>0){
            return sAList;
        } else{
            return null;
        }
    }
    /** @description : getSetOfMainWorkTypes method to set Of Main WorkType Names
     * @return Set<String>**/
    public static Set<String> getSetOfMainWorkTypes(){
        Set<String> setOfMainWT = new Set<String>();
        //setOfMainWT = null;
        for(WorkType wT:[SELECT Id, Name, BLN_IsMainJob__c, EstimatedDuration FROM WorkType WHERE BLN_IsMainJob__c = true]){
            if(wT.Name!=null){
                setOfMainWT.add(wT.Name);
            }
        }
        return setOfMainWT;
    }

    /** @description : getSkillReq method to get the records of SkillRequirement by RelatedRecordId
    *@param : Set<String> setOfRelatedRecIds @return List<SkillRequirement>
    *@Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107
    */
    public static List<SkillRequirement> getSkillReq(Set<String> setOfRelatedRecIds) {
        List<SkillRequirement> srList = [SELECT Id, SkillLevel, SkillId, Skill.MasterLabel, RelatedRecordId FROM SkillRequirement WHERE RelatedRecordId IN:setOfRelatedRecIds];
        
        if(srList!=null && srList.size()>0){
            return srList;
        }else{
            return null; 
        }
    }
    
    /** @description : getCaseConRole method to get the records of CaseContactRole by CasesId
    *@param : Set<String> setOfCasesIds @return List<CaseContactRole>
    *@Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107
    */
    public static List<CaseContactRole> getCaseConRole(Set<String> setOfCasesIds) {
        List<CaseContactRole> caseConRoleList = new List<CaseContactRole>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           CaseContactRole.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           caseConRoleList = [SELECT Id, CasesId, ContactId, Role FROM CaseContactRole WHERE CasesId IN:setOfCasesIds ];
       	}
       	else{
           caseConRoleList = [SELECT Id, CasesId, ContactId, Role FROM CaseContactRole WHERE CasesId IN:setOfCasesIds];
        }
        
        if(caseConRoleList!=null && caseConRoleList.size()>0){
            return caseConRoleList;
        }else{
            return null; 
        }
    }
    
    /** @description : getCCRByCaseIdAndConId method to get the records of CaseContactRole by CasesId
    *@param : String caseId, String contactId @return List<CaseContactRole>
    *@Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107
    */
    public static List<CaseContactRole> getCCRByCaseIdAndConId(String caseId, String contactId) {
        List<CaseContactRole> caseConRoleList = new List<CaseContactRole>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           caseConRoleList = [SELECT Id,CasesId, ContactId from CaseContactRole Where CasesId =:caseId AND ContactId =:contactId LIMIT 1];
       	}
       	else{
           caseConRoleList = [SELECT Id,CasesId, ContactId from CaseContactRole Where CasesId =:caseId AND ContactId =:contactId LIMIT 1];
        }
        if(caseConRoleList!=null && caseConRoleList.size()>0){
            return caseConRoleList;
        }else{
            return null; 
        }
    }
    
    
    /** @description : getPersonAccountByName method to get the records of PersonAccount by Name and Role
    * @param : Set<Id> idSet
    * @return : List<Account>
    */     
    public static List<Account> getPersonAccountByName(String salutation, String fName, String lName, String phone){
        Id personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        List<Account> accountList = new List<Account>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           accountList = [SELECT Id, FirstName, LastName, Name, Phone, personContactId, Salutation FROM Account 
                                     WHERE RecordTypeId =: personAccRecTypeId AND Salutation =: salutation 
                                     AND FirstName =: fName AND LastName =: lName AND Phone =: phone LIMIT 1];
       	}
       	else{
           accountList = [SELECT Id, FirstName, LastName, Name, Phone, personContactId, Salutation FROM Account 
                                     WHERE RecordTypeId =: personAccRecTypeId AND Salutation =: salutation 
                                     AND FirstName =: fName AND LastName =: lName AND Phone =: phone LIMIT 1];
        }
        
        if(accountList!=null && accountList.size()>0){
            return accountList;
        }else{
            return null;   
        }
    }
    
    public static ServiceTerritory getServiceTerritoryByName(String name) {
        ServiceTerritory serviceTerritories = new ServiceTerritory();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
            serviceTerritories = [
            SELECT
                Id, BLN_TerritoryBuffer__c
            FROM
                ServiceTerritory
            WHERE
                Name like :name 
                LIMIT 1
            ];
       	}
       	else{
           serviceTerritories = [
            SELECT
            Id, BLN_TerritoryBuffer__c
            FROM
            ServiceTerritory
            WHERE
            Name like :name
            LIMIT 1
        	];
		}              

        if (serviceTerritories != null) {
            return serviceTerritories;
        } else {
            return null;
        }
    }

    /** @description : getOrderItemByOrder method to get the records of OrderItem by OrderId
    * @param : orderId
    * @return : List<OrderItem>
    */
    public static List<OrderItem> getOrderItemByOrder(String orderId){
        List<OrderItem> oIList = new List<OrderItem>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           OrderItem.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           oIList = [SELECT Id, OrderId, Product2.ProductCode, Product2Id, Product2.BLN_BelronFittingTime__c, Quantity, Product2.BLN_ADASRecalibrationNeeded__c, Product2.BLN_ProductCategory__c, Product2.BLN_ProductStockable__c, Product2.BLN_WMSTracked__c, BLN_IsProductSelected__c FROM OrderItem WHERE OrderId =: orderId ];

       	}
       	else{
           oIList = [SELECT Id, OrderId, Product2.ProductCode, Product2Id, Product2.BLN_BelronFittingTime__c, Quantity, Product2.BLN_ADASRecalibrationNeeded__c, Product2.BLN_ProductCategory__c, Product2.BLN_ProductStockable__c, Product2.BLN_WMSTracked__c, BLN_IsProductSelected__c FROM OrderItem WHERE OrderId =: orderId WITH SECURITY_ENFORCED];
        }
       
        if(oIList != null && oIList.size()>0){
            return oIList;
        }else{
            return null;
        }
    }

    /** @description : getProductByProductCode method to get the records of Product2 by ProductCode
    * @param : productCode
    * @return : List<Product2>
    */
    public static List<Product2> getProductByProductCode(Set<String> productCode){
        List<Product2> productList = new List<Product2>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           Product2.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           productList = [SELECT Id, Name, ProductCode, BLN_BusinessUnitSpecificBranchOnly__c, BLN_NumberofTechnicianNeeded__c, BLN_BelronFittingTime__c, BLN_SkillComplexity__c, BLN_BusinessUnitSpecificAssistDuration__c, BLN_ProductCategory__c, BLN_ADASRecalibrationNeeded__c, BLN_ProductStockable__c, BLN_ProductVanSize__c, BLN_WMSTracked__c,BLN_MDMID__c FROM Product2 WHERE BLN_MDMID__c IN : productCode ]; //Added BLN_SkillComplexity__c field in place of BLN_DifficultyFactor for FOUK-10294
       	}
       	else{
           productList = [SELECT Id, Name, ProductCode, BLN_BusinessUnitSpecificBranchOnly__c, BLN_NumberofTechnicianNeeded__c, BLN_BelronFittingTime__c, BLN_SkillComplexity__c, BLN_BusinessUnitSpecificAssistDuration__c, BLN_ProductCategory__c, BLN_ADASRecalibrationNeeded__c, BLN_ProductStockable__c, BLN_ProductVanSize__c, BLN_WMSTracked__c, BLN_MDMID__c FROM Product2 WHERE BLN_MDMID__c IN : productCode WITH SECURITY_ENFORCED];
        }
       
        if(productList != null && productList.size()>0){
            return productList;
        }else{
            return null;
        }
    }

    /** @description : getServiceTerritoryByAppointmentId method to get the records of ServiceTerritory by Service Appointment Id
    * @param : appointmentId
    * @return : ServiceTerritory
    */
    public static ServiceTerritory getServiceTerritoryByAppointmentId(String appointmentId){
        ServiceAppointment sa = new ServiceAppointment();
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        List<ServiceTerritory> stList = new List<ServiceTerritory>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           saList = [SELECT Id, ServiceTerritoryId FROM ServiceAppointment WHERE Id =: appointmentId LIMIT 1];
            if(!saList.isEmpty() && saList.size() > 0){
                sa = saList[0];
            }
            stList = [SELECT Id, BLN_GUID__c, Name, Street, City, State, PostalCode, Country, BLN_MeetAndGreetTime__c, BLN_IsBranch__c, BLN_Type__c, BLN_IsPrioritized__c, BLN_SchedulingPolicy__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, OperatingHours.Name, BLN_AnyDurationAssist__c, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_ExcludedWorkType__c, BLN_ExcludedProduct__c, BLN_ExcludedProductCategory__c, BLN_MaxGapMin__c FROM ServiceTerritory WHERE Id =: sa.ServiceTerritoryId ];
       	}
        else{
            saList = [SELECT Id, ServiceTerritoryId FROM ServiceAppointment WHERE Id =: appointmentId WITH SECURITY_ENFORCED LIMIT 1];
            if(!saList.isEmpty() && saList.size() > 0){
                sa = saList[0];
            }
            stList = [SELECT Id, BLN_GUID__c, Name, Street, City, State, PostalCode, Country, BLN_MeetAndGreetTime__c, BLN_IsBranch__c, BLN_Type__c, BLN_IsPrioritized__c, BLN_SchedulingPolicy__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, OperatingHours.Name, BLN_AnyDurationAssist__c, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_ExcludedWorkType__c, BLN_ExcludedProduct__c, BLN_ExcludedProductCategory__c, BLN_MaxGapMin__c FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND Id =: sa.ServiceTerritoryId WITH SECURITY_ENFORCED];
        }
                
        if(!stList.isEmpty()){
            return stList[0];
        } else {
            return null;
        }
    }

    /** @description : getWorkType method to get the records of WorkType by Name
    * @param : name
    * @return : List<WorkType>
    */
    public static List<WorkType> getWorkType(Set<String> names){
        List<WorkType> workTypeList = new List<WorkType>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
            workTypeList = [SELECT Id, Name, EstimatedDuration, BLN_IsMainJob__c FROM WorkType WHERE Name IN: names ];
       	}
       	else{
            workTypeList = [SELECT Id, Name, EstimatedDuration, BLN_IsMainJob__c FROM WorkType WHERE Name IN: names WITH SECURITY_ENFORCED];
        }
       
        if(!workTypeList.isEmpty() && workTypeList.size() > 0){
            return workTypeList;
        } else {
            return [SELECT Id, Name, EstimatedDuration, BLN_IsMainJob__c FROM WorkType WHERE Name =: label.BLN_Replacement WITH SECURITY_ENFORCED];
        }
    }

    /** @description : getCaseFromId method to get the records of Case by caseId
    * @param : caseId
    * @return : Case
    */
    public static Case getCaseFromId(String caseId){
        List<Case> caseList = new List<Case>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           caseList = [SELECT Id, AccountId,ContactId, Priority, BLN_Vehicle__r.BLN_SpecialVehicle__c, BLN_ServiceCounty__c, BLN_ServiceCountry__c, BLN_ServiceGeolocation__c, BLN_ServicePostCode__c, BLN_ServiceStreet__c, BLN_ServiceTown__c, BLN_Vehicle__c, BLN_SubType__c,BLN_BufferDays__c, BLN_Vehicle__r.BLN_ModelOfVehicle__c, BLN_Vehicle__r.BLN_MakeOfVehicle__c FROM Case WHERE Id =: caseId ];
       	}
       	else{
           caseList = [SELECT Id, AccountId, ContactId, Priority, BLN_Vehicle__r.BLN_SpecialVehicle__c, BLN_ServiceCounty__c, BLN_ServiceCountry__c, BLN_ServiceGeolocation__c, BLN_ServicePostCode__c, BLN_ServiceStreet__c, BLN_ServiceTown__c, BLN_Vehicle__c, BLN_SubType__c,BLN_BufferDays__c, BLN_Vehicle__r.BLN_ModelOfVehicle__c, BLN_Vehicle__r.BLN_MakeOfVehicle__c FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED];
        }
       
        if(!caseList.isEmpty() && caseList.size() > 0){
            return caseList[0];
        } else {
            return null;
        }
    }


    /** @description : getServiceTerritoryFromGUID method to get the records of ServiceTerritory by OrderId
    * @param : guid
    * @return : ServiceTerritory 
    */
    public static ServiceTerritory getServiceTerritoryFromGUID(String guid){
        List<ServiceTerritory> territoryList = new List<ServiceTerritory>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           territoryList =  [SELECT Id, BLN_GUID__c, Name, Street, City, State, PostalCode, Country, BLN_MeetAndGreetTime__c, BLN_IsBranch__c, BLN_Type__c, BLN_IsPrioritized__c, BLN_SchedulingPolicy__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, OperatingHours.Name, BLN_AnyDurationAssist__c, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_ExcludedWorkType__c, BLN_ExcludedProduct__c, BLN_ExcludedProductCategory__c, BLN_MaxGapMin__c FROM ServiceTerritory WHERE BLN_GUID__c =:guid LIMIT 1];//: guid and IsActive = true 
       	}
       	else{
           territoryList =  [SELECT Id, BLN_GUID__c, Name, Street, City, State, PostalCode, Country, BLN_MeetAndGreetTime__c, BLN_IsBranch__c, BLN_Type__c, BLN_IsPrioritized__c, BLN_SchedulingPolicy__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, OperatingHours.Name, BLN_AnyDurationAssist__c, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_ExcludedWorkType__c, BLN_ExcludedProduct__c, BLN_ExcludedProductCategory__c, BLN_MaxGapMin__c FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND BLN_GUID__c =: guid WITH SECURITY_ENFORCED LIMIT 1];
        }

        if(!territoryList.isEmpty() && territoryList.size() > 0){
            return territoryList[0];
        } else {
            return null;
        }
    }

    /** @description : getServiceTerritoryFromOrgID method to get the records of ServiceTerritory by OrderId
    * @param : guid
    * @return : ServiceTerritory 
    */
    public static ServiceTerritory getServiceTerritoryFromOrgID(String orgid){
        List<ServiceTerritory> territoryList = new List<ServiceTerritory>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           territoryList =  [SELECT Id, BLN_GUID__c, Name, Street, City, State, PostalCode, Country, BLN_MeetAndGreetTime__c, BLN_IsBranch__c, BLN_Type__c, BLN_IsPrioritized__c, BLN_SchedulingPolicy__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, OperatingHours.Name, BLN_AnyDurationAssist__c, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_ExcludedWorkType__c, BLN_ExcludedProduct__c, BLN_ExcludedProductCategory__c, BLN_MaxGapMin__c, BLN_OrgCodeLocation__c FROM ServiceTerritory WHERE BLN_OrgCodeLocation__c  =:orgid LIMIT 1];//: guid and IsActive = true 
       	}
       	else{
           territoryList =  [SELECT Id, BLN_GUID__c, Name, Street, City, State, PostalCode, Country, BLN_MeetAndGreetTime__c, BLN_IsBranch__c, BLN_Type__c, BLN_IsPrioritized__c, BLN_SchedulingPolicy__c, BLN_SplitReplaceAndRecalibration__c, OperatingHoursId, OperatingHours.Name, BLN_AnyDurationAssist__c, BLN_DropOffWindowDuration__c, BLN_CollectionWindowDuration__c, BLN_ExcludedWorkType__c, BLN_ExcludedProduct__c, BLN_ExcludedProductCategory__c, BLN_MaxGapMin__c, BLN_OrgCodeLocation__c  FROM ServiceTerritory WHERE BLN_ConsiderforR1__c = false AND BLN_OrgCodeLocation__c  =: orgid WITH SECURITY_ENFORCED LIMIT 1];
        }

        if(!territoryList.isEmpty() && territoryList.size() > 0){
            return territoryList[0];
        } else {
            return null;
        }
    }
    
    /** @description : getEndTimeFromTimeSlot method to get the records of TimeSlot by OperatingHoursId and DayOfWeek
    * @param : OperatingHoursId, DayOfWeek
    * @return : TimeSlot
    */
    public static TimeSlot getEndTimeFromTimeSlot(String operatingHourId, String dayOfWeek){
        List<TimeSlot> timeSlotList = new List<TimeSlot>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            TimeSlot.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            timeSlotList = [SELECT Id, StartTime, EndTime, DayOfWeek, OperatingHoursId FROM TimeSlot WHERE OperatingHoursId =: operatingHourId AND DayOfWeek =: dayOfWeek ORDER BY EndTime DESC LIMIT 1];
            if(timeSlotList.isEmpty() || timeslotList == null){
                timeSlotList = [SELECT Id, StartTime, EndTime, DayOfWeek, OperatingHoursId FROM TimeSlot WHERE OperatingHoursId =: operatingHourId ORDER BY EndTime DESC LIMIT 1];    
            }
        }
        else{
            timeSlotList = [SELECT Id, StartTime, EndTime, DayOfWeek, OperatingHoursId FROM TimeSlot WHERE OperatingHoursId =: operatingHourId AND DayOfWeek =: dayOfWeek WITH SECURITY_ENFORCED ORDER BY EndTime DESC LIMIT 1];
            if(timeSlotList.isEmpty() || timeslotList == null){
                timeSlotList = [SELECT Id, StartTime, EndTime, DayOfWeek, OperatingHoursId FROM TimeSlot WHERE OperatingHoursId =: operatingHourId WITH SECURITY_ENFORCED ORDER BY EndTime DESC LIMIT 1];    
            }
        }
        return timeSlotList[0];
    }
    
    
    /** @description : getStartTimeFromTimeSlot method to get the records of TimeSlot by OperatingHoursId and DayOfWeek
    * @param : OperatingHoursId, DayOfWeek
    * @return : TimeSlot
    */
    /** @description : getStartTimeFromTimeSlot method to get the records of TimeSlot by OperatingHoursId and DayOfWeek
    * @param : OperatingHoursId, DayOfWeek
    * @return : TimeSlot
    */
    public static TimeSlot getStartTimeFromTimeSlot(String operatingHourId, String dayOfWeek){
        List<TimeSlot> timeSlotList = new List<TimeSlot>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            TimeSlot.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            timeSlotList = [SELECT Id, StartTime, EndTime, DayOfWeek, OperatingHoursId FROM TimeSlot WHERE OperatingHoursId =: operatingHourId AND DayOfWeek =: dayOfWeek ORDER BY StartTime ASC LIMIT 1];
            if(timeSlotList.isEmpty() || timeslotList == null){
                timeSlotList = [SELECT Id, StartTime, EndTime, DayOfWeek, OperatingHoursId FROM TimeSlot WHERE OperatingHoursId =: operatingHourId ORDER BY StartTime DESC LIMIT 1];    
            }
        }
        else{
            timeSlotList = [SELECT Id, StartTime, EndTime, DayOfWeek, OperatingHoursId FROM TimeSlot WHERE OperatingHoursId =: operatingHourId AND DayOfWeek =: dayOfWeek WITH SECURITY_ENFORCED ORDER BY StartTime ASC LIMIT 1];
            if(timeSlotList.isEmpty() || timeslotList == null){
                timeSlotList = [SELECT Id, StartTime, EndTime, DayOfWeek, OperatingHoursId FROM TimeSlot WHERE OperatingHoursId =: operatingHourId WITH SECURITY_ENFORCED ORDER BY StartTime DESC LIMIT 1];    
            }
        }
        return timeSlotList[0];
    }
    
    /** @description : getProdFromId method to get the records of Product by productIdSet
    * @param : productIdSet
    * @return : Product2
    */
    public static List<Product2> getProdFromId(Set<String> productIdSet){
        List<Product2> productList = new List<Product2>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           productList = [Select Id, BLN_BusinessUnitSpecificAssistDuration__c, BLN_BusinessUnitSpecificBranchOnly__c, BLN_BelronFittingTime__c, BLN_ProductCategory__c, BLN_SkillComplexity__c, BLN_ADASRecalibrationNeeded__c,BLN_ProductVanSize__c from Product2 where Id IN:productIdSet ]; //Added BLN_SkillComplexity__c field in place of BLN_DifficultyFactor for FOUK-10294
       	}
       	else{
           productList = [Select Id, BLN_BusinessUnitSpecificAssistDuration__c, BLN_BusinessUnitSpecificBranchOnly__c, BLN_BelronFittingTime__c, BLN_ProductCategory__c, BLN_SkillComplexity__c, BLN_ADASRecalibrationNeeded__c,BLN_ProductVanSize__c from Product2 where Id IN:productIdSet WITH SECURITY_ENFORCED];
        }
       
        if(!productList.isEmpty() && productList.size() > 0){
            return productList;
        } else {
            return null;
        }
    }
    
    /** @description : getPriceBookEntryMap method to get the records of PriceBookEntry by prodList
    * @param : prodList
    * @return : List<PriceBookEntry>
    */
    public static List<PriceBookEntry> getPriceBookEntryMap(List<Product2> prodList){
        List<PriceBookEntry> priceBookEntryList = new List<PriceBookEntry>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           PriceBookEntry.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           priceBookEntryList = [SELECT Id, Product2Id FROM PriceBookEntry WHERE Product2Id IN : prodList ];
       	}
       	else{
           priceBookEntryList = [SELECT Id, Product2Id FROM PriceBookEntry WHERE Product2Id IN : prodList WITH SECURITY_ENFORCED];
        }
       
        if (!priceBookEntryList.isEmpty() && priceBookEntryList.size() > 0) {
            return priceBookEntryList;
        } else {
            return null;
        }
    }
    
     /** @description : getStandardPriceBook method to get the records of Pricebook2 by check
    * @param : check
    * @return : Pricebook2
    */
    public static Pricebook2 getStandardPriceBook(Boolean check, String name){
        List<Pricebook2> priceBookList = new List<Pricebook2>();
        priceBookList = [SELECT Id, Name FROM Pricebook2 WHERE isStandard =: check limit 1];
        if (!priceBookList.isEmpty() && priceBookList.size() > 0) {
            return priceBookList[0];
        } else {
            return null;
        }
    }

    /** @description : getSkills method to get the records of Skills
    * @param : 
    * @return : Skill
    */
    public static List<Skill> getSkills(){
        List<Skill> skillsList = new List<Skill>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           Skill.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           skillsList = [SELECT Id, DeveloperName, MasterLabel FROM Skill ];
       	}
       	else{
           skillsList = [SELECT Id, DeveloperName, MasterLabel FROM Skill WITH SECURITY_ENFORCED];
        }
       
        if(!skillsList.isEmpty() && skillsList.size() > 0){
            return skillsList;
        } else {
            return null;
        }
    }
    
    /** @description : getOrderByOrderId method to get the records of Order by orderId
    * @param : orderId
    * @return : Order
    */
    public static Order getOrderByOrderId(Id orderId){
        List<Order> orderList = new List<Order>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           Order.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           orderList = [SELECT Id, BLN_IsDropOff__c FROM Order where Id =: orderId LIMIT 1];
       	}
       	else{
           orderList = [SELECT Id, BLN_IsDropOff__c FROM Order where Id =: orderId WITH SECURITY_ENFORCED LIMIT 1];
        }
       
        if(!orderList.isEmpty() && orderList.size() > 0){
            return orderList[0];
        } else {
            return null;
        }
    }
    
    /** @description : getWorkTypeById method to get the records of WorkType by Id
    * @param : wtIdSet
    * @return : List<WorkType>
    */
    public static List<WorkType> getWorkTypeById(Set<Id> wtIdSet){
        List<WorkType> workTypeList = new List<WorkType>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           workTypeList = [SELECT Id, Name, BLN_IsMainJob__c FROM WorkType where Id IN : wtIdSet ];
       	}
       	else{
            workTypeList = [SELECT Id, Name, BLN_IsMainJob__c FROM WorkType where Id IN : wtIdSet WITH SECURITY_ENFORCED];
        }
        
        if (!workTypeList.isEmpty() && workTypeList.size() > 0) {
            return workTypeList;
        } else {
            return null;
        }
    }
    
    /** @description : getBUMetadata method to get the records of BU Metadata by DeveloperName
    * @param : developerName
    * @return : BLN_BU__mdt
    */
    public static BLN_BU__mdt getBUMetadata(String developerName){
        List<BLN_BU__mdt> metadataList = new List<BLN_BU__mdt>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           BLN_BU__mdt.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           metadataList = [SELECT Id, DeveloperName, Label, BLN_Country__c, BLN_BUSpecificStockCollectionTime__c, BLN_BUSpecificDefaultAssistDuration__c FROM BLN_BU__mdt WHERE DeveloperName =: developerName limit 1];
       	}
       	else{
           metadataList = [SELECT Id, DeveloperName, Label, BLN_Country__c, BLN_BUSpecificStockCollectionTime__c, BLN_BUSpecificDefaultAssistDuration__c FROM BLN_BU__mdt WHERE DeveloperName =: developerName WITH SECURITY_ENFORCED limit 1];
        }
       
        if (!metadataList.isEmpty() && metadataList.size() > 0) {
            return metadataList[0];
        } else {
            return null;
        }
    }
    
    /** @description : getWorkOrderById method to get the records of WorkOrder By ID
    * @param : Id
    * @return : WorkOrder
    */
    public static WorkOrder getWorkOrderById(String id){
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           workOrderList = [SELECT Id, WorkOrderNumber, WorkTypeId, WorkType.Name FROM WorkOrder WHERE Id =: Id ];
       	}
       	else{
           workOrderList = [SELECT Id, WorkOrderNumber, WorkTypeId, WorkType.Name FROM WorkOrder WHERE Id =: Id WITH SECURITY_ENFORCED];
        }
        
        if (!workOrderList.isEmpty()) {
            return workOrderList[0];
        } else {
            return null;
        }
    } 

    /** @description : getSchedulingPolicyName method to get the record of FSL__Scheduling_Policy__c by Name
    * @param : schPolicy
    * @return : FSL__Scheduling_Policy__c
    */
    public static FSL__Scheduling_Policy__c getSchedulingPolicyName(String schPolicy){
        List<FSL__Scheduling_Policy__c> policyList = new List<FSL__Scheduling_Policy__c>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           policyList = [SELECT Id, Name FROM FSL__Scheduling_Policy__c WHERE Name =: schPolicy Limit 1];
       	}
       	else{
           policyList = [SELECT Id, Name FROM FSL__Scheduling_Policy__c WHERE Name =: schPolicy WITH SECURITY_ENFORCED Limit 1];
        }
        
        if (!policyList.isEmpty() && policyList.size() > 0) {
            return policyList[0];
        } else {
            return null;
        }
    } 
       
    /** @description : getLocationByGuid method to get the record of Location by GUID
    * @param : guid
    * @return : Location
    */
    public static Schema.Location getLocationByGuid(String guid){
        List<Schema.Location> locationList = new List<Schema.Location>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           Location.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           locationList = [SELECT Id, BLN_PrimarySourceCollectId__c, BLN_OrgCodeLocation__c , VisitorAddressId, VisitorAddress.Street, VisitorAddress.City, VisitorAddress.State, VisitorAddress.PostalCode, VisitorAddress.Country FROM Location WHERE BLN_GUID__c =: guid LIMIT 1];
       	}
       	else{
           locationList = [SELECT Id, BLN_PrimarySourceCollectId__c, BLN_OrgCodeLocation__c , VisitorAddressId, VisitorAddress.Street, VisitorAddress.City, VisitorAddress.State, VisitorAddress.PostalCode, VisitorAddress.Country FROM Location WHERE BLN_GUID__c =: guid WITH SECURITY_ENFORCED LIMIT 1];
        }
       
        if (!locationList.isEmpty() && locationList.size() > 0) {
            return locationList[0];
        } else {
            return null;
        }
    } 
       
    /** @description : getLocationByPrimarySourceCollectId method to get the record of Location by primarySourceCollectId
    * @param : primarySourceCollectId
    * @return : Location
    */
    public static Schema.Location getLocationByPrimarySourceCollectId(String primarySourceCollectId){
        List<Schema.Location> locationList = new List<Schema.Location>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           locationList =  [SELECT Id, BLN_PrimarySourceCollectId__c, BLN_OrgCodeLocation__c, VisitorAddressId, VisitorAddress.Street, VisitorAddress.City, VisitorAddress.State, VisitorAddress.PostalCode, VisitorAddress.Country FROM Location WHERE BLN_OrgCodeLocation__c =: primarySourceCollectId  LIMIT 1];
       	}
       	else{
           locationList =  [SELECT Id, BLN_PrimarySourceCollectId__c, BLN_OrgCodeLocation__c, VisitorAddressId, VisitorAddress.Street, VisitorAddress.City, VisitorAddress.State, VisitorAddress.PostalCode, VisitorAddress.Country FROM Location WHERE BLN_PrimarySourceCollectId__c =: primarySourceCollectId WITH SECURITY_ENFORCED LIMIT 1];
        }
       
        if (!locationList.isEmpty() && locationList.size() > 0) {
            return locationList[0];
        } else {
            return null;
        }
    } 

    /** @description : getLocationByGuid method to get the record of Location by GUID
    * @param : orgid
    * @return : Location
    */
    public static Schema.Location getLocationByOrgid(String orgid){
        List<Schema.Location> locationList = new List<Schema.Location>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           Location.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           locationList = [SELECT Id, BLN_PrimarySourceCollectId__c, BLN_OrgCodeLocation__c , VisitorAddressId, VisitorAddress.Street, VisitorAddress.City, VisitorAddress.State, VisitorAddress.PostalCode, VisitorAddress.Country FROM Location WHERE BLN_OrgCodeLocation__c  =: orgid LIMIT 1];
       	}
       	else{
           locationList = [SELECT Id, BLN_PrimarySourceCollectId__c, BLN_OrgCodeLocation__c , VisitorAddressId, VisitorAddress.Street, VisitorAddress.City, VisitorAddress.State, VisitorAddress.PostalCode, VisitorAddress.Country FROM Location WHERE BLN_OrgCodeLocation__c  =: orgid WITH SECURITY_ENFORCED LIMIT 1];
        }
       
        if (!locationList.isEmpty() && locationList.size() > 0) {
            return locationList[0];
        } else {
            return null;
        }
    } 
       
    /** @description : getServiceReportLayoutByName method to get the record of ServiceReportLayout by developerName
    * @param : developerName
    * @return : ServiceReportLayout
    */
    public static ServiceReportLayout getServiceReportLayoutByName(String developerName){
        List<ServiceReportLayout> serviceReportList = new List<ServiceReportLayout>();
        serviceReportList = [SELECT Id, DeveloperName, MasterLabel FROM ServiceReportLayout WHERE DeveloperName =: developerName LIMIT 1];
        if (!serviceReportList.isEmpty() && serviceReportList.size() > 0) {
            return serviceReportList[0];
        } else {
            return null;
        }
    }

    /** @description : getTimeDependencyByAppointmentId method to get the records of FSL__Time_Dependency__c by ServiceAppointmentId
    * @param : appointmentId
    * @return : FSL__Time_Dependency__c
    */
    public static List<FSL__Time_Dependency__c> getTimeDependencyByAppointmentId(String appointmentId){
        List<FSL__Time_Dependency__c> dependencyList = new List<FSL__Time_Dependency__c>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           FSL__Time_Dependency__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           dependencyList = [SELECT Id, Name, FSL__Service_Appointment_1__c,FSL__Service_Appointment_2__c FROM FSL__Time_Dependency__c WHERE FSL__Service_Appointment_1__c =: appointmentId ];
       	}
       	else{
           dependencyList = [SELECT Id, Name, FSL__Service_Appointment_1__c,FSL__Service_Appointment_2__c FROM FSL__Time_Dependency__c WHERE FSL__Service_Appointment_1__c =: appointmentId OR FSL__Service_Appointment_2__c =: appointmentId WITH SECURITY_ENFORCED];
        }
       
        if (!dependencyList.isEmpty() && dependencyList.size() > 0) {
            return dependencyList;
        } else {
            return null;
        }
    }

    public static List<FSL__Time_Dependency__c> getTimeDependencyByAppointmentIdSet(Set<Id> appointmentId){
        List<FSL__Time_Dependency__c> dependencyList = new List<FSL__Time_Dependency__c>();
        dependencyList = [SELECT Id, Name, FSL__Service_Appointment_1__c,FSL__Service_Appointment_2__c FROM FSL__Time_Dependency__c WHERE FSL__Service_Appointment_1__c IN: appointmentId OR FSL__Service_Appointment_2__c IN: appointmentId WITH SECURITY_ENFORCED];
        if (!dependencyList.isEmpty() && dependencyList.size() > 0) {
            return dependencyList;
        } else {
            return null;
        }
    }


    /** @description : getServiceAppointmentByWorkOrder method to get the record of ServiceAppointment by WorkOrder
    * @param : id, workOrderId
    * @return : ServiceAppointment
    */
    public static List<ServiceAppointment> getServiceAppointmentByWorkOrder(String workOrderId){
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           saList = [SELECT Id, AppointmentNumber, BLN_WorkOrderNumber__c, Duration, WorkType.Name, ArrivalWindowStartTime, ArrivalWindowEndTime FROM ServiceAppointment WHERE BLN_WorkOrderNumber__c =: workOrderId AND (Status = 'None' OR Status = 'Open' OR Status = 'Pending') ];
       	}
       	else{
           saList = [SELECT Id, AppointmentNumber, BLN_WorkOrderNumber__c, Duration, WorkType.Name, ArrivalWindowStartTime, ArrivalWindowEndTime FROM ServiceAppointment WHERE BLN_WorkOrderNumber__c =: workOrderId AND (Status = 'None' OR Status = 'Open' OR Status = 'Pending') WITH SECURITY_ENFORCED];
        }
       
        if (!saList.isEmpty() && saList.size() > 0) {
            return saList;
        } else {
            return null;
        }
    }

    /** @description : getWeatherGuardProductMetadata method to get the records of WeatherGuardProduct Metadata
    * @param : N/A
    * @return : BLN_WeatherGuardAppointmentConfiguration__mdt
    */
    public static BLN_WeatherGuardAppointmentConfiguration__mdt getWeatherGuardProductMetadata(){
        List<BLN_WeatherGuardAppointmentConfiguration__mdt> metadataList = new List<BLN_WeatherGuardAppointmentConfiguration__mdt>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           BLN_WeatherGuardAppointmentConfiguration__mdt.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           metadataList = [SELECT Id, BLN_ProductCategory__c, BLN_ProductCode__c FROM BLN_WeatherGuardAppointmentConfiguration__mdt LIMIT 1];
       	}
       	else{
           metadataList = [SELECT Id, BLN_ProductCategory__c, BLN_ProductCode__c FROM BLN_WeatherGuardAppointmentConfiguration__mdt WITH SECURITY_ENFORCED LIMIT 1];
        }
       
        if (!metadataList.isEmpty() && metadataList.size() > 0) {
            return metadataList[0];
        } else {
            return null;
        }
    }
    
    /** @description : getServAppShortningConfigMetadata method to get AppointmentShorteningConfiguration Metadata
    * @param : N/A
    * @return : BLN_AppointmentShorteningConfiguration__mdt
    */
    public static BLN_AppointmentShorteningConfiguration__mdt getServAppShortningConfigMetadata(){
        List<BLN_AppointmentShorteningConfiguration__mdt> metadataList = new List<BLN_AppointmentShorteningConfiguration__mdt>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           BLN_AppointmentShorteningConfiguration__mdt.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           metadataList =  [SELECT BLN_RoundedDurationInMinutes__c, BLN_HorizonInHours__c, BLN_ArrivalStartTimeAdjustmentInMinutes__c, BLN_ShorteningWindowInMinutes__c, BLN_BusinessUnit__c, BLN_Active__c, BLN_AllowVirtualTech__c, BLN_MaxPlnDurationInMins__c, BLN_MaxSchDurationInMins__c FROM BLN_AppointmentShorteningConfiguration__mdt LIMIT 1];
       	}
       	else{
           metadataList =  [SELECT BLN_RoundedDurationInMinutes__c, BLN_HorizonInHours__c, BLN_ArrivalStartTimeAdjustmentInMinutes__c, BLN_ShorteningWindowInMinutes__c, BLN_BusinessUnit__c, BLN_Active__c, BLN_AllowVirtualTech__c, BLN_MaxPlnDurationInMins__c, BLN_MaxSchDurationInMins__c FROM BLN_AppointmentShorteningConfiguration__mdt WITH SECURITY_ENFORCED LIMIT 1];
        }
        
        if (!metadataList.isEmpty() && metadataList.size() > 0) {
            return metadataList[0];
        } else {
            return null;
        }
    }

    /** @description : getCorporateRecordTypes method to get Corporate RecordTypes
    * @param : List<RecordType>
    * @return : List<RecordType>
    */
    public static List<RecordType> getCorporateRecordTypes(List<String> recTypeList){
        List<RecordType> recordTypeList = new List<RecordType>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            recordTypeList = [SELECT Id, Name FROM RecordType WHERE NAME IN : recTypeList ];
        }
        else{
        recordTypeList = [SELECT Id, Name FROM RecordType WHERE NAME IN : recTypeList WITH SECURITY_ENFORCED];
        }
        if (!recordTypeList.isEmpty() && recordTypeList.size() > 0) {
            return recordTypeList;
        } else {
            return null;
        }
    }

    /** @description : getWorkOrderFromCase method to get Existing Work Order record using under the case
    * @param : caseId
    * @return : List<WorkOrder>
    */
    public static List<WorkOrder> getWorkOrderFromCase(String caseId){
        List<WorkOrder> woList = new List<WorkOrder>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           woList = [SELECT Id, WorkOrderNumber, Status, CaseId, WorkTypeId, WorkType.Name FROM WorkOrder WHERE CaseId =: caseId ];
       	}
       	else{
           woList = [SELECT Id, WorkOrderNumber, Status, CaseId, WorkTypeId, WorkType.Name FROM WorkOrder WHERE CaseId =: caseId WITH SECURITY_ENFORCED];
        }
       
        if (!woList.isEmpty() && woList.size() > 0) {
            return woList;
        } else {
            return null;
        }
    }

    public static List<WorkOrderLineItem> getWoliFromWorkOrderId(String workOrderId){
        List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           woliList = [SELECT Id, WorkOrderId, WorkTypeId, WorkType.Name FROM WorkOrderLineItem WHERE WorkOrderId =: workOrderId ];
       	}
       	else{
			woliList = [SELECT Id, WorkOrderId, WorkTypeId, WorkType.Name FROM WorkOrderLineItem WHERE WorkOrderId =: workOrderId WITH SECURITY_ENFORCED];
               	}
       
        if (!woliList.isEmpty() && woliList.size() > 0) {
            return woliList;
        } else {
            return null;
        }
    }

    public static WorkType getWorkTypeFromWorkOrderId(String workOrderId){
        WorkOrder wo = new WorkOrder();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
        If(isPortalUser){
            wo = [SELECT Id, WorkTypeId, WorkType.Name FROM WorkOrder WHERE Id =: workOrderId LIMIT 1];
            if(String.isNotBlank(wo.WorkTypeId)){
                return [SELECT Id, Name FROM WorkType WHERE Id =: wo.WorkTypeId  LIMIT 1];
            } else {
                return null;
            }
        }
        else{
            wo = [SELECT Id, WorkTypeId, WorkType.Name FROM WorkOrder WHERE Id =: workOrderId WITH SECURITY_ENFORCED LIMIT 1];
        if(String.isNotBlank(wo.WorkTypeId)){
            return [SELECT Id, Name FROM WorkType WHERE Id =: wo.WorkTypeId WITH SECURITY_ENFORCED LIMIT 1];
        } else {
            return null;
        }
    }
    }

    public static List<ProductRequired> getPRListUsingWoliIdSet(Set<String> woliIdSet){
        List<ProductRequired> prList = new List<ProductRequired>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           ProductRequired.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
           prList = [SELECT Id, ParentRecordId, Product2Id FROM ProductRequired WHERE ParentRecordId IN : woliIdSet ];
       	}
       	else{
           prList = [SELECT Id, ParentRecordId, Product2Id FROM ProductRequired WHERE ParentRecordId IN : woliIdSet WITH SECURITY_ENFORCED];
        }
        
        if (!prList.isEmpty() && prList.size() > 0) {
            return prList;
        } else {
            return null;
        }
    }

    public static WorkType getWorkTypeById(String id){
        List<WorkType> workTypeList = new List<WorkType>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
           workTypeList = [SELECT Id, Name FROM WorkType WHERE Id =: id LIMIT 1];
       	}
       	else{
           workTypeList = [SELECT Id, Name FROM WorkType WHERE Id =: id WITH SECURITY_ENFORCED LIMIT 1];
        }
       
        if (!workTypeList.isEmpty() && workTypeList.size() > 0) {
            return workTypeList[0];
        } else {
            return null;
        }
    }
    
    /** @description : getPortalUserProfile method to get portal user for Portal Login Check
    * @param : No param
    * @return : Boolean
    */
    public static Boolean getPortalUserProfile(){
        Boolean result = (UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'CspLitePortal' || UserInfo.getUserType() == 'PowerCustomerSuccess') ? true : false;
       	return result;
    }
}