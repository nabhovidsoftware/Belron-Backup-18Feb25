/** @description :  Test Class for LAD_QuoteHandler
*  @author:         (ashwin.r.raja@pwc.com (IN))
*  @story:          FOUK-9920; FOUK-9922; FOUK-9923; FOUK-9925
*/

@isTest
public class LAD_QuoteHandlerTest {
 
    @TestSetup
    static void testdata(){
        Account testAccount = new Account(Name = 'ABC Corp');
        insert testAccount;
        Contact testContact = New Contact(LastName = 'Test', AccountID = testAccount.id);
        insert testContact;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Laddaw B2B Commerce External User' LIMIT 1];
        user testUser = New User(UserName = 'test_' + math.random() + '@test.com',
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
        
        Product2 testProduct1 = new Product2(Name = 'Test Product 1', ProductCode = 'Prod1');
        Product2 testProduct2 = new Product2(Name = 'Test Product 2', ProductCode = 'Prod2');
        Product2 testProduct3 = new Product2(Name = 'Test Product 3', ProductCode = 'Prod3');

        insert testProduct1;
        insert testProduct2;
        insert testProduct3;

        LAD_Quote__c currentQuote = new LAD_Quote__c(LAD_Account__c = testAccount.Id, LAD_Contact__c = testContact.Id, OwnerId = testUser.Id);
        insert currentQuote;
        
		List<LAD_Quote_Item__c> quoteItemList = new List<LAD_Quote_Item__c>();
        for(integer i=0; i<3; i++){
            LAD_Quote_Item__c temp = new LAD_Quote_Item__c();
            String name = 'Test Product '+ (i+1);
            Id prod = [SELECT Id, ProductCode, Name FROM Product2 WHERE Name =:name LIMIT 1].Id;
            temp.LAD_Quote__c = currentQuote.Id;
            temp.LAD_Product__c = prod;
            temp.LAD_Price__c = 5;
            temp.LAD_Quantity__c = 5;
            quoteItemList.add(temp);
         }

         insert quoteItemList; 
    } 
	
    @isTest
    private static void createQuoteAndQuoteItemsTest(){
        Id u = [SELECT Id FROM User WHERE LastName ='Test-Last' LIMIT 1].Id;
        Id acc = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        LAD_QuoteHandler.QuoteDetailWrapper testQuote = new LAD_QuoteHandler.QuoteDetailWrapper();
        testQuote.effectiveAccountId = acc;
        testQuote.userId = u;
        List <LAD_QuoteHandler.QuoteItemWrapper> testQuoteItems = new List <LAD_QuoteHandler.QuoteItemWrapper>();
        for(integer i=0; i<3; i++){
            String name = 'Test Product '+ (i+1);
            LAD_QuoteHandler.QuoteItemWrapper tempQuoteItem = new LAD_QuoteHandler.QuoteItemWrapper();
            Product2 temp = [SELECT Id, ProductCode, Name FROM Product2 WHERE Name = 'Test Product 1' LIMIT 1];
            tempQuoteItem.ProductCode = temp.ProductCode;
            tempQuoteItem.ProductId = temp.Id;
            tempQuoteItem.ProductName = temp.Name;
            tempQuoteItem.Price = String.valueOf(i+100);
            tempQuoteItem.Quantity = Double.valueOf(i+5);
            testQuoteItems.add(tempQuoteItem);
        }
        testQuote.quoteItems = testQuoteItems;
        
       	Test.startTest();
        Map<String, String> result = LAD_QuoteHandler.createQuoteAndQuoteItems(testQuote);
        System.AssertEquals(result.containsKey('Success'),True);
        Test.stopTest();
    }
    
    @isTest
    private static void generateQuoteDocTest(){
        Id acc = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        Id u = [SELECT Id FROM User WHERE LastName ='Test-Last' LIMIT 1].Id;
        LAD_Quote__c q = [SELECT Id, LAD_Account__c, 
                                 LAD_Contact__c, LAD_Total_Price__c 
                          FROM LAD_Quote__c 
                          WHERE LAD_Account__c =:acc ];
        
        LAD_QuoteHandler.QuoteDetailWrapper testQuote = new LAD_QuoteHandler.QuoteDetailWrapper();
        testQuote.effectiveAccountId = q.LAD_Account__c;
        testQuote.userId = u;
        testQuote.quoteId = q.Id;
        
        List <LAD_QuoteHandler.QuoteItemWrapper> testQuoteItems = new List <LAD_QuoteHandler.QuoteItemWrapper>();
        for(integer i=0; i<3; i++){
            String name = 'Test Product '+ (i+1);
            LAD_QuoteHandler.QuoteItemWrapper tempQuoteItem = new LAD_QuoteHandler.QuoteItemWrapper();
            LAD_Quote_Item__c temp = [SELECT Id, LAD_Product__c, LAD_Product__r.ProductCode,
                                             LAD_Product__r.Name, LAD_Price__c, LAD_Quantity__c 
                                      FROM LAD_Quote_Item__c 
                                      WHERE LAD_Quote__c=:q.Id LIMIT 1];
            tempQuoteItem.ProductCode = temp.LAD_Product__r.ProductCode;
            tempQuoteItem.ProductId = temp.LAD_Product__c;
            tempQuoteItem.ProductName = temp.LAD_Product__r.Name;
            tempQuoteItem.Price = String.valueOf(temp.LAD_Price__c);
            tempQuoteItem.Quantity = temp.LAD_Quantity__c;
            testQuoteItems.add(tempQuoteItem);
        }
        testQuote.quoteItems = testQuoteItems;
        
        LAD_QuoteHandler.QuoteWrapper getQuote = LAD_QuoteHandler.getQuoteDetailsAndItems(testQuote);
        System.debug('getQuote'+ getQuote);
		String productCodes;
        String productName;
        String productQuantity;
        String productPrice;
        Map<String,String> response = new Map<String,String>();
        response.put('AccountName', getQuote.AccountName);
        response.put('ContactName', getQuote.ContactName);
        response.put('QuoteNumber', getQuote.QuoteNumber);
        response.put('Date', getQuote.CreatedDate);
        
        for(LAD_QuoteHandler.QuoteItemWrapper qi:getQuote.quoteItems){
            productCodes+='\r\n'+ qi.ProductCode;
            productName+='\r\n'+ qi.ProductName;
            productQuantity+='\r\n'+qi.Quantity;  
            productPrice+='\r\n'+qi.Price;
        }
        
        response.put('ProductCode', productCodes);
        response.put('ProductName', productName);
        response.put('ProductQuantity', productQuantity);
        response.put('ProductPrice', productPrice);
        response.put('TotalPrice', getQuote.TotalPrice);
        
        Test.startTest();
        String s = LAD_QuoteHandler.generateQuoteDoc(response);
        Test.stopTest();
    }
    
    @isTest
    private static void getQuotesTest(){
        Id acc = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        
        Test.startTest();
        List<LAD_QuoteHandler.QuoteWrapper> q = LAD_QuoteHandler.getQuotes(acc);
        Test.stopTest();
    }
    
    
    @isTest
    private static void getQuoteDetailsAndItemsTest(){
        Id acc = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        Id u = [SELECT Id FROM User WHERE LastName ='Test-Last' LIMIT 1].Id;
        LAD_Quote__c q = [SELECT Id, LAD_Account__c, 
                                 LAD_Contact__c, LAD_Total_Price__c 
                          FROM LAD_Quote__c 
                          WHERE LAD_Account__c =:acc ];
        
        LAD_QuoteHandler.QuoteDetailWrapper testQuote = new LAD_QuoteHandler.QuoteDetailWrapper();
        testQuote.effectiveAccountId = q.LAD_Account__c;
        testQuote.userId = u;
        testQuote.quoteId = q.Id;
        
        List <LAD_QuoteHandler.QuoteItemWrapper> testQuoteItems = new List <LAD_QuoteHandler.QuoteItemWrapper>();
        for(integer i=0; i<3; i++){
            String name = 'Test Product '+ (i+1);
            LAD_QuoteHandler.QuoteItemWrapper tempQuoteItem = new LAD_QuoteHandler.QuoteItemWrapper();
            LAD_Quote_Item__c temp = [SELECT Id, LAD_Product__c, LAD_Product__r.ProductCode,
                                             LAD_Product__r.Name, LAD_Price__c, LAD_Quantity__c 
                                      FROM LAD_Quote_Item__c 
                                      WHERE LAD_Quote__c=:q.Id LIMIT 1];
            tempQuoteItem.ProductCode = temp.LAD_Product__r.ProductCode;
            tempQuoteItem.ProductId = temp.LAD_Product__c;
            tempQuoteItem.ProductName = temp.LAD_Product__r.Name;
            tempQuoteItem.Price = String.valueOf(temp.LAD_Price__c);
            tempQuoteItem.Quantity = temp.LAD_Quantity__c;
            testQuoteItems.add(tempQuoteItem);
        }
        testQuote.quoteItems = testQuoteItems;
        
        Test.startTest();
        LAD_QuoteHandler.QuoteWrapper getQuote = LAD_QuoteHandler.getQuoteDetailsAndItems(testQuote);
        System.AssertEquals(String.isBlank(getQuote.Error),true);
        Test.stopTest();
    }
    
    @isTest
    private static void invokeDeleteQuotesTest(){
        Id acc = [SELECT Id FROM Account WHERE Name = 'ABC Corp' LIMIT 1].Id;
        Id con = [SELECT Id FROM Contact WHERE LastName = 'Test' LIMIT 1].Id;
        Id u = [SELECT Id FROM User WHERE LastName ='Test-Last' LIMIT 1].Id;
        Date cutoffDate = Date.today().addYears(-3); 
        LAD_Quote__c currentQuote = new LAD_Quote__c(LAD_Account__c = acc, LAD_Contact__c = con, OwnerId = u);
        insert currentQuote;
        Test.setCreatedDate(currentQuote.Id, cutoffDate);
        Test.startTest();
        LAD_QuoteHandler.invokeDeleteQuoteBatch(); 
        Test.stopTest();
    }
    
}