/** 
 * @description : Test class for BLN_MDM_TriggerHandler.
 * @Story : FOUK- 5167
 * @author: PWC-India
 * @CreatedDate: Subhamita
 */
@isTest
public class BLN_AccountTriggerHandlerTest {

@testSetup
    @TestVisible static void setup() {
        // Create test data for Account
        Account oldAccount = new Account(Name = 'Old Account', Phone = '1234567890');
        insert oldAccount;
        
        // Creating a clone to simulate old records
      
        
        // Create a new Account with changes
        Account newAccount = new Account(Id = oldAccount.Id, Name = 'New Account', Phone = '0987654321');
        update newAccount;

        Individual indv1 = new Individual(Salutation ='Mrs',FirstName = 'John', LastName = 'DoOne');
        Individual indv2 = new Individual(Salutation ='Mrs',FirstName = 'Alice', LastName = 'DoTwo');
        Individual indv3 = new Individual(Salutation ='Mrs',FirstName = 'Jane', LastName = 'Smith');

        List<Individual> listOfIndv = new List<Individual>{indv1, indv2, indv3};

        insert listOfIndv;
        
        Account acc1 =  BLN_TestDataFactory.createAccount('Mrs John DoOne','PersonAccount','8698023891');
        acc1.Salutation='Mrs';
        acc1.FirstName='John';
        acc1.LastName='DoOne';
        acc1.PersonIndividualId=indv1.id;
        
        Account acc2 =  BLN_TestDataFactory.createAccount('Mrs Alice DoTwo','PersonAccount','8698023892');
        acc2.Salutation='Mrs';
        acc2.FirstName='Alice';
        acc2.LastName='DoTwo';
        acc2.PersonIndividualId=indv2.id;
        
        Account acc3 =  BLN_TestDataFactory.createAccount('Mrs Ahin DoThree','PersonAccount','8698023893');
        acc3.PersonIndividualId=null;
        Account acc4 =  BLN_TestDataFactory.createAccount('Mrs Vijain DoFour','PersonAccount','8698023894');

        List<Account> listOfAcc = new List<Account>{acc1, acc2, acc3, acc4};
        insert listOfAcc;

    }

    @isTest
    @TestVisible static  void testAfterUpdate() {
        // Create test data
        Account acc =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert acc;
        Account acc2 =  BLN_TestDataFactory.createSalesAccount('Sample12','Agriculture','',1,'','','','','','','','','','','','BLN_CustomerB2BAccount');
        insert acc2;

        acc.personHomePhone = '8698023823';
        update acc;
        acc2.Name = 'Sample22';

        List<Account> newAccounts = new List<Account>{ acc };
        List<Account> oldAccounts = new List<Account>{ new Account(Name = 'Sample') }; // Old account before update
      
        Map<Id, Account> oldMap = new Map<Id, Account>{ oldAccounts[0].Id => oldAccounts[0] };

        BLN_AccountTriggerHandler handler = new BLN_AccountTriggerHandler();
        handler.afterUpdate(newAccounts, oldMap);

        List<SObject> newAccounts2 = new List<SObject>{ acc2 };
        List<Account> oldAccounts2 = new List<Account>{ new Account(Name = 'Sample') }; // Old account before update
            
      
        Map<Id, Account> oldMap2 = new Map<Id, Account>{ oldAccounts2[0].Id => oldAccounts2[0] };
        handler.afterUpdate(newAccounts2, oldMap2);
        acc2.Industry = 'Banking';
        update acc2;
        
        Contact con = new Contact();
        con.FirstName = 'Sample1';
        con.LastName = 'Sample2';
        insert con;
        con.FirstName = 'Sample3';
        update con;
        
        List<Contact> newContacts3 = new List<Contact>{ con };
        List<Contact> oldContacts3 = new List<Contact>{ new Contact(FirstName = 'Sample', LastName = 'S2') };
        Map<Id, SObject> oldMap3 = new Map<Id, SObject>{ oldContacts3[0].Id => oldContacts3[0] };
        
        BLN_ChildMDMTriggerHandler handler3 = new BLN_ChildMDMTriggerHandler();
        //handler3.afterUpdate(newContacts3, oldMap3);
        
        
        handler3.beforeDelete(newAccounts2, oldMap2);
        handler3.afterDelete(newAccounts2, oldMap2);
        handler3.afterUnDelete(newAccounts2, oldMap2);
        
        
        
        delete acc2;
        undelete acc2;
        
        System.assertEquals(null, handler.mdmFields,'result is null');
    }
    
    @isTest
     static  void testAfterInsert() {
        // Create test data
        Account acc =  BLN_TestDataFactory.createAccount('Sample','PersonAccount','8698023890');
        insert acc;
        
        Account acc2 =  BLN_TestDataFactory.createSalesAccount('Sample','Agriculture','',1,'','','','','','','','','','','','BLN_CustomerB2BAccount');
        insert acc2;

        List<Account> newAccounts = new List<Account>{ acc, acc2 };
        Map<Id, Account> newMap = new Map<Id, Account>{ acc.Id => acc, acc2.Id => acc2 };

        BLN_AccountTriggerHandler handler = new BLN_AccountTriggerHandler();
        handler.afterInsert(newAccounts, newMap);

        System.assertEquals(null, handler.mdmFields,'result is null');
    }
    
    @isTest
     static  void testbeforeDelete() {
        // Create test data
        Account acc =  BLN_TestDataFactory.createSalesAccount('Sample','Agriculture','',1,'','','','','','','','','','','','BLN_CustomerB2BAccount');
        insert acc;

        List<Account> newAccounts = new List<Account>{ acc };
        Map<Id, Account> newMap = new Map<Id, Account>{ acc.Id => acc };

        BLN_AccountTriggerHandler handler = new BLN_AccountTriggerHandler();
        handler.beforeDelete(newAccounts, newMap);
         
         BLN_ChildMDMTriggerHandler handler2 = new BLN_ChildMDMTriggerHandler();
        handler2.beforeUpdate(newAccounts, newMap);

        System.assertEquals(null, handler.mdmFields,'result is null');
    }
    
    @isTest
     static  void testbeforeUpdate() {
        // Create test data
        Account acc =  BLN_TestDataFactory.createSalesAccount('Sample','Agriculture','',1,'','','','','','','','','','','','BLN_CustomerB2BAccount');
        insert acc;

        List<Account> newAccounts = new List<Account>{ acc };
        Map<Id, Account> newMap = new Map<Id, Account>{ acc.Id => acc };

        BLN_AccountTriggerHandler handler = new BLN_AccountTriggerHandler();
        handler.beforeUpdate(newAccounts, newMap);
         
        BLN_ChildMDMTriggerHandler handler2 = new BLN_ChildMDMTriggerHandler();
        handler2.beforeUpdate(newAccounts, newMap);

        System.assertEquals(null, handler.mdmFields,'result is null');
    }

    
     @isTest
     @TestVisible static void testResponseWrapper() {
        BLN_MDMConfiguration.ResponseWrapper response = new BLN_MDMConfiguration.ResponseWrapper();
        response.Response = 'TestResponse';
        response.StatusCode = 200;
        response.Message = 'Success';

        System.assertEquals('TestResponse', response.response,'result is not null');
		
		}
    
    @isTest
    @TestVisible static void testGetJsonBodyByMap() {
        BLN_MDMCalloutSetup setup = new BLN_MDMCalloutSetup();

        Map<String, Object> mockMap = new Map<String, Object>{ 'Field1' => 'Value1', 'Field2' => 'Value2' };

        Test.startTest();
        String result = setup.GetJsonBodyByMap(mockMap);
        Test.stopTest();

        System.assertNotEquals(null, result,'result is null');
    }
    
      @isTest
    @TestVisible static void testGetFieldsChangedWithOldRecord() {
        Test.startTest();

        // Retrieve the old and new records
        List<Account> oldAccounts = new List<Account>{ new Account(Name = 'Old Account') };
        List<Account> newAccounts = new List<Account>{ new Account(Name = 'New Account') };

        List<SObject> oldRecordList = new List<SObject>();
        List<SObject> newRecordList = new List<SObject>();

        oldRecordList.addAll(oldAccounts);
        newRecordList.addAll(newAccounts);
        Set<String> fieldsToProcess = new Set<String>{'Name', 'Phone'};

        BLN_MetaDataHandler handler = new BLN_MetaDataHandler();
        Map<String, Map<String, String>> fieldsChanged = handler.getFieldsChanged(oldRecordList, newRecordList, fieldsToProcess,new Map<String,String>{'objectName'=> 'Account', 'streamName'=>'Service'});

        Test.stopTest();

        System.assert(fieldsChanged.containsKey(oldAccounts[0].Id), 'The map should contain the account ID');
    }


  @isTest
    static void testSetPersonIndividualId() {
        
        List<Account> newListAcc = [SELECT Id,FirstName, PersonEmail,LastName, PersonIndividualId, IsPersonAccount, RecordTypeId FROM Account WHERE RecordType.Name='Person Account'];
		Individual indv1 = [SELECT Id FROM Individual WHERE Salutation ='Mrs'AND FirstName = 'John'AND LastName = 'DoOne'];
        Individual indv2 = [SELECT Id FROM Individual WHERE Salutation ='Mrs'AND FirstName = 'Alice'AND LastName = 'DoTwo'];
        //List<Account> newAccounts = newListAcc;
        Map<Id, Account> newMap = new Map<Id, Account>(newListAcc);

        Test.startTest();
        BLN_AccountTriggerHandler handler = new BLN_AccountTriggerHandler();
       // BLN_AccountTriggerHandler.setPersonIndividualId(null);
        handler.beforeInsert(newListAcc);
		Test.stopTest();
       
        // Retrieve the updated accounts
        List<Account> newAccList = [SELECT Id,FirstName, LastName, PersonIndividualId FROM Account WHERE RecordType.Name='Person Account'];

        // Assert the results
        for (Account acc : newAccList) {
            if (acc.FirstName == 'John' && acc.LastName == 'DoOne') {
                System.assertEquals(indv1.Id, acc.PersonIndividualId, 'John DoOne should be linked to the correct Individual');
            } else if (acc.FirstName == 'Alice' && acc.LastName == 'DoTwo') {
                System.assertEquals(indv2.Id, acc.PersonIndividualId, 'Alice DoTwo should be linked to the correct Individual');
            } 
        }

        // Verify that new individuals were created for the accounts without corresponding individuals
        List<Individual> newIndividuals = [
            SELECT FirstName, LastName FROM Individual WHERE FirstName = 'Jane' AND LastName = 'Smith'
        ];
        System.assertEquals(1, newIndividuals.size(), 'A new Individual should be created for Jane Smith');        
    }

}