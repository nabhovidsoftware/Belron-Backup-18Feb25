@isTest
public class BLN_CryptoUtilityTest {
    // Define test data
    static final String ENCRYPTION  = '8cPkWGCoHv9a3D7K';
    static final String DATA = 'Test Data';
    
    @isTest
    static void testEncryptData() {
        // Set up encryption key
        BLN_CryptoUtility cryptoUtility = new BLN_CryptoUtility();
        BLN_CryptoUtility.setEncryptionKey(ENCRYPTION);
        
        // Encrypt test data
        String encryptedData = cryptoUtility.encyptData(DATA);
        
        // Verify encrypted data is not null
        System.assertNotEquals(null, encryptedData,'Data Not equal');
    }
    
    @isTest
    static void testDecryptData() {
        // Set up encryption key
        BLN_CryptoUtility cryptoUtility = new BLN_CryptoUtility();
        BLN_CryptoUtility.setEncryptionKey(ENCRYPTION);
        String encryptedData = cryptoUtility.encyptData(DATA);
        encryptedData = EncodingUtil.urlDecode(encryptedData,'UTF-8');
        String decryptedData = cryptoUtility.decryptData(encryptedData);
        System.assertnotEquals(data, decryptedData,'Data not equal');
    }
    @isTest
    static void testEncryptEmail(){
     BLN_CryptoUtility cryptoUtility = new BLN_CryptoUtility();
     String encryptedData = cryptoUtility.encryptEmail('lab05@jetboy.co.uk');
     System.assertNotEquals(null, encryptedData, 'Encrypted data should not be null.');  
     System.assertNotEquals('', encryptedData, 'Encrypted data should not be empty.');  
    }
    
    @isTest
    static void testDecryptEmail(){
     BLN_CryptoUtility cryptoUtility = new BLN_CryptoUtility();
     String decryptedData = cryptoUtility.decryptEmail('lab05%40jetboy.co.uk');
     System.assertNotEquals(null, decryptedData, 'Encrypted data should not be null.');  
     System.assertNotEquals('', decryptedData, 'Encrypted data should not be empty.'); 
    }
    
}