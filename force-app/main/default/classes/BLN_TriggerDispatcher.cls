/** @description : Trigger Dispatcher
*   @author: Rahul Jain(PwC IN)
*    @CreatedDate: 21/06/2024
*/
public with sharing class BLN_TriggerDispatcher {
   public static void dispatch(BLN_TriggerInterface handler, System.TriggerOperation triggerEvent, String objName) {
       if (handler.stopDispatch()) {
           return;
       }
       BLN_TriggerSetting__mdt tsMdt = getTriggerSetting(objName);
       if (tsMdt != null && tsMdt.BLN_Active__c) {
           handleTriggerEvent(handler, triggerEvent, tsMdt);
       }
   }
   private static BLN_TriggerSetting__mdt getTriggerSetting(String objName) {
       List<BLN_TriggerSetting__mdt> mdtList = [
           SELECT BLN_Active__c, BLN_BeforeUpdate__c,BLN_AfterInsert__c,BLN_AfterUpdate__c,BLN_BeforeInsert__c, BLN_BeforeDelete__c, BLN_AfterDelete__c,BLN_AfterUndelete__c
           FROM BLN_TriggerSetting__mdt
           WHERE BLN_Object__c = :objName WITH SECURITY_ENFORCED
       ];
       if (!mdtList.isEmpty()) {
           return mdtList[0];
       }
       return null;
   } 
   private static void handleTriggerEvent(BLN_TriggerInterface handler, System.TriggerOperation triggerEvent, BLN_TriggerSetting__mdt tsMdt) {
       switch on triggerEvent {

            when BEFORE_INSERT { 
                If (tsMdt.BLN_BeforeInsert__c){handler.beforeInsert(Trigger.New);}
            }
            //5167
            when AFTER_INSERT {
                If (tsMdt.BLN_AfterInsert__c){ 
                    handler.afterInsert(Trigger.New,Trigger.newMap);
                }
            }
        
           when BEFORE_UPDATE {
               if (tsMdt.BLN_BeforeUpdate__c) {
                   handler.beforeUpdate(Trigger.New, Trigger.OldMap);
               }
           }

            when AFTER_UPDATE {
                If (tsMdt.BLN_AfterUpdate__c){
                    handler.afterUpdate(Trigger.New,Trigger.oldMap);
                }
            }

            when BEFORE_DELETE {
                If (tsMdt.BLN_BeforeDelete__c){
                    handler.beforeDelete(Trigger.old,Trigger.oldMap);
                }
            }
            when AFTER_DELETE {
                    If (tsMdt.BLN_AfterDelete__c){ 
                        handler.afterDelete(Trigger.old,Trigger.oldMap);
                    }
            }
            when AFTER_UNDELETE {                        
                    If (tsMdt.BLN_AfterUndelete__c){
                        handler.afterUnDelete(Trigger.new,trigger.newMap);
                    }
 }
           // when AFTER_INSERT { ... }
           // when BEFORE_DELETE { ... }
           // when AFTER_DELETE { ... }
       }
   }
}