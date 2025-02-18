/* description :  Abandoned Cart Time Limit
       			  This apex class is used to delete cart records which are inactive for 48 hours from last modified date
	author:       (punam.patil@pwc.com (IN))
    Story:         FOUK-8504
*/
public class LAD_BatchDeleteInactiveCarts implements Database.Batchable<sObject>{
    
    public boolean isTest=false;
    public LAD_BatchDeleteInactiveCarts(boolean isTest){
        this.isTest=istest;
    }
    //start method
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        DateTime cartTime = System.now().addHours(-48);
        String storeName = Label.LAD_storeName;
        string CartStatus=label.LAD_cartStatus;
       // string sId = [select id,name from WebStore where name='Laddaw' limit 1].id;
        string storeId;
        list<webStore> storeData = [select id,name from WebStore where name=:storeName limit 1];
        if(!storeData.isEmpty())
        {
         storeId=storeData[0].id;    
        }
        
        string query = 'SELECT ID, CreatedDate, lastmodifieddate FROM webCart';
        if(isTest){
            query=query+' WHERE lastmodifieddate <= LAST_N_DAYS:2 AND lastmodifieddate < :cartTime AND WebStoreId =:storeId AND Status !=:CartStatus';
        }
                   
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<WebCart> scope){
        system.debug('scope is:  ' +scope);
        if(!scope.isEmpty()){
            try{ delete scope;					// delete records
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