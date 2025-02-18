/*****************************************
ClassName : BLN_PopulateCommunityURLHandler
Description : The BLN_PopulateCommunityURLHandler class is responsible for Generating URL
@Story : FOUK-4951
CreatedDate: 04-01-2024
CreatedBy : Vedita
****************************************/
Public class BLN_PopulateCommunityURLHandler   {
    
    @InvocableMethod(label='update community url' description ='update community url with encrypted email address')
    public static void updateUrlonInsertion(List<Account> accList){ 
        
        String customLabelValue = System.Label.BLN_CommunityEncrptUrl;
        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : accList) {     
            if (acc.PersonEmail != null) {// Check if the email field is not null
                try{        
                    BLN_CryptoUtility cryptoUtilityInstance = new BLN_CryptoUtility();
                    String encryptedEmail = cryptoUtilityInstance.encyptData(acc.PersonEmail); // Encrypt the email using BLR_CryptoUtility.cls (Assuming you have this class available)
                    //system.debug('encryptedEmail--->'+encryptedEmail);
                   
                    String communityURL = customLabelValue + encryptedEmail; // Build the Community URL using the formula
                    //system.debug('CommunityURL --->'+CommunityURL);
                    acc.BLN_Community_URL__c = communityURL; //system.debug('BLN_Community_URL__c--->'+acc.BLN_Community_URL__c);
                }
                catch (Exception e) {
                    //System.debug('Encryption error: ' + e.getMessage());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred.'));
                }
            }
        }
    }   
}