/** @description : The Utility class use in FSL
* @author: Rajat Rewri(PwC IN)
* @Story : FOUK-116,FOUK-117,FOUK-119,FOUK-120,FOUK-121
* @CreatedDate : 31/05/2023
*/
public without sharing class BLN_FSLUtility{
    /** @description : fetchFieldMapping() method to make a map of JSON_attribute__c and SFDC_Field_API__c of the Request from Remedy
    * @param : None
    * @return : Map<String, Map<String, String>>
    */
    /*public static Map<String, Map<String, String>> fetchFieldMapping(){
        Map<String, Map<String, String>> fieldMap = new Map<String, Map<String, String>>();
        List<BLN_Remedy_Field_Mapping__mdt> fieldMappingRecs = [SELECT Id, JSON_attribute__c, SFDC_Field_API__c, sObjectName__c, DeveloperName FROM BLN_Remedy_Field_Mapping__mdt WITH SECURITY_ENFORCED];
        if(fieldMappingRecs!=null && fieldMappingRecs.size()>0){
            for(BLN_Remedy_Field_Mapping__mdt fieldMapping:fieldMappingRecs){
                if(fieldMapping.JSON_attribute__c!=null && fieldMapping.SFDC_Field_API__c!=null && fieldMapping.sObjectName__c!=null){
                    if(!fieldMap.containsKey(fieldMapping.sObjectName__c)){
                        fieldMap.put(fieldMapping.sObjectName__c, new Map<String,String>{fieldMapping.JSON_attribute__c => fieldMapping.SFDC_Field_API__c});
                    }
                    else{
                        fieldMap.get(fieldMapping.sObjectName__c).put(fieldMapping.JSON_attribute__c, fieldMapping.SFDC_Field_API__c);
                    }
                }
            }
        }
        return fieldMap;
    }*/

    /** @description : changeStrToDateTime() method to convert string DateTime to instance of DateTime
    * @param : String strDateTime
    * @return : DateTime
    */
    public static DateTime changeStrToDateTime(String strDateTime){
        //strDateTime  = '2023-04-26T08:00:00';
        List<String> str = strDateTime.split('T');
        List<String> strDate = str[0].split('-');
        List<String> strTime = str[1].split(':');
        String stringDT = strDate[0] + '-' + strDate[1] + '-' + strDate[2] + ' ' + strTime[0] + ':' + strTime[1] +  ':' + strTime[2];
        return DateTime.valueOf(stringDT);
    }

    /** @description : fetchFailureReasonsFromCode() method to make a map of SFS_Reason_Level_1 and SFS_Reason_Level_2 for the all CodeIds
    * @param :
    * @return : Map<Decimal, Map<String, String>>
    */
    public static Map<String, Map<String, String>> fetchFailureReasonsFromCode(){
        Map<String,Map<String, String>> mapOfFailureReasons = new Map<String, Map<String, String>>();
       List<BLN_RemedyFailureCodeMapping__mdt> failureReasons = [SELECT Id, DeveloperName, BLN_CodeId__c ,BLN_Remedy_Reason__c,BLN_SFS_Reason_Level_1__c,
                                                  BLN_SFS_Reason_Level_2__c FROM BLN_RemedyFailureCodeMapping__mdt WHERE BLN_CodeId__c !=null WITH SECURITY_ENFORCED];
       if(failureReasons!=null && failureReasons.size()>0 ){
            for(BLN_RemedyFailureCodeMapping__mdt fReason:failureReasons){
                if(!mapOfFailureReasons.containsKey(fReason.BLN_CodeId__c)){
                    mapOfFailureReasons.put(fReason.BLN_CodeId__c,new Map<String,String>{'Level1' =>fReason.BLN_SFS_Reason_Level_1__c,'Level2' =>fReason.BLN_SFS_Reason_Level_2__c});
                }
            }
        }
        return mapOfFailureReasons;
    }

    /** @description : fetchFailureCodeFromReasons() method to make a map of SFS_Reason_Level_1 and SFS_Reason_Level_2 for the all CodeIds
    * @param :
    * @return : Map<String, String>
    */
    /*public static Map<String, String> fetchFailureCodeFromReasons(){
        Map<String, String> mapOfFailureReasons = new Map<String, String>();
       List<BLN_SFReasonFailureCodeMapping__mdt> failureReasons = [SELECT Id, DeveloperName, BLN_RemedyFailureCode__c , BLN_RemedyReason__c, BLN_SFSReasonLevel1__c,
                                                  BLN_SFSReasonLevel2__c FROM BLN_SFReasonFailureCodeMapping__mdt WHERE BLN_RemedyFailureCode__c !=null WITH SECURITY_ENFORCED];
       if(failureReasons!=null && failureReasons.size()>0 ){
            for(BLN_SFReasonFailureCodeMapping__mdt fReason:failureReasons){
                if(!mapOfFailureReasons.containsKey(fReason.BLN_SFSReasonLevel1__c+fReason.BLN_SFSReasonLevel2__c)){
                    mapOfFailureReasons.put(fReason.BLN_SFSReasonLevel1__c+fReason.BLN_SFSReasonLevel2__c, String.valueOf(fReason.BLN_RemedyFailureCode__c));
                }
            }
        }
        return mapOfFailureReasons;
    }*/

    /** @description : mapOfSkillNameAndId() method to make a map of Skill DeveloperName and Id
    * @param :
    * @return : Map<String, String>
    */
    public static Map<String, String> mapOfSkillNameAndId(){
        List<Skill> skillList = new List<Skill>();
        Map<String, String> mapOfSkillNameAndId = new Map<String, String>();
        skillList = [Select Id,MasterLabel from Skill WITH SECURITY_ENFORCED];
        if(skillList.size()>0){
            for(Skill sk:skillList){
                if(sk.Id !=null && sk.MasterLabel !=null) {
                    mapOfSkillNameAndId.put(sk.MasterLabel, sk.Id);
                }
            }
        }
        return mapOfSkillNameAndId;

    }

     /** @description : mapOfSfWTNameAndId() method to make a map of Skill DeveloperName and Id
    * @param :
    * @return : Map<String, String>
    */
    /*public static Map<String, String> mapOfSfWTNameAndId(){
        List<WorkType> wTList = new List<WorkType>();
        Set<String> setOfSFWTNames = new Set<String>{'Assist','Recalibration','Repair','Replacement','Replacement & Recalibration','Side & Rear Replacement','Stock Collect','Warranty Replacement'};
        Map<String, String> mapOfSfWorkTypeNameAndId = new Map<String, String>();
        wTList = [Select Id,Name from WorkType WHERE Name IN:setOfSFWTNames WITH SECURITY_ENFORCED];
        if(wTList.size()>0){
            for(WorkType wT:wTList){
                if(wT.Id !=null && wT.Name !=null) {
                    mapOfSfWorkTypeNameAndId.put(wT.Name, wT.Id);
                }
            }
        }
        return mapOfSfWorkTypeNameAndId;

    }*/

    /** @description : calculateDiffBetTime() method to difference between two datetimes
    * @param : DateTime t1, DateTime t2
    * @return : String
    */
    public static String calculateDiffBetTime(DateTime dateTime1, DateTime dateTime2){
        Decimal decSec2 = dateTime2.getTime();
        Decimal decSec1 = dateTime1.getTime();
        Decimal miliDiff = decsec2 - decsec1;
        Decimal secDiff = miliDiff/1000;
        Decimal rounded = secDiff.setScale(3);
        String secondsGapStr = String.valueOf(rounded);
        return secondsGapStr;
    }

    /** @description : Converts input DateTime to UTC date in String format
    * @param inputDateTime  DateTime input
    * @param inputTimeZoneName Time Zone Name
    * @return String DateTime in yyyy-MM-dd'T'HH:mm:ss.SSSZ format
    */
    public static String convertDateTimeToUTC(Datetime inputDateTime, String inputTimeZoneName) {
        if (inputDateTime == null || inputTimeZoneName == null) {
            return '';
        }

        TimeZone tz = TimeZone.getTimeZone(inputTimeZoneName);
        //Offsetting the received datetime
        inputDateTime = inputDateTime.addMinutes((tz.getOffset(inputDateTime)/60000)*-1);

        return formatGMT(inputDateTime);
    }

    /** @description Formats input DateTime to GMT standard for MuleSoft callouts
    * @param inputDateTime DateTime
    * @return String DateTime in yyyy-MM-dd'T'HH:mm:ss.SSSZ format
    */
    public static String formatGMT(Datetime inputDateTime) {
        return (inputDateTime != null) ? inputDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : '';
    }
    
    public static Boolean isTriggerDisabled(Id userId) {
        return BLN_ProcessDeactivation__c.getInstance(userId).BLN_DisableApexTriggers__c;
    }
}