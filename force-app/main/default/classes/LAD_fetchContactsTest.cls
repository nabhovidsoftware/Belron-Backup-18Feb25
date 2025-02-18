@isTest
public class LAD_fetchContactsTest {
	@TestSetup
    public static void testData(){
        Account testAccount = new Account(Name = 'ABC Corp');
        insert testAccount;
        
        Contact temp1 = New Contact(LastName = 'Test0', AccountID = testAccount.id);
        insert temp1;
        Contact temp2 = New Contact(LastName = 'Test1', AccountID = testAccount.id);
        insert temp2;
        Contact temp3 = New Contact(LastName = 'Test2', AccountID = testAccount.id);
        insert temp3;
        Contact temp4 = New Contact(LastName = 'Test3', AccountID = testAccount.id);
        insert temp4;
        Contact temp5 = New Contact(LastName = 'Test4', AccountID = testAccount.id);
        insert temp5;
    }
    
    @isTest
    public static void testgetRelatedContacts(){
        Id acc = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        Test.startTest();
        List<Contact> conList=LAD_fetchContacts.getRelatedContacts(acc);
        System.debug(conList);
        for(integer i=0; i<5; i++){
            System.assertEquals(conList[i].Name,'Test'+i);
        }
        Test.stopTest();
    }
}