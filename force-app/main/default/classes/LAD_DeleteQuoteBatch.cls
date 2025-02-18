public class LAD_DeleteQuoteBatch implements Database.Batchable<SObject>, Database.Stateful{
    // The variable to store the cut-off date
    private Date cutoffDate;

    public LAD_DeleteQuoteBatch() {
        // Get the value of 'n' from the custom label and convert it to an integer
        String yearsStr = System.Label.LAD_QuoteHandler_InternalLimit;
        Integer years;
        
        if(!yearsStr.isNumeric() || yearsStr.contains('.')){
            years = 2;
        }
        else{
            years = Integer.valueOf(yearsStr);
        }
        // Calculate the cutoff date
        cutoffDate = Date.today().addYears(-years);
    }

    // Start method to define the query to retrieve records
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query all Quote records that were created before the cutoff date
        String query = 'SELECT Id FROM LAD_Quote__c WHERE CreatedDate < :cutoffDate';
        return Database.getQueryLocator(query);
    }

    // Execute method to process each batch of records
    public void execute(Database.BatchableContext BC, List<LAD_Quote__c> scope) {
        try {
            // Perform a hard delete (permanent delete) of the records
            List<LAD_Quote__c> quotesToDelete = scope;
            Database.delete(quotesToDelete, false); // Soft delete first

            // Permanently delete (hard delete) the records
            Database.emptyRecycleBin(quotesToDelete);
        } catch (Exception e) {
            // Handle any exceptions
            System.debug('Exception: ' + e.getMessage());
        }
    }

    // Finish method
    public void finish(Database.BatchableContext BC) {
        // Any final processing or logging can be done here
        System.debug('Batch process finished.');
    }
}