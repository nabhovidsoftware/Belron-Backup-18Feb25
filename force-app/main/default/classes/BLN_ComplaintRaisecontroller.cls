/*
ClassName : BLN_ComplaintRaisecontroller having test class BLN_ComplaintRaisecontrollerTest
Description :	
@Story : FOUK-7476
CreatedDate: 30/04/2024
LastModified date : 30/04/2024
CreatedBy : Dheeraj Sharma
*/

public without sharing class BLN_ComplaintRaisecontroller {

    // Method to retrieve RecordTypeId based on RecordType Label
    private static Id getRecordTypeId(String objectApiName, String recordTypeLabel) {
        Id recordTypeId = null;
        
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = :objectApiName AND DeveloperName = :recordTypeLabel LIMIT 1];
        if (!recordTypes.isEmpty()) {
            recordTypeId = recordTypes[0].Id;
        }
        
        return recordTypeId;
    }

    @AuraEnabled(cacheable=true)
    public static String isVRNRegistered(String vrn) {
        String vehicleId = null;
        List<BLN_Vehicle__c> existingVehicles = [SELECT Id FROM BLN_Vehicle__c WHERE BLN_VehicleRegNumber__c = :vrn LIMIT 1];
        if (!existingVehicles.isEmpty()) {
            vehicleId = existingVehicles[0].Id;
        }
        return vehicleId;
    }

   @AuraEnabled
    public static Map<String,String> createCaseRecord(Case caseData, String base64Data, String fileName) {
        Map<String,String> caseRecordMap = new Map<String,String>();
        List<Case> insertCaseList = new List<Case>();
        string caseId = null;
        try {
            caseData.Type = 'Feedback';
            caseData.BLN_SubType__c = 'Complaint';

            // Retrieve RecordTypeId dynamically based on RecordType Label
            caseData.RecordTypeId = getRecordTypeId('Case', 'BLN_Feedback'); // Change 'Case' to your object API name
            System.debug('RecordTypeId: ' + caseData.RecordTypeId); // Log RecordTypeId for debugging

            if (caseData.RecordTypeId == null) {
                throw new AuraHandledException('Invalid Record Type');
            }

            // Set AssignmentRule and EmailHeader options
            setAssignmentRuleOptions(caseData);

            // Insert the Case record
            insert caseData;
            if(caseData.Id!=null){
            caseId = caseData.Id;
             insertCaseList = [select id ,CaseNumber from case where Id =: caseData.Id];
            }
            if(insertCaseList!=null){
                
                caseRecordMap.put('Id',insertCaseList[0].Id);
                caseRecordMap.put('CaseNumber',insertCaseList[0].CaseNumber);

            }
           

            // Process file attachment if base64Data and fileName are provided
            if (base64Data != null && fileName != null) {
                processFileAttachment(caseId, base64Data, fileName);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error creating case: ' + e.getMessage());
        }
        return caseRecordMap;
    }

    // Helper method to set AssignmentRule and EmailHeader options for Case
    private static void setAssignmentRuleOptions(Case caseData) {
        AssignmentRule AR = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true AND Name = 'B2B Case Assignment Rules' LIMIT 1];
        if (AR != null) {
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.Id;
            dmlOpts.EmailHeader.triggerAutoResponseEmail = true;
            dmlOpts.EmailHeader.triggerUserEmail = true;
            caseData.setOptions(dmlOpts);
        } else {
            throw new AuraHandledException('Assignment rule not found');
        }
    }

    // Helper method to process file attachment and link to Case
    private static void processFileAttachment(Id caseId, String base64Data, String fileName) {
        // Insert ContentVersion for the file attachment
        ContentVersion contentVersion = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName,
            VersionData = EncodingUtil.base64Decode(base64Data),
            IsMajorVersion = true
        );
        insert contentVersion;

        // Create ContentDocumentLink to link the file to the Case
        ContentDocumentLink contentLink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
            LinkedEntityId = caseId,
            ShareType = 'V'
        );
        insert contentLink;
    }
}