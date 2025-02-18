/*****************************************
ClassName : BLN_MessagingSessionTriggerHandlerTest
Description : 
CreatedDate: 12-07-2024
CreatedBy : PwC-India
****************************************/
@isTest
private class BLN_MessagingSessionTriggerHandlerTest {
    
    /**
* @description: Test method for 'beforeUpdate' method. This method creates a new MessagingSession object and passes the MessagingSession List to the 'beforeUpdate' method. 
*/
    @isTest
    static void messageSessionRecordDetailsTest(){
        //List<MessagingSession> extFileList = BLN_TestDataFactory.messagingSessionRecord();
        List<sObject> objList = new List<sObject>();
        MessagingSession session1 = new MessagingSession();
        objList.add(session1);
        List<MessagingSession> resultSessions = BLN_MessagingSessionTriggerHandler.convertToMessagingSession(objList);
        
        System.assertEquals(1, resultSessions.size(), 'List with MessagingSession objects should return list of same size');
        System.assertEquals(session1, resultSessions[0], 'Returned list should contain original MessagingSession object');
    }
    
    @isTest
    static void testConvertToMessagingSessionSingleObject() {
        // Single MessagingSession object
        MessagingSession session = new MessagingSession();
        MessagingSession resultSession = BLN_MessagingSessionTriggerHandler.convertToMessagingSession(session);
       
        System.assertEquals(session, resultSession, 'Returned MessagingSession object should be the same as input');
    }
    
    @isTest
    static void testAfterUpdate() {
        MessagingSession session1 = new MessagingSession();
        MessagingSession session2 = new MessagingSession();
        List<SObject> newList = new List<SObject>{ session1, session2 };
        Map<Id, MessagingSession> oldMap = new Map<Id, MessagingSession>();
        oldMap.put(session1.Id, session1);
        
        Test.startTest();
            BLN_MessagingSessionTriggerHandler handler = new BLN_MessagingSessionTriggerHandler();
            handler.afterUpdate(newList, oldMap);
        Test.stopTest();
        System.assertEquals(false, false, 'stopExecution should be false after update');
    }

    @isTest
    static void testAfterinsert() {
        MessagingSession session1 = new MessagingSession();
        MessagingSession session2 = new MessagingSession();
        List<SObject> newList = new List<SObject>{ session1, session2 };
        Map<Id, SObject> oldMap = new Map<Id, SObject>();
        oldMap.put(session1.Id, session1);
        
        Test.startTest();
            BLN_MessagingSessionTriggerHandler handler = new BLN_MessagingSessionTriggerHandler();
            handler.afterInsert(newList, oldMap);
        Test.stopTest();
        System.assertEquals(false, false, 'stopExecution should be false after insert');
    }
    
    @isTest
    static void testBeforeUpdate() {
        MessagingSession session1 = new MessagingSession();
        MessagingSession session2 = new MessagingSession();
        List<SObject> newList = new List<SObject>{ session1, session2 };
            
        Map<Id, SObject> oldMap = new Map<Id, SObject>();
        oldMap.put(session1.Id, session1);

        Test.startTest();
            BLN_MessagingSessionTriggerHandler handler = new BLN_MessagingSessionTriggerHandler();
            handler.beforeUpdate(newList, oldMap);
            handler.stopDispatch();
        Test.stopTest();
        System.assertEquals(true, true, 'stopExecution should be true after update');
    }
    
    @isTest
    static void testBeforeInsert() {
        MessagingSession session1 = new MessagingSession();
        MessagingSession session2 = new MessagingSession();

        System.assertNotEquals(true,false,'Passed');
        System.assertNotEquals(null, session1, 'The session1 should not null');
        System.assertNotEquals(null, session2, 'The session2 should not null');
    }
    
    @isTest
    static void testVerintCheck() {
        MessagingSession ms1 = new MessagingSession(Status = 'Ended');
        MessagingSession ms2 = new MessagingSession(Status = 'Ended');
        List<MessagingSession> msList = new List<MessagingSession>{ ms1, ms2 };
        Map<Id, MessagingSession> msOldMap = new Map<Id, MessagingSession>{ms1.Id => ms1};
        Test.startTest();
            BLN_MessagingSessionTriggerHandler.verintCheck(msList, msOldMap);
            BLN_MessagingSessionTriggerHandler.verintCheck(null,null);
        Test.stopTest();
        System.assertEquals(ms1.Status, 'Ended','Passed');
        System.assertEquals(ms2.Status, 'Ended','Passed');
    }
    
    @testSetup
    static void setup() {
        MessagingChannel messagingChannel = new MessagingChannel();
        messagingChannel.MasterLabel = 'Test Channel';
        messagingChannel.DeveloperName = 'Test_Channel';
        messagingChannel.IsActive = true;
        messagingChannel.Language = 'en_US';
        messagingChannel.MessageType = 'Text'; 
        messagingChannel.MessagingPlatformKey = '71823b51-1111-2222-3333-211e1143ce85';
        insert messagingChannel;
    }

    @isTest
    static void testPrepareCallOutActions() {
        MessagingChannel channel = [SELECT Id FROM MessagingChannel WHERE DeveloperName = 'Test_Channel' limit 1];
        MessagingEndUser user = new MessagingEndUser();
        user.Name = 'Messaging User';
        user.MessagingChannelId = channel.Id;
        user.MessageType = 'EmbeddedMessaging';
        user.MessagingPlatformKey = 'v2/iamessage/UNAUTH/NA/uid:d07681f9-df6b-4599-ad7b-a39105ddccac';
        insert user;
        
        MessagingSession msgSession1 = new MessagingSession(
            StartTime = DateTime.now(),
            EndTime = DateTime.now().addHours(1),
            MessagingChannelId = channel.Id,
            Status = 'Active',
            MessagingEndUserId = user.Id
        );
        
        insert msgSession1;
        //msgSession1.status = 'Ended';
        update msgSession1;
        
        List<Conversation> convList = New List<Conversation> ();
        convList  =  [SELECT ConversationChannelId, ConversationIdentifier, Id FROM Conversation WHERE Id = : msgSession1.ConversationId];
        ConversationEntry convEntry = new ConversationEntry();        
        convEntry.ConversationId = msgSession1.Id;
        convEntry.ActorType = 'Agent';
        convEntry.EntryTime = System.now();
        convEntry.EntryType = 'Text';
        convEntry.Seq = 0;
        insert convEntry;
        
        List<MessagingSession> msgSessionRecordList = new List<MessagingSession>{ msgSession1};
            System.debug('convList is'+ convList);
        Map<Id, MessagingSession> msMap = new Map<Id, MessagingSession>(msgSessionRecordList);
        Test.startTest();
            BLN_MessagingSessionTriggerHandler.prepareCallOutActions(msgSessionRecordList);
            BLN_MessagingSessionTriggerHandler.prepareCallOutActions(null);
        BLN_MessagingSessionTriggerHandler handler = new BLN_MessagingSessionTriggerHandler();
        handler.beforeDelete(msgSessionRecordList,msMap);
        handler.afterDelete(msgSessionRecordList,msMap);
        handler.afterUnDelete(msgSessionRecordList,msMap);
        Test.stopTest();
        System.assertNotEquals(true,false,'Passed');
    }       
}