public class BLN_Queue_MDM_GateWay extends BLN_MDM_CalloutSetup implements Queueable {
    
	string Stream{get;set;}
    string FieldsJson{get;set;}
    BLN_MDM_Configuration.MDMParameters MDMParameter{get;set;}
    
    public BLN_Queue_MDM_GateWay(BLN_MDM_Configuration.MDMParameters parameters){
     	this.MDMParameter=parameters;
    }
    
    public void execute(QueueableContext context) {
        try{
            //todo:If required add Finalizer
        	initalizeSetup();
            if(!string.isempty(FieldsJson)){
                BLN_MDM_Configuration.MDMParameters up_Param=new BLN_MDM_Configuration.MDMParameters();
                
                up_Param=MDMParameter;
                up_Param.FieldsToSync=FieldsJson;
                up_Param.fieldsToSync_DataType='STRING';
                
                //HTTP callout
                BLN_Queue_MDM_Callout mdmGateway=new BLN_Queue_MDM_Callout(up_Param); 
        		System.enqueueJob(mdmGateway);
            }
             
        }catch(exception ex){
            system.debug(ex);
            //Logger entry 
        }
    } 
    
    void initalizeSetup(){
      	//Setup
        string objectName=MDMParameter.SourceObject;
        list<sobject> lstMDM_MetaConfig=GetMDMFieldMapping(objectName);
        Map<string,Map<string,string>> mpFieldsToSync=(Map<string,Map<string,string>>)MDMParameter.FieldsToSync;
        Map<string,string> mpChangedField=mpFieldsToSync.values()[0];//for now sends single record fields.
        FieldsJson=GetJsonBodyByMDMMapping(mpChangedField,lstMDM_MetaConfig);
    }
}