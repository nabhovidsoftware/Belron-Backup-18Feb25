/**
 * @description       : 
 * @author            : Prajjawal Tiwari
 * @group             : 
 * @last modified on  : 07-12-2024
 * @last modified by  : Prajjawal Tiwari
**/
public class LAD_CancelOrder {

  
    @auraenabled
    public static List<sobject> getOrderProductDetails(string orderSummaryId){
        List<OrderItemSummary> orderItemLst=[select id,name,quantity,unitprice,productcode,totalprice,status,LAD_Status__c,OrderDeliveryGroupSummary.orderdeliverymethod.name from OrderItemSummary where OrderSummaryId=:orderSummaryId];
        
        
        return orderItemLst;
    }
    @auraenabled    
    public static void createPlatformEvent(string platformEventBody){
        LAD_OrderCancellation__e platformEvent=new LAD_OrderCancellation__e();
        platformEvent.LAD_Cancellation_Details__c=platformEventBody;
        EventBus.publish(platformEvent);
         
    }
    @auraenabled
    public static Boolean checkSpecialOrder(string orderSummaryId){
         string contactId=[select contactId from user where id=:Userinfo.getUserId()].contactId;
        boolean isRole=false;
        List<String> possibleValues = new List<String>{
            'Wholesale Manager',
            'Hub Manager',
            'Hub Team User'
        };
        if(contactId!=null){
            Contact i=[select LAD_Role__c from contact where id=:contactId];
            if(possibleValues.contains(i.LAD_Role__c)){isRole=true;}
        }
      List<PermissionSetAssignment> lstcurrentUserPerSet =    [   SELECT Id, PermissionSet.Name,AssigneeId
                                                                FROM PermissionSetAssignment
                                                                WHERE AssigneeId = :Userinfo.getUserId() and (PermissionSet.Name ='Laddaw_Internal_Portal_User_Object_Access' or permissionsetgroup.developername ='Laddaw_Internal_Portal_User') ];
		boolean isInternalUser=lstcurrentUserPerSet.size()>0?true:false;
        List<Ordersummary> i=[select LAD_Special_Order__c from OrderSummary where id=:orderSummaryId];
		boolean isSpecialOrder = i.size()!=0 ?i[0].LAD_Special_Order__c:false;
        return isSpecialOrder==true?isInternalUser & isRole:true;
    }
        
    }