public without sharing class BLN_PortalAppointmentSlots {
    public static List<FSL.AppointmentBookingSlot> appointmentBookingSlots = new List<FSL.AppointmentBookingSlot>();
    /*
        @description : This method is used to Update Appointments according to Drop Off and Collection window.
        @param : String appointmentId
        @retun : String
    */
    @AuraEnabled
    public static String updateAppointment(String appointmentId, Date arrivalStartAndEndDate, Date startDate, Integer interval){
        ServiceTerritory serviceTerritory = BLN_PortalHandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);
        ServiceAppointment appointmentObj = BLN_PortalQueryHandlerWebservice.getServiceAppointment(appointmentId);

        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format(System.label.BLN_EEEEText);

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
    public static BLN_PortalAppointmentDataCreationService.Slots getBranchSlots(String appointmentId){
        Integer duration = 0;
        ServiceTerritory serviceTerritory = BLN_PortalHandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);
        Datetime dateToday = System.Today();
        String dayOfWeek = dateToday.format(System.label.BLN_EEEEText);
        TimeSlot timeSlotStart = BLN_PortalHandlerWebservice.getStartTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);
        TimeSlot timeSlotEnd = BLN_PortalHandlerWebservice.getEndTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);

        OperatingHours op = new OperatingHours();
        if(serviceTerritory.BLN_Type__c == System.Label.BLN_Mobile){
            op = BLN_PortalQueryHandlerWebservice.getOperatingHours(System.Label.BLN_OneHourSlot);
        } else {
            op = BLN_PortalQueryHandlerWebservice.getOperatingHours(System.Label.BLN_30MinutesSlot);
        }
        
        ServiceAppointment appointmentObj = new ServiceAppointment();
        appointmentObj = BLN_PortalQueryHandlerWebservice.getServiceAppointment(appointmentId);
        if(appointmentObj == null){
            return null;
        }
        Set<Id> appointmentIds = new Set<Id>();
        List<FSL__Time_Dependency__c> dependencyList = BLN_PortalQueryHandlerWebservice.getTimeDependencyByAppointmentId(appointmentId);
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
            appointmentList = BLN_PortalQueryHandlerWebservice.getServiceAppointmentByIds(appointmentIds);
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
        List<WorkType> workTypeList = BLN_PortalHandlerWebservice.getWorkTypeById(workTypeId);
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
        
        List<BLN_PortalAppointmentDataCreationService.SlotData> dropOffSlotList = new List<BLN_PortalAppointmentDataCreationService.SlotData>();
        List<BLN_PortalAppointmentDataCreationService.SlotData> waitingSlotList = new List<BLN_PortalAppointmentDataCreationService.SlotData>();
        BLN_PortalAppointmentDataCreationService.SlotData slots = new BLN_PortalAppointmentDataCreationService.SlotData();
        BLN_PortalAppointmentDataCreationService.Slots branchSlots = new BLN_PortalAppointmentDataCreationService.Slots();
        branchSlots.waitingSlots = new List<BLN_PortalAppointmentDataCreationService.SlotData>();
        branchSlots.dropOffSlots = new List<BLN_PortalAppointmentDataCreationService.SlotData>();
        if(appointmentBookingSlots.size() > 0){
            // Order order = BLN_PortalHandlerWebservice.getOrderByOrderId(appointmentObj.BLN_WorkOrderNumber__r.BLN_Order__c);
            Integer collectionMins = serviceTerritory.BLN_CollectionWindowDuration__c != Null ? Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c) : 0;
            Integer dropOffMins = serviceTerritory.BLN_DropOffWindowDuration__c != Null ? Integer.valueOf(serviceTerritory.BLN_DropOffWindowDuration__c) : Integer.valueOf(System.label.BLN_DefaultDropOffDuration);
            Integer appDuration = appointmentObj.Duration != Null ? Integer.valueOf(appointmentObj.Duration) : 0;
            Map<Date, List<BLN_PortalAppointmentDataCreationService.SlotData>> tempMap = new Map<Date, List<BLN_PortalAppointmentDataCreationService.SlotData>>();
            for (Integer i = 0; i < appointmentBookingSlots.size(); i++) {
                FSL.AppointmentBookingSlot slot = appointmentBookingSlots[i];
                if(tempMap.containsKey(slot.Interval.Start.Date())){
                    slots = new BLN_PortalAppointmentDataCreationService.SlotData();
                    slots.startTime = BLN_PortalAppointmentSlots.formatUTC(DateTime.newInstance(slot.Interval.Start.Date(), timeSlotStart.StartTime).addMinutes(dropOffMins));
                    slots.endTime = BLN_PortalAppointmentSlots.formatUTC(DateTime.newInstance(slot.Interval.Start.Date(), timeSlotEnd.EndTime).addMinutes(-collectionMins));
                    List<BLN_PortalAppointmentDataCreationService.SlotData> listForMap = tempMap.get(slot.Interval.Start.Date());
                    listForMap.add(slots);
                    tempMap.put(slot.Interval.Start.Date(), listForMap);
                } else {
                    slots = new BLN_PortalAppointmentDataCreationService.SlotData();
                    slots.startTime = BLN_PortalAppointmentSlots.formatUTC(DateTime.newInstance(slot.Interval.Start.Date(), timeSlotStart.StartTime).addMinutes(dropOffMins));
                    slots.endTime = BLN_PortalAppointmentSlots.formatUTC(DateTime.newInstance(slot.Interval.Start.Date(), timeSlotEnd.EndTime).addMinutes(-collectionMins));
                    tempMap.put(slot.Interval.Start.Date(), new List<BLN_PortalAppointmentDataCreationService.SlotData> {slots});
                }
                
                if(appointmentObj.BLN_DropOffAppointment__c == false) {
                    slots = new BLN_PortalAppointmentDataCreationService.SlotData();
                    slots.startTime = BLN_PortalAppointmentSlots.formatUTC(slot.Interval.Start);
                    slots.endTime = BLN_PortalAppointmentSlots.formatUTC(slot.Interval.Finish.addMinutes(duration));
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
                    List<BLN_PortalAppointmentDataCreationService.SlotData> listOfSlots = tempMap.get(slotDate);
                    dropOffSlotList.add(listOfSlots[0]);
                }
                branchSlots.dropOffSlots = dropOffSlotList;
                branchSlots.isSuceess = true;
                branchSlots.msg = '';
            }
        } else {
            branchSlots.waitingSlots = new List<BLN_PortalAppointmentDataCreationService.SlotData>();
            branchSlots.dropOffSlots = new List<BLN_PortalAppointmentDataCreationService.SlotData>();
            branchSlots.isSuceess = false;
            branchSlots.msg = System.Label.BLN_NoSlotsAvailable;
        }
        System.debug('branchSlots :: ' + branchSlots);
        return branchSlots;
    }

    /*
        @description : This method is used to fetch slots from FSL.AppointmentBookingService API.
        @param : String appointmentId
        @retun : List<TimeSlotsWithProfile>
    */
    @AuraEnabled
    public static List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile> getMobileSlots(String appointmentId){
        ServiceTerritory serviceTerritory = BLN_PortalHandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);
        OperatingHours op = new OperatingHours();
        if(serviceTerritory.BLN_Type__c == System.Label.BLN_Mobile) {
            op = BLN_PortalQueryHandlerWebservice.getOperatingHours(System.Label.BLN_OneHourSlot);
        } else { op = BLN_PortalQueryHandlerWebservice.getOperatingHours(serviceTerritory.OperatingHours.Name);
        }
        
        ServiceAppointment appointmentObj = BLN_PortalQueryHandlerWebservice.getServiceAppointment(appointmentId);
        List<FSL__Time_Dependency__c> dependencyList = new List<FSL__Time_Dependency__c>();
        dependencyList = BLN_PortalQueryHandlerWebservice.getTimeDependencyByAppointmentId(appointmentId);
        Boolean isDependencyCreated = dependencyList!= null && dependencyList.size() > 0 ? true : false;
        Timezone tz = UserInfo.getTimeZone();
        Set<Id> workTypeId = new Set<Id>();
        workTypeId.add(appointmentObj.WorkTypeId);
        List<WorkType> workTypeList = BLN_PortalHandlerWebservice.getWorkTypeById(workTypeId);
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
        slotMappingList = [SELECT Id, MasterLabel, DeveloperName, BLN_StartTime__c, BLN_EndTime__c, BLN_Sequence__c FROM BLN_MobileAppointmentSlotMapping__mdt  ORDER BY BLN_Sequence__c];
        Map<Date, List<BLN_MobileAppointmentSlotMapping__mdt>> slotsMap = new Map<Date, List<BLN_MobileAppointmentSlotMapping__mdt>>();

        List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile> finalListToReturn = new List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile>();
        
        List<BLN_MobileAppointmentSlotMapping__mdt> metadataList = new List<BLN_MobileAppointmentSlotMapping__mdt>();
        for (BLN_MobileAppointmentSlotMapping__mdt metadataObj : slotMappingList) {
            for(Integer i = 0; i < appointmentBookingSlots.size(); i++){
                FSL.AppointmentBookingSlot slot = appointmentBookingSlots[i];
                String[] strTimeSplit = metadataObj.BLN_StartTime__c.split(':');
                String[] endTimeSplit = metadataObj.BLN_EndTime__c.split(':');
                Time startTime = Time.newInstance( Integer.valueOf(strTimeSplit[0]), Integer.valueOf(strTimeSplit[1]) ,0 ,0);
                Time endTime = Time.newInstance( Integer.valueOf(endTimeSplit[0]), Integer.valueOf(endTimeSplit[1]) ,0 ,0);
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
        List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile> slotProfileList = new List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile>();
        Map<String, List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile>> tempMap = new Map<String, List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile>>();
        for(Date slotsDate : slotsMap.keySet()){
            List<BLN_MobileAppointmentSlotMapping__mdt> metadataListForWrapper = slotsMap.get(slotsDate);
            for(BLN_MobileAppointmentSlotMapping__mdt metadataObj : metadataListForWrapper){
                BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile timeSlot = new BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile();
                timeSlot.slotDate = slotsDate;
                timeSlot.profileName = metadataObj.MasterLabel;
                timeSlot.slotStart = metadataObj.BLN_StartTime__c;
                timeSlot.slotEnd = metadataObj.BLN_EndTime__c;
                timeSlot.isSuceess = true;
                timeSlot.msg = '';
                slotProfileList.add(timeSlot);
                String mapKey = slotsDate + '-' + metadataObj.MasterLabel;
                if(tempMap.containsKey(mapKey)){
                    List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile> tempList = tempMap.get(mapKey);
                    tempList.add(timeSlot);
                    tempMap.put(mapKey, tempList);
                } else {
                    tempMap.put(mapKey, new List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile> {timeSlot});
                }
            }
        }
        
        for(String ti : tempMap.keySet()){
            List<BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile> temp = tempMap.get(ti);
            finalListToReturn.add(temp[0]);
        }
        
        if(finalListToReturn.isEmpty()){
            BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile timeSlot = new BLN_PortalAppointmentDataCreationService.TimeSlotsWithProfile();
            timeSlot.slotDate = Null;   timeSlot.profileName = '';
            timeSlot.slotStart = '';  timeSlot.slotEnd = '';
            timeSlot.isSuceess = false;
            timeSlot.msg = System.Label.BLN_NoSlotsAvailable;

            finalListToReturn.add(timeSlot);
        }
        return finalListToReturn;
    }

    public static String formatUTC(Datetime inputDateTime) {
        TimeZone tz = UserInfo.getTimezone();
        // IF EWP then call convertDateTimeToUTC from Utility else below
        inputDateTime = inputDateTime.addMinutes(tz.getOffset(inputDateTime) / 60000);
        return (inputDateTime != null) ? inputDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : '';
    }

    public static DateTime formatUTCDateTime(Datetime inputDateTime) {
        TimeZone tz = UserInfo.getTimezone();
        // IF EWP then call convertDateTimeToUTC from Utility else below
        inputDateTime = inputDateTime.addMinutes((tz.getOffset(inputDateTime) / 60000)*-1);
        return inputDateTime;
    }
}