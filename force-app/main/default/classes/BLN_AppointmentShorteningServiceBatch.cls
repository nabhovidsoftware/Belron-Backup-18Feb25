/**@description : This batch class handle the service appointments to be dispatched to their assigned technician.
*  @author: Shubbh ArorA
*  @Story: FOUK-777
*  @CreatedDate: 07/03/2024
*/

public class BLN_AppointmentShorteningServiceBatch implements Database.Batchable<sObject>, Schedulable{
    public static DateTime currentDateTime = System.now();
    public static DateTime currentDateTimeWithHorizon;
    public static Integer durationInMinutes;
    public static Integer fslDurationInMinutes;
    Set<String> excludedWorkTypes = new Set<String>{System.label.BLN_Assist, System.label.BLN_StockCollect};
    
    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        String query = queryFormation();
        if(query != System.label.BLN_InactiveMetadata){
            return Database.getQueryLocator(query);
        }
        else{
             return null;
        }
    }

    public void execute(Database.BatchableContext batchableContext, List<ServiceAppointment> saList){
        DateTime newArrivalStart;
        DateTime newArrivalEnd;
        DateTime newDueDate;
        Integer arrivalStartTimeFromMetadata;
        Integer roundedDurationFromMetadata;
        Integer shortningWindowFromMetadata;
        List<ServiceAppointment> updatedSAList = new List<ServiceAppointment>();

        BLN_AppointmentShorteningConfiguration__mdt appShortningConfigMetadata = new BLN_AppointmentShorteningConfiguration__mdt();
        appShortningConfigMetadata = BLN_HandlerWebservice.getServAppShortningConfigMetadata();
        if(saList.size() > 0 && saList != null){
            for(ServiceAppointment eachServApp: saList){				
                arrivalStartTimeFromMetadata = appShortningConfigMetadata.BLN_ArrivalStartTimeAdjustmentInMinutes__c != null ? Integer.valueOf(appShortningConfigMetadata.BLN_ArrivalStartTimeAdjustmentInMinutes__c) : 0;
                roundedDurationFromMetadata = appShortningConfigMetadata.BLN_RoundedDurationInMinutes__c != null ? Integer.valueOf(appShortningConfigMetadata.BLN_RoundedDurationInMinutes__c) : 0;
                shortningWindowFromMetadata = appShortningConfigMetadata.BLN_ShorteningWindowInMinutes__c != null ? Integer.valueOf(appShortningConfigMetadata.BLN_ShorteningWindowInMinutes__c) : 0;
                    
                newArrivalStart = eachServApp.SchedStartTime.addMinutes(-arrivalStartTimeFromMetadata);
                newArrivalStart = roundOffTime(newArrivalStart, roundedDurationFromMetadata);

                newArrivalStart = newArrivalStart < eachServApp.ArrivalWindowStartTime ? eachServApp.ArrivalWindowStartTime : newArrivalStart;

                newDueDate = newArrivalStart.addMinutes(shortningWindowFromMetadata);

                newDueDate = newDueDate > eachServApp.DueDate ? eachServApp.DueDate : newDueDate;

                newArrivalEnd = newDueDate.addMinutes(-Integer.valueOf(eachServApp.DurationInMinutes));

                eachServApp.ArrivalWindowStartTime = newArrivalStart;
                eachServApp.DueDate = newDueDate;
                eachServApp.ArrivalWindowEndTime = newArrivalEnd;

                eachServApp.BLN_IsAppointementShortened__c = True;
                eachServApp.BLN_AppointmentShorteningDateTime__c = System.now();

                updatedSAList.add(eachServApp);
            }
        }
        if(updatedSAList.size() > 0 && Schema.sObjectType.ServiceAppointment.isUpdateable()){
            DATABASE.update(updatedSAList, FALSE);
        }
    }

    public void finish(Database.BatchableContext batchableContext){
        try{
            AsyncApexJob job = new AsyncApexJob();
            job = [SELECT Id, JobType, ApexClassId, Status, NumberOfErrors, MethodName, CompletedDate FROM AsyncApexJob WHERE Id =: BatchableContext.getJobId()];
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
    }

    public void execute(SchedulableContext ctx) {
        integer batchSize = 200;
        BLN_AppointmentShorteningServiceBatch appShortningBatch = new BLN_AppointmentShorteningServiceBatch();
        database.executeBatch(appShortningBatch, batchSize);
    }

    public static String queryFormation(){
        String virtualTech;
        Boolean virtualTechFlag;
        Integer horizon;

        BLN_AppointmentShorteningConfiguration__mdt appShortningConfigMetadata = getAppShortningMetadata();
        durationInMinutes = appShortningConfigMetadata.BLN_MaxPlnDurationInMins__c != null ? Integer.valueOf(appShortningConfigMetadata.BLN_MaxPlnDurationInMins__c) : 0;
        fslDurationInMinutes = appShortningConfigMetadata.BLN_MaxSchDurationInMins__c != null ? Integer.valueOf(appShortningConfigMetadata.BLN_MaxSchDurationInMins__c) : 0;

        if(appShortningConfigMetadata.BLN_Active__c == True){
            virtualTechFlag = appShortningConfigMetadata.BLN_AllowVirtualTech__c;
            horizon = appShortningConfigMetadata.BLN_HorizonInHours__c != null ? Integer.valueOf(appShortningConfigMetadata.BLN_HorizonInHours__c) : 0;
            currentDateTimeWithHorizon = currentDateTime.addHours(horizon);
            if(virtualTechFlag == False){
                virtualTech = ' AND BLN_AssignedServiceResource__r.BLN_Type__c != \'' + System.label.BLN_VirtualTech + '\' ';
            }
            else{
                virtualTech = ' ';
            }
            String query = 'SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, SchedStartTime, SchedEndTime, DueDate, DurationInMinutes, FSL__Duration_In_Minutes__c FROM ServiceAppointment WHERE (Status = \'Dispatched\' OR Status = \'Scheduled\') ' + 
            'AND BLN_IsForcedAppointment__c = False AND BLN_IsAppointementShortened__c = False AND ServiceTerritory.BLN_EnableAppointmentShortening__c = True' + virtualTech + 'AND SchedStartTime >=: currentDateTime AND SchedStartTime <=: currentDateTimeWithHorizon ' +
            'AND DurationInMinutes <=: durationInMinutes AND FSL__Duration_In_Minutes__c <=: fslDurationInMinutes AND WorkType.Name NOT IN : excludedWorkTypes ' + 
            'WITH SECURITY_ENFORCED';
            return query;
        }
        else{
            return System.label.BLN_InactiveMetadata;
        }
    }

    public static BLN_AppointmentShorteningConfiguration__mdt getAppShortningMetadata(){
        BLN_AppointmentShorteningConfiguration__mdt appShortningConfigMetadata = new BLN_AppointmentShorteningConfiguration__mdt();
        appShortningConfigMetadata = BLN_HandlerWebservice.getServAppShortningConfigMetadata();
        return appShortningConfigMetadata;
    }
    
    public static DateTime roundOffTime(DateTime arrivalWindowStartTime, Integer roundDownTime){
        Integer rOff = roundDownTime;
        Time timeValue = arrivalWindowStartTime.time();
        Integer remainder = Math.mod((timeValue.hour() * 60 + timeValue.minute()), rOff);
        Integer roundedMinutes = ((timeValue.hour() * 60 + timeValue.minute()) - remainder);
        if(remainder >= rOff / 2){
            roundedMinutes += rOff;
        }
        Integer roundedHours = roundedMinutes / 60;
        roundedMinutes -= roundedHours*60;
        Time roundedTime = Time.newInstance(roundedHours, roundedMinutes, 0, 0);
        DateTime roundedDateTime = DateTime.newInstance(arrivalWindowStartTime.dateGmt(), roundedTime);
        return roundedDateTime;
    }

}