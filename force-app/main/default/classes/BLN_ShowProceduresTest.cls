/*****************************************
ClassName : BLN_ShowProceduresTest
@description : FOUK 5079 This class is used to test BLN_ShowProcedures.
@author: PwC
CreatedDate:  01-08-2024
CreatedBy : PwC-India
***************************************/
@isTest
public with sharing class BLN_ShowProceduresTest {

    @isTest
    public static void getProceduresArpTest() {
        String customerB2BAccountRecordtypeId = [SELECT Id, Name FROM RecordType where Name = 'Customer(B2B Account)'].Id;
        Account accRec1 = new Account(Name = 'Test Account', BLn_ClientType__c = 'Insurance',recordtypeId = customerB2BAccountRecordtypeId);
        insert accRec1;
        Account accRec2 = new Account(Name = 'Test Account1', BLn_ClientType__c = 'Insurance',recordtypeId = customerB2BAccountRecordtypeId); 
        insert accRec2;
            
            String procedureRecType = Schema.SObjectType.BLN_AccountRuleParameter__c.getRecordTypeInfosByName().get('Procedure').getRecordTypeId();
            
            BLN_AccountRuleParameter__c procedureRec1 = new BLN_AccountRuleParameter__c(
                BLN_Account__c = accRec1.Id,
                RecordTypeId = procedureRecType	,
                BLN_Procedure__c = 'Test text',
                BLN_ActiveFrom__c = System.now().addDays(-1).date(),
                BLN_ActiveTo__c = System.Date.today()
            );
            insert procedureRec1;

            BLN_AccountRuleParameter__c procedureRec2 = new BLN_AccountRuleParameter__c(
                BLN_Account__c = accRec2.Id,
                RecordTypeId = procedureRecType	,
                BLN_Procedure__c = 'Test text',
                BLN_ActiveFrom__c = System.now().addDays(-1).date(),
                BLN_ActiveTo__c = System.Date.today()
            );
            insert procedureRec2;
            
            Test.startTest();
                List<List<BLN_AccountRuleParameterWrapper>> arpList1 =  BLN_ShowProcedures.getProceduresArp(new List<List<String>>{new List<String>{accRec1.Id}});
                List<List<BLN_AccountRuleParameterWrapper>> arpList2 =  BLN_ShowProcedures.getProceduresArp(new List<List<String>>{new List<String>{accRec1.Id,accRec2.Id}});
            Test.stopTest();
            System.assertEquals(false, arpList1.isEmpty(), 'procedures not null');
            System.assertEquals(false, arpList2.isEmpty(), 'procedures not null');
    }
}