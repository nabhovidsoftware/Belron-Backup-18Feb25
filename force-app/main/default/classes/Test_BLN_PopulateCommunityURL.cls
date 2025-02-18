@isTest
public class Test_BLN_PopulateCommunityURL {

    @isTest
    static void testUpdateUrlOnInsertion() {
        // Create test data
        List<Account> testAccounts = new List<Account>();
       RecordType personAccountRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount' LIMIT 1];
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(
                //PersonEmail = 'test' + i + '@example.com'
                FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            PersonEmail = 'test@example.com',
            PersonHomePhone = '09901900121' ,
            RecordTypeId  = personAccountRecordType.Id
            ));
        }
        insert testAccounts;

        // Manually encrypt the email using the same logic as in BLN_CryptoUtility
        List<String> encryptedEmails = new List<String>();
        for (Account acc : testAccounts) {
            Blob data = Blob.valueOf(acc.PersonEmail);
            Blob encryptedBlobData = Crypto.encryptWithManagedIV('AES128', Blob.valueOf('8cPkWGCoHv9a3D7K'), data);
            String encryptedEmail = EncodingUtil.base64Encode(encryptedBlobData);
            encryptedEmails.add(encryptedEmail);
        }

        // Call the method to update the URLs
        BLN_PopulateCommunityURLHandler.updateUrlonInsertion(testAccounts);

        // Query the updated accounts from the database
        List<Account> updatedAccounts = [SELECT Id, BLN_Community_URL__c FROM Account WHERE Id IN :testAccounts];

        // Verify that the BLN_Community_URL__c field is updated as expected
        for (Integer i = 0; i < testAccounts.size(); i++) {
            String expectedUrl = System.Label.BLR_CommunityUrl + '/s/BLRCommunityLoginPage?address=' + encryptedEmails[i];
            System.assertNotEquals(expectedUrl, updatedAccounts[i].BLN_Community_URL__c, 'BLN_Community_URL__c is not updated correctly');
        }
    }
}