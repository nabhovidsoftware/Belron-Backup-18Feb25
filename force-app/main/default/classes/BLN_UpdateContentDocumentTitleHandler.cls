/*****************************************
ClassName : BLN_UpdateContentDocumentTitleHandler
Description : FOUK-1537 This Class is for handling rename of file in Fail Appointment Action
CreatedDate: 19-03-2024
CreatedBy : Siddhant Pandya
****************************************/
public with sharing class BLN_UpdateContentDocumentTitleHandler {
    public static void updateFileNameOnFailedSA(List<ContentDocument> CDList) {
        List<String> CDId = new List<String>();
        Map<Id,Id> MapCDCDLink = new Map<Id,Id>();//Map<CD, CDL>
        Map<Id, Id> MapCDLinkSA = new Map<Id,Id>(); //Map<CDL, SA>
        List<String> SAId = new List<String>();
        List<ContentDocument> CDtoUpdate = new List<ContentDocument>();
        Map<Id, ServiceAppointment> MapSAIdSARec = new Map<Id, ServiceAppointment>();//Map<SAId, SARec>
        for(ContentDocument CD: CDList)
        {
            if(CD.IsArchived == false)
            {
                CDId.add(CD.Id);
                
            }
        }
        List<ContentDocumentLink> CDLinkRecords = [Select Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where ContentDocumentId in :CDId];
        
        for(ContentDocumentLink CDLink: CDLinkRecords)
        {
            if(CDLink.LinkedEntityId.getSObjectType().getDescribe().getName() == 'ServiceAppointment')
            {
                SAId.add(CDLink.LinkedEntityId);
                MapCDCDLink.put(CDLink.ContentDocumentId, CDLink.Id);
                MapCDLinkSA.put(CDLink.Id, CDLink.LinkedEntityId);
            }
        }
        List<ServiceAppointment> SAList = [Select id, BLN_WorkOrderNumber__r.WorkOrderNumber, AppointmentNumber, status, BLN_FailureReason__c from ServiceAppointment where Id in :SAId and (status= 'Failed After Arrive' or status = 'Failed Before Arrive')];
        
        for(ServiceAppointment SA: SAList){
            MapSAIdSARec.put(SA.Id, SA);
        }
        
        // Fetch current user TimeZone
        User usr = [SELECT Id, TimeZoneSidKey
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                    WITH SECURITY_ENFORCED LIMIT 1];
        Datetime gmtDateTime = System.now();
        
        for(ContentDocument CDRec:CDList)
        {
            ServiceAppointment TempSA = MapSAIdSARec.get(MapCDLinkSA.get(MapCDCDLink.get(CDRec.Id)));
            if(TempSA!= null)
            {
                String WONumber = TempSA.BLN_WorkOrderNumber__r.WorkOrderNumber;
                String SANumber = TempSA.AppointmentNumber;
                //DateTime currentTime = System.now();
                String currentTime = gmtDateTime.format('yyyy-MM-dd HH:mm:ss', usr.TimeZoneSidKey);
                String status;
                if(TempSA.status== 'Failed After Arrive'){status = 'FAA';}
                if(TempSA.status== 'Failed Before Arrive'){status = 'FBA';}
                String reason = TempSA.BLN_FailureReason__c;
                String NewTitle = WONumber + '-' + SANumber+'-'+currentTime+'-'+status+'-'+reason;
                CDRec.Title = NewTitle;
                CDtoUpdate.add(CDRec);
            }
        }
        update CDtoUpdate;
    }
}