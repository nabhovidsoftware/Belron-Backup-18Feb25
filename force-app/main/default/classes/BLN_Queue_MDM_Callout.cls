public class BLN_Queue_MDM_Callout extends BLN_MDM_CalloutSetup implements Queueable, Database.AllowsCallouts  {
	
    BLN_MDM_Configuration.MDMParameters MDMParameter{get;set;}
    
    public BLN_Queue_MDM_Callout(BLN_MDM_Configuration.MDMParameters parameters){
     	this.MDMParameter=parameters; 
    }
    
    public void execute(QueueableContext context) {
        try{
            //todo:If required add Finalizer
            //HTTP callout
        }catch(exception ex){
            system.debug(ex);
            //Logger entry 
        }
    } 
}