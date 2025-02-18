/** @description : Test class for BLN_RelationshipMatrixController.
*   @Story : FOUK-2031
*   @author:PWC-India
*   @CreatedDate: 16/02/2024
*/
@isTest
public class BLN_RelationshipMatrixControllerTest {
    /*****************************************
*MethodName : getRelationshipTest
*@description This method is used to test relationship Records.
*Input Parameter : 
*Output Parameter : void
*CreatedDate: 16-02-2024
*CreatedBy : Pwc-India
*Change log :
****************************************/
    @isTest
    static void getRelationshipTest(){
        //Initialization
           String role = '';
        
         Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]?.Id;//Retrieves the Id of the System Administrator profile
     
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        //Create Test User
    User testSalesPerson = new User(
            UserroleId =role,
            ProfileId = adminProfileId,
            FirstName = 'PS',
            LastName = 'Test User',
            UserName = System.now().getTime() + '@test.demo',
            Alias = 'pstes',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true);            
        
        //insert adminUser;
        insert testSalesPerson;
        System.runas(testSalesPerson){
            
            Account testAccount = BLN_TestDataFactory.createSalesAccount('TestRelationShipAccount','Agriculture','Underwriter',1,'Insurance','GB123456779', 'AA161811','San Francisco', 'testStreet','12345' ,'GB','Blue Anchor' ,'Minehead',
            '7890' , 'United Kingdom','BLN_CustomerB2BAccount');
insert testAccount;
Contact testContactData = BLN_TestDataFactory.createSalesContact('Test', 'Contact', testAccount.Id,'Manager','No Influence','Advocate');
insert testContactData;


BLN_Relationship__c testRelationshipData = BLN_TestDataFactory.createRelationship('Desired Contact',testSalesPerson.id,testAccount.id,testContactData.Id);
        insert testRelationshipData;
        
        Test.startTest();
        Map<Id, List<BLN_Relationship__c>> relationsMap = BLN_RelationshipMatrixController.getRelationships(testAccount.Id);
        Test.stopTest();
        
        system.runAs(testSalesPerson){
            System.assertEquals(testContactData.Id, new List<Id>(relationsMap.keySet())[0], 'Relationship records is quered');
            System.assertNotEquals('',new List<Id>(relationsMap.keySet())[0], 'Relationship records are not quereyed');
            
        }}
        
    }
    /*****************************************
*MethodName : getRelationshipIdTest
*@description This method is used to test relationshipId .
*Input Parameter : 
*Output Parameter : void
*CreatedDate: 16-02-2024
*CreatedBy : Pwc-India
*Change log :
****************************************/
    
    @isTest
    static void getRelationshipIdTest(){
       
        
          String role = '';
        
        /*User testSalesPerson = BLN_TestDataFactory.createSalesTestUser('salesuser' + DateTime.now().getTime() + '@testorg.com', 'Belron Integration Profile', 'salesus', 'salesuser@testorg.com', 'salesuser',
         'en_US', 'en_US', 'Europe/London', 'UTF-8');
        testSalesPerson.UserRoleId= role;*/
        
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]?.Id;
        //String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
    User testSalesPerson = new User(
            UserroleId =role,
            ProfileId = adminProfileId,
            FirstName = 'PS',
            LastName = 'Test User',
            UserName = System.now().getTime() + '@test.demo',
            Alias = 'pstes',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true);            
        //insert adminUser;
      
        
        insert testSalesPerson;
        System.runas(testSalesPerson){
            
             Account testAccount = BLN_TestDataFactory.createSalesAccount('TestRelationShipAccount','Agriculture','Underwriter',1,'Insurance','GB123456779', 'AA161811','San Francisco', 'testStreet','12345' ,'GB','Blue Anchor' ,'Minehead',
                                                                     '7890' , 'United Kingdom','BLN_CustomerB2BAccount');
        insert testAccount;
        Contact testContactData = BLN_TestDataFactory.createSalesContact('Test', 'Contact', testAccount.Id,'Manager','No Influence','Advocate');
        insert testContactData;


        BLN_Relationship__c testRelationshipData = BLN_TestDataFactory.createRelationship('Desired Contact',testSalesPerson.id,testAccount.id,testContactData.Id);
        insert testRelationshipData;
        Test.startTest();
        String relationshipId = BLN_RelationshipMatrixController.getRelationshipId(testContactData.Id,testSalesPerson.LastName);
        //String relationshipId1 = BLN_RelationshipMatrixController.getRelationshipId('test',testSalesPerson.LastName);

        Test.stopTest();
        
        //system.runAs(testSalesPerson){
            System.assertNotEquals(testRelationshipData.Id, relationshipId,'RelationId is matched');
            System.assertNotEquals('',relationshipId, 'RelationshipId is not matched');
        }
        
    }
    /*****************************************
*MethodName : handleCatchTest
*@description This method is used to test .
*Input Parameter : 
*Output Parameter : void
*CreatedDate: 16-02-2024
*CreatedBy : Pwc-India
*Change log :
****************************************/
    
    @isTest
    static void handleCatchTest(){
        
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1]?.Id;
        String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
    User testSalesPerson = new User(
            UserroleId =role,
            ProfileId = adminProfileId,
            FirstName = 'PS',
            LastName = 'Test User',
            UserName = System.now().getTime() + '@test.demo',
            Alias = 'pstes',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true);            
        //insert adminUser;
      
        
        insert testSalesPerson;
        System.runas(testSalesPerson){

        
        Test.StartTest();
        String relationshipId = BLN_RelationshipMatrixController.getRelationshipId('','');        
        Test.stopTest();
        system.runAs(testSalesPerson){
            System.assertEquals(null, relationshipId,'Null is matched');
            System.assertNotEquals('',relationshipId, 'Null not matched');
        }
 
        } }
}