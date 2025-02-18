/**@description : This Apex class used to break the records into batches and enqueue the job.
*  @author: PwC India
*  @Story: 
*  @CreatedDate: 10/07/2024
*/
public without sharing class BLN_QueueMSGSessionGateWay implements Database.Batchable<String> {
    private List<String> jsonList = new List<String>();
    
    public BLN_QueueMSGSessionGateWay(List<String> payloadList){
        jsonList = payloadList;
    }

    public List<String> start(Database.BatchableContext bc){
        return jsonList;
    } 
    public void execute(Database.BatchableContext bc, List<String> jsonList){
        for(String payload : jsonList){
            initiateJob(payload);
        }
    }

    public void finish(Database.BatchableContext bc){
        AsyncApexJob asyncJobId = [SELECT Id,Status,NumberOfErrors, JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :bc.getJobId()];
    }

    private Id initiateJob(String payload){
        Id jobId = System.enqueueJob(new BLN_QueueMSGSessionCallout(payload));
        
        return jobId;
    }
}