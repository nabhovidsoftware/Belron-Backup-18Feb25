/**@description : The Apex class handle Task Creation and Updation
*  @author: Shubbh ArorA
*  @Story: FOUK-5446
*  @CreatedDate: 18/12/2023
*/
public with sharing class BLN_LeadTimeFieldCalculation {
    public static Time dueTime;
    public static Date interimDate2;
    public static Time interimTime2;
    public static Time interimTime;
    public static DateTime dueDate;
    public static Time windowEndTime;
    public static DateTime earliestStartTimeMain1;
    public static DateTime dateTodayWithConfigTime;
    public static DateTime earlyStartTime;
    
    public static Decimal mainSADuration = 0.0;
    public static Decimal allMainSADuration = 0.0; 
    public static Decimal recabSADuration = 0.0;
    public static Decimal warrantyReplacementSADuration = 0.0;
    public static Datetime dateToday = System.Today();
    public static List<ServiceAppointment> servAppList = new List<ServiceAppointment>();
    public static Set<Id> wtIdSet = new Set<Id>();
    public static Map<Id, String> workTypeMap = new Map<Id, String>();
    
    public static Case caseObj = new Case();
    //public static Integer bufferDaysVal;
    
    /** @description : setLeadTimeFields method is main method which is calling another method based on SA Conditions
    * @param : saList, isDropOff, serviceTerritory, workType, earliestStartTime
    * @return : void
    */
    public static void setLeadTimeFields(List<ServiceAppointment> saList, /*Boolean isDropOff,*/ ServiceTerritory serviceTerritory, Set<String> workType, DateTime earliestStartTime, String caseId){
        caseObj = BLN_HandlerWebservice.getCaseFromId(caseId);
        //bufferDaysVal = caseObj.BLN_BufferDays__c > 0 ? Integer.valueOf(caseObj.BLN_BufferDays__c) : 0;
        Time eightAM = dateToday.Time().addHours(Integer.valueOf(System.label.BLN_ConfigTime));
        String dayOfWeek = dateToday.format(System.label.BLN_EEEEText);
        TimeSlot timeSlotStart = BLN_HandlerWebservice.getStartTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);
        TimeSlot timeSlot = BLN_HandlerWebservice.getEndTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);
        Date interimDate = earliestStartTime.date().addDays(Integer.valueOf(System.label.BLN_7Text));
        dateTodayWithConfigTime = datetime.newInstance(dateToday.date(), eightAM);

    List<ServiceAppointment> saRevList = new List<ServiceAppointment>();
    for(Integer i = saList.size()-1; i>=0; i--) {
        saRevList.add(saList.get(i));
    }

        for(ServiceAppointment servAppointment: saRevList){
            wtIdSet.add(servAppointment.WorkTypeId);
        }

        List<WorkType> wtList = BLN_HandlerWebservice.getWorkTypeById(wtIdSet);
        for(WorkType eachWT: wtList){
            workTypeMap.put(eachWT.Id, eachWT.Name);
        }

        for(ServiceAppointment servAppointment: saRevList){
            mainSADurationCalculation(servAppointment);
        }
        
        for(ServiceAppointment servAppointment: saRevList){
            // if(isDropOff == FALSE){
                if(serviceTerritory.BLN_SplitReplaceAndRecalibration__c == FALSE && workType.contains(System.label.BLN_StockCollect)){
                    servAppList.add(nDOSplitFalseStockCreated(servAppointment, earliestStartTime, timeSlot, interimDate));
                }
                else if(serviceTerritory.BLN_SplitReplaceAndRecalibration__c == FALSE && !workType.contains(System.label.BLN_StockCollect)){
                    servAppList.add(nDOSplitFalseStockNotCreated(servAppointment, earliestStartTime, timeSlot, timeSlotStart, interimDate));
                }
                else if(serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE && workType.contains(System.label.BLN_StockCollect)){
                    servAppList.add(nDOSplitTrueStockCreated(servAppointment, earliestStartTime, timeSlot, interimDate));
                }
                else if(serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE && !workType.contains(System.label.BLN_StockCollect)){
                    servAppList.add(nDOSplitTrueStockNotCreated(servAppointment, earliestStartTime, timeSlot, timeSlotStart, interimDate));
                }
            /*}
            else{
                if(serviceTerritory.BLN_SplitReplaceAndRecalibration__c == FALSE && workType.contains(System.label.BLN_StockCollect)){
                    servAppList.add(dOSplitFalseStockCreated(servAppointment, earliestStartTime, timeSlot, interimDate, serviceTerritory));
                }
                else if(serviceTerritory.BLN_SplitReplaceAndRecalibration__c == FALSE && !workType.contains(System.label.BLN_StockCollect)){
                    servAppList.add(dOSplitFalseStockNotCreated(servAppointment, earliestStartTime, timeSlot, timeSlotStart, interimDate, serviceTerritory));
                }
                else if(serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE && workType.contains(System.label.BLN_StockCollect)){
                    servAppList.add(dOSplitTrueStockCreated(servAppointment, earliestStartTime, timeSlot, interimDate, serviceTerritory));
                }else if(serviceTerritory.BLN_SplitReplaceAndRecalibration__c == TRUE && !workType.contains(System.label.BLN_StockCollect)){
                    servAppList.add(dOSplitTrueStockNotCreated(servAppointment, earliestStartTime, timeSlot, timeSlotStart, interimDate, serviceTerritory));
                }
            }*/
        }
        if(servAppList.size() > 0){
            update servAppList;
        }   
    }
    
    //1. Non Drop-off, Combined or Single Main SA, Stock created
    /** @description : nDOSplitFalseStockCreated method is setting multiple Time fields on SA Record
    * @param : servAppointment, earliestStartTime, timeSlot, interimDate
    * @return : ServiceAppointment
    */
    public static ServiceAppointment nDOSplitFalseStockCreated(ServiceAppointment servAppointment, DateTime earliestStartTime, TimeSlot timeSlot, Date interimDate){
        servAppointment.EarliestStartTime = earliestStartTime; //.addDays(bufferDaysVal);
        if(workTypeMap.get(servAppointment.WorkTypeId) != System.label.BLN_StockCollect){
            dueTime = timeSlot.EndTime;
            if(workTypeMap.get(servAppointment.WorkTypeId) != System.label.BLN_Assist){
                mainSADuration = mainSADuration;
            }
        } else {
            dueTime = timeSlot.EndTime.addMinutes(-Integer.valueOf(mainSADuration));
        }
        dueDate = datetime.newInstance(interimDate, dueTime);
        servAppointment.DueDate = dueDate;
        servAppointment.ArrivalWindowStartTime = servAppointment.EarliestStartTime;
        servAppointment.ArrivalWindowEndTime = dueDate.addMinutes(-Integer.valueOf(mainSADuration));
        return servAppointment;
    }
    
    //2. Non Drop-off, Combined or Single Main SA, Stock not created
    /** @description : nDOSplitFalseStockNotCreated method is setting multiple Time fields on SA Record
    * @param : servAppointment, earliestStartTime, timeSlot, interimDate
    * @return : ServiceAppointment
    */
    public static ServiceAppointment nDOSplitFalseStockNotCreated(ServiceAppointment servAppointment, DateTime earliestStartTime, TimeSlot timeSlot, TimeSlot timeSlotStart, Date interimDate){
        if(workTypeMap.get(servAppointment.WorkTypeId) != System.label.BLN_StockCollect && workTypeMap.get(servAppointment.WorkTypeId) != System.label.BLN_Assist){
            if(earliestStartTime.Time() > timeSlot.EndTime){
                interimDate2 = earliestStartTime.date().addDays(Integer.valueOf(System.label.BLN_1Text));
                interimTime2 = timeSlotStart.StartTime;
                servAppointment.EarliestStartTime = datetime.newInstance(interimDate2, interimTime2); //.addDays(bufferDaysVal);
                mainSADuration = mainSADuration;
            } else if(earliestStartTime < dateTodayWithConfigTime || earliestStartTime.date() >= dateToday.date()){
                interimDate2 = earliestStartTime.date();
                interimTime2 = timeSlotStart.StartTime;
                servAppointment.EarliestStartTime = datetime.newInstance(interimDate2, interimTime2); //.addDays(bufferDaysVal);
                mainSADuration = mainSADuration;
            }
        } else if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Assist){
            servAppointment.EarliestStartTime = datetime.newInstance(interimDate2, timeSlotStart.StartTime); //.addDays(bufferDaysVal);
        }
        servAppointment.DueDate = datetime.newInstance(interimDate, timeSlot.EndTime.addMinutes(Integer.valueOf(mainSADuration)));
        servAppointment.ArrivalWindowStartTime = servAppointment.EarliestStartTime;
        interimTime2 = timeSlot.EndTime.addMinutes(-Integer.valueOf(mainSADuration));
        servAppointment.ArrivalWindowEndTime = datetime.newInstance(servAppointment.DueDate.Date(), interimTime2);
        return servAppointment;
    }
    
    //3. Non Drop-off, Split SA, Stock created
    /** @description : nDOSplitTrueStockCreated method is setting multiple Time fields on SA Record
    * @param : servAppointment, earliestStartTime, timeSlot, interimDate
    * @return : ServiceAppointment
    */
    public static ServiceAppointment nDOSplitTrueStockCreated(ServiceAppointment servAppointment, DateTime earliestStartTime, TimeSlot timeSlot, Date interimDate){
        servAppointment.EarliestStartTime = earliestStartTime; //.addDays(bufferDaysVal);
        servAppointment.ArrivalWindowStartTime = servAppointment.EarliestStartTime;
        if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Recalibration){
            servAppointment.EarliestStartTime = earliestStartTime.addMinutes(Integer.valueOf(warrantyReplacementSADuration)); //.addDays(bufferDaysVal);
            servAppointment.ArrivalWindowStartTime = servAppointment.EarliestStartTime;  
        } else if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_StockCollect){
            interimTime2 = timeSlot.EndTime.addMinutes(-Integer.valueOf(allMainSADuration));
            dueDate = datetime.newInstance(interimDate, interimTime2);
            interimDate2 = dueDate.Date();
            servAppointment.ArrivalWindowEndTime = datetime.newInstance(interimDate2, interimTime2);
        }
        if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Recalibration || workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Assist){
            interimTime2 = timeSlot.EndTime;
            dueDate = datetime.newInstance(interimDate, interimTime2);
            interimDate2 = dueDate.Date();
            if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Recalibration){
                interimTime = timeSlot.EndTime.addMinutes(-Integer.valueOf(recabSADuration));
                servAppointment.ArrivalWindowEndTime = datetime.newInstance(interimDate2, interimTime);
            }else{
                interimTime = dueDate.Time().addMinutes(-Integer.valueOf(allMainSADuration));
                servAppointment.ArrivalWindowEndTime = datetime.newInstance(interimDate2, interimTime);
            }
        }
        if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Replacements || workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_WarrantyReplacement || workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_SideRearReplacementWT || workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Repair){
            interimTime2 = timeSlot.EndTime.addMinutes(-Integer.valueOf(recabSADuration));
            dueDate = datetime.newInstance(interimDate, interimTime2);
            interimDate2 = dueDate.Date();
            interimTime = timeSlot.EndTime.addMinutes(-Integer.valueOf(allMainSADuration));
            servAppointment.ArrivalWindowEndTime = datetime.newInstance(interimDate2, interimTime);
        }
        servAppointment.DueDate = dueDate;
        return servAppointment;
    }
    
    //4. Non Drop-off, Split SA, Stock not created
    /** @description : nDOSplitTrueStockNotCreated method is setting multiple Time fields on SA Record
    * @param : servAppointment, earliestStartTime, timeSlot, interimDate
    * @return : ServiceAppointment
    */
    public static ServiceAppointment nDOSplitTrueStockNotCreated(ServiceAppointment servAppointment, DateTime earliestStartTime, TimeSlot timeSlot, TimeSlot timeSlotStart, Date interimDate){
        DateTime startDateTime;
        if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Replacements || workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_WarrantyReplacement || workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_SideRearReplacementWT || workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Repair){
            if(earliestStartTime.Time() > timeSlot.EndTime){
                interimDate2 = earliestStartTime.date().addDays(Integer.valueOf(System.label.BLN_1Text));
                startDateTime = datetime.newInstance(interimDate2, timeSlotStart.StartTime);
            } else if(earliestStartTime < dateTodayWithConfigTime || earliestStartTime.date() >= dateToday.date()){
                startDateTime = datetime.newInstance(earliestStartTime.date(), timeSlotStart.StartTime);
            }
            dueTime = timeSlot.EndTime.addMinutes(-Integer.valueOf(recabSADuration));
            servAppointment.DueDate = datetime.newInstance(interimDate, dueTime);
            servAppointment.EarliestStartTime = startDateTime; //.addDays(bufferDaysVal);
            servAppointment.ArrivalWindowStartTime = servAppointment.EarliestStartTime;
            windowEndTime = dueTime.addMinutes(-Integer.valueOf(allMainSADuration));
        } else if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Recalibration){
            interimTime2 = timeSlotStart.StartTime.addMinutes(Integer.valueOf(warrantyReplacementSADuration));
            servAppointment.EarliestStartTime = datetime.newInstance(earliestStartTime.date(), interimTime2); //.addDays(bufferDaysVal);
            dueTime = timeSlot.EndTime;
            servAppointment.DueDate = datetime.newInstance(interimDate, dueTime);
            windowEndTime = dueTime.addMinutes(-Integer.valueOf(recabSADuration));
            servAppointment.ArrivalWindowStartTime = datetime.newInstance(earliestStartTime.date(), interimTime2.addMinutes(Integer.valueOf(warrantyReplacementSADuration))); //.addDays(bufferDaysVal);
        } else if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Assist){
            servAppointment.EarliestStartTime = datetime.newInstance(earliestStartTime.date(), timeSlotStart.StartTime); //.addDays(bufferDaysVal);
            dueTime = timeSlot.EndTime;
            servAppointment.DueDate = datetime.newInstance(interimDate, dueTime);
            servAppointment.ArrivalWindowStartTime = startDateTime; //.addDays(bufferDaysVal);
            windowEndTime = dueTime.addMinutes(-Integer.valueOf(allMainSADuration));
        }
        servAppointment.ArrivalWindowEndTime = datetime.newInstance(servAppointment.DueDate.date(), windowEndTime);
        return servAppointment;
    }
    
    //5. Drop-off, Single Main SA, Stock created
    /** @description : dOSplitFalseStockCreated method is setting multiple Time fields on SA Record
    * @param : servAppointment, earliestStartTime, timeSlot, interimDate
    * @return : ServiceAppointment
    */
    /* public static ServiceAppointment dOSplitFalseStockCreated(ServiceAppointment servAppointment, DateTime earliestStartTime, TimeSlot timeSlot, Date interimDate, ServiceTerritory serviceTerritory){
        servAppointment.EarliestStartTime = earliestStartTime; //.addDays(bufferDaysVal);
        if(workTypeMap.get(servAppointment.WorkTypeId) != System.label.BLN_StockCollect){
            if(workTypeMap.get(servAppointment.WorkTypeId) != System.label.BLN_Assist){
                mainSADuration = mainSADuration;
            }
            dueTime = timeSlot.EndTime.addMinutes(-Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c != null ? serviceTerritory.BLN_CollectionWindowDuration__c : 0));
            servAppointment.DueDate = datetime.newInstance(interimDate, dueTime);
        } else{
            dueTime = timeSlot.EndTime.addMinutes(-Integer.valueOf(mainSADuration));
            servAppointment.DueDate = datetime.newInstance(interimDate, dueTime);
        }
        servAppointment.ArrivalWindowStartTime = earliestStartTime;
        servAppointment.ArrivalWindowEndTime = datetime.newInstance(interimDate, dueTime.addMinutes(-Integer.valueOf(mainSADuration)));
        return servAppointment;
    } */
    
    //6. Drop-off, Single Main SA, Stock not created
    /** @description : dOSplitFalseStockNotCreated method is setting multiple Time fields on SA Record
    * @param : servAppointment, earliestStartTime, timeSlot, interimDate
    * @return : ServiceAppointment
    */
    /* public static ServiceAppointment dOSplitFalseStockNotCreated(ServiceAppointment servAppointment, DateTime earliestStartTime, TimeSlot timeSlot, TimeSlot timeSlotStart, Date interimDate, ServiceTerritory serviceTerritory){
        if(workTypeMap.get(servAppointment.WorkTypeId) != System.label.BLN_StockCollect){
            if(workTypeMap.get(servAppointment.WorkTypeId) != System.label.BLN_Assist){
                mainSADuration = mainSADuration;
            }
            interimTime2 = timeSlotStart.StartTime.addMinutes(Integer.valueOf(serviceTerritory.BLN_DropOffWindowDuration__c != null ? serviceTerritory.BLN_DropOffWindowDuration__c : 0));
            if(earliestStartTime.Time() > timeSlot.EndTime){
                interimDate2 = earliestStartTime.date().addDays(Integer.valueOf(System.label.BLN_1Text));
                servAppointment.EarliestStartTime = datetime.newInstance(interimDate2, interimTime2); //.addDays(bufferDaysVal);
            } else if(earliestStartTime < dateTodayWithConfigTime || earliestStartTime.date() >= dateToday.date()){
                interimDate2 = earliestStartTime.date();
                servAppointment.EarliestStartTime = datetime.newInstance(earliestStartTime.date(), interimTime2); //.addDays(bufferDaysVal);
            }
            dueTime = timeSlot.EndTime.addMinutes(-Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c != null ? serviceTerritory.BLN_CollectionWindowDuration__c : 0));
            servAppointment.DueDate = datetime.newInstance(interimDate, dueTime);
            interimTime = timeSlotStart.StartTime.addMinutes(Integer.valueOf(serviceTerritory.BLN_DropOffWindowDuration__c != null ? serviceTerritory.BLN_DropOffWindowDuration__c : 0)); 
            servAppointment.ArrivalWindowStartTime = datetime.newInstance(earliestStartTime.date(), interimTime);
            windowEndTime = servAppointment.DueDate.Time().addMinutes(-Integer.valueOf(mainSADuration));
            servAppointment.ArrivalWindowEndTime = datetime.newInstance(interimDate, windowEndTime);
        }
        return servAppointment;
    } */
    
    //7. Drop-off, Split SA, Stock created
    /** @description : dOSplitTrueStockCreated method is setting multiple Time fields on SA Record
    * @param : servAppointment, earliestStartTime, timeSlot, interimDate
    * @return : ServiceAppointment
    */
    /* public static ServiceAppointment dOSplitTrueStockCreated(ServiceAppointment servAppointment,DateTime earliestStartTime,TimeSlot timeSlot, Date interimDate,ServiceTerritory serviceTerritory){
        servAppointment.EarliestStartTime = earliestStartTime; //.addDays(bufferDaysVal);
        if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_StockCollect){
            interimTime2 = timeSlot.EndTime.addMinutes(-(Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c != null ? serviceTerritory.BLN_CollectionWindowDuration__c : 0) - Integer.valueOf(allMainSADuration)));
            dueDate = datetime.newInstance(interimDate, interimTime2);
            servAppointment.DueDate = dueDate;
            servAppointment.ArrivalWindowStartTime = earliestStartTime;
            servAppointment.ArrivalWindowEndTime = dueDate.addMinutes(-Integer.valueOf(allMainSADuration));
        } else if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Replacements || workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_WarrantyReplacement || workTypeMap.get(servAppointment.WorkTypeId) ==  System.label.BLN_SideRearReplacementWT || workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Repair){
            interimTime2 = timeSlot.EndTime.addMinutes(-(Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c != null ? serviceTerritory.BLN_CollectionWindowDuration__c : 0) - Integer.valueOf(recabSADuration)));
            dueDate = datetime.newInstance(interimDate, interimTime2);
            servAppointment.DueDate = dueDate;
            servAppointment.ArrivalWindowStartTime = earliestStartTime;
            servAppointment.ArrivalWindowEndTime = dueDate.addMinutes(-Integer.valueOf(allMainSADuration));
        } else if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Recalibration){
            servAppointment.EarliestStartTime = earliestStartTime.addMinutes(Integer.valueOf(warrantyReplacementSADuration)); //.addDays(bufferDaysVal).addMinutes(Integer.valueOf(warrantyReplacementSADuration));
            interimTime2 = timeSlot.EndTime.addMinutes(-Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c != null ? serviceTerritory.BLN_CollectionWindowDuration__c : 0));
            dueDate = datetime.newInstance(interimDate, interimTime2);
            servAppointment.DueDate = dueDate;
            servAppointment.ArrivalWindowStartTime = earliestStartTime.addMinutes(Integer.valueOf(warrantyReplacementSADuration));
            servAppointment.ArrivalWindowEndTime = dueDate.addMinutes(-Integer.valueOf(recabSADuration));
        } else if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Assist){
            interimTime2 = timeSlot.EndTime.addMinutes(-Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c != null ? serviceTerritory.BLN_CollectionWindowDuration__c : 0)); 
            dueDate = datetime.newInstance(interimDate, interimTime2);
            servAppointment.DueDate = dueDate;
            servAppointment.ArrivalWindowStartTime = earliestStartTime;
            servAppointment.ArrivalWindowEndTime = dueDate.addMinutes(-Integer.valueOf(allMainSADuration));
        }
        return servAppointment;
    } */
    
    //8. Drop-off, Split SA, Stock not created
    /** @description : dOSplitTrueStockNotCreated method is setting multiple Time fields on SA Record
    * @param : servAppointment, earliestStartTime, timeSlot, interimDate
    * @return : ServiceAppointment
    */
    /* public static ServiceAppointment dOSplitTrueStockNotCreated(ServiceAppointment servAppointment,DateTime earliestStartTime,TimeSlot timeSlot, TimeSlot timeSlotStart, Date interimDate,ServiceTerritory serviceTerritory){
        Date interimDate2 = earliestStartTime.date().addDays(Integer.valueOf(System.label.BLN_1Text));
        interimTime2 = timeSlotStart.StartTime.addMinutes(Integer.valueOf(serviceTerritory.BLN_DropOffWindowDuration__c != null ? serviceTerritory.BLN_DropOffWindowDuration__c : 0));

        if(workTypeMap.get(servAppointment.WorkTypeId) != System.label.BLN_StockCollect && (
            workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Replacements || 
            workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_WarrantyReplacement || 
            workTypeMap.get(servAppointment.WorkTypeId) ==  System.label.BLN_SideRearReplacementWT || 
            workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Repair)){

            if(earliestStartTime.Time() > timeSlot.EndTime){
                earlyStartTime = datetime.newInstance(interimDate2, interimTime2);   
            }else if(earliestStartTime < dateTodayWithConfigTime || earliestStartTime.date() >= dateToday.date()){
                earlyStartTime = datetime.newInstance(earliestStartTime.date(), interimTime2);
                }
            servAppointment.EarliestStartTime = earlyStartTime; //.addDays(bufferDaysVal);
                interimTime2 = timeSlot.EndTime.addMinutes(-(Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c != null ? serviceTerritory.BLN_CollectionWindowDuration__c : 0) - Integer.valueOf(recabSADuration)));
                dueDate = datetime.newInstance(interimDate, interimTime2);  
                servAppointment.DueDate = dueDate;
                servAppointment.ArrivalWindowStartTime = servAppointment.EarliestStartTime;
                servAppointment.ArrivalWindowEndTime = dueDate.addMinutes(-Integer.valueOf(allMainSADuration));
            }
            if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Recalibration){
                if(earliestStartTime.Time() > timeSlot.EndTime){
                    earlyStartTime = datetime.newInstance(interimDate2, interimTime2);   
                }else if(earliestStartTime < dateTodayWithConfigTime || earliestStartTime.date() >= dateToday.date()){
                    earlyStartTime = datetime.newInstance(earliestStartTime.date(), interimTime2);
                }
            servAppointment.EarliestStartTime = earlyStartTime.addMinutes(Integer.valueOf(warrantyReplacementSADuration)); //.addDays(bufferDaysVal);
                interimTime2 = timeSlot.EndTime.addMinutes(-Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c != null ? serviceTerritory.BLN_CollectionWindowDuration__c : 0)); 
                dueDate = datetime.newInstance(interimDate, interimTime2);
                servAppointment.DueDate = dueDate;
                servAppointment.ArrivalWindowStartTime = earlyStartTime.addMinutes(Integer.valueOf(warrantyReplacementSADuration));
                servAppointment.ArrivalWindowEndTime = dueDate.addMinutes(-Integer.valueOf(recabSADuration));
            }
            if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Assist){
            servAppointment.EarliestStartTime = earlyStartTime; //.addDays(bufferDaysVal);
                interimTime2 = timeSlot.EndTime.addMinutes(-Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c != null ? serviceTerritory.BLN_CollectionWindowDuration__c : 0)); 
                dueDate = datetime.newInstance(interimDate, interimTime2); 
                servAppointment.DueDate = dueDate;
                servAppointment.ArrivalWindowStartTime = earlyStartTime;
                servAppointment.ArrivalWindowEndTime = dueDate.addMinutes(-Integer.valueOf(allMainSADuration));  
            }
        return servAppointment;
    } */
    
    /** @description : mainSADurationCalculation method is setting Duration field based on Main Appointment
    * @param : servAppointment
    * @return : void
    */
    public static void mainSADurationCalculation(ServiceAppointment servAppointment){
        if((workTypeMap.get(servAppointment.WorkTypeId) != System.label.BLN_Recalibration) || (workTypeMap.get(servAppointment.WorkTypeId) != System.label.BLN_StockCollect) || (workTypeMap.get(servAppointment.WorkTypeId) != System.label.BLN_Assist)){
            warrantyReplacementSADuration = servAppointment.Duration;
            mainSADuration = servAppointment.Duration;
        }
        else if(workTypeMap.get(servAppointment.WorkTypeId) == System.label.BLN_Recalibration){
            recabSADuration = servAppointment.Duration;
            mainSADuration = servAppointment.Duration;
        }
        allMainSADuration = warrantyReplacementSADuration + recabSADuration;
    }
}