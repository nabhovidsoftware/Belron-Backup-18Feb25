/*****************************************
ClassName : BLN_QueueMSGSessionGateWayTest
Description : 
CreatedDate: 12-07-2024
CreatedBy : PwC-India
***************************************/
@isTest
public class BLN_QueueMSGSessionGateWayTest {

    @isTest
    static void testExecuteBatchClass() {

        // Mock data to be used.
       // List<String> jsonList = new List<String>{'{"Test": "value"}'};
       List<String> jsonList = new List<String>();
        String json = '{'+
		'\"initialisedSystem\" : \"Salesforce\",'+
		'\"timestamp\" : \"2024-07-15T12:44:22+01:00\",'+
		'\"sourceSystem\" : \"Salesforce\",'+
		'\"eventType\" : \"Create\",'+
		'\"entityID\" : \"0MwFg000001LIZFKA4\",'+
		'\"entityName\" : \"Event\",'+
		'\"data\" : {'+
		'\"current\" : {'+
		'\"participants\" : [ {'+
		'\"role\" : \"EndUser\",'+
		'\"key\" : \"v2/iamessage/UNAUTH/NA/uid:d07681f9-df6b-4599-ad7b-a39105ddccac\",'+
		'\"id\" : \"0PAFg000001LaxZOAS\",'+
		'\"name\" : \"Guest\"'+
		'} ],'+
		'\"language\" : \"en_US\",'+
		'\"name\" : \"Web Message\",'+
		'\"endTime\" : \"2024-07-15T11:44:21.000Z\",'+
		'\"startTime\" : \"2024-07-15T11:40:24.000Z\",'+
		'\"eventTypeName\" : \"EmbeddedMessaging\",'+
		'\"eventConversationId\" : \"4fc1ef11-851f-4e90-a361-a90bc1472387\"'+
		'}'+
		'}'+
		'}';
        jsonList.add(json);
        
        BLN_QueueMSGSessionGateWay gateWayBatch = new BLN_QueueMSGSessionGateWay(jsonList);
        
        Test.startTest();
        // Enqueue only one batch job
        Id batch = Database.executeBatch(gateWayBatch);
        Test.stopTest();
        
        // Ensure the batch was queued correctly.
        AsyncApexJob job = [SELECT Status FROM AsyncApexJob Where ID = :batch];
        System.assertNotEquals(job, null, 'Test');
    }
}