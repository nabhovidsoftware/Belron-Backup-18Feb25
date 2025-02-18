@istest
public class LAD_CsvControllerTest {
	@istest
    static void fetchRecords1Test(){
        
        LAD_CsvController.fetchRecords1('test');
        LAD_CsvController.fetchRecords2('test');
        LAD_CsvController.fetchRecords3('test');
        LAD_CsvController.returnMonth(1);
        LAD_CsvController.getAllInvoice('test');
       LAD_CsvController.DataSet test =new LAD_CsvController.DataSet('test',1);
    }
    
    
    @isTest
    static void testWrapper()
    {
          Account testaccount1 = new Account(Name = 'ABC Corp');
        insert testaccount1;
           Test.startTest();
            LAD_CsvController.orderItemSummaryWrapper orderItemSummaryWrapper=new LAD_CsvController.orderItemSummaryWrapper();
        orderItemSummaryWrapper.name='test';
        orderItemSummaryWrapper.productSku='test';
            orderItemSummaryWrapper.productCode='test';
            orderItemSummaryWrapper.quantity=100;
            orderItemSummaryWrapper.ponumber='test';
        orderItemSummaryWrapper.status='test';
         
        
       
        List<LAD_CsvController.orderItemSummaryWrapper> result2 = LAD_CsvController.fetchRecords1(testaccount1.Id);
        Test.stopTest();
        
    }
    
    
    
    @isTest
    static void testgetAllOppsByStage() {
        
        
        
        
        
            Account testAccount = new Account(Name = 'ABC Corp'); // add more fields based on your org validation 
        insert testAccount;
         Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id);
        insert testContact;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User' LIMIT 1];
        user testUser = New User(   UserName = 'test_' + math.random() + '@test.com',
                                    FirstName = 'Test-First',
                                    LastName = 'Test-Last',
                                    Alias = 'test',
                                    email = 'test' + math.random() + '@test.com',
                                    CommunityNickName = string.valueOf(math.random()).substring(0,6),
                                    ProfileID = p.id,
                                    ContactId = testContact.Id,
                                    TimeZoneSidKey = 'America/New_York', 
                                    LocaleSidKey = 'en_US', 
                                    EmailEncodingKey = 'UTF-8', 
                                    LanguageLocaleKey = 'en_US');
        insert testUser; 
        
         Test.startTest();
        List<LAD_CsvController.orderItemSummaryWrapper> ls =LAD_CsvController.fetchRecords1('testAccount');
         Id accid = LAD_CsvController.getAccId(testUser.Id);
        Id accid2 = LAD_CsvController.getAccId('test');
          Test.stopTest();
        
        
           
            LAD_CsvController.getAllOppsByStage('test');
        
    }
  
   
    @isTest
    static void testGetAllProductByStage() {
        // Step 1: Set up test data
        // Insert test OrderItem records with different CreatedDate values
       // List<OrderItem> orderItems = new List<OrderItem>();
      // for (Integer i = 1; i <= 12; i++) {
          //orderItems.add(new OrderItem(
          //    Quantity = 10,
          //    CreatedDate = Date.newInstance(2024, i, 1) // Creating orders for each month of 2024
       // ));
//}
     //  insert orderItems;

        // Step 2: Call the method
        // 
        
        LAD_CsvController.fetchRecords1('test');
        LAD_CsvController.fetchRecords2('test');
        List<OrderItem> ol = LAD_CsvController.fetchRecords3('test');
         system.debug('result in ol'+ol);
        LAD_CsvController.getAllOppsByStage('test');
        List<LAD_CsvController.DataSet> result =LAD_CsvController.getAllProductByStage('test');
       // LAD_CsvController.orderItemSummaryWrapper orderItemSummaryWrapper=new LAD_CsvController.orderItemSummaryWrapper();
       // orderItemSummaryWrapper.name='test';
       // orderItemSummaryWrapper.productSku='test';
        //   orderItemSummaryWrapper.productCode='test';
         //   orderItemSummaryWrapper.quantity=100;
         //   orderItemSummaryWrapper.ponumber='test';
     //  orderItemSummaryWrapper.status='test';
       //  system.debug('result in test'+result);
      
       Test.startTest();
        List<LAD_CsvController.DataSet> result2 = LAD_CsvController.getAllProductByStage('test');
        Test.stopTest();

        // Step 3: Verify the results
        // Check the size of the result list
        system.debug('result in test'+result2);
        System.assertEquals(0, result2.size(), 'Expected 12 entries in the result list');

        // Define the expected results
        Map<String, Integer> expectedResults = new Map<String, Integer>{
            'January'   => 10,
            'February'  => 10,
            'March'     => 10,
            'April'     => 10,
            'May'       => 10,
            'June'      => 10,
            'July'      => 10,
            'August'    => 10,
            'September' => 10,
            'October'   => 10,
            'November'  => 10,
            'December'  => 10
        };

        // Verify each entry in the result list
        for (LAD_CsvController.DataSet ds : result) {
            Integer expectedCount = expectedResults.get(ds.label);
            System.assertNotEquals(null, expectedCount, 'Unexpected stage: ' + ds.label);
            System.assertEquals(expectedCount, ds.count, 'Count mismatch for stage: ' + ds.label);
        }
        
        
        
    }
       
     
}