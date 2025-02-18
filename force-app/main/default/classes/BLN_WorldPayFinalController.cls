global without sharing class BLN_WorldPayFinalController {

    @RemoteAction
    global static Map<String,String> verification(String challengeUrl,String paymentid){
        Map<String,String> returnmap = BLN_WorldPayVerification.performCallout(paymentid);
        return returnmap;
    }
}