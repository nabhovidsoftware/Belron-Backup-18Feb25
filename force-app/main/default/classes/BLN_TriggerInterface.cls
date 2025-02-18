/** @description : Trigger Interface
*   @author: Rahul Jain(PwC IN)
*    @CreatedDate: 21/06/2024
*/ 
public interface BLN_TriggerInterface {
    /*void beforeUpdate(List<sObject> newList,Map<Id,sObject> oldMap);

    void afterInsert(List<sObject> newList,Map<Id,sObject> newMap);  //5167
    void afterUpdate(List<sObject> newList,Map<Id,sObject> oldMap);  //5167
    void beforeInsert(List<sObject> newList,Map<Id,sObject> newMap);*/
    
    void beforeInsert(List<sObject> newList);
         
    void afterInsert(List<sObject> newList,Map<Id,sObject> newMap);
         
    void beforeUpdate(List<sObject> newList,Map<Id,sObject> oldMap);
     
    void afterUpdate(List<sObject> newList,Map<Id,sObject> oldMap);
                   
    void beforeDelete(List<sObject> oldList,Map<Id,sObject> oldMap);
         
    void afterDelete(List<sObject> oldList,Map<Id,sObject> oldMap);
         
    void afterUnDelete(List<sObject> newList,Map<Id, sObject> newMap);
         
    Boolean stopDispatch();

}