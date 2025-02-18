public class BLN_ReserveCptStockMock implements HttpCalloutMock{
public HTTPResponse respond(HTTPRequest req) {
     String dateToday = '20231028';
     /*String jsonRes = '{'+
         	' \"jobId\": '
            ' \"items\": [ '+
            '  {'+
            '   \"lineId\": \"123\",'+
            '    \"returnedQuantity\": 1,'+
            '    \"errorCode\": \"00000\",'+
			'  }'+
			']' + 
    		'}';  */      
    String jsonRes = '[\n  {\n    \"jobId\": \"13441111\",\n    \"foStockOrderId\": \"77347\",\n    \"costCenterId\": \"23401\",\n    \"itemsCreate\": [\n      {\n        \"lineId\": \"11\",\n        \"itemId\": \"HGFG743799800\",\n        \"stockLocationOrganizationId\": \"201\",\n        \"currentQuantity\": 0,\n        \"actionQuantity\": 1,\n        \"requiredByDateTime\": \"2023-11-25T10:00:00+00:00\",\n        \"collectionFlag\": \"N\",\n        \"actionType\": \"RESERVATION\"\n      },\n      {\n        \"lineId\": \"12\",\n        \"itemId\": \"GGHHJ73466767\",\n        \"stockLocationOrganizationId\": \"201\",\n        \"currentQuantity\": 0,\n        \"actionQuantity\": 3,\n        \"requiredByDateTime\": \"2023-11-25T10:00:00+00:00\",\n        \"collectionFlag\": \"N\",\n        \"actionType\": \"RESERVATION\"\n      }\n    ],\n    \"itemsRevoke\": [\n      {\n        \"lineId\": \"13\",\n        \"itemId\": \"ffggtgt34rgtg\",\n        \"stockLocationOrganizationId\": \"CPT\",\n        \"currentQuantity\": 1,\n        \"actionQuantity\": 0,\n        \"requiredByDateTime\": \"2023-11-25T10:00:00+00:00\",\n        \"collectionFlag\": \"Y\",\n        \"actionType\": \"CANCEL\"\n      },\n      {\n        \"lineId\": \"14\",\n        \"itemId\": \"eededededd\",\n        \"stockLocationOrganizationId\": \"201\",\n        \"currentQuantity\": 3,\n        \"actionQuantity\": 0,\n        \"requiredByDateTime\": \"2023-11-25T10:00:00+00:00\",\n        \"collectionFlag\": \"Y\",\n        \"actionType\": \"CANCEL\"\n      }\n    ]\n  }\n]';
        String contentType = 'application/x-www-form-urlencoded';
        if(req.getEndpoint() == 'callout:BLN_OktaAuthToken'){
            HttpResponse response = new HttpResponse();
            response.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"MockAccessToken123","scope":"read"}');
            response.setStatusCode(200);
            return response;      
        }else {
            HttpResponse response = new HttpResponse();
            response.setBody(jsonRes);
            response.setStatusCode(200);
            return response; 
        }
    }
}