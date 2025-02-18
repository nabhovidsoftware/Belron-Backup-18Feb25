/** @description :  This apex class is used to delete financial document batch created before the archival limit
*   @Story :        FOUK-8956
*   @author:        hrithas.sardar@pwc.com (IN)
*   @CreatedDate:   23-09-2024
*/

public class LAD_DeleteFinancialDocumentsBatch implements Database.Batchable<SObject>, Database.Stateful{
    //variable to store date to delete previous financial document
    private Date financialDate;

    public LAD_DeleteFinancialDocumentsBatch() {
        // Get the value for limitlabel from the custom label and convert it to an integer
        String limitlabel = System.Label.LAD_FinancialDocument_ArchivalLimit;
        Integer monthoffset;
        
        
        if(limitlabel.isNumeric() || limitlabel.contains('.')){
            monthoffset=  Integer.valueOf(limitlabel);
        }
        else{
           monthoffset= 24;
        }
       
        if(Test.isRunningTest()){
            monthoffset = 0;
        }
         // Calculate the financial date
        financialDate = Date.today().addMonths(-monthoffset);
    }

   // Start method to define the query to retrieve records
    public Database.QueryLocator start(Database.BatchableContext BC) {
       // Query all FinancialDocument records that were created before the financial date
        String query = 'SELECT Id FROM 	LAD_Financial_Document__c WHERE CreatedDate < :financialDate';
        return Database.getQueryLocator(query);
    }

    // Execute method to process each batch of records
    public void execute(Database.BatchableContext BC, List<LAD_Financial_Document__c> scope) {
        try {
            // Perform a hard delete (permanent delete) of the records
            List<LAD_Financial_Document__c> documentsToDelete = scope;
            Database.delete(documentsToDelete, false); // Soft delete first

            // Permanently delete (hard delete) the records
            Database.emptyRecycleBin(documentsToDelete);
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