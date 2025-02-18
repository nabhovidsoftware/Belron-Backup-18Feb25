/** @description :  This class is used to create cases from a contact us form
*   @Story :        FOUK-9936
*   @author:        (ashwin.r.raja@pwc.com (IN))
*   @CreatedDate:   09-09-2024
*/

public with sharing class LAD_contactUsForm {
    @AuraEnabled
    public static Map<String,String> fetchData(string userId, string accountId){
      try {
              Map<String, String> data = new Map<String,String>();
              User u = [SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.Phone, Contact.Email
                        FROM User 
                        WHERE Id =:userId];
              Account acc = [SELECT Name, AccountNumber FROM Account WHERE Id=:accountId];
              data.put('firstName',u.Contact.FirstName);
              data.put('lastName', u.Contact.LastName);
              data.put('accountName',acc.Name);
              data.put('accountNumber',acc.AccountNumber);
              data.put('phoneNumber',u.Contact.Phone);
              data.put('email',u.Contact.Email);
              return data;
      } 
      catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }

/** @description :  This method is used to create cases from the data from contact us form
*   @Story :        FOUK-9936
*   @author:        (ashwin.r.raja@pwc.com (IN))
*   @CreatedDate:   09-09-2024
*/
    @AuraEnabled
    public static String createCases(CaseWrapper casesData, String userId) {
        RecordType laddawCase= [SELECT Id FROM RecordType WHERE DeveloperName='LAD_Laddaw_Case'];
        Group hubTeam = [SELECT Id 
                         FROM Group 
                         WHERE Type = 'Queue' AND DeveloperName = 'LAD_Hub_Team_Queue'];
        String caseIds;
        Case newCase = new Case();
        
        if(userId == null){
            newCase.RecordTypeId = laddawCase.Id;
            newCase.Description = casesData.description;
            newCase.Type = casesData.type;
            newCase.BLN_SubType__c = casesData.reason;
            newCase.Origin = 'Web';
            newCase.LAD_First_Name__c = casesData.firstName;
            newCase.LAD_Last_Name__c = casesData.lastName;
            newCase.LAD_Company_Name__c = casesData.accountName;
            newCase.LAD_Phone_Number__c	= casesData.phoneNumber;
            newCase.SuppliedEmail = casesData.email;
            newCase.OwnerId = hubTeam.Id;
        }
        else{
              User u = [SELECT Id, ContactId, AccountId, Profile.Name 
              FROM User 
              WHERE Id =:userId];
              newCase.RecordTypeId = laddawCase.Id;
              newCase.Description = casesData.description;
              newCase.Type = casesData.type;
              newCase.BLN_SubType__c = casesData.reason;
              newCase.Origin = 'Web';
              newCase.AccountId = casesData.accountId;
              newCase.OwnerId = hubTeam.Id;
        }

        try {
                insert newCase;
                caseIds = newCase.Id;
                return caseIds;
            } catch (Exception e) {
                throw new AuraHandledException('Error creating cases: ' + e.getMessage());
            }
    }

    public class CaseWrapper {
        @AuraEnabled
        public String firstName { get; set; }
        @AuraEnabled
        public String lastName { get; set; }
        @AuraEnabled
        public string type{ get; set; }
        @AuraEnabled
        public string reason{ get; set; }
        @AuraEnabled
        public string accountName { get; set; }
        @AuraEnabled
        public string accountId { get; set; }
        @AuraEnabled
        public string email { get; set; }
        @AuraEnabled
        public string phoneNumber { get; set; }
        @AuraEnabled
        public string description { get; set; }
    }

/** @description :  This method is used to upload the attachements from the contact us form to the respective case
*   @Story :        FOUK-9936
*   @author:        (ashwin.r.raja@pwc.com (IN))
*   @CreatedDate:   09-09-2024
*/
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
          ContentVersion cv = createContentVersion(base64, filename);        
          ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
          if (cv == null || cdl == null) { return null; }
          return cdl.Id;
    }
    
    private static ContentVersion createContentVersion(String base64, String filename) {
      ContentVersion cv = new ContentVersion();
      cv.VersionData = EncodingUtil.base64Decode(base64);
      cv.Title = filename;
      cv.PathOnClient = filename;
      
      try {
        insert cv;
        return cv;
      } catch(DMLException e) {
        System.debug(e);
        return null;
      }
    }
  
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
                if (contentVersionId == null || recordId == null) { return null; }
      ContentDocumentLink cdl = new ContentDocumentLink();
      cdl.ContentDocumentId = [
        SELECT ContentDocumentId 
        FROM ContentVersion 
        WHERE Id =: contentVersionId
      ].ContentDocumentId;
      cdl.LinkedEntityId = recordId;
      // ShareType is either 'V', 'C', or 'I'
      // V = Viewer, C = Collaborator, I = Inferred
      cdl.ShareType = 'V';
      try {
        insert cdl;
        return cdl;
      } catch(DMLException e) {
        System.debug(e);
        return null;
      }
    }
}