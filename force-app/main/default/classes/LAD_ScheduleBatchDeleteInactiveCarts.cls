/* description :   This apex class is used to schedule LAD_BatchDeleteInactiveCarts batch class
   author:         (punam.patil@pwc.com (IN))
   Story:          FOUK-8504
*/


public class LAD_ScheduleBatchDeleteInactiveCarts implements Schedulable{
    //creat schedule
    public void execute(SchedulableContext context){
        LAD_BatchDeleteInactiveCarts batchJob = new LAD_BatchDeleteInactiveCarts(true);
        Database.executeBatch(batchJob);
    }

}