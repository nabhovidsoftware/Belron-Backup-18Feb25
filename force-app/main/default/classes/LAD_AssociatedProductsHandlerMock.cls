/** @description :  This apex class is used to generate mock response for the testing LAD_AssociatedProductsHandler.
*   @Story :        FOUK-7848; FOUK-7866; FOUK-7867; FOUK-7868; FOUK-8518
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   03-07-2024
*/
@isTest
public with sharing class LAD_AssociatedProductsHandlerMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest request){
        String json ='{'+
        '"currencyIsoCode":"GBP",'+
        '"error":{},'+
        '"pricingLineItemResults":[{"error":{},'+
            '"listPrice":null,'+
            '"pricebookEntryId":"01uFg0000000000000",'+
            '"productId":"'+ LAD_AssociatedProductsHandlerTest.childProduct1 +'",'+
            '"success":true,'+
            '"unitPrice":"50"},'+
            '{"error":{},'+
            '"listPrice":"100",'+
            '"pricebookEntryId":"01uFg0000000000000",'+
            '"productId":"'+ LAD_AssociatedProductsHandlerTest.childProduct2 +'",'+
            '"success":true,'+
            '"unitPrice":"100"}],'+
        '"success":true}';
    
        HttpResponse response = new HttpResponse();
        response.setBody(json);
        response.setStatusCode(200);
        return response;
    }
}