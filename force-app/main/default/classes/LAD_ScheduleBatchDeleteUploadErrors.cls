/* description :   This apex class is used to schedule LAD_ScheduleBatchDeleteUploadErrors batch class
   author:         (punam.patil@pwc.com (IN))
   Story:          FOUK-10117
*/


public class LAD_ScheduleBatchDeleteUploadErrors implements Schedulable{
    //creat schedule
    public void execute(SchedulableContext context){
        LAD_BatchDeleteUploadErrors batchJob = new LAD_BatchDeleteUploadErrors();
        Database.executeBatch(batchJob);
    }

}