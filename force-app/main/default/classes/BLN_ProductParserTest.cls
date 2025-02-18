@isTest
private class BLN_ProductParserTest {
    @isTest
    static void testParseMethod() {
        String jsonData = '{"discount":"10%","quote":[{"quotename":"Quote1","location":"XYZ","liability":"Liability","net":"Net","vat":"VAT","total":"Total","earliestAppointmentAvailability":"September 23th,2024","weatherGuard":"September 23th,2024","quoteLineItem":[{"name":"Product1","qty":1,"net":"10,001","vat":"VAT","total":"Total","price":100,"isVap":false}]}]}';
        BLN_ProductParser parsedData = BLN_ProductParser.parse(jsonData);
        System.assertEquals('10%', parsedData.discount, 'expected 10%');
        System.assertEquals('Quote1', parsedData.quote[0].quotename, 'expected Quote1');
    }

    @isTest
    static void testParseGPSMethod() {
        String jsonGPSData = '{"results":[{"bomId":123,"partNumber":"ABC123"}],"vehicleDamage":{"transactionId":"123","status":"OK","vehicleId":456}}';
        BLN_ProductParser parsedGPSData = BLN_ProductParser.parseGPS(jsonGPSData);
        System.assertEquals(123, parsedGPSData.results[0].bomId, 'expected 123');
        System.assertEquals('ABC123', parsedGPSData.results[0].partNumber, 'expected ABC123');
        System.assertEquals('OK', parsedGPSData.vehicleDamage.status, 'expected OK');
    }

    @isTest
    static void testServCertainityParsing() {
        String jsonData = '{"glassDamageDocument": {"glassDamageDocumentID": "GD123", "uploadURL": "https://example.com/upload"}}';
        BLN_ProductParser parsedData = BLN_ProductParser.parse(jsonData);
        
        System.assertNotEquals(null, parsedData.glassDamageDocument, 'glassDamageDocument should not be null');
        System.assertEquals('GD123', parsedData.glassDamageDocument.glassDamageDocumentID, 'expected glassDamageDocumentID to be GD123');
        System.assertEquals('https://example.com/upload', parsedData.glassDamageDocument.uploadURL, 'expected uploadURL to be https://example.com/upload');
    }
}