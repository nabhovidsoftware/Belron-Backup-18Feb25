@isTest
public class LAD_IsInvoicedUpdateTest {
    
    @isTest
    static void testUpdateAmountNotInvoiced() {
        Account testAccount = new Account(Name = 'ABC Corp'); // add more fields based on your org validation 
        insert testAccount;
        // Prepare input variables
        LAD_IsInvoicedUpdate.inputVariables inputVar = new LAD_IsInvoicedUpdate.inputVariables();
        inputVar.accountId = testAccount.id;

        // Call the method
        Test.startTest();
        LAD_IsInvoicedUpdate.updateAmountNotInvoiced(new List<LAD_IsInvoicedUpdate.inputVariables> { inputVar });
        Test.stopTest();

     }
}