/** @description : BLN_InvokeWorldPayMobileAppTest Class used for testing BLN_InvokeWorldPayMobileApp.
*  	@autor: Gaurav Giradkar
* 	@Story: FOUK-1609
*	@Created Date: 01/0/2024
*/
@isTest
public class BLN_InvokeWorldPayMobileAppTest {
    @isTest
    public static void generateSaltAndHashTest(){
        BLN_InvokeWorldPayMobileApp.SaltAndHash result = BLN_InvokeWorldPayMobileApp.generateSaltAndHash();
        System.assertNotEquals(null, result,'result is not null');
        System.assertNotEquals(null, result.saltVal,'saltVal is not null');
        System.assertNotEquals('', result.saltVal,'saltVal is not blank');
        System.assertNotEquals(null, result.hashVal,'hashVal is not null');
        System.assertNotEquals('', result.hashVal,'hashVal is not blank');
        System.assertNotEquals(null, result.dateTimeVal,'dateTimeVal is not null');
        System.assertNotEquals('', result.dateTimeVal,'dateTimeVal is not blank');
    }
    @isTest
    public static void generateEncodedURLTest(){
        String urlToEncode = 'Test String To Encode 123';
        String encodedUrl = BLN_InvokeWorldPayMobileApp.generateEncodedURL(urlToEncode);
        BLN_InvokeWorldPayMobileApp.checkSTRelease(null);
        System.assertNotEquals(null, encodedUrl,'Encoded URL should not be null');
        System.assertNotEquals('', encodedUrl,'Encoded URL should not be blank');
    }
}