/**@description : The Apex class handle Task Creation and Updation
*  @author: Wasim Akram
*  @Story: 
*  @CreatedDate: 12/12/2023
*/
public with sharing class BLN_GenerateSkillRequirement {
    public static List<SkillRequirement> listServiceRecquirementRec = new List<SkillRequirement>();
    
    /** @description : createSkillRequirement method is creating SkillRequirement record on WOLI obj. based on several conditions
    * @param : woLi, skillMap, caseObj, isADASProd, prodList, workTypeMaps, st
    * @return : List<SkillRequirement>
    */
    public static List<SkillRequirement> createSkillRequirement(WorkOrderLineItem woLi, Map<String,String> skillMap, Case caseObj, Boolean isADASProd, List<Product2> prodList, Map<String,WorkType> workTypeMaps, ServiceTerritory st){
        
        String workTypeName = workTypeMaps.get(woLi.WorkTypeId).Name;
        Decimal diffFact = 0;
        Boolean checkInside=false;
        //For Assist
        if(workTypeName == System.Label.BLN_AssistWT){
            SkillRequirement assistServiceRecquirementRec = new SkillRequirement();
            assistServiceRecquirementRec.RelatedRecordId = woLi.Id;
                if(caseObj.BLN_Vehicle__r.BLN_SpecialVehicle__c == False){
                    assistServiceRecquirementRec.SkillLevel = 1;
                }else if(caseObj.BLN_Vehicle__r.BLN_SpecialVehicle__c == True){
                    assistServiceRecquirementRec.SkillLevel = 2;
                }
            assistServiceRecquirementRec.SkillId = skillMap.get(System.Label.BLN_AssistSk);
                listServiceRecquirementRec.add(assistServiceRecquirementRec);
        }
        //For Van
        if((workTypeName == System.Label.BLN_AssistWT) && (st.BLN_Type__c == System.Label.BLN_Mobile)){
            SkillRequirement vanServiceRecquirementRec1 = new SkillRequirement();
            vanServiceRecquirementRec1.RelatedRecordId = woLi.Id;
            vanServiceRecquirementRec1.SkillLevel = 1;
            vanServiceRecquirementRec1.SkillId = skillMap.get(System.Label.BLN_VanSkill);
            listServiceRecquirementRec.add(vanServiceRecquirementRec1);
        }
        
        if((workTypeName != System.Label.BLN_AssistWT) && (workTypeName != System.Label.BLN_StockCollectWT) && (st.BLN_Type__c == System.Label.BLN_Mobile) && (workTypeMaps.get(woLi.WorkTypeId).BLN_IsMainJob__c == True)){
            if(prodList.size()>0){
                for(Product2 prod : prodList){
                    checkInside = diffFact < prod.BLN_ProductVanSize__c ? true : false;
                    diffFact = diffFact < prod.BLN_ProductVanSize__c ? prod.BLN_ProductVanSize__c : 0;
                    diffFact = checkInside == false ? 1 : 0;
                    // if(diffFact < prod.BLN_ProductVanSize__c){
                    //     checkInside = true;
                    //     diffFact = prod.BLN_ProductVanSize__c;
                    // } else if(checkInside == false){
                    //     diffFact = 1;
                    // }
            }
            }else{
                diffFact = 1;
            }
            
            SkillRequirement vanServiceRecquirementRec3 = new SkillRequirement();
            vanServiceRecquirementRec3.RelatedRecordId = woLi.Id;
            vanServiceRecquirementRec3.SkillLevel = diffFact;
            vanServiceRecquirementRec3.SkillId = skillMap.get(System.Label.BLN_VanSkill);
            listServiceRecquirementRec.add(vanServiceRecquirementRec3);
        }
        diffFact = 0;
        checkInside = false;
        //For ADAS
        if((workTypeName == System.Label.BLN_RecalibrationWT || workTypeName == System.Label.BLN_ReplacementRecalibrationWT || workTypeName == System.Label.BLN_WarrantyReplacementRecalibration)&&
            (isADASProd == True)){
            SkillRequirement aDASServiceRecquirementRec = new SkillRequirement();
            aDASServiceRecquirementRec.RelatedRecordId = woLi.Id;
            aDASServiceRecquirementRec.SkillLevel = 1;
            aDASServiceRecquirementRec.SkillId = skillMap.get(System.Label.BLN_ADASSkill);
            listServiceRecquirementRec.add(aDASServiceRecquirementRec);
        }
        //For Warranty
        if(workTypeName == System.Label.BLN_WarrantyReplacementWT || workTypeName == System.Label.BLN_WarrantyReplacementRecalibration){
            SkillRequirement warrantyServiceRecquirementRec = new SkillRequirement();
            warrantyServiceRecquirementRec.RelatedRecordId = woLi.Id;
            warrantyServiceRecquirementRec.SkillLevel = 1;
            warrantyServiceRecquirementRec.SkillId = skillMap.get(System.Label.BLN_WarrantySkill);
            listServiceRecquirementRec.add(warrantyServiceRecquirementRec);
        }
        //For Special
        if((caseObj.BLN_Vehicle__r.BLN_SpecialVehicle__c == True) && (workTypeName == System.Label.BLN_ReplacementWT || workTypeName == System.Label.BLN_ReplacementRecalibrationWT || workTypeName == System.Label.BLN_SideRearReplacementWT || workTypeName == System.Label.BLN_WarrantyReplacementWT || workTypeName == System.Label.BLN_WarrantyReplacementRecalibration)){
            SkillRequirement specialServiceRecquirementRec = new SkillRequirement();
            specialServiceRecquirementRec.RelatedRecordId = woLi.Id;
            specialServiceRecquirementRec.SkillLevel = 1;
            specialServiceRecquirementRec.SkillId = skillMap.get(System.Label.BLN_SpecialSkill);
            listServiceRecquirementRec.add(specialServiceRecquirementRec);
        }
        //For Windscreen
        for(Product2 prod : prodList){
            if(String.isNotBlank(prod.BLN_ProductCategory__c) && ((prod.BLN_ProductCategory__c == System.label.BLN_Windscreen ||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('11')) ||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('261')) ||
                    (String.valueOf(prod.BLN_ProductCategory__c).startsWith('24'))) || 
                    ((String.valueOf(prod.BLN_ProductCategory__c) == '5110') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5210') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5310') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5410') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5450') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5810') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '2510'))) && (workTypeName == System.Label.BLN_ReplacementWT || workTypeName == System.Label.BLN_ReplacementRecalibrationWT || workTypeName == System.Label.BLN_SideRearReplacementWT || workTypeName == System.Label.BLN_WarrantyReplacementWT || workTypeName == System.Label.BLN_WarrantyReplacementRecalibration) && prod.BLN_SkillComplexity__c !=null){
                        if(diffFact < prod.BLN_SkillComplexity__c){
                            diffFact = prod.BLN_SkillComplexity__c;
        
                        }
                }
            }

        if(diffFact >0){
            SkillRequirement windscreenServiceRecquirementRec = new SkillRequirement();
            windscreenServiceRecquirementRec.RelatedRecordId = woLi.Id;
            windscreenServiceRecquirementRec.SkillLevel = diffFact;
            windscreenServiceRecquirementRec.SkillId = skillMap.get(System.Label.BLN_WindscreenSkill);
            listServiceRecquirementRec.add(windscreenServiceRecquirementRec);
        }
        diffFact = 0;
        //For Side & Rear
        for(Product2 prod : prodList){
            if(String.isNotBlank(prod.BLN_ProductCategory__c) && (( prod.BLN_ProductCategory__c == System.label.BLN_SideGlass || prod.BLN_ProductCategory__c == System.label.BLN_RearGlass || 
                     (String.valueOf(prod.BLN_ProductCategory__c).startsWith('12')) ||
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('13')) ||
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('262'))||
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('263')) ||
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('242')) ||
                (String.valueOf(prod.BLN_ProductCategory__c).startsWith('243')))|| 
                ((String.valueOf(prod.BLN_ProductCategory__c) == '5120') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5220') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5320') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5420') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5130') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5230') ||
                (String.valueOf(prod.BLN_ProductCategory__c) == '5430') ||
                    (String.valueOf(prod.BLN_ProductCategory__c) == '5330'))) && (workTypeName == System.Label.BLN_ReplacementWT || workTypeName == System.Label.BLN_ReplacementRecalibrationWT || workTypeName == System.Label.BLN_SideRearReplacementWT || workTypeName == System.Label.BLN_WarrantyReplacementWT || workTypeName == System.Label.BLN_WarrantyReplacementRecalibration) && prod.BLN_SkillComplexity__c !=null){
                        if(diffFact < prod.BLN_SkillComplexity__c){
                            diffFact = prod.BLN_SkillComplexity__c;
                    }
          }
        }
        if(diffFact >0){
            SkillRequirement sideRearServiceRecquirementRec = new SkillRequirement();
            sideRearServiceRecquirementRec.RelatedRecordId = woLi.Id;
            sideRearServiceRecquirementRec.SkillLevel = diffFact;
            sideRearServiceRecquirementRec.SkillId = skillMap.get(System.Label.BLN_Side_RearSkill);
            listServiceRecquirementRec.add(sideRearServiceRecquirementRec);
        }
        diffFact = 0;
        //For Sunroof
        for(Product2 prod : prodList){
            if(String.isNotBlank(prod.BLN_ProductCategory__c) && (String.valueOf(prod.BLN_ProductCategory__c).startsWith('20') || prod.BLN_ProductCategory__c == System.label.BLN_Sunroof) && (workTypeName == System.Label.BLN_ReplacementWT || workTypeName == System.Label.BLN_ReplacementRecalibrationWT || workTypeName == System.Label.BLN_SideRearReplacementWT || workTypeName == System.Label.BLN_WarrantyReplacementWT || workTypeName == System.Label.BLN_WarrantyReplacementRecalibration) && prod.BLN_SkillComplexity__c !=null){
                if(diffFact < prod.BLN_SkillComplexity__c){
                    diffFact = prod.BLN_SkillComplexity__c;
                }
          }
        }
        if(diffFact >0){
            SkillRequirement sunroofServiceRecquirementRec = new SkillRequirement();
            sunroofServiceRecquirementRec.RelatedRecordId = woLi.Id;
            sunroofServiceRecquirementRec.SkillLevel = diffFact;
            sunroofServiceRecquirementRec.SkillId = skillMap.get(System.Label.BLN_SunroofSkill);
            listServiceRecquirementRec.add(sunroofServiceRecquirementRec);
        }
        diffFact = 0;
        //For Repair
        for(Product2 prod : prodList){
            if(String.isNotBlank(prod.BLN_ProductCategory__c)){
                if((String.valueOf(prod.BLN_ProductCategory__c).startsWith('14') || prod.BLN_ProductCategory__c == System.label.BLN_Repair)  && (workTypeName == System.Label.BLN_RepairWT) && (checkInside == false)/* && prod.BLN_SkillComplexity__c !=null*/){
                    checkInside = true;
                    SkillRequirement repairServiceRecquirementRec = new SkillRequirement();
                    repairServiceRecquirementRec.RelatedRecordId = woLi.Id;
                    repairServiceRecquirementRec.SkillLevel = 1;
                    repairServiceRecquirementRec.SkillId = skillMap.get(System.Label.BLN_RepairSkill);
                    listServiceRecquirementRec.add(repairServiceRecquirementRec);
                }
            }
        }
        checkInside = false;
        return listServiceRecquirementRec;
    }
}