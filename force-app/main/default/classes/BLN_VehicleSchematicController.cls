/*****************************************
ClassName : BLN_VehicleSchematicController
Description : FOUK-580,FOUK-1181 This controller class is used in bln_VehicleSchematicCmp lwc.
CreatedDate: 28-08-2023
CreatedBy : PwC-India
****************************************/
public with sharing class BLN_VehicleSchematicController {

    /*****************************************
MethodName : fetchMetaListLwc
Description : This method is used to get the records from BLN_IdentifyDamageAssessment__mdt custom metadata.
Input Parameter : 
Output Parameter : WrapMapData
CreatedDate: 28-08-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    @AuraEnabled( cacheable= TRUE )
    public static List<WrapMapData> fetchMetaListLwc(){
        
        List<WrapMapData> wrapMdList = new List<WrapMapData>();
        List<BLN_IdentifyDamageAssessment__mdt> fetchMeta = new List<BLN_IdentifyDamageAssessment__mdt>();
        Map<String,List<WrapfldData>> rowVsMetaMap = new  Map<String,List<WrapfldData>>();
        
        try {
            
            fetchMeta = [SELECT Id,BLN_StaticResourceName__c,BLN_GlassName__c,BLN_HoleId__c,
                         BLN_IsImage__c,MasterLabel,BLN_Row__c,BLN_Column__c,BLN_IsActive__c 
                         from BLN_IdentifyDamageAssessment__mdt WHERE BLN_IsActive__c = true  WITH SECURITY_ENFORCED 
                         Order By BLN_HoleId__c ASC ];
            
            if(!fetchMeta.isEmpty()){
               
                for(BLN_IdentifyDamageAssessment__mdt mt : fetchMeta ){
                 
                    List<WrapfldData> wrapList = new List<WrapfldData>();
                    WrapfldData wrpfd = new WrapfldData();
                    wrpfd.mdt = mt;
                    wrpfd.checked=false;
                    if(String.isNotBlank( mt.BLN_StaticResourceName__c)){
                     
                        wrpfd.urlRef = URL.getSalesforceBaseUrl().toExternalForm()+ System.label.BLN_VehicleResource + System.label.BLN_SlashLabel + mt.BLN_StaticResourceName__c;
                        wrpfd.imageLabel =  Label.get('',mt.BLN_StaticResourceName__c,UserInfo.getLanguage());
                        
                    }
                
                    if(rowVsMetaMap.containsKey(String.valueOf(mt.BLN_Row__c))){
                        
                        rowVsMetaMap.get(String.valueOf(mt.BLN_Row__c)).add(wrpfd);
                    } 
                    
                    else{
                        
                        wrapList.add(wrpfd);
                        rowVsMetaMap.put(String.valueOf(mt.BLN_Row__c),wrapList);
                    }
                }
            }
            
            for (String key : rowVsMetaMap.keySet()){
                
                WrapMapData wd  = new WrapMapData();
                wd.row = key;
                wd.wrapFldList = rowVsMetaMap.get(key);
                wrapMdList.add(wd);
            }
        }
        catch (Exception ex) {
            BLN_ExceptionLogger.captureException(ex);
        }
        return wrapMdList;
    }
    /* description: This is a wrapper class */
    public class WrapMapData{
        
        @AuraEnabled public String row{get;set;}
        @AuraEnabled public List<WrapfldData> wrapFldList{get;set;}
        
        /* description: This is a wrapper  */
        public WrapMapData(){
            this.row = '';
            this.wrapFldList = new List<WrapfldData>();
        }
    }
    
     /* description: This is a wrapper class */
    public class WrapfldData{
       
        @AuraEnabled public BLN_IdentifyDamageAssessment__mdt mdt{get;set;}
        @AuraEnabled public String urlRef{get;set;}
        @AuraEnabled public String imageLabel{get;set;}
        @AuraEnabled public boolean checked{get;set;}
        
        /* description: This is a wrapper  */
        public WrapfldData(){
            
            this.mdt = new BLN_IdentifyDamageAssessment__mdt();
            this.urlRef = '';
            this.imageLabel = '';
            this.checked=false;
        }
    }
}