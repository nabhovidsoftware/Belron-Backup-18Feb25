/** @description :  This is the test class for LAD_contactUsForm
*   @Story :        FOUK-9936
*   @author:        (ashwin.r.raja@pwc.com (IN))
*   @CreatedDate:   09-09-2024
*/

@isTest
public class LAD_contactUsFormTest {
	@TestSetup
    static void testUploadFileSuccess() {
        User u = LAD_TestDataFactory.createAdminUser();
        PermissionSet ps = [
          SELECT Id
          FROM PermissionSet
          WHERE Name = 'BLN_BypassValidationRules'
        ];
        insert new PermissionSetAssignment(
          AssigneeId = u.id,
          PermissionSetId = ps.Id
        );
        
        //Individual individual = new Individual();
         // individual.LastName = 'Test';
          //insert individual;
        
        System.runAs(u){
        Account testAccount = new Account(Name = 'ABC Corp');
        insert testAccount;
        Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id /*IndividualId = individual.id*/);
        insert testContact;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Laddaw B2B Commerce External User' LIMIT 1];
        user testUser = New User(UserName = 'test_' + math.random() + '@test.com',
                                 FirstName = 'Test-First',
                                 LastName = 'Test-Last',
                                 Alias = 'test',
                                 email = 'test' + math.random() + '@test.com',
                                 CommunityNickName = string.valueOf(math.random()).substring(0,6),
                                 ProfileID = p.id,
                                 ContactId = testContact.Id,
                                 TimeZoneSidKey = 'America/New_York', 
                                 LocaleSidKey = 'en_US', 
                                 EmailEncodingKey = 'UTF-8', 
                                 LanguageLocaleKey = 'en_US');
        insert testUser; 
       }
    }
    
   	@isTest
    static void testcreateCasesforGuestUser(){
        Id acc = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        Id u = [SELECT Id FROM User WHERE FirstName = 'Test-First' AND LastName = 'Test-Last' LIMIT 1].Id;
        Map<String,String> data = LAD_contactUsForm.fetchData(u, acc);
        LAD_contactUsForm.CaseWrapper newCase = new LAD_contactUsForm.CaseWrapper();
        newCase.accountId = acc;
        newCase.description = 'test';
        newCase.type = 'General Enquiry';
        newCase.reason = 'Service';
        
        Test.startTest();
        LAD_contactUsForm.createCases(newCase,null);
        Test.stopTest();
    }
    
    @isTest
    static void testcreateCasesforAuthUser(){
        Id acc = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        Id u = [SELECT Id FROM User WHERE FirstName = 'Test-First' AND LastName = 'Test-Last' LIMIT 1].Id;
        Map<String,String> data = LAD_contactUsForm.fetchData(u, acc);
        LAD_contactUsForm.CaseWrapper newCase = new LAD_contactUsForm.CaseWrapper();
        newCase.accountId = acc;
        newCase.description = 'test';
        newCase.type = 'General Enquiry';
        newCase.reason = 'Service';
        
        Test.startTest();
        LAD_contactUsForm.createCases(newCase, u);
        Test.stopTest();
    }
    
    @isTest
    static void testuploadFile(){
        String base64Data = 'SGK';
        String fileName = 'testfile.txt';
        Id acc = [SELECT Id from Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        Id conId = [SELECT Id from Contact WHERE LastName = 'Test' LIMIT 1].Id;
        Id laddawCase= [SELECT Id FROM RecordType WHERE DeveloperName='LAD_Laddaw_Case'].Id;
        Case newCase = new Case(AccountId = acc, ContactId = conId, RecordTypeId = laddawCase);
        insert newCase;
        
        Test.startTest();
        String contentDocumentLinkId = LAD_contactUsForm.uploadFile(base64Data, fileName, newCase.Id);
        Test.stopTest();
        
        ContentDocumentLink cdl = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE Id = :contentDocumentLinkId LIMIT 1];
        System.assertNotEquals(null, cdl, 'ContentDocumentLink should be created.');
        System.assertEquals(newCase.Id, cdl.LinkedEntityId, 'LinkedEntityId should match the Account Id.');

    }
}