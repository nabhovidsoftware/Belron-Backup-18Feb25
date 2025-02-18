/** @description :  This apex class is used to generate mock response for the testing LAD_ReturnAssociatedLocationDetails.
*   @Story :        FOUK-9051; FOUK-8454; FOUK-8231; FOUK-8232; FOUK-8230; FOUK-7684; FOUK-8367
*   @author:        (prajjawal.tiwari@pwc.com (IN)) (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
@isTest
public  class LAD_ReturnAssociatedLocationDetailsMock implements HttpCalloutMock{
    //respond method
    public HTTPResponse respond(HTTPRequest request) {
        
        String json ='' + 
            '{' + 
            '"CheckAvailabilityOutput":{' + 
            '"PromisingSystem":"HVGOP",' + 
            '"PromisingInstance":"GOP",' + 
            '"PromiseDateTime":"2024-06-07T00:00:00.000+0000",' + 
            '"FulfillmentLineEntryResultList":[' + 
            '{' + 
            '"FulfillmentLineReplyList":[' + 
            '{' + 
            '"FulillmentLineIdentifier":"1",' + 
            '"NumberOfAltOptions":0,' + 
            '"DefaultAvailabilityOption":{' + 
            '"OptionRank":0,' + 
            '"OptionSummary":"0",' + 
            '"FulfillmentLineResultList":[' + 
            '{' + 
            '"FulfillmentLineIdentifier":"1",' + 
            '"TotalPrice":50.0,' + 
            '"TotalProfit":50.0,' + 
            '"TotalMargin":100.0,' + 
            '"TotalValue":0.0,' + 
            '"NumberOfSplits":0,' + 
            '"NumberOfSubstitutions":0,' + 
            '"FillRate":100.0,' + 
            '"NumberOfAtpItems":1,' + 
            '"NumberOfCtpItems":0,' + 
            '"ResultDetailList":[' + 
            '{' + 
            '"SplitLineIdentifier":"",' + 
            '"PromisingStatus":"",' + 
            '"RequestedDateTime":"2024-06-07T00:00:00.000+0000",' + 
            '"PromisingType":"Ship",' + 
            '"ExpectedArrivalDateTime":"2024-06-07T22:59:59.000+0000",' + 
            '"ExpectedShipDateTime":"2024-06-07T22:59:59.000+0000",' + 
            '"ExpectedPickDateTime":"2024-06-07T22:59:59.000+0000",' + 
            '"RequestedItem":"6558LGSV3FVZ",' + 
            '"ExpectedAvailableItem":"6558LGSV3FVZ",' + 
            '"ExpectedAvailabilityOnRequestedDate":10.0,' + 
            '"ExpectedAvailableQuantity":10.0,' + 
            '"ExpectedAvailableQuantityUOM":"EA",' + 
            '"ExpectedDropShipSupplierSourceSystem":"",' + 
            '"ExpectedDemandClass":"",' + 
            '"ExpectedTotalFulfilmentCost":0.0,' + 
            '"ExpectedShippingCost":0.0,' + 
            '"LineFillRate":100.0,' + 
            '"ExpectedShipFromOrgList":[' + 
            '{' + 
            '"OrgIdentifier":"L31_UK"}' + 
            ']' + 
            ',' + 
            '"PeggingDetailList":[' + 
            '{' + 
            '"ItemIdentifier":"6558LGSV3FVZ",' + 
            '"ShippingCalendar":"Belron Facility Schedule",' + 
            '"ReceivingCalendar":"Belron Facility Schedule",' + 
            '"ManufacturingCalendar":"Belron Facility Schedule",' + 
            '"BackToBackFlag":false,' + 
            '"AtpDetailList":[' + 
            '{' + 
            '"Quantity":10.0,' + 
            '"QuantityUom":"EA",' + 
            '"AtpCost":0.0,' + 
            '"AtpMode":"3",' + 
            '"LeadTime":0.0,' + 
            '"RequiredQuantity":10.0,' + 
            '"RequiredDateTime":"2024-06-07T22:59:59.000+0000"}' + 
            ']' + 
            ',' + 
            '"OrgInfoList":[' + 
            '{' + 
            '"OrgIdentifier":"L31_UK"}' + 
            '' + 
            ']' + 
            '}' + 
            ']' + 
            '}' + 
            ']' + 
            '}' + 
            ']' + 
            '}' + 
            '}' + 
            ']' + 
            '}' + 
            ']' + 
            '}' + 
            '}' + 
            '';
        
        HttpResponse response = new HttpResponse();
        response.setBody(json);
        response.setStatusCode(200);
        return response;
    }
}