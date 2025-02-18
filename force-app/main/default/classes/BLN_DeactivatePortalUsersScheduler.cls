Public with sharing class BLN_DeactivatePortalUsersScheduler implements Schedulable {
   
    Public void execute (SchedulableContext sC){
        BLN_DeactivatePortalUsers batchImpliedObj = new  BLN_DeactivatePortalUsers();
        database.executeBatch(batchImpliedObj);
    }
    public static void scheduleJob(){
        string sch = '0 0 0 * * ?';
        system.schedule ('Batch', sch, new BLN_DeactivatePortalUsersScheduler());
    }
}