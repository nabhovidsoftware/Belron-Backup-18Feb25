/*****************************************
ClassName : BLN_UpdateCaseOwnerController
Description : FOUK-1626 This controller class is used in BLN_AssignToRecoveryTeam lwc.
CreatedDate: 10-08-2023
CreatedBy : PwC-India
****************************************/
/* @description : This controller class is used in BLN_AssignToRecoveryTeam lwc. */
public with sharing class BLN_UpdateCaseOwnerController {
    
    
/*****************************************
MethodName : getQueueName
Description : This method is used to get the Recovery Team queue Id and Queue Name.
Input Parameter : ()
Output Parameter : Group
CreatedDate: 10-08-2023
CreatedBy : Pwc-India
Change log :
****************************************/

/*  *@description:This method is used to get Recovery Team queue Id and Queue Name.
    *return : Group
*/
    @AuraEnabled
    public static Group getQueueName() {
        
        List<Group> queueList = new List<Group>();
        Group recQueue = new Group();
        queueList = [SELECT Id,Name FROM Group WHERE Type =:System.Label.BLN_Queue AND DeveloperName =:System.label.BLN_RecoveryTeamQueue  WITH SECURITY_ENFORCED ];
        
        if(!queueList.isEmpty() && queueList.size()== 1){
            
            recQueue = queueList.get(0);
        }
        return recQueue;
        
    }
    
}