/** @description : The Service class Remedy Webservice used for BLN_WebservicePrepData
*  @author: Ayush Singh(PwC IN)
*  @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
*  @CreatedDate : 31/05/2023
*/
public class BLN_HandlerWebservice {
    
    /** @description : getWorkType method to get the records of WorkType by name
    * @param : String name
    * @return : List<WorkType> 
    */ 
    public static List<WorkType> getWorkType(String name){
        return BLN_QueryHandlerWebservice.selectByNameOrNumber('WorkType', name);
    }
    
    /** @description : getWorkType method to get the records of WorkType by name
    * @param : Set<String> name
    * @return : List<WorkType>
    */ 
    public static List<WorkType> getWorkType(Set<String> nameSet){
        return BLN_QueryHandlerWebservice.selectByNameOrNumber('WorkType', nameSet);
    }    
    
    /** @description : getDistrictServiceTerritory method to get the records of ServiceTerritory by name and of District Type
    * @param : String name
    * @return : List<ServiceTerritory>
    */ 
    public static List<ServiceTerritory> getDistrictServiceTerritory(Set<String> names){
        String sAType = 'District';
        return getServiceTerritoryByType(names, sAType);
    }
    
    /** @description : getServiceTerritoryByType method to get the records of ServiceTerritory by name and Type
    * @param : String name, String sAType
    * @return : List<ServiceTerritory>
    */ 
    public static List<ServiceTerritory> getServiceTerritoryByType(Set<String> names, String sAType){
            return BLN_QueryHandlerWebservice.getServiceTerritoryByType(names,sAType);
    }  
    
    /** @description : getWOByRemedyJobId method to get the records of WorkOrder by remedyJobId
    * @param : String remedyJobId
    * @return : List<WorkOrder>
    */    
    public static List<WorkOrder> getWOByRemedyJobId(String remedyJobId){
            return BLN_QueryHandlerWebservice.getWOByRemedyJobId(remedyJobId);
    }
    
    /** @description : getWOByLIKERemedyJobId method to get the records of WorkOrder by remedyJobId
    * @param : String remedyJobId
    * @return : List<WorkOrder>
    */    
    public static List<WorkOrder> getWOByLikeRemedyJobId(String remedyJobId){
            return BLN_QueryHandlerWebservice.getWOByLikeRemedyJobId(remedyJobId);
    }
    
    /** @description : getWorkOrderLineItemById method to get the records of WorkOrderLineItem by Id
    * @param : Set<Id> setOfIds
    * @return : List<WorkOrderLineItem>
    */     
    public static List<WorkOrderLineItem> getWorkOrderLineItemById(Set<Id> setOfIds){
            return BLN_QueryHandlerWebservice.getWorkOrderLineItemById(setOfIds);
    }
    
    /** @description : getSAByRemedyTaskId method to get the records of ServiceAppointment by remedyTaskId
    * @param : Set<String> remedyTaskIds
    * @return : List<ServiceAppointment>
    */     
    public static List<ServiceAppointment> getSAByRemedyTaskId(Set<String> remedyTaskIds){
            return BLN_QueryHandlerWebservice.getSAByRemedyTaskId(remedyTaskIds);
    }
    
    /** @description : getSAByWorkTypeName method to get the records of ServiceAppointment by workTypeName
    * @param : Set<String> workTypeNames
    * @return : List<ServiceAppointment>
    */     
    public static List<ServiceAppointment> getSAByWorkTypeName(String remedyJobId, Set<String> workTypeNames){
        return BLN_QueryHandlerWebservice.getSAByWorkTypeName(remedyJobId, workTypeNames);   
    }
    
     /** @description : getServiceAppointmentByIds method to get the records of ServiceAppointment by Id
    * @param : Set<Id> setOfIds
    * @return : List<ServiceAppointment>
    */     
    public static List<ServiceAppointment> getServiceAppointmentByIds(Set<Id> setOfIds){
            return BLN_QueryHandlerWebservice.getServiceAppointmentByIds(setOfIds);
    }
    
    /** @description : getDummyPersonAcc method to get the records of Account by Name
    * @param : String name
    * @return : List<Account>
    */    
    public static List<Account> getDummyPersonAcc(String name){

        return BLN_QueryHandlerWebservice.selectByNameOrNumber('Account', name);
    }
    
    /** @description : getSchedulingPolicy method to get the records of FSL__Scheduling_Policy__c by Name
    * @param : String name
    * @return : List<FSL__Scheduling_Policy__c>
    */    
    public static List<FSL__Scheduling_Policy__c> getSchedulingPolicy(String name){
        return BLN_QueryHandlerWebservice.selectByNameOrNumber('FSL__Scheduling_Policy__c', name);
    }
    
    /** @description : getVehicleByRegNum method to get the records of BLN_Vehicle__c by BLN_VehicleRegNumber__c
    * @param : String regNumber
    * @return : List<BLN_Vehicle__c>
    */    
    public static List<BLN_Vehicle__c> getVehicleByRegNum(String regNumber){
            return BLN_QueryHandlerWebservice.getVehicleByRegNum(regNumber);
    } 
    
     /** @description : getMainSAByWOId method to get the Main ServiceAppointment by workOrderId
    * @param : String workOrderId
    * @return : List<ServiceAppointment>
    */     
    //public static List<ServiceAppointment> getMainSAByWOId(String workOrderId){
        //return BLN_QueryHandlerWebservice.getMainSAByWOId(workOrderId);
   // }

    public static List<Case> getCaseRecordById(String caseId){
        return BLN_QueryHandlerWebservice.getCaseRecordById(caseId);
    }
    
	/** @description : getAccountById method to get the records of PersonAccount by Name
    * @return : List<Account>
    */     
    public static List<Account> getAccountByIdAndType(Set<Id> idSet){
        return BLN_QueryHandlerWebservice.getAccountByIdAndType(idSet);
    } 
    
    /** @description : getSetOfMainWorkTypes method to set Of Main WorkType Names
    * @return : Set<String>
    */  
    public static Set<String> getSetOfMainWorkTypes(){
        return BLN_QueryHandlerWebservice.getSetOfMainWorkTypes();
    }
    
    /** @description : getSkillReq method to get the records of SkillRequirement by RelatedRecordId
	*@param : Set<String> setOfRelatedRecIds
	*@Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107
	*/
    public static List<SkillRequirement> getSkillReq(Set<String> setOfRelatedRecIds) {
        return BLN_QueryHandlerWebservice.getSkillReq(setOfRelatedRecIds);
    }
    
    /** @description : getCaseConRole method to get the records of CaseContactRole by CasesId
    *@param : Set<String> setOfCasesIds
    *@Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107
    */
    public static List<CaseContactRole> getCaseConRole(Set<String> setOfCasesIds) {       
        return BLN_QueryHandlerWebservice.getCaseConRole(setOfCasesIds);
    }
    
     /** @description : getCCRByCaseIdAndConId method to get the records of CaseContactRole by CasesId
    *@param : String caseId, String contactId
    *@Story : FOUK-678,FOUK-192,FOUK-109,FOUK-108,FOUK-107
    */
    public static List<CaseContactRole> getCCRByCaseIdAndConId(String caseId, String contactId) {
        return BLN_QueryHandlerWebservice.getCCRByCaseIdAndConId(caseId, contactId);
    }
    
     /** @description : getAccountByPersonConId method to get the records of PersonAccount by Name and Role
    * @param : Set<Id> idSet
    * @return : List<Account>
    */     
    public static List<Account> getAccountByPersonConId(Set<Id> personConIds){
        return BLN_QueryHandlerWebservice.getAccountByPersonConId(personConIds);
    }

    /** @description : getPersonAccountByName method to get the records of PersonAccount by Name and Role
    * @param : String salutation, String fName, String lName, String phone
    * @return : List<Account>
    */     
    public static List<Account> getPersonAccountByName(String salutation, String fName, String lName, String phone){
        return BLN_QueryHandlerWebservice.getPersonAccountByName(salutation, fName, lName, phone);        
    }
    
    /** @description : getOrderItemByOrder method to get the records of OrderItem by OrderId
    * @param : orderId
    * @return : List<OrderItem>
    */    
    public static List<OrderItem> getOrderItemByOrder(String orderId){
        return BLN_QueryHandlerWebservice.getOrderItemByOrder(orderId);
    }

    /** @description : getProductByProductCode method to get the records of Product2 by ProductCode
    * @param : productCode
    * @return : List<Product2>
    */  
    public static List<Product2> getProductByProductCode(Set<String> productCode){
        return BLN_QueryHandlerWebservice.getProductByProductCode(productCode);
    }
    
    /** @description : getServiceTerritoryByAppointmentId method to get the records of ServiceTerritory by Service Appointment Id
    * @param : appointmentId
    * @return : ServiceTerritory
    */
    public static ServiceTerritory getServiceTerritoryByAppointmentId(String appointmentId){
        return BLN_QueryHandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);
    }

    /** @description : getWorkType method to get the records of WorkType by Name
    * @param : name
    * @return : WorkType
    */
    public static List<WorkType> getWorkTypeRec(Set<String> names){
        return BLN_QueryHandlerWebservice.getWorkType(names);
    }

    /** @description : getCaseFromId method to get the records of Case by OrderId
    * @param : caseId
    * @return : Case
    */
    public static Case getCaseFromId(String caseId){
        return BLN_QueryHandlerWebservice.getCaseFromId(caseId);
    }

    /** @description : getServiceTerritoryFromGUID method to get the records of Case by OrderId
    * @param : guid
    * @return : ServiceTerritory
    */
    public static ServiceTerritory getServiceTerritoryFromGUID(String guid){
        return BLN_QueryHandlerWebservice.getServiceTerritoryFromGUID(guid);
    }
    
    /** @description : getEndTimeFromTimeSlot method to get the records of TimeSlot by OperatingHoursId and DayOfWeek
    * @param : OperatingHoursId, DayOfWeek
    * @return : TimeSlot
    */
    public static TimeSlot getEndTimeFromTimeSlot(String operatingHourId, String dayOfWeek){
        return BLN_QueryHandlerWebservice.getEndTimeFromTimeSlot(operatingHourId, dayOfWeek);
    }
    
    /** @description : getStartTimeFromTimeSlot method to get the records of TimeSlot by OperatingHoursId and DayOfWeek
    * @param : OperatingHoursId, DayOfWeek
    * @return : TimeSlot
    */
    public static TimeSlot getStartTimeFromTimeSlot(String operatingHourId, String dayOfWeek){
        return BLN_QueryHandlerWebservice.getStartTimeFromTimeSlot(operatingHourId, dayOfWeek);
    }
    
    /** @description : getProdFromId method to get the records of Product2 by productIdSet
    * @param : productIdSet
    * @return : List<Product2>
    */
    
    public static List<Product2> getProdFromId(Set<String> productIdSet){
        return BLN_QueryHandlerWebservice.getProdFromId(productIdSet);
    }
    
    /** @description : getPriceBookEntryMap method to get the records of PriceBookEntry by prodList
    * @param : prodList
    * @return : List<PriceBookEntry>
    */
    public static List<PriceBookEntry> getPriceBookEntryMap(List<Product2> prodList){
        return BLN_QueryHandlerWebservice.getPriceBookEntryMap(prodList);
    }
    
    /** @description : getStandardPriceBook method to get the records of Pricebook2 by check
    * @param : check
    * @return : Pricebook2
    */
    public static Pricebook2 getStandardPriceBook(Boolean check, String name){
        return BLN_QueryHandlerWebservice.getStandardPriceBook(check, name);
    }
    
    /** @description : getSkills method to get the records of Skills
    * @param : 
    * @return : Skill
    */
    public static List<Skill> getSkills(){
        return BLN_QueryHandlerWebservice.getSkills();
    }
    
    /** @description : getOrderByOrderId method to get the records of Order by orderId
    * @param : wtIdSet
    * @return : Map
    */
    public static Order getOrderByOrderId(Id orderId){
        return BLN_QueryHandlerWebservice.getOrderByOrderId(orderId);
    }
    
    /** @description : getWorkTypeById method to get the records of WorkType by Id
    * @param : wtIdSet
    * @return : List<WorkType>
    */
    public static List<WorkType> getWorkTypeById(Set<Id> wtIdSet){
        return BLN_QueryHandlerWebservice.getWorkTypeById(wtIdSet);
    }    
    
    /** @description : getBUMetadata method to get the records of BU Metadata by DeveloperName
    * @param : developerName
    * @return : BLN_BU__mdt
    */
    public static BLN_BU__mdt getBUMetadata(String developerName){
        return BLN_QueryHandlerWebservice.getBUMetadata(developerName);
    } 
    
    /** @description : getWorkOrderById method to get the records of WorkOrder By ID
    * @param : Id
    * @return : WorkOrder
    */
    public static WorkOrder getWorkOrderById(String id){
        return BLN_QueryHandlerWebservice.getWorkOrderById(Id);
    } 
       
    /** @description : getSchedulingPolicyName method to get the record of FSL__Scheduling_Policy__c by Name
    * @param : schPolicy
    * @return : FSL__Scheduling_Policy__c
    */
    public static FSL__Scheduling_Policy__c getSchedulingPolicyName(String schPolicy){
        return BLN_QueryHandlerWebservice.getSchedulingPolicyName(schPolicy);
    } 
       
    /** @description : getLocationByGuid method to get the record of Location by GUID
    * @param : guid
    * @return : Location
    */
    public static Schema.Location getLocationByGuid(String guid){
        return BLN_QueryHandlerWebservice.getLocationByGuid(guid);
    } 
       
    /** @description : getLocationByPrimarySourceCollectId method to get the record of Location by primarySourceCollectId
    * @param : primarySourceCollectId
    * @return : Location
    */
    public static Schema.Location getLocationByPrimarySourceCollectId(String primarySourceCollectId){
        return BLN_QueryHandlerWebservice.getLocationByPrimarySourceCollectId(primarySourceCollectId);
    } 
       
    /** @description : getServiceReportLayoutByName method to get the record of ServiceReportLayout by developerName
    * @param : developerName
    * @return : ServiceReportLayout
    */
    public static ServiceReportLayout getServiceReportLayoutByName(String developerName){
        return BLN_QueryHandlerWebservice.getServiceReportLayoutByName(developerName);
    } 
       
    /** @description : getServiceAppointmentByWorkOrder method to get the record of ServiceAppointment by WorkOrder
    * @param : workOrderId, Id
    * @return : ServiceAppointment
    */
    public static List<ServiceAppointment> getServiceAppointmentByWorkOrder(String workOrderId){
        return BLN_QueryHandlerWebservice.getServiceAppointmentByWorkOrder(workOrderId);
    } 

    /** @description : getWeatherGuardProductMetadata method to get the records of WeatherGuardProduct Metadata
    * @param : N/A
    * @return : BLN_WeatherGuardAppointmentConfiguration__mdt
    */
    public static BLN_WeatherGuardAppointmentConfiguration__mdt getWeatherGuardProductMetadata(){
        return BLN_QueryHandlerWebservice.getWeatherGuardProductMetadata();
    }

    /** @description : getServAppShortningConfigMetadata method to get AppointmentShorteningConfiguration Metadata
    * @param : N/A
    * @return : BLN_AppointmentShorteningConfiguration__mdt
    */
    public static BLN_AppointmentShorteningConfiguration__mdt getServAppShortningConfigMetadata(){
        return BLN_QueryHandlerWebservice.getServAppShortningConfigMetadata();
    }

    /** @description : getWorkOrderFromCase method to get Existing Work Order record using under the case
    * @param : caseId
    * @return : List<WorkOrder>
    */
    public static List<WorkOrder> getWorkOrderFromCase(String caseId){
        return BLN_QueryHandlerWebservice.getWorkOrderFromCase(caseId);
    }
}