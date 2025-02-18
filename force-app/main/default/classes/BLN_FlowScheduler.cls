/** @description : This apex class is used to send the Lunch Break Notification.
*  @author: (pruthvising.vanrajsinh.pujara@pwc.com (IN))
*  @Story: FOUK-1596
*/
public without sharing class BLN_FlowScheduler implements Schedulable {
    Set<ResourceAbsence> absenceRecords;
    public String notificationTypeId;
    public BLN_FlowScheduler(Set<ResourceAbsence> absenceRecords,String notificationTypeId) {
        this.absenceRecords = absenceRecords;
        this.notificationTypeId = notificationTypeId;
    }
    public void execute(SchedulableContext context) {
        Set<String> recipientsIds = new Set<String>();
        String startTime;
        String endTime;
        for(ResourceAbsence rA:absenceRecords){
            if(rA.Resource.RelatedRecordId!=NULL){
                recipientsIds.add(rA.Resource.RelatedRecordId);
                startTime = ra.start.format('HH:mm');
                endTime = ra.end.format('HH:mm');
            }
        }
        
        if(recipientsIds.size()>0){
            notifyUsers(recipientsIds,notificationTypeId,startTime,endTime);
        }

    }
    public static void notifyUsers(Set<String> recipientsIds,String notificationId,String receiveStartTime,String receiveEndTime) {
        String pageRef = '{ "type": "standard__objectPage", "attributes": { "objectApiName": "ServiceAppointment", "actionName": "home" } }';
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(System.Label.BLN_PushNotificationTitle);
        notification.setBody(System.Label.BLN_PushNotificationMessage+' Starting At '+receiveStartTime+' Ending At '+receiveEndTime);
        notification.setNotificationTypeId(notificationId);
        notification.setTargetPageRef(pageRef);
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            pageRef = '';
        }
    }
}