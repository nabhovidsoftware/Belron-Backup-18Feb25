/*****************************************
ClassName : BLN_PaymentScreenController
Description : FOUK-4838 This controller class is used in BLN_PaymentScreenCmp lwc.
CreatedDate: 21-12-2023
CreatedBy : PwC-India
****************************************/

public with sharing class BLN_PaymentScreenController {
    
    /*****************************************
MethodName : getUserPermissionSet
Description : This method is used to check assigned permisseion set to current user.
Input Parameter : ()
Output Parameter : Boolean
CreatedDate: 21-12-2023
CreatedBy : Pwc-India
Change log :
****************************************/
    /*@description : getUserPermissionSet method used to check the availble of permission set.
      @Return : method returns the boolean */
    @AuraEnabled
    public static String getUserPermissionSet() {
        
        String userHasPermission = System.Label.BLN_False;
        /*query to get logged-in user permissionset*/
        PermissionSetAssignment.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible();
        List<PermissionSetAssignment> lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name,PermissionSet.Label,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() /*WITH SECURITY_ENFORCED */];
        for (PermissionSetAssignment psa: lstcurrentUserPerSet)
        {  /*to check which permission set user is having and return varible to js controller*/
            if(psa.PermissionSet.Label.equals(System.Label.BLN_CER)||psa.PermissionSet.Label.equals(System.Label.BLN_Concierge)||psa.PermissionSet.Label.equals(System.Label.BLN_ConciergeFLTR)|| psa.PermissionSet.Label.equals(System.Label.BLN_WarrantyRectificationRep)||psa.PermissionSet.Label.equals(System.Label.BLN_RecoveryTeamManager)||psa.PermissionSet.Label.equals(System.Label.BLN_CECTeamManager)||psa.PermissionSet.Label.equals(System.Label.BLN_WarrantyRectificationTeamManager)||psa.PermissionSet.Label.equals(System.Label.BLN_DigitalTeamManager) || psa.PermissionSet.Label.equals(System.Label.BLN_CERGroup) || psa.PermissionSet.Label.equals(System.Label.BLN_ConciergeGroup) || psa.PermissionSet.Label.equals(System.Label.BLN_ConciergeFLTRGroup) || psa.PermissionSet.Label.equals(System.Label.BLN_WarrantyRectificationRepGroup) || psa.PermissionSet.Label.equals(System.Label.BLN_RecoveryTeamManagerGroup) || psa.PermissionSet.Label.equals(System.Label.BLN_CECTeamManagerGroup) || psa.PermissionSet.Label.equals(System.Label.BLN_WarrantyRectificationTeamManagerGroup) || psa.PermissionSet.Label.equals(System.Label.BLN_DigitalTeamManagerGroup)){  
                userHasPermission  = System.Label.BLN_True;  break;
               }
        }
        return userHasPermission;
    }
}