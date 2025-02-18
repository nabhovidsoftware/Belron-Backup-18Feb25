/** @description : Test class for BLN_HTTPCallOutAccessToken
*   @Story : FOUK-1175
*   @author: PwC India
*   @CreatedDate: 06/12/2023
*/

// *@description: This method is used to test BLN_HTTPCallOutAccessToken WrapperAccessToken class.
@isTest
public class BLN_HTTPCallOutAccessTokenTest {
       private class MockResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String contentType = 'application/x-www-form-urlencoded';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', contentType);
            res.setBody('{"access_token": "MockAccessToken123", "expires_in": 3600}');
            res.setStatusCode(200);
            return res;
        }
    }
    
// *@description: This method is used to test BLN_HTTPCallOutAccessToken WrapperAccessToken class for getAccessToken.
@isTest
static void testMakeCallOutSuccess1() {
    // Create new User
    User adminUser = BLN_TestDataFactory.createAdminUser('test');
    insert adminUser;

    // Create new Account
    Account testAccount = BLN_TestDataFactory.createAccountforAPI();
    system.runAs(adminUser){
    insert testAccount;
    }

    Test.startTest();
    System.runAs(adminUser){
    Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
    BLN_HTTPCallOutAccessToken.WrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken(); 
            System.assertNotEquals(null, wrapperToken.accessToken,'Is Null');
    }
    
    Test.stopTest();
    BLN_HTTPCallOutAccessToken.WrapperAccessToken resultToken=BLN_HTTPCallOutAccessToken.getAccessToken();
    resultToken.accessToken='';
    resultToken.expiresIn=1234;
    resultToken.expireTime=Datetime.now();
}
}

    /*  
        *@return : void
    */
   /* @isTest
    static void testMakeCallOutSuccess() {
        
        String role = '';
        role= [Select Id FROM UserRole where developerName = 'BLN_UK'].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']?.Id;
        User adminUser = new User(
            ProfileId = adminProfileId,
             UserroleId =role,
            FirstName = 'PS',
            LastName = 'Test User',
            UserName = System.now().getTime() + '@test.demo',
            Alias = 'pstes',
            Email = 'test@sample.demo',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'nl_NL',
            TimeZoneSidKey = UserInfo.getTimeZone().getID(),
            UserPermissionsSupportUser = true); 
        insert adminUser;
        
        Account testAccount = BLN_TestDataFactory.createAccountforAPI();
        system.runAs(adminUser){
        insert testAccount;
        }
        Test.startTest();
        System.runAs(adminUser){
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        BLN_HTTPCallOutAccessToken.WrapperAccessToken wrapperToken = BLN_HTTPCallOutAccessToken.getAccessToken(); 
                System.assertNotEquals(null, wrapperToken.accessToken,'Is Null');
        }
        Test.stopTest();
        BLN_HTTPCallOutAccessToken.WrapperAccessToken resultToken=BLN_HTTPCallOutAccessToken.getAccessToken();
        resultToken.accessToken='';
        resultToken.expiresIn=1234;
        resultToken.expireTime=Datetime.now();
    }
}
*/