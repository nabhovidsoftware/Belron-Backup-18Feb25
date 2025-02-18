/** @description : This apex class is used to find the Number of Lunch Breaks per day.
*  @author: (pruthvising.vanrajsinh.pujara@pwc.com (IN))
*  @Story: FOUK-1596
*/
public without sharing class BLN_FetchLunchBreakBatch implements Database.stateful,Database.Batchable<sObject>,Schedulable {
    public Map<Datetime,Set<ResourceAbsence>> breakTimeResources;
    public BLN_FetchLunchBreakBatch() {
        breakTimeResources = new Map<Datetime,Set<ResourceAbsence>>();
	}

    public void execute(SchedulableContext context) {
        BLN_FetchLunchBreakBatch objLunchBreak = new BLN_FetchLunchBreakBatch();
        Database.executeBatch(objLunchBreak,2000);
    }
    public Database.QueryLocator start(Database.BatchableContext bc){ 
        String breakType = System.Label.BLN_ShiftBreak;
        return Database.getQueryLocator('SELECT Id, Start, End, ResourceId, Resource.RelatedRecordId FROM ResourceAbsence where Start = Today and Type =:breakType order by Start');
    }

    public void execute(Database.BatchableContext bc, List<ResourceAbsence> scope){
        for (ResourceAbsence ra : scope) {
            Datetime dt = ra.Start.addMinutes(-15);
            if(!breakTimeResources.containsKey(dt)){
                breakTimeResources.put(dt,new Set<ResourceAbsence>());
            }
            breakTimeResources.get(dt).add(ra);
        }
    }

    public void finish(Database.BatchableContext bc){
        if(breakTimeResources!=null){
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName=:System.Label.BLN_CustomNotificationTypeDevName];
             for(Datetime dt:breakTimeResources.keySet()){
                 if(breakTimeResources.get(dt)!=null && dt>System.now()){
                     System.schedule(
                         System.Label.BLN_PushNotificationTitle+' '+dt,
                         '0 '+dt.minute()+' '+dt.hour()+' '+dt.day()+' '+dt.month()+' ? '+dt.year(),
                         new BLN_FlowScheduler(breakTimeResources.get(dt),notificationType.Id)
                     );
                 }
             }
        }
    }
}