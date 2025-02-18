/**
* @description       : Mock Response Class for LAD_FetchTaxDetails
* @author            : Prajjawal Tiwari
* @group             : B2B Commerce - Belron
* @last modified on  : 03-09-2024
* @last modified by  : Prajjawal Tiwari
**/

public class LAD_FetchTaxDetailsMockOcta implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest request) {
        string json='{ "lineItems": [ { "totalTax": 12.7, "taxRate": 0.2, "taxCode": "STD 20", "lineItemNumber": 11 } ] }';
         if(request.getEndpoint().contains('oauth/token')){
            HttpResponse response = new HttpResponse();
            response.setBody('{ "isoCurrencyCodeAlpha": "GBP", "documentDate": "2024-08-02", "bsId": "69489897", "tradeAccountId": "", "vatRegistrationNumber": "", "delegatedAuthority": "", "sellerCountry": "United Kingdom", "customerCountry": "United Kingdom", "lineItems": [ { "lineItemNumber": 11, "cpqPartNumber": "8580AGAGYVW", "quantity": 2, "unitPrice": 63.50, "extendedPrice": 63.50 } ] }');
            response.setStatusCode(200);
            return response;
        }
        else{
            HttpResponse response = new HttpResponse();
            response.setBody(json);
            response.setStatusCode(200);
            return response;
        }
    }
}