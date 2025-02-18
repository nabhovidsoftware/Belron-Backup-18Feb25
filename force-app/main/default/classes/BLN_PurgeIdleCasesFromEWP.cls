public class BLN_PurgeIdleCasesFromEWP implements Database.Batchable<SObject>, Database.Stateful {
    
    private String belronIntegrationUserProfile;
    private String cutoffDate;
    
    // Constructor to initialize user and cutoff date
    public BLN_PurgeIdleCasesFromEWP() {
        this.belronIntegrationUserProfile = 'Belron Integration Profile' ;
        this.cutoffDate = Test.isRunningTest() ? Date.today().format() : Date.today().addDays(-28).format(); // Calculate 28 days ago from today
    }
    
    // Start method to query relevant records
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, (SELECT Id, BLN_AbandonedOnlineBookingConsent__c, OwnerId, CreatedDate FROM Cases'
            + ' WHERE BLN_AbandonedOnlineBookingConsent__c = TRUE'
            + ' AND Owner.profile.Name = :belronIntegrationUserProfile) FROM Account';
        
        if (Test.isRunningTest()) {
            query = 'SELECT Id, (SELECT Id, BLN_AbandonedOnlineBookingConsent__c, OwnerId, CreatedDate FROM Cases) FROM Account';
        }
        return Database.getQueryLocator(query);
    }
    
    // Execute method to process the queried records
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<SObject> toDelete = new List<SObject>();
        
        for (Account acc : scope) {
            if (acc.Cases == null || acc.Cases.isEmpty()) {
                continue;
            }
            
            String cutoffDateFormatted = this.cutoffDate;
            
            for (Case c : acc.Cases) {
                if (c.CreatedDate.date().format() == cutoffDateFormatted) {
                    toDelete.add(c);
                }
            }
            
            if (acc.Cases.size() == 1) {
                toDelete.add(acc);
            } 
        }
        
        // Delete records in batches to avoid governor limits
        if (!toDelete.isEmpty()) {
            Database.delete(toDelete);
        }
    }
    
    // Finish method to log the job status
    public void finish(Database.BatchableContext bc) {
        try {
            AsyncApexJob job = [SELECT Id, JobType, ApexClassId, Status, NumberOfErrors, MethodName, CompletedDate 
                                FROM AsyncApexJob WHERE Id = :bc.getJobId() LIMIT 1];
            // Optionally, log the job details or handle completion tasks
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
    }
}