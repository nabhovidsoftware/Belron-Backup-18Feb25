/** @description : This class is used to used to clone order records
*   @Story : FOUK-8101
*   @author: Siddhant Pandya (PwC)
*   @CreatedDate: 13/05/2024
*/
public with sharing class BLN_CloneOrderRecords {
/**
*@description : This method is called from 'Case Update Order Status On Reopen' flow, used to clone order records.
*@return void
*/
    @InvocableMethod(label = 'Clone Orders' description = 'Clone all the provided Orders')
    public static void cloneOrderRecords(List<List<Id>> orderList) {
      try {
        List<Id> input = orderList[0];
        String fieldsOrderStr = '';
        List<Order> ordersToUpdate = new List<Order>();
        String ids = '';

        
        List<Schema.FieldSetMember> fieldSetOrder = Schema.getGlobalDescribe().get('Order').getDescribe().FieldSets.getMap().get(System.Label.BLN_OrderCloneFields).getFields(); 
        for(Schema.FieldSetMember fieldSetMemberOrder : fieldSetOrder)
        {
          fieldsOrderStr+= fieldSetMemberOrder.getFieldPath()+', ';
        }
        fieldsOrderStr+= 'Id ';
        for(Id idRec : input)
        {
          ids+= '\''+idRec+'\'' +', ';
        }
        ids+= '\''+input[0]+'\'';
        String query = 'Select ' +fieldsOrderStr+' from Order where id in ('+ids+')';
        
        List<Order> fetchedOrders = Database.query(query);
        Map<String, Order> ordIdMap = new Map<String, Order>();
        List<Id> caseId = new List<Id>();
        for(Order orderRec: fetchedOrders)
        {
          caseId.add(orderRec.BLN_Case__c);
          String oldId = (String) orderRec.Id;
          Order clonedOrder = new Order();
          clonedOrder = orderRec;
          clonedOrder.Id = null;
          clonedOrder.BLN_OrigInvReference__c = orderRec.OrderNumber;
          clonedOrder.Status = System.label.BLN_Accepted;
          if(orderRec.BLN_InvoiceOrderNum__c!=null)
          {clonedOrder.BLN_InvoiceOrderNum__c = orderRec.BLN_InvoiceOrderNum__c + 1;}
          else {
            clonedOrder.BLN_InvoiceOrderNum__c = 1;
          }
          ordIdMap.put(oldId, clonedOrder);
          ordersToUpdate.add(clonedOrder);
        }
        if(Schema.sObjectType.Order.isCreateable()==true)
          {
            insert ordersToUpdate;
            List<Case> caseList = [SELECT Id, BLN_RevisionNumber__c FROM Case WHERE Id in :caseId WITH SECURITY_ENFORCED];
            List<Case> caseToUpdate = new List<Case>();
            for(Case caseObj: caseList)
            {
              if(caseObj.BLN_RevisionNumber__c!=null)
              {
                caseObj.BLN_RevisionNumber__c = caseObj.BLN_RevisionNumber__c + 1;
              }
              else {
                caseObj.BLN_RevisionNumber__c = 1;
              }
              caseToUpdate.add(caseObj);
            }

            if(Schema.sObjectType.Case.isUpdateable()==true)
            {
              update caseToUpdate;
            }
          }

        //OrderItem Part Start
        String fieldsOrderItemStr = '';
        List<String> orderItemFields = new List<String>();
        List<Schema.FieldSetMember> fieldSetOrderItem = Schema.getGlobalDescribe().get('OrderItem').getDescribe().FieldSets.getMap().get(System.Label.BLN_OrderItemCloneFields).getFields(); 
        for(Schema.FieldSetMember fieldSetMemberOrderItem : fieldSetOrderItem)
        {
          orderItemFields.add(fieldSetMemberOrderItem.getFieldPath());
          fieldsOrderItemStr+= fieldSetMemberOrderItem.getFieldPath()+', ';
        }
        fieldsOrderItemStr+= 'Id ';
        String orderItemQuery = 'Select ' +fieldsOrderItemStr+' from OrderItem where orderid in ('+ids+')';

        List<OrderItem> existingOrderItem = Database.query(orderItemQuery);

        List<OrderItem> listOrderItems = new List<OrderItem>();
        for (orderItem orderItemRec : existingOrderItem) {
          OrderItem newOrderItem = new OrderItem();
          for(String oIField: orderItemFields)
          {
            if(oIField=='OrderId'){
              newOrderItem.OrderId = ordIdMap.get(orderItemRec.orderId).Id;
            }
            else if(oIField == 'BLN_OrigTxnNumber__c'){
              //string orgNum = orderItemRec.BLN_OrigTxnNumber__c;
              //string lastTwo = orgNum.substring(orgNum.length()-2);
              
              String orgNum = orderItemRec.BLN_OrigTxnNumber__c != null ? orderItemRec.BLN_OrigTxnNumber__c.right(2) : '00';
              Integer result  = integer.valueof(orgNum) + 10;
              newOrderItem.BLN_OrigTxnNumber__c= string.valueof(result);
            }
            else if(oIField == 'OrderItemNumber'){
              newOrderItem.BLN_OrigInvReference__c = orderItemRec.OrderItemNumber;
            }
            else {
              newOrderItem.put(oIField, orderItemRec.get(oIField));
            }
          }
          listOrderItems.add(newOrderItem);
        }
        if(Schema.sObjectType.OrderItem.isCreateable()==true)
          {
            insert listOrderItems;
          }
      } catch (Exception ex) {
        BLN_ExceptionLogger.captureException(ex);
      }
	}

}