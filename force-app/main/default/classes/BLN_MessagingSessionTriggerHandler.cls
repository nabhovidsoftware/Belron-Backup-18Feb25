/**@description : This Apex class used to handle the after insert and after update operation on MessagingSession object .
*  @author: PwC India
*  @Story: 
*  @CreatedDate: 10/07/2024
*/
public without sharing class BLN_MessagingSessionTriggerHandler implements BLN_TriggerInterface{ 
    
    public static Boolean stopExecution = false;
    
    /**
*@description:This method is used to check trigger executed or not.
*@return boolean
*/
    public Boolean stopDispatch(){
        return stopExecution;
    }
        /**
*@description:This method is used in interface so declare in class..
*@return void
*/
public static void beforeInsert(List<SObject> newList) {

    stopExecution=false;
}
    
    /**
*@description:This method is used in interface so declare in class..
*@return void
*/
    public void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        stopExecution = false;       
    }
    
    public static List<MessagingSession> convertToMessagingSession(List<sObject> objList){
        List<MessagingSession> msgSessionList= new List<MessagingSession>();
        if(objList.size() > 0){
            msgSessionList = (List<MessagingSession>) objList;
        }
        return msgSessionList;
    }
    public static MessagingSession convertToMessagingSession(sObject obj){
        return (MessagingSession) obj;
    }
    
    /**
*@description:Once Account inserted method will pass below parameters for next execution.
*@return void
*/
    public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
        List<MessagingSession> msList = convertToMessagingSession(newList);
        verintCheck(msList, null);
    }
    
    /**
*@description:Once Account updated  method will pass below parameters for next execution.
*@return void
*/
    public void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        
        List<MessagingSession> msList = convertToMessagingSession(newList);
        Map<Id, MessagingSession> msOldMap = ( Map<Id, MessagingSession>)oldMap;
        verintCheck(msList, msOldMap);
    }
    
    public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
        stopExecution = false;
     }
     
     public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
         stopExecution = false;
     }
     
     
     public void afterUnDelete(List<SObject> newList, Map<Id, SObject> newMap) {
         stopExecution = false;
     }
    
    public static void verintCheck(List<MessagingSession> msList, Map<Id, MessagingSession> msOldMap){
        
        List<MessagingSession> filteredMsgSessionList = new List<MessagingSession>();
        try{
            if(msList != null && !msList.isEmpty() ) {
                for (MessagingSession ms : msList){
                    
                    if((ms.Status == 'Ended' && ms.ChannelType =='EmbeddedMessaging') && ( msOldMap == null || (msOldMap != null && ms.Status !=  msOldMap.get(ms.Id).Status ))){            
                        filteredMsgSessionList.add(ms);
                    }
                }
                if(filteredMsgSessionList != null && !filteredMsgSessionList.isEmpty() ) {
                    prepareCallOutActions(filteredMsgSessionList);
                    
                }
            }
            
        }catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
            
        }
        
    }
    
    /**
*@description:This method used to prepare data which is required for callout.
*@return void
*/
    public static void prepareCallOutActions(List<MessagingSession> msgSessionRecordList) {
                
        List<String> payloadList = new List<String>();
        set<Id> conversionIds = new set<Id>();
        set<Id> channelIds = new set <Id>();
        
        try{
            if(msgSessionRecordList != null && !msgSessionRecordList.isEmpty() ) {
            for(MessagingSession msgSessionRecord : msgSessionRecordList){
                conversionIds.add(msgSessionRecord.ConversationId);
                channelIds.add(msgSessionRecord.MessagingChannelId);
            }
            }
            
            Map<String,Object> currentMap = new Map<String,Object>();
            Map<String,Object> dataMap = new Map<String,Object>();
            Map<String,Object> mainJsonMap = new Map<String,Object>();
            Map<Id,String> mapOfChannel = new Map<Id,String>();
            Map<Id,String> mapOfLanguage = new Map<Id,String>();
            List<MessagingChannel> msgChannelRec = new List<MessagingChannel>();
            
            msgChannelRec = [SELECT Id, DeveloperName,MasterLabel, Language FROM MessagingChannel WHERE Id IN : channelIds WITH SECURITY_ENFORCED];
            
            if(msgChannelRec != null && !msgChannelRec.isEmpty() ) {
            for(MessagingChannel msg: msgChannelRec){
                mapOfChannel.put(msg.Id,msg.MasterLabel);
                mapOfLanguage.put(msg.Id,msg.Language);
            }
            }
            
            List<Conversation> convList = new List<Conversation>();
            convList = [SELECT ConversationChannelId, ConversationIdentifier, Id FROM Conversation WHERE Id IN :conversionIds WITH SECURITY_ENFORCED];
            Map<Id,String> convIdVsConvIdentifier = new Map<Id,String>();

            if(convList != null && !convList.isEmpty() ){
            for(Conversation conv : convList){
                convIdVsConvIdentifier.put(conv.Id,conv.ConversationIdentifier);
            }
        }
            
            if(msgSessionRecordList != null && !msgSessionRecordList.isEmpty() ) {
            for(MessagingSession msgSessionRecord : msgSessionRecordList){
                
                currentMap.put('eventConversationId',convIdVsConvIdentifier.get(msgSessionRecord.ConversationId));
                currentMap.put('eventTypeName',msgSessionRecord.ChannelType);
                currentMap.put('startTime',msgSessionRecord.StartTime);
                currentMap.put('endTime',msgSessionRecord.EndTime);                
                currentMap.put('name',mapOfChannel.containsKey(msgSessionRecord.MessagingChannelId) ? mapOfChannel.get(msgSessionRecord.MessagingChannelId) : '');                
                currentMap.put('language',mapOfLanguage.containsKey(msgSessionRecord.MessagingChannelId) ? mapOfLanguage.get(msgSessionRecord.MessagingChannelId) : '');
                
                    dataMap.put('current',currentMap);
                    mainJsonMap.put('data',dataMap);
                mainJsonMap.put('entityName','Event');
                mainJsonMap.put('entityID',msgSessionRecord.Id);
                mainJsonMap.put('eventType','Create');
                mainJsonMap.put('sourceSystem','Salesforce');
                mainJsonMap.put('timestamp',System.now().format('YYYY-MM-dd\'T\'HH:mm:ssXXX'));
                mainJsonMap.put('initialisedSystem','Salesforce');
                    payloadList.add(JSON.serializePretty(mainJsonMap));
                }
            }
            String processId = '';
            processId = Database.executeBatch(new BLN_QueueMSGSessionGateWay(payloadList), 1);
        }
        catch(Exception e){
            BLN_ExceptionLogger.captureException(e);
            
        }
        
    }    
}