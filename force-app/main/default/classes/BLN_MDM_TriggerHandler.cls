public class BLN_MDM_TriggerHandler extends BLN_MetaData_Handler {
    
    Map<string,Map<string,string>> MDMFields{get;set;}
    string objectName{get;set;}
    System.TriggerOperation operationType{get;set;}
    
    Map<Id, SObject> oldMap{get;set;}
    {
        oldMap=new Map<Id, SObject>();
    }
    Map<Id, SObject> newMap {get;set;}
    {
        newMap=new Map<Id, SObject>();
    }
    
    public void HandleTriggerRequest(string trg_objectName,System.TriggerOperation trg_operationType ,Map<Id, SObject> trg_oldMap, Map<Id, SObject> trg_newMap){
        
        if((trg_operationType==System.TriggerOperation.AFTER_INSERT) || (trg_operationType==System.TriggerOperation.AFTER_UPDATE)){
            system.debug('Inside');
            this.objectName=trg_objectName;
            this.operationType=trg_operationType;
            this.oldMap=trg_oldMap;
            this.newMap=trg_newMap;
            //Process Request
            this.ValidateRequest();
        }
    }
    
    void ValidateRequest(){
        try{
            string fieldSetName=GetConfigurations();
            system.debug('GetConfigurations');
            set<string> fieldSet=GetFielsetFields(objectName, fieldSetName);
            MDMFields=GetFieldsChanged(oldMap.values(),newMap.values(),fieldSet);
            if(MDMFields.size()>0){
                PrepareCallOutActions();
                system.debug('PrepareCallOutActions');
            }
        }catch(exception ex){
            system.debug(ex);
        }
    }
    
    void PrepareCallOutActions()
    {
        BLN_MDM_Configuration.MDMParameters param=new BLN_MDM_Configuration.MDMParameters();
        param.StreamName='Sales';
        param.FieldsToSync=MDMFields;
        param.SourceObject=objectName;
        system.debug(MDMFields);
        BLN_Queue_MDM_GateWay mdmGateway=new BLN_Queue_MDM_GateWay(param); 
        System.enqueueJob(mdmGateway);
    }
    
    string GetConfigurations(){
        BLN_MDM_Configuration.Metadata_Retreiver_Param meta_Parameters= GetSobjectFieldSet(objectName);
        string fieldSetName='';
        if(meta_Parameters==null){
            throw new IllegalArgumentException('Parameters cannot be null or empty');
        }
        
        list<sobject> retrieveSettings=retrieveMetaData(meta_Parameters); 
        if(retrieveSettings.size()==0){
            throw new IllegalArgumentException('Metadata configuration is missing'); // make message dynamic
        }
        
        for(sobject metadata : retrieveSettings){
            MDM_Configuration__mdt config=(MDM_Configuration__mdt)metadata;
            fieldSetName=config.FieldApiName__c;
            break;
        }
        return fieldSetName;
    }
    
    
    
    BLN_MDM_Configuration.Metadata_Retreiver_Param GetSobjectFieldSet(string objectName){
        BLN_MDM_Configuration.Metadata_Retreiver_Param meta_parameters=null;
        
        //this logic need to be dynamic
        
        string metadataName='MDM_Configuration__mdt';
        string filterCriteria='Fieldset';
        if(objectName.toUpperCase()=='ACCOUNT'){
            Map<string,string> mpFilterCriteria=new Map<string,string>();
            meta_parameters=new BLN_MDM_Configuration.Metadata_Retreiver_Param();
            meta_parameters.Metadata_Name=metadataName;
            mpFilterCriteria.put('FilterCriteria__c',filterCriteria);
            mpFilterCriteria.put('ObjectName__c',objectName);
            meta_parameters.FilterCriteria=mpFilterCriteria;
        }
        return meta_parameters;
    }    
}