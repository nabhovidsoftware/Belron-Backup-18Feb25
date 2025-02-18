/* description :  LAD_BatchDeleteUploadErrors
 				  This batch class is used to delete records from LAD_Upload_Error__c object which is created before 1 year. 	
	author:       (punam.patil@pwc.com (IN))
    Story:         FOUK-10117
    Create Date : 20/08/2024
*/

public class LAD_BatchDeleteUploadErrors implements Database.Batchable<sObject> {
    
    public LAD_BatchDeleteUploadErrors ()
    {
        
    }
     
          
    //start method
     
    public Database.QueryLocator start(Database.BatchableContext bc)
    {    
        string query = 'SELECT Id FROM LAD_Upload_Error__c where createdDate < LAST_N_YEARS : 1';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<LAD_Upload_Error__c> scope){
        system.debug('scope is:  ' +scope);
        if(!scope.isEmpty()){
            try{ 
                delete scope;					            // delete records
                system.debug('Record is: '+scope);
            }   
        	catch(Exception e)
            {
                System.debug(e.getMessage());
            }
        } 
        else{
            System.debug('No record found');
        }
    }
    public void finish(Database.BatchableContext bc){
        //for logic after finish like confirmation message.
    }
}