/**@description : The Apex class handle Task Creation and Updation
*  @author: Wasim Akram
*  @Story: 
*  @CreatedDate: 17/12/2023
*/
public with sharing class BLN_DurationCalculation {
    public static Decimal duration = 0.0;
    public static String isAssistNeedToCreate = '';
    /*
        @description : This method is used to return Duration on SA.
        @param : workType worktypeObj, ServiceTerritory serviceTerritoryObj, WorkOrderLineItem workOrderLineItemObj, Decimal specificAssistDuration, BLN_BU__mdt bumetadata, String woWorkType
        @retun : String
    */
        public static String durationCal(workType worktypeObj, 
                                      ServiceTerritory serviceTerritoryObj, 
                                      WorkOrderLineItem workOrderLineItemObj, 
                                      Decimal specificAssistDuration,
                                      BLN_BU__mdt bumetadata,
                                      String woWorkType){
        
        decimal meetAndGreet = 0;
        decimal estimateDur = 0;
        decimal prodFittingDuration = 0;
        if(worktypeObj.Name != system.label.BLN_Assist && WorktypeObj.Name != system.label.BLN_StockCollect){
            meetAndGreet = serviceTerritoryObj.BLN_MeetAndGreetTime__c != null ? serviceTerritoryObj.BLN_MeetAndGreetTime__c : 0;
            estimateDur = WorktypeObj.EstimatedDuration!= null ? WorktypeObj.EstimatedDuration : 0;
            prodFittingDuration = workOrderLineItemObj.BLN_ProductFittingDuration__c != null ? workOrderLineItemObj.BLN_ProductFittingDuration__c : 0;
        }

        if(woWorkType == System.label.BLN_WarrantyReplacementRecalibration || woWorkType == System.label.BLN_ReplaceAndRecal || woWorkType == System.label.BLN_Repair && (worktypeObj.Name != system.label.BLN_Assist && WorktypeObj.Name != system.label.BLN_StockCollect)){
            if(worktypeObj.Name == system.label.BLN_Recalibration && serviceTerritoryObj.BLN_SplitReplaceAndRecalibration__c == TRUE){
                duration = prodFittingDuration;
            } else {
                duration = meetAndGreet + estimateDur + prodFittingDuration;
            }
        } else {
            duration = meetAndGreet + estimateDur + prodFittingDuration;
            }

        if(WorktypeObj.Name == System.label.BLN_StockCollect && (serviceTerritoryObj.Country == bumetadata.BLN_Country__c || serviceTerritoryObj.Country == system.label.BLN_CountryValue)){
            duration = bumetadata.BLN_BUSpecificStockCollectionTime__c;
        }
        if(worktypeObj.Name == System.label.BLN_Assist && specificAssistDuration > bumetadata.BLN_BUSpecificDefaultAssistDuration__c){
            duration = specificAssistDuration;
        } else if(worktypeObj.Name == System.label.BLN_Assist && specificAssistDuration > 0 && specificAssistDuration <= bumetadata.BLN_BUSpecificDefaultAssistDuration__c){
                    if(serviceTerritoryObj.BLN_AnyDurationAssist__c == true){
                        duration = specificAssistDuration;
                    } else {
                        return System.label.BLN_NotNeeded;
                    }
        } else if(worktypeObj.Name == System.label.BLN_Assist && specificAssistDuration > Integer.valueOf(System.label.BLN_DefaultAssistDuration) && bumetadata.BLN_BUSpecificDefaultAssistDuration__c == Null){
            duration = specificAssistDuration;
        } else if(worktypeObj.Name == System.label.BLN_Assist && specificAssistDuration < Integer.valueOf(System.label.BLN_DefaultAssistDuration) && bumetadata.BLN_BUSpecificDefaultAssistDuration__c == Null){
            if(serviceTerritoryObj.BLN_AnyDurationAssist__c == true){
                duration = specificAssistDuration;
            } else if(serviceTerritoryObj.BLN_AnyDurationAssist__c == false){
                return System.label.BLN_NotNeeded;
            }
        } else if(worktypeObj.Name == System.label.BLN_Assist && (specificAssistDuration == Null || specificAssistDuration == 0)){
                    if(serviceTerritoryObj.BLN_AnyDurationAssist__c == true){
                        duration = bumetadata.BLN_BUSpecificDefaultAssistDuration__c;
                    } else {
                        return System.label.BLN_NotNeeded;
                    }
                }

        isAssistNeedToCreate = String.valueOf(duration);
        return isAssistNeedToCreate;
    }
}