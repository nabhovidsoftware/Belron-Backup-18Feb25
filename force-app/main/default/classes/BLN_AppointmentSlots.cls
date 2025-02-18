/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-27-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class BLN_AppointmentSlots {
    public static List<FSL.AppointmentBookingSlot> appointmentBookingSlots = new List<FSL.AppointmentBookingSlot>();
    /*
        @description : This method is used to Update Appointments according to Drop Off and Collection window.
        @param : String appointmentId
        @retun : String
    */
    @AuraEnabled
    public static String updateAppointment(String appointmentId, Date arrivalStartAndEndDate, Boolean isDropOff){
        ServiceTerritory serviceTerritory = BLN_HandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);
        ServiceAppointment appointmentObj = BLN_QueryHandlerWebservice.getServiceAppointment(appointmentId);

        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format(System.label.BLN_EEEEText);

        TimeSlot timeSlotStart = BLN_HandlerWebservice.getStartTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);
        TimeSlot timeSlotEnd = BLN_HandlerWebservice.getEndTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);

        //Date appArrivalWindowStartDate = appointmentObj.ArrivalWindowStartTime.Date();
        Integer dropOffMins = serviceTerritory.BLN_DropOffWindowDuration__c != Null ? Integer.valueOf(serviceTerritory.BLN_DropOffWindowDuration__c) : Integer.valueOf(System.label.BLN_DefaultDropOffDuration);
        Time arrivalStartTime = timeSlotStart.StartTime;
        if(isDropOff){arrivalStartTime = timeSlotStart.StartTime.addMinutes(dropOffMins);}

        //Date appArrivalWindowEndDate = appointmentObj.ArrivalWindowEndTime.Date();
        Integer appDuration = appointmentObj.Duration != Null ? Integer.valueOf(appointmentObj.Duration) : 0;
        Time arrivalTime = timeSlotEnd.EndTime.addMinutes(-appDuration);
        Integer collectionWindow = serviceTerritory.BLN_CollectionWindowDuration__c != Null ? Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c) : 0;
        Time arrivalEndTime = arrivalTime;
        if(isDropOff){arrivalEndTime = arrivalTime.addMinutes(-collectionWindow);}

        appointmentObj.ArrivalWindowStartTime = DateTime.newInstance(arrivalStartAndEndDate, arrivalStartTime); 
        appointmentObj.ArrivalWindowEndTime = DateTime.newInstance(arrivalStartAndEndDate, arrivalEndTime); 

        appointmentObj.EarliestStartTime = DateTime.newInstance(arrivalStartAndEndDate, arrivalStartTime); //added for unlimited slots
        appointmentObj.DueDate = DateTime.newInstance(arrivalStartAndEndDate, arrivalEndTime); //added for unlimited slots
        appointmentObj.BLN_DropOffAppointment__c = isDropOff;

        if(Schema.sObjectType.ServiceAppointment.isUpdateable()){
            UPDATE appointmentObj;
        }

        return appointmentId;
    }

    /* Portal Method
        @description : This method is used to Update Appointments according to Drop Off and Collection window.
        @param : String appointmentId, Date arrivalStartAndEndDate, Date startDate, Integer interval
        @retun : 
    */
    @AuraEnabled
    public static String updateAppointmentPortal (String appointmentId, Date arrivalStartAndEndDate, Date startDate, Integer interval){
      //  ServiceTerritory serviceTerritory = BLN_PortalHandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);
        ServiceAppointment appointmentObj = BLN_QueryHandlerWebservice.getServiceAppointment(appointmentId);

        //Datetime dateToday = System.Today();
      //  String dayOfWeek = dateToday.format(System.label.BLN_EEEEText);

       // TimeSlot timeSlotStart = BLN_PortalHandlerWebservice.getStartTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);
      //  TimeSlot timeSlotEnd = BLN_PortalHandlerWebservice.getEndTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);

        //Date appArrivalWindowStartDate = appointmentObj.ArrivalWindowStartTime.Date();
      //  Integer dropOffMins = serviceTerritory.BLN_DropOffWindowDuration__c != Null ? Integer.valueOf(serviceTerritory.BLN_DropOffWindowDuration__c) : Integer.valueOf(System.label.BLN_DefaultDropOffDuration);
       // Time arrivalStartTime = timeSlotStart.StartTime.addMinutes(dropOffMins);

        //Date appArrivalWindowEndDate = appointmentObj.ArrivalWindowEndTime.Date();
       // Integer appDuration = appointmentObj.Duration != Null ? Integer.valueOf(appointmentObj.Duration) : 0;
        //Time arrivalTime = timeSlotEnd.EndTime.addMinutes(-appDuration);
        //Integer collectionWindow = serviceTerritory.BLN_CollectionWindowDuration__c != Null ? Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c) : 0;
        //Time arrivalEndTime = arrivalTime.addMinutes(-collectionWindow);
        Date  startDatePortal;
        startDatePortal = startDate.addDays(interval);
      //  System.debug('startDatePortal'+startDatePortal);
        appointmentObj.EarliestStartTime = startDate.addDays(interval);
        appointmentObj.ArrivalWindowStartTime = startDate.addDays(interval);
        appointmentObj.DueDate = startDatePortal.addDays(interval);
        appointmentObj.ArrivalWindowEndTime = startDatePortal.addDays(interval);

       // appointmentObj.ArrivalWindowStartTime = DateTime.newInstance(ArrivalWindowStartTime, arrivalStartTime); 
        // appointmentObj.ArrivalWindowEndTime = DateTime.newInstance(arrivalStartAndEndDate, arrivalEndTime); 

        if(Schema.sObjectType.ServiceAppointment.isUpdateable()){
            UPDATE appointmentObj;
        }

        return appointmentId;
    }

    /*
        @description : This method is used to fetch slots from FSL.AppointmentBookingService API.
        @param : String appointmentId
        @retun : List<SlotData>
    */
    @AuraEnabled
    public static BLN_AppointmentDataCreationService.Slots getBranchSlots(String appointmentId){
        Integer duration = 0;
        ServiceTerritory serviceTerritory = BLN_HandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);
        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format(System.label.BLN_EEEEText);
        TimeSlot timeSlotStart = BLN_HandlerWebservice.getStartTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);
        TimeSlot timeSlotEnd = BLN_HandlerWebservice.getEndTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);

        OperatingHours op = new OperatingHours();
        if(serviceTerritory.BLN_Type__c == System.Label.BLN_Mobile){
            op = BLN_QueryHandlerWebservice.getOperatingHours(System.Label.BLN_OneHourSlot);
        } else {
            op = BLN_QueryHandlerWebservice.getOperatingHours(System.Label.BLN_30MinutesSlot);
        }
        
        ServiceAppointment appointmentObj = new ServiceAppointment();
        appointmentObj = BLN_QueryHandlerWebservice.getServiceAppointment(appointmentId);
        if(appointmentObj == null){
            return null;
        }
        Set<Id> appointmentIds = new Set<Id>();
        List<FSL__Time_Dependency__c> dependencyList = BLN_QueryHandlerWebservice.getTimeDependencyByAppointmentId(appointmentId);
        if(dependencyList != null) {
            for(FSL__Time_Dependency__c dependencyRec : dependencyList){
                appointmentIds.add(dependencyRec.FSL__Service_Appointment_1__c);
                appointmentIds.add(dependencyRec.FSL__Service_Appointment_2__c);
            }
        } else {
            appointmentIds.add(appointmentId);
        }
        
        List<ServiceAppointment> appointmentList = new List<ServiceAppointment>();
        if(!appointmentIds.isEmpty() && appointmentIds.size() > 0){
            appointmentList = BLN_QueryHandlerWebservice.getServiceAppointmentByIds(appointmentIds);
        }
        
        if(appointmentList != null){
            for(ServiceAppointment sa : appointmentList){
                if(sa.WorkType.Name != System.label.BLN_StockCollect && sa.WorkType.Name != System.label.BLN_Assist){
                    duration += Integer.valueOf(sa.Duration);
                }
            }
        }
        
        Boolean isDependencyCreated = dependencyList != null && dependencyList.size() > 0 ? true : false;
        Timezone tz = UserInfo.getTimeZone();
        Set<Id> workTypeId = new Set<Id>();
        workTypeId.add(appointmentObj.WorkTypeId);
        List<WorkType> workTypeList = BLN_HandlerWebservice.getWorkTypeById(workTypeId);
        WorkType workTypeObj = workTypeList[0];
        if(workTypeObj.Name != System.label.BLN_Assist && workTypeObj.Name != System.label.BLN_StockCollect && !Test.isRunningTest()){
            appointmentBookingSlots = new List<FSL.AppointmentBookingSlot>();
            if(isDependencyCreated == true){
                FSL.ABSlotsResponse abSlots = FSL.AppointmentBookingService.getABSlots(appointmentId, serviceTerritory.BLN_SchedulingPolicy__c, op, tz, 'SORT_BY_DATE', false);
                appointmentBookingSlots = abSlots.Slots;
            } else if(isDependencyCreated == false){
                appointmentBookingSlots = FSL.AppointmentBookingService.getSlots(appointmentId, serviceTerritory.BLN_SchedulingPolicy__c, op.Id, tz, false);
            }
        }

        List<BLN_AppointmentDataCreationService.SlotData> dropOffSlotList = new List<BLN_AppointmentDataCreationService.SlotData>();
        List<BLN_AppointmentDataCreationService.SlotData> waitingSlotList = new List<BLN_AppointmentDataCreationService.SlotData>();
        BLN_AppointmentDataCreationService.SlotData slots = new BLN_AppointmentDataCreationService.SlotData();
        BLN_AppointmentDataCreationService.Slots branchSlots = new BLN_AppointmentDataCreationService.Slots();
        branchSlots.waitingSlots = new List<BLN_AppointmentDataCreationService.SlotData>();
        branchSlots.dropOffSlots = new List<BLN_AppointmentDataCreationService.SlotData>();
        if(appointmentBookingSlots.size() > 0){
            // Order order = BLN_HandlerWebservice.getOrderByOrderId(appointmentObj.BLN_WorkOrderNumber__r.BLN_Order__c);
            Integer collectionMins= serviceTerritory.BLN_CollectionWindowDuration__c != Null ? Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c) : 0;
            Integer dropOffMins = serviceTerritory.BLN_DropOffWindowDuration__c != Null ? Integer.valueOf(serviceTerritory.BLN_DropOffWindowDuration__c) : Integer.valueOf(System.label.BLN_DefaultDropOffDuration);
            // Integer appDuration = appointmentObj.Duration != Null ? Integer.valueOf(appointmentObj.Duration) : 0;
            Map<Date, List<BLN_AppointmentDataCreationService.SlotData>> tempMap = new Map<Date, List<BLN_AppointmentDataCreationService.SlotData>>();
            for (Integer i = 0; i < appointmentBookingSlots.size(); i++) {
                FSL.AppointmentBookingSlot slot = appointmentBookingSlots[i];
                if(tempMap.containsKey(slot.Interval.Start.Date())){
                    slots = new BLN_AppointmentDataCreationService.SlotData();
                    slots.startTime = BLN_AppointmentSlots.formatUTC(DateTime.newInstance(slot.Interval.Start.Date(), timeSlotStart.StartTime).addMinutes(dropOffMins));
                    slots.endTime = BLN_AppointmentSlots.formatUTC(DateTime.newInstance(slot.Interval.Start.Date(), timeSlotEnd.EndTime).addMinutes(-collectionMins));
                    List<BLN_AppointmentDataCreationService.SlotData> listForMap = tempMap.get(slot.Interval.Start.Date());
                    listForMap.add(slots);
                    tempMap.put(slot.Interval.Start.Date(), listForMap);
                } else {
                    slots = new BLN_AppointmentDataCreationService.SlotData();
                    slots.startTime = BLN_AppointmentSlots.formatUTC(DateTime.newInstance(slot.Interval.Start.Date(), timeSlotStart.StartTime).addMinutes(dropOffMins));
                    slots.endTime = BLN_AppointmentSlots.formatUTC(DateTime.newInstance(slot.Interval.Start.Date(), timeSlotEnd.EndTime).addMinutes(-collectionMins));
                    tempMap.put(slot.Interval.Start.Date(), new List<BLN_AppointmentDataCreationService.SlotData> {slots});
                }
                if(appointmentObj.BLN_DropOffAppointment__c == false) {
                    slots = new BLN_AppointmentDataCreationService.SlotData();
                    slots.startTime = BLN_AppointmentSlots.formatUTC(slot.Interval.Start);
                    slots.endTime = BLN_AppointmentSlots.formatUTC(slot.Interval.Finish.addMinutes(duration));
                    waitingSlotList.add(slots);
                }
            }

            if(appointmentObj.BLN_DropOffAppointment__c == false){
                branchSlots.waitingSlots = waitingSlotList;
                branchSlots.isSuceess = true;
                branchSlots.msg = '';
            }

            if(appointmentObj.BLN_DropOffAppointment__c == true){
                for(Date slotDate : tempMap.keySet()){
                    List<BLN_AppointmentDataCreationService.SlotData> listOfSlots = tempMap.get(slotDate);
                    dropOffSlotList.add(listOfSlots[0]);
                }
                branchSlots.dropOffSlots = dropOffSlotList;
                branchSlots.isSuceess = true;
                branchSlots.msg = '';
            }
        } else {
            branchSlots.waitingSlots = new List<BLN_AppointmentDataCreationService.SlotData>();
            branchSlots.dropOffSlots = new List<BLN_AppointmentDataCreationService.SlotData>();
            branchSlots.isSuceess = false;
            branchSlots.msg = System.Label.BLN_NoSlotsAvailable;
        }
        return branchSlots;
    }

    /*
        @description : This method is used to fetch slots from FSL.AppointmentBookingService API.
        @param : String appointmentId
        @retun : List<TimeSlotsWithProfile>
    */
    @AuraEnabled
    public static List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile> getMobileSlots(String appointmentId){
        ServiceTerritory serviceTerritory = BLN_HandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);
        OperatingHours op = new OperatingHours();
        if(serviceTerritory.BLN_Type__c == System.Label.BLN_Mobile) {
            op = BLN_QueryHandlerWebservice.getOperatingHours(System.Label.BLN_OneHourSlot);
        } else {
            op = BLN_QueryHandlerWebservice.getOperatingHours(serviceTerritory.OperatingHours.Name);
        }
        
        ServiceAppointment appointmentObj = BLN_QueryHandlerWebservice.getServiceAppointment(appointmentId);
        List<FSL__Time_Dependency__c> dependencyList = new List<FSL__Time_Dependency__c>();
        dependencyList = BLN_QueryHandlerWebservice.getTimeDependencyByAppointmentId(appointmentId);
        Boolean isDependencyCreated = dependencyList != null && dependencyList.size() > 0 ? true : false;
        Timezone tz = UserInfo.getTimeZone();
        Set<Id> workTypeId = new Set<Id>();
        workTypeId.add(appointmentObj.WorkTypeId);
        List<WorkType> workTypeList = BLN_HandlerWebservice.getWorkTypeById(workTypeId);
        WorkType workTypeObj = workTypeList[0];
        
        if(workTypeObj.Name != System.label.BLN_Assist && workTypeObj.Name != System.label.BLN_StockCollect && !Test.isRunningTest()){
        	appointmentBookingSlots = new List<FSL.AppointmentBookingSlot>();
            if(isDependencyCreated == true){
                FSL.ABSlotsResponse abSlots = FSL.AppointmentBookingService.getABSlots(appointmentId, serviceTerritory.BLN_SchedulingPolicy__c, op, tz, 'SORT_BY_DATE', false);
                appointmentBookingSlots = abSlots.Slots;
            } else if(isDependencyCreated == false){
                appointmentBookingSlots = FSL.AppointmentBookingService.getSlots(appointmentId, serviceTerritory.BLN_SchedulingPolicy__c, op.Id, tz, false);
            }
        }

        List<BLN_MobileAppointmentSlotMapping__mdt> slotMappingList = new List<BLN_MobileAppointmentSlotMapping__mdt>();
        //Added a condition for portal User check
        Boolean isPortalUser = getPortalUserProfile();
       	If(isPortalUser){
            BLN_MobileAppointmentSlotMapping__mdt.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
            slotMappingList = [SELECT Id, MasterLabel, DeveloperName, BLN_StartTime__c, BLN_EndTime__c, BLN_Sequence__c FROM BLN_MobileAppointmentSlotMapping__mdt ORDER BY BLN_Sequence__c];
        }
        else{
            slotMappingList = [SELECT Id, MasterLabel, DeveloperName, BLN_StartTime__c, BLN_EndTime__c, BLN_Sequence__c FROM BLN_MobileAppointmentSlotMapping__mdt WITH SECURITY_ENFORCED ORDER BY BLN_Sequence__c];
        }
        Map<Date, List<BLN_MobileAppointmentSlotMapping__mdt>> slotsMap = new Map<Date, List<BLN_MobileAppointmentSlotMapping__mdt>>();

        List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile> finalListToReturn = new List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile>();
        
        List<BLN_MobileAppointmentSlotMapping__mdt> metadataList = new List<BLN_MobileAppointmentSlotMapping__mdt>();
        for (BLN_MobileAppointmentSlotMapping__mdt metadataObj : slotMappingList) {
            for(Integer i = 0; i < appointmentBookingSlots.size(); i++){
                FSL.AppointmentBookingSlot slot = appointmentBookingSlots[i];
                String[] strTimeSplit = metadataObj.BLN_StartTime__c.split(':');
                String[] endTimeSplit = metadataObj.BLN_EndTime__c.split(':');
                Time startTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]) ,Integer.valueOf(strTimeSplit[1]) ,0 ,0);
                Time endTime = Time.newInstance( Integer.valueOf(endTimeSplit[0]) ,Integer.valueOf(endTimeSplit[1]) ,0 ,0);
                DateTime slotEndTime = slot.Interval.Finish.addMinutes(Integer.valueOf(appointmentObj.Duration));
                if(slot.Interval.Start.Time() >= startTime && slotEndTime.Time() <= endTime){
                    if(slotsMap.containsKey(slot.Interval.Start.Date())){
                        metadataList = slotsMap.get(slot.Interval.Start.Date());
                        metadataList.add(metadataObj);
                        slotsMap.put(slot.Interval.Start.Date(), metadataList);
                    } else {
                        slotsMap.put(slot.Interval.Start.Date(), new List<BLN_MobileAppointmentSlotMapping__mdt> {metadataObj});
                    }
                }
            }
        }
        List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile> slotProfileList = new List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile>();
        Map<String, List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile>> tempMap = new Map<String, List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile>>();
        for(Date slotsDate : slotsMap.keySet()){
            List<BLN_MobileAppointmentSlotMapping__mdt> metadataListForWrapper = slotsMap.get(slotsDate);
            for(BLN_MobileAppointmentSlotMapping__mdt metadataObj : metadataListForWrapper){
                BLN_AppointmentDataCreationService.TimeSlotsWithProfile timeSlot = new BLN_AppointmentDataCreationService.TimeSlotsWithProfile();
                timeSlot.slotDate = slotsDate;
                timeSlot.profileName = metadataObj.MasterLabel;
                timeSlot.slotStart = metadataObj.BLN_StartTime__c;
                timeSlot.slotEnd = metadataObj.BLN_EndTime__c;
                timeSlot.isSuceess = true;
                timeSlot.msg = '';
                slotProfileList.add(timeSlot);
                String mapKey = slotsDate + '-' + metadataObj.MasterLabel;
                if(tempMap.containsKey(mapKey)){
                    List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile> tempList = tempMap.get(mapKey);
                    tempList.add(timeSlot);
                    tempMap.put(mapKey, tempList);
                } else {
                    tempMap.put(mapKey, new List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile> {timeSlot});
                }
            }
        }
        
        for(String ti : tempMap.keySet()){
            List<BLN_AppointmentDataCreationService.TimeSlotsWithProfile> temp = tempMap.get(ti);
            finalListToReturn.add(temp[0]);
        }
        
        if(finalListToReturn.isEmpty()){
            BLN_AppointmentDataCreationService.TimeSlotsWithProfile timeSlot = new BLN_AppointmentDataCreationService.TimeSlotsWithProfile();
            timeSlot.slotDate = Null;
            timeSlot.profileName = '';
            timeSlot.slotStart = '';
            timeSlot.slotEnd = '';
            timeSlot.isSuceess = false;
            timeSlot.msg = System.Label.BLN_NoSlotsAvailable;

            finalListToReturn.add(timeSlot);
        }
        return finalListToReturn;
    }

    public static String formatUTC(Datetime inputDateTime) {
        // TimeZone tz = UserInfo.getTimezone();
        // // IF EWP then call convertDateTimeToUTC from Utility else below
        // inputDateTime = inputDateTime.addMinutes(tz.getOffset(inputDateTime) / 60000);
        return (inputDateTime != null) ? inputDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : '';
    }

    public static DateTime formatUTCDateTime(Datetime inputDateTime) {
        TimeZone tz = UserInfo.getTimezone();
        // IF EWP then call convertDateTimeToUTC from Utility else below
        inputDateTime = inputDateTime.addMinutes((tz.getOffset(inputDateTime) / 60000)*-1);
        return inputDateTime;
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