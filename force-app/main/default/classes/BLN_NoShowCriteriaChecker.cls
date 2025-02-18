/**
 * @description : The Apex class handles Task Creation and Updation Used in portal 
 * @author:  Vedita Kashi
 * @Story: FOUK-8205
 * @CreatedDate: 24/07/2024
 */
public without sharing class BLN_NoShowCriteriaChecker {

    // Wrapper class to hold criteria and match found flag
    public class NoShowCriteriaWrapper {
        public BLN_NoShowCriteria_mtd__mdt criteria;
        public Boolean matchFound;
        public Boolean newresult;
        public String status ; // Added Status field

        // public NoShowCriteriaWrapper(BLN_NoShowCriteria_mtd__mdt criteria, Boolean MatchFound) {
        //     this.criteria = criteria;
        //     this.MatchFound = MatchFound;
        // }
        public NoShowCriteriaWrapper(BLN_NoShowCriteria_mtd__mdt criteria, Boolean matchFound, String status) {
            this.criteria = criteria;
            this.matchFound = matchFound;
            this.status = status;
        }
    }

    /**
     * Method to check if a match exists between ServiceAppointment and BLN_NoShowCriteria_mtd__mdt
     * @param windowLocation - URL from where ServiceAppointment Id is extracted
     * @return JSON serialized string of List<NoShowCriteriaWrapper>
     */
   

    /*@AuraEnabled(cacheable=true)
    public static String getMatchingNoShowCriteria(String windowLocation) {
        String sid = extractSidFromUrl(windowLocation);
        List<NoShowCriteriaWrapper> wrappers = new List<NoShowCriteriaWrapper>();

        // Fetch ServiceAppointment record
        ServiceAppointment serviceAppointment = [SELECT Id, BLN_FailureReason__c, BLN_SubFailureReason__c, Status
                                                 FROM ServiceAppointment
                                                 WHERE Id = :sid];

        if (serviceAppointment != null) {
            // Fetch records from BLN_NoShowCriteria_mtd__mdt
            List<BLN_NoShowCriteria_mtd__mdt> reasonList = [
                SELECT BLN_FailReason__c, BLN_FailSubReason__c
                FROM BLN_NoShowCriteria_mtd__mdt
            ];

            // Iterate through the list to find matching criteria
            for (BLN_NoShowCriteria_mtd__mdt criteria : reasonList) {
                Boolean matchFound = (criteria.BLN_FailReason__c == serviceAppointment.BLN_FailureReason__c &&
                                      criteria.BLN_FailSubReason__c == serviceAppointment.BLN_SubFailureReason__c);
                
                NoShowCriteriaWrapper wrapper = new NoShowCriteriaWrapper(criteria, matchFound, serviceAppointment.Status);
                wrappers.add(wrapper);
            }
        }

        // Serialize the wrappers list to JSON string
        String wrappersJson = JSON.serialize(wrappers);

        return wrappersJson;
    }*/
    
    /**  
     * Method to check if a match exists between ServiceAppointment and BLN_NoShowCriteria_mtd__mdt  
     * @param windowLocation - URL from where ServiceAppointment Id is extracted  
     * @return JSON serialized string of List<NoShowCriteriaWrapper>  
     */  
    @AuraEnabled(cacheable=true)
public static String getMatchingNoShowCriteria(String windowLocation) {
    String sid = extractSidFromUrl(windowLocation);
    List<NoShowCriteriaWrapper> wrappers = new List<NoShowCriteriaWrapper>();

    // Check if the user has read access to ServiceAppointment and its fields
    // if (Schema.sObjectType.ServiceAppointment.isAccessible() &&
    //     Schema.sObjectType.ServiceAppointment.fields.BLN_FailureReason__c.isAccessible() &&
    //     Schema.sObjectType.ServiceAppointment.fields.BLN_SubFailureReason__c.isAccessible() &&
    //     Schema.sObjectType.ServiceAppointment.fields.Status.isAccessible()) {
        ServiceAppointment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        // Fetch ServiceAppointment record
        ServiceAppointment serviceAppointment = [
            SELECT Id, BLN_FailureReason__c, BLN_SubFailureReason__c, Status
            FROM ServiceAppointment
            WHERE Id = :sid
        ];

        if (serviceAppointment != null) {
            // Check if the user has read access to BLN_NoShowCriteria_mtd__mdt
            if (Schema.sObjectType.BLN_NoShowCriteria_mtd__mdt.isAccessible()) {
                // Fetch records from BLN_NoShowCriteria_mtd__mdt
                List<BLN_NoShowCriteria_mtd__mdt> reasonList = [
                    SELECT BLN_FailReason__c, BLN_FailSubReason__c
                    FROM BLN_NoShowCriteria_mtd__mdt
                ];

                // Iterate through the list to find matching criteria
                for (BLN_NoShowCriteria_mtd__mdt criteria : reasonList) {
                    Boolean matchFound = (criteria.BLN_FailReason__c == serviceAppointment.BLN_FailureReason__c &&
                                          criteria.BLN_FailSubReason__c == serviceAppointment.BLN_SubFailureReason__c);

                    NoShowCriteriaWrapper wrapper = new NoShowCriteriaWrapper(criteria, matchFound, serviceAppointment.Status);
                    wrappers.add(wrapper);
                }
            } else {
                // Handle the case where the user does not have access to the metadata
                throw new CustomAccessException('Access to BLN_NoShowCriteria_mtd__mdt is denied');
            }
        }
    // } else {
    //     // Handle the case where the user does not have access to the ServiceAppointment object or fields
    //     throw new CustomAccessException('Access to ServiceAppointment or its fields is denied');
    // }

    // Serialize the wrappers list to JSON string
    String wrappersJson = JSON.serialize(wrappers);

    return wrappersJson;
}


    /**
     * Method to extract ServiceAppointment Id from window location URL
     * @param windowLocation - URL from where ServiceAppointment Id is extracted
     * @return ServiceAppointment Id as String
     */
    private static String extractSidFromUrl(String windowLocation) {
        String sid = windowLocation.right(18); // Assuming Id length is 18 characters
        return sid;
    }
    
    // Custom exception class for insufficient privileges
    public class CustomAccessException extends Exception {}
}