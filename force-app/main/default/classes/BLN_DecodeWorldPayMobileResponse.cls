/** @description : BLN_DecodeWorldPayMobileResponse is used in bln_PaymentResponse LWC to create payment record.
*  	@autor: Gaurav Giradkar
* 	@Story: FOUK-1609
*	@Created Date: 22/07/2024
*/
public with sharing class BLN_DecodeWorldPayMobileResponse {
    @AuraEnabled
    public static Boolean decodeWorldPayResponse(String returnResp, String woliId){
        Map<String, String> keyValueMap = new Map<String, String>();
        //Getting Payment record Id
        Id paymentRT = SObjectType.BLN_Payment__c.getRecordTypeInfosByDeveloperName().get('BLN_Payments').getRecordTypeId();
        //Gtting WOLI Details
        WorkOrderLineItem woli = [Select Id,WorkOrder.CaseId From WorkOrderLineItem Where Id =: woliId WITH SECURITY_ENFORCED];

        Boolean returnString = false;
        String paymentAmount = '';
        String paymentStatus = '';
        String tokenNumber = '';
        String linkData = '';
        
        // URL decode the string
        String urlDecodedString = EncodingUtil.urlDecode(returnResp, 'UTF-8');
        Blob decodedBlob = EncodingUtil.base64Decode(urlDecodedString);
        // Base64 Decode to URL Decoded string
        String base64DecodedString = decodedBlob.toString();
        // Split the returnString into responseLines
        List<String> responseLines = base64DecodedString.split('\n');
        
        for (String line : responseLines) {
            List<String> parts = line.split('=');
            if (parts.size() == 2) {
                keyValueMap.put(parts[0], parts[1]);
            }
        }
        // Check conditions and assign values
        if (keyValueMap.containsKey('3')) {
            String value3 = keyValueMap.get('3');
            if (value3 == '1' || value3 == '2') {
                returnString = true;
                paymentStatus = 'SUCCESS';
            } else if(value3 == '4' || value3 == '5' || value3 == '19' || value3 == '27' || value3 == '28' ||
                      value3 == '29' || value3 == '36' || value3 == '37' || value3 == '42'){
                returnString = false;
                paymentStatus = 'DECLINE';
            }
        }
        if (keyValueMap.containsKey('18')) {
            paymentAmount = String.valueOf(keyValueMap.get('18'));
        }
        if (keyValueMap.containsKey('5')) {
            tokenNumber = keyValueMap.get('5');
        }
        
        if (keyValueMap.containsKey('98')) {
            linkData = keyValueMap.get('98');
        }
         
        String randomString = BLN_SCUtility.generateRandomAlphabetString();
        String originalString = tokenNumber;  
        String updatedTokenNumber = originalString.replace('XXXXXX', randomString);  
         

        //Creating payment record
        BLN_Payment__c paymentRec = new BLN_Payment__c();
        paymentRec.BLN_PaymentAmountTaken__c = Decimal.valueOf(paymentAmount);
        paymentRec.BLN_PaymentId__c = tokenNumber;
        paymentRec.BLN_Status__c = paymentStatus;
        paymentRec.BLN_LinkData__c = linkData;
        paymentRec.BLN_PaymentType__c = System.label.BLN_ChipAndPin;
        paymentRec.RecordTypeId = paymentRT;
        paymentRec.BLN_Case__c = woli.WorkOrder.CaseId;
        paymentRec.BLN_PmtGatewayProvider__c = System.label.BLN_Worldpay;
        paymentRec.BLN_InitiatedBy__c = UserInfo.getName();
        paymentRec.BLN_PaymentMethod__c = System.label.BLN_Technician;
        if(Schema.sObjectType.BLN_Payment__c.isCreateable()){
            insert paymentRec;
        }
        return returnString;
    }
}