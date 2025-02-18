public class BLN_PDSSearchMuleMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
     String dateToday = '20231028';
     String jsonRes = '{'+
            ' \"corporate\": [ '+
            '  {'+
            '   \"policyNumber\": \"1000005\",'+
            '    \"policyStartDate\": \"2023-10-28T00:00:00Z\",'+
            '    \"policyEndDate\": \"2023-11-11T00:00:00Z\",'+
            '    \"validationToken\": null,'+
            '    \"additionalDrivers\": null,'+
            '   \"schemeCode\": null,'+
            '    \"policyTypeCode\": \"COMP\",'+
            '    \"replacementLimit\": null,'+
            '   \"replacementExcess\": null,'+
            '    \"repairLimit\": null,'+
            '    \"repairExcess\": null,'+
            '    \"VRN\": \"A1000005\",'+
            '   \"vehicleMake\": \"FIAT\",'+
            '    \"vehicleModel\": \"500 POP\",'+
            '    \"site\": \"TBD\",'+
            '   \"accountName\": null,'+
            '    \"salutation\": \"Miss\",'+
            '   \"firstName\": \"DummyFirstName\",'+
            '    \"middleName\": null,'+
            '    \"lastName\": \"DummyLastName\",'+
            '   \"billingAddressPostalCode\": \"ABCDXYZ\",'+
            '   \"billingAddressStreet\": null,'+
            '   \"VATRegistered\": null,'+
            '   \"legalEntity\": \"012606988175\",'+
            '   \"fleetSite\": \"\",'+
            '   \"fleetLegalEntity\": null,'+
            '   \"fleetCountryGrouping\": \"UK\",'+
            '   \"fleetOperatingCompanyName\": \"DummyName\",'+
            '   \"fleetOperatingCompanyPostcode\": \"1234567\",'+
            '   \"fleetContractStartDate\":' + '\"2023-10-28\"' + ','+
            '   \"fleetContractEndDate\":' + '\"2023-11-11\"' +
            '  }'+
			'],' +
			' \"errors\" : [' +
			' {'+
			'  \"status\" : \"503\" ,' +
			'  \"title\" : \"Service Unavailable\",'+
			'  \"detail\" : \"The server is currently unable to handle the request due to a temporary overload or maintenance of the server. Please try again later.\",'+
			'  \"insurerAPI\" : \"ADMIRAL\" '+
			'  }'+
			']' + 
    		'}';        
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