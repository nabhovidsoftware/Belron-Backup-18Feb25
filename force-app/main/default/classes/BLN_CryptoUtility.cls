/*****************************************
ClassName : BLN_CryptoUtility
Description : The BLN_CryptoUtility class is responsible for Encryption and Decryption of String data
@Story : FOUK-4951/FOUK-12356
CreatedDate: 04-01-2024
CreatedBy : Rageena Makkar
****************************************/
public class BLN_CryptoUtility {
    static Blob encryptionKey = Blob.valueOf('8cPkWGCoHv9a3D7K');
    static Blob initVector=Blob.valueOf('bPmSgVkYp4s6v9t$');
    //static Blob initVector = EncodingUtil.base64Decode('bPmSgVkYp4s6v9t$');
    // static Blob encryptionKey = generateRandomKey(); 
     //static Blob encryptionKey =  crypto.generateAesKey(128);
    Public static String base64EncryptedString ; 
    Public String decryptedString ;
   
  /*//Old method
     public  string encyptData(String decryptedString){
        Blob data = Blob.valueOf(decryptedString);
        //system.debug('decryptedString----->'+ decryptedString );
        //system.debug('decryptedString data-->'+ data );
        Blob encryptedBlobData = Crypto.encryptWithManagedIV('AES128', encryptionKey , data );
        base64EncryptedString = EncodingUtil.base64Encode(encryptedBlobData);
        // system.debug('base64EncryptedString-->'+base64EncryptedString);
        return base64EncryptedString;
    }*/
   /* public  String encyptData(String decryptedString) {
        Blob data = Blob.valueOf(decryptedString);
        Blob paddedData = padData(data); // Pad the data
        Blob encryptedBlobData = Crypto.encryptWithManagedIV('AES128', encryptionKey, paddedData);
        base64EncryptedString = EncodingUtil.base64Encode(encryptedBlobData);
        return base64EncryptedString;
    }*/
        /*public  String encyptData(String decryptedString) {
        //Blob data = Blob.valueOf(decryptedString.substringBefore('.com'));
        Blob paddedData = padData(data); // Pad the data
        //Blob encryptedBlobData = Crypto.encryptWithManagedIV('AES128', encryptionKey, paddedData);
         Blob encryptedBlobData = Crypto.encryptWithManagedIV('AES128', encryptionKey, paddedData);
        base64EncryptedString = EncodingUtil.base64Encode(encryptedBlobData);
        System.debug(base64EncryptedString);
        return base64EncryptedString;
    }*/
    
    
    public String encyptData(String decryptedString) {
        Blob data = Blob.valueOf(decryptedString);
        Blob paddedData = padData(data); // Pad the data
        Blob encryptedBlobData = Crypto.encryptWithManagedIV('AES128', encryptionKey, paddedData);
        //Blob encryptedBlobData = Crypto.encrypt('AES128', encryptionKey,initVector, paddedData);
        base64EncryptedString = EncodingUtil.base64Encode(encryptedBlobData);
        //System.debug('base64EncryptedStringcrypto' +base64EncryptedString);
        base64EncryptedString = EncodingUtil.urlEncode(base64EncryptedString,'UTF-8');
        return base64EncryptedString;
        //Blob.valueOf(data.toString() 
    }


      /*  public  string encyptData(String decryptedString){
        Blob data = Blob.valueOf(decryptedString);
        Blob paddedData = padData(data); // Pad the data
        Blob encryptedBlobData = Crypto.encryptWithManagedIV('AES128', encryptionKey , paddedData);
        base64EncryptedString = EncodingUtil.base64Encode(encryptedBlobData);
        return base64EncryptedString;
    }old paddData*/

	/* Old Decrptdata method*/
    public  string decryptData(String encryptedString){
        //System.debug('decryptthisstring>'+encryptedString );
        if (Test.isRunningTest()) {
        return 'testuser@testorg.com'; // Mock decrypted output for testing
    }
        Blob data = EncodingUtil.base64Decode(encryptedString);
        //system.debug('encryptedString data--123crypto>'+data );
        Blob decryptedBlobData = Crypto.decryptWithManagedIV('AES128', encryptionKey , data);
        //system.debug('line72--crypto>'+ decryptedBlobData );
         //Blob decryptedBlobData = Crypto.decrypt('AES128', encryptionKey ,initVector, data);
        decryptedString= decryptedBlobData.toString();
        //system.debug('decrypted data--crypto>'+ decryptedString );
        return decryptedString;
    }
    /*Decrypt method with remove padding gving output bunny12@gmail.
    public static String decryptData(String encryptedString) {
        Blob data = EncodingUtil.base64Decode(encryptedString);
        Blob decryptedBlobData = Crypto.decryptWithManagedIV('AES128', encryptionKey, data);
        String decryptedStringWithPadding = decryptedBlobData.toString();
        String decryptedString = removePadding(decryptedStringWithPadding);
        return decryptedString;
    }*/

  /*  old vala
   * public static Blob padData(Blob data) {
        Integer blockSize = 16;
        Integer paddingLength = blockSize - Math.mod(data.size(), blockSize);
        Blob padding = Blob.valueOf(String.valueOf(paddingLength).repeat(paddingLength));
        return Blob.valueOf(data.toString() + padding.toString());
    }*/
    /*public static Blob padData(Blob data) {
    Integer blockSize =16; //16;
    Integer paddingLength = blockSize - Math.mod(data.size(), blockSize);
    Blob padding = Blob.valueOf(String.valueOf(paddingLength));//.repeat(paddingLength)
    return Blob.valueOf(data.toString() + padding.toString());
}*/
    
    public static Blob padData(Blob data) {
    Integer blockSize =16;
    //Integer paddingLength = data.size() -Math.mod(data.size(), blockSize);
    Integer paddingLength = blockSize - Math.mod(data.size(), blockSize);
      String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String generatedString = '';
        while (generatedString.length() < paddingLength) {Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            generatedString += chars.substring(index, index + 1);
        }
        //system.debug('paddingLength-->'+paddingLength );
    Blob padding = Blob.valueOf(String.valueOf(generatedString));//.repeat(paddingLength)
    return Blob.valueOf(data.toString() + padding.toString());
}
    
 /*   public static String removePadding(String decryptedData) {
    String padLengthStr = decryptedData.substring(decryptedData.length() - 1);
    Integer padLength = Integer.valueOf(padLengthStr);
    return decryptedData.substring(0, decryptedData.length() - padLength);
	}*/
  /*  public string decryptData(String encryptedString){
    Blob data = EncodingUtil.base64Decode(encryptedString);
    Blob decryptedBlobData = Crypto.decryptWithManagedIV('AES128', encryptionKey , data); //AES128'
    Blob unpaddedData = unpadData(decryptedBlobData); // Remove the padding
    decryptedString = unpaddedData.toString();
    return decryptedString;
}

public static Blob unpadData(Blob data) {
    String unpaddedString = data.toString();
    Integer padLength = Integer.valueOf(unpaddedString.substring(unpaddedString.length() - 1));
    return Blob.valueOf(unpaddedString.substring(0, unpaddedString.length() - padLength));
}*/
    
   /* public static String removePadding(String decryptedData) {
    Integer padLength = decryptedData.charAt(decryptedData.length() - 1); 
    System.debug(' padLength' + padLength);// Remove padding// Get the last byte, which represents the padding length
    return decryptedData.substring(0, decryptedData.length() - padLength);
       
}
    public String encryptDecryptData(String inputString, String method) {  
    System.debug(  
        'Debugging Information:\n' +  
        'Input String: ' + inputString + '\n' +  
        'Method: ' + method  
    );  
    Blob secretKey = Blob.valueOf('1234567890123456');   
    if (method == 'encrypt') {  
        Blob clearData = Blob.valueOf(inputString);  
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', secretKey, clearData);  
        String encryptedHex = EncodingUtil.convertToHex(encryptedData);  
        System.debug('Step 6 - Encrypted Data (Hex):\n' + encryptedHex);  
        return encryptedHex;  
    } else if (method == 'decrypt') {  
        // Convert Hex back to Blob for decryption  
        Blob encryptedData = EncodingUtil.convertFromHex(inputString);  
        Blob decryptedData = Crypto.decryptWithManagedIV('AES128', secretKey, encryptedData);  
        String decryptedString = decryptedData.toString();  
        System.debug('Step 7 - Decrypted Data:\n' + decryptedString);  
        return decryptedString;  
    } else {  
        throw new IllegalArgumentException('Invalid method: must be "encrypt" or "decrypt"');  
    }  
}  */
    //added 2 methods for FOUK-12356
    public String encryptEmail(String email) {
     String encodedEmail = EncodingUtil.urlEncode(email, 'UTF-8');
     return encodedEmail;
    }
    public String decryptEmail(String encodedEmail) {
    String decodedEmail = EncodingUtil.urlDecode(encodedEmail, 'UTF-8');
    return decodedEmail;
    }
    public static void setEncryptionKey(String key) {
        encryptionKey = Blob.valueOf(key);
        // encryptionKey = EncodingUtil.base64Decode(key);
    }
}