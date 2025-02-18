/** @description : BLN_InvokeWorldPayMobileApp is used in bln_InvokeWorldPayMobileApp LWC to generate hash value and salt value and to encode url.
*  	@autor: Gaurav Giradkar
* 	@Story: FOUK-1609
*	@Created Date: 01/0/2024
*/
public with sharing class BLN_InvokeWorldPayMobileApp {
    @AuraEnabled
    public static SaltAndHash generateSaltAndHash(){
        String timestamp = Datetime.now().format('ddMMyyyyHHmmss');
        String salt = String.valueOf(Crypto.getRandomInteger());
        String uuid = System.label.BLN_WorldPayMobileUUID;
        //Key will be UUID
        Blob key = Blob.valueOf(uuid);
        Blob data = Crypto.generateMac('hmacSHA512', Blob.valueOf(UUID+salt+timestamp), key);
        //HMAC is hex
        String hashData = EncodingUtil.convertToHex(data);
        hashData = hashData.toUpperCase();
        //Random transaction refrence generation
        Blob blobKey = Crypto.GenerateAESKey(128);
        String hexKey = EncodingUtil.ConvertTohex(blobKey);
        String randomTransactionRefrence = hexKey.SubString(0,8)+ '-' + hexKey.SubString(8,12) + '-' + hexKey.SubString(12,16) + '-' + hexKey.SubString(16,20) + '-' + hexKey.substring(20);
        SaltAndHash obj = new SaltAndHash();
        obj.saltVal = salt;
        obj.hashVal = hashData;
        obj.dateTimeVal = timestamp;
        obj.transactionRefrence = randomTransactionRefrence;
        return obj;
    }

    @AuraEnabled
    public static string generateEncodedURL(String urlToEncodeString){
        String originalEncodedString = EncodingUtil.base64Encode(Blob.valueOf(urlToEncodeString));
        String encodedString = EncodingUtil.urlEncode(originalEncodedString, 'UTF-8');
        return encodedString;
    }

    @AuraEnabled
    public static Boolean checkSTRelease(String woliID){
        try {
            WorkOrderLineItem woli = [SELECT Id, ServiceTerritory.BLN_ConsiderforR1__c FROM WorkOrderLineItem WHERE Id = :woliID WITH SECURITY_ENFORCED];
            return woli.ServiceTerritory.BLN_ConsiderforR1__c;
            
        } catch (Exception e) {
            BLN_ExceptionLogger.captureException(e);
        }
        return false;
    }
    public class SaltAndHash{
        @AuraEnabled public string saltVal;
        @AuraEnabled public string hashVal;
        @AuraEnabled public string dateTimeVal;
        @AuraEnabled public string transactionRefrence;
    }
}