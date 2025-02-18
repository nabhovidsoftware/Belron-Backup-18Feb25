/**@description : The Apex class created for scheduling appointments
*  @author: Wasim Akram
*  @Story: FOUK-6078
*  @CreatedDate: 13/02/2024
*/

public with sharing class BLN_AppointmentBooking {
    /*
        @description : This method is used to Update Service Appointment According to the selected datetime for schedule.
        @param : DateTime slotStart, DateTime slotFinish, String appointmentId, Boolean isForceAppointment
        @retun : String
    */
    @auraEnabled
    public static String bookAppointment(DateTime slotStart, DateTime slotFinish, String appointmentId, Boolean isDropOff, Boolean isForceAppointment){
        ServiceTerritory serviceTerritory = BLN_HandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);
        if(serviceTerritory != null) {
            if(serviceTerritory.BLN_Type__c == System.Label.BLN_Mobile) {
                return BLN_AppointmentBooking.bookMobileAppointment(slotStart, slotFinish, appointmentId, isForceAppointment);
            } else {
                return BLN_AppointmentBooking.bookBranchAppointment(slotStart, slotFinish, appointmentId, isDropOff, isForceAppointment);
            }
        } else {
            BLN_AppointmentDataCreationService.BookingResponse bookingResponse = new BLN_AppointmentDataCreationService.BookingResponse();
            bookingResponse.appointmentId = appointmentId;
            bookingResponse.isSuccess = false;
            bookingResponse.message = System.Label.BLN_AppNotMappedWithTerrError; //'Error: Appointment did not mapped with any Territory';
            return JSON.serialize(bookingResponse);
        }
    }

    public static String bookBranchAppointment(DateTime slotStart, DateTime slotFinish, String appointmentId, Boolean isDropOff, Boolean isForceAppointment){
        BLN_AppointmentDataCreationService.BookingResponse bookingResponse = new BLN_AppointmentDataCreationService.BookingResponse();
        try{
            bookingResponse.appointmentId = appointmentId;
            bookingResponse.isSuccess = true;
            bookingResponse.message = '';
            ServiceAppointment appointment = BLN_QueryHandlerWebservice.getServiceAppointmentForUpdate(appointmentId);
            ServiceTerritory serviceTerritory = BLN_HandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);

            //New list to store the dependent service appointments.
            List<ServiceAppointment> dependentSAList = new List<ServiceAppointment>();

            Datetime dateToday = appointment.DueDate;
            String dayOfWeek = dateToday.format(System.label.BLN_EEEEText);
            List<ServiceAppointment> appointmentList = new List<ServiceAppointment>();

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

            if(String.isNotBlank(appointment.BLN_WorkOrderNumber__c)){
                appointmentList = BLN_QueryHandlerWebservice.getServiceAppointmentByIds(appointmentIds);
            }

            if(appointmentList == null){
                bookingResponse.isSuccess = false;
                bookingResponse.message = System.Label.BLN_UnableToFindApp; //'Error: Unable to find appointments.';
                //return '';
            }
            
            List<ServiceAppointment> saDropOffUpdate = new List<ServiceAppointment>();
            ServiceAppointment recalibrationSA = new ServiceAppointment();
            if(isForceAppointment){
                appointment.BLN_IsForcedAppointment__c = isForceAppointment;//added by Ayush
            }
            
            if(isDropOff){
                Integer duration = 0;
                for(ServiceAppointment sa : appointmentList){
                    sa.BLN_IsPrepDataCall__c = false;
                    if(sa.WorkType.Name != System.label.BLN_StockCollect && sa.WorkType.Name != System.label.BLN_Assist){
                        duration += Integer.valueOf(sa.Duration);
                        sa.BLN_DropOffAppointment__c = isDropOff;
                        // sa.BLN_IsPrepDataCall__c = false;
                        saDropOffUpdate.add(sa);
                    }
                }
                TimeSlot timeSlotEnd = BLN_HandlerWebservice.getEndTimeFromTimeSlot(serviceTerritory.OperatingHoursId, dayOfWeek);
                if(timeSlotEnd == null){
                    bookingResponse.isSuccess = false;
                    bookingResponse.message = System.Label.BLN_UnableToFindTimeSlotRec; //'Error: Unable to find TimeSlot record.';
                    //return '';
                }
                Date dueDateOnly = slotFinish.date();
                // Integer collectionWindow = serviceTerritory.BLN_CollectionWindowDuration__c != Null ? Integer.valueOf(serviceTerritory.BLN_CollectionWindowDuration__c) : 0;
                // Integer dropOffMins = serviceTerritory.BLN_DropOffWindowDuration__c != Null ? Integer.valueOf(serviceTerritory.BLN_DropOffWindowDuration__c) : 0;
                Time dueTime = timeSlotEnd.EndTime;
                DateTime dueDate = datetime.newInstance(dueDateOnly, dueTime);
                appointment.EarliestStartTime = BLN_AppointmentSlots.formatUTCDateTime(slotStart);
                appointment.ArrivalWindowStartTime = BLN_AppointmentSlots.formatUTCDateTime(slotStart);
                appointment.ArrivalWindowEndTime = BLN_AppointmentSlots.formatUTCDateTime(dueDate.addMinutes(-duration));
                appointment.DueDate = BLN_AppointmentSlots.formatUTCDateTime(dueDate);
                appointment.BLN_DropOffAppointment__c = isDropOff;
            } else {
                if(serviceTerritory.BLN_SplitReplaceAndRecalibration__c){
                    for(ServiceAppointment sa : appointmentList){
                        if(sa.WorkType.Name == System.label.BLN_Recalibration){
                            recalibrationSA = sa;
                        }
                    }
                    appointment.EarliestStartTime = BLN_AppointmentSlots.formatUTCDateTime(slotStart);
                    appointment.ArrivalWindowStartTime = BLN_AppointmentSlots.formatUTCDateTime(slotStart);
                    appointment.ArrivalWindowEndTime = BLN_AppointmentSlots.formatUTCDateTime(slotStart.addMinutes(Integer.valueOf(System.label.BLN_WaitingTime)));
                    appointment.DueDate = BLN_AppointmentSlots.formatUTCDateTime(appointment.ArrivalWindowEndTime.addMinutes(Integer.valueOf(appointment.Duration)));
                    
                    Integer recalArrivalEndTime = Integer.valueOf(appointment.Duration + (serviceTerritory.BLN_MaxGapMin__c != null ? serviceTerritory.BLN_MaxGapMin__c : 0) );
                    DateTime recalArrivalEnd = BLN_AppointmentSlots.formatUTCDateTime(appointment.ArrivalWindowEndTime.addMinutes(Integer.valueOf(recalArrivalEndTime)));
                    recalibrationSA.EarliestStartTime = BLN_AppointmentSlots.formatUTCDateTime(appointment.EarliestStartTime);
                    recalibrationSA.ArrivalWindowStartTime = BLN_AppointmentSlots.formatUTCDateTime(appointment.ArrivalWindowStartTime.addMinutes(Integer.valueOf(appointment.Duration)));
                    recalibrationSA.ArrivalWindowEndTime = recalArrivalEnd;
                    Integer recalibrationDuration = recalibrationSA.Duration != null ? Integer.valueOf(recalibrationSA.Duration) : 0;
                    recalibrationSA.DueDate = recalibrationSA.ArrivalWindowEndTime.addMinutes(recalibrationDuration);
                } else {
                    DateTime arrivalEnd = BLN_AppointmentSlots.formatUTCDateTime(slotStart.addMinutes(Integer.valueOf(System.label.BLN_WaitingTime)));
                    appointment.EarliestStartTime = BLN_AppointmentSlots.formatUTCDateTime(slotStart);
                    appointment.ArrivalWindowStartTime = BLN_AppointmentSlots.formatUTCDateTime(slotStart);
                    appointment.ArrivalWindowEndTime = arrivalEnd;
                    appointment.DueDate = arrivalEnd.addMinutes(Integer.valueOf(appointment.Duration));
                    //Loop over the dependency list for service appointments and set Is Prep Data call false
                    for(ServiceAppointment dependentSA: appointmentList){
                        if(dependentSA.Id != appointment.Id){
                            dependentSA.BLN_IsPrepDataCall__c = false;
                            dependentSAList.add(dependentSA);
                        }
                    }
                }
            }
            
            if(Schema.sObjectType.ServiceAppointment.isUpdateable()){
                appointment.BLN_IsPrepDataCall__c = false;
                UPDATE appointment;
                if(String.isNotBlank(recalibrationSA.Id)){
                    recalibrationSA.BLN_IsPrepDataCall__c = false;
                    UPDATE recalibrationSA;
                }
                if(saDropOffUpdate.size() > 0){
                    UPDATE saDropOffUpdate;
                }
                //Empty list check for dependentSAList
                if(dependentSAList.size() > 0){
                    UPDATE dependentSAList;
                }
            }
        }catch(DmlException e) {
            BLN_ExceptionLogger.captureException(e);
            bookingResponse.appointmentId = appointmentId;
            bookingResponse.isSuccess = false;
            bookingResponse.message = System.Label.BLN_DMLError + e.getMessage()+''+e.getStackTraceString();
        }
        catch(Exception ex){
            BLN_ExceptionLogger.captureException(ex);
            bookingResponse.appointmentId = appointmentId;
            bookingResponse.isSuccess = false;
            bookingResponse.message = System.Label.BLN_ErrorColon + ex.getMessage()+''+ex.getStackTraceString();
        }
        
        return JSON.serialize(bookingResponse);
    }

    public static String bookMobileAppointment(DateTime slotStart, DateTime slotFinish, String appointmentId, Boolean isForceAppointment){
        BLN_AppointmentDataCreationService.BookingResponse bookingResponse = new BLN_AppointmentDataCreationService.BookingResponse();
        try{
            bookingResponse.appointmentId = appointmentId;
            bookingResponse.isSuccess = true;
            bookingResponse.message = '';
            ServiceAppointment appointment = BLN_QueryHandlerWebservice.getServiceAppointmentForUpdate(appointmentId);
            //ServiceAppointment recalibrationSA = new ServiceAppointment();
            
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

            Integer duration = 0;
            List<ServiceAppointment> saDependentList = new List<ServiceAppointment>();
            if(!appointmentIds.isEmpty() && appointmentIds.size() > 0){
                List<ServiceAppointment> appointmentList = BLN_QueryHandlerWebservice.getServiceAppointmentByIds(appointmentIds);
                for(ServiceAppointment sa : appointmentList){
                    sa.BLN_IsPrepDataCall__c = false;
                    saDependentList.add(sa);
                    if(sa.WorkType.Name != System.label.BLN_StockCollect && sa.WorkType.Name != System.label.BLN_Assist){
                        duration += Integer.valueOf(sa.Duration);
                    }
                }
            }
            
            appointment.EarliestStartTime = BLN_AppointmentSlots.formatUTCDateTime(slotStart);
            appointment.ArrivalWindowStartTime = BLN_AppointmentSlots.formatUTCDateTime(slotStart);
            appointment.DueDate = BLN_AppointmentSlots.formatUTCDateTime(slotFinish);
            appointment.ArrivalWindowEndTime = BLN_AppointmentSlots.formatUTCDateTime(slotFinish.addMinutes(-duration));
            if(isForceAppointment){
                appointment.BLN_IsForcedAppointment__c = isForceAppointment;//added by Ayush
            }

            if(Schema.sObjectType.ServiceAppointment.isUpdateable()){
                appointment.BLN_IsPrepDataCall__c = false;
                UPDATE appointment;
                UPDATE saDependentList;
            }
        } catch(DmlException e) {
            BLN_ExceptionLogger.captureException(e);
            bookingResponse.appointmentId = appointmentId;
            bookingResponse.isSuccess = false;
            bookingResponse.message = System.Label.BLN_DMLError + e.getMessage();
        }
        catch(Exception ex){
            BLN_ExceptionLogger.captureException(ex);
            bookingResponse.appointmentId = appointmentId;
            bookingResponse.isSuccess = false;
            bookingResponse.message = System.Label.BLN_ErrorColon + ex.getMessage();
        }
        
        return JSON.serialize(bookingResponse);
    }
    
    /*
        @description : This method is used to Schedule Service Appointment using FSL.ScheduleService.
        @param : String appointmentId
        @retun : String
    */
    @auraEnabled
    public static String scheduleAppointment(String appointmentId){
        FSL.ScheduleResult result = new FSL.ScheduleResult();
        String returnCode = '';
        try{
            ServiceTerritory serviceTerritory = BLN_HandlerWebservice.getServiceTerritoryByAppointmentId(appointmentId);
            if(!Test.isRunningTest() && serviceTerritory != null){           
                if(Boolean.valueOf(System.Label.BLN_IsSchedulingBypass) != true){
                    result = FSL.ScheduleService.schedule(serviceTerritory.BLN_SchedulingPolicy__c, appointmentId);
                }else{
                    result = null;
                }               
            }
            if(result != null){
                returnCode = System.Label.BLN_SchedulingSuccess; //'{"returnCode": "Success"}';
            } else {
                updateFailedAppointment(appointmentId);
                returnCode = System.Label.BLN_SchedulingFailed; //'{"returnCode": "Scheduling Fail"}';
            }
        } catch(exception ex) {
            BLN_ExceptionLogger.captureException(ex);
            updateFailedAppointment(appointmentId);
            returnCode = System.Label.BLN_SchedulingFailed; //'{"returnCode": "Scheduling Fail"}';
        }
        return returnCode;
    }

    @future
    public static void updateFailedAppointment(String appointmentId) {   
        ServiceAppointment serviceApp = BLN_QueryHandlerWebservice.getServiceAppointmentForUpdate(appointmentId);
        if(serviceApp != null){
            serviceApp.BLN_IsBookingFailed__c = true;
        }
        if(Schema.sObjectType.ServiceAppointment.isUpdateable()){
            UPDATE serviceApp;
        }
    }
}