public class productAvailablility_httpCallout {
    
    public static HttpResponse makeCallout(Map<String, String> requestMap){
        /*Map<String, String> requestMap = new Map<String, String>{
'endpoint' => 'https://example.com/api/stockdelivery',
'method' => 'GET',
'body' => '{"productId":"01tFg000003K8nhIAC","location":"New York","quantity":100,"deliveryDate":"15 April 2024" }',
'header' => '{"Content-Type":"application/json"}'
};*/
        
        system.debug('requestMap co>>'+requestMap);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        try {
            if(!requestMap.isEmpty()){
                if(requestMap.containsKey('endpoint') && requestMap.get('endpoint')!=null){
                    request.setEndpoint(requestMap.get('endpoint'));                
                }
                if(requestMap.containsKey('method') && requestMap.get('method')!=null){
                    request.setMethod(requestMap.get('method'));
                }
                if(requestMap.containsKey('body') && requestMap.get('body')!=null){
                    request.setBody(requestMap.get('body'));
                }
                if(requestMap.containsKey('header') && requestMap.get('header')!=null){
                    Map<string,Object> headerMap = (map<string,object>)JSON.deserializeUntyped(requestMap.get('header'));
                    for(string key : headerMap.keyset()){
                        request.setHeader(key,string.valueOf(headerMap.get(key)));
                    }
                }                
                if(test.isrunningtest()){  
                    response.setStatusCode(200);
                    response.setStatus('OK');
                    response.setBody('{"CheckAvailabilityOutput": {"PromisingSystem": "NewGop","PromisingInstance": "GOP","PromiseDateTime": "2020-09-17T00:00:00.000+0000","FulfillmentLineEntryResultList": [{"FulfillmentLineReplyList":[{"FulillmentLineIdentifier":"1","NumberOfAltOptions":1,"DefaultAvailabilityOption":{"OptionRank":0,"OptionSummary":"0","FulfillmentLineResultList":[{"FulfillmentLineIdentifier":"1","TotalPrice":100,"TotalProfit":100,"TotalMargin":100,"TotalValue":0,"NumberOfSplits":0,"NumberOfSubstitutions":0,"FillRate":100,"NumberOfAtpItems":1,"NumberOfCtpItems":0,"SourcingRule":"GOP-EXT-CTP-Tran1","ResultDetailList":[{"SplitLineIdentifier":"","PromisingStatus":"","RequestedDateTime":"2020-09-17T00:00:00.000+0000","PromisingType":"Ship","ExpectedArrivalDateTime":"2020-09-17T23:59:59.000+0000","ExpectedShipDateTime":"2020-09-17T23:59:59.000+0000","ExpectedPickDateTime":"2020-09-17T23:59:59.000+0000","RequestedItem":"RI-HV-GOP-Computer","ExpectedAvailableItem":"RI-HV-GOP-Computer","ExpectedAvailabilityOnRequestedDate":20,"ExpectedAvailableQuantity":20,"ExpectedAvailableQuantityUOM":"Ea","ExpectedDropShipSupplierSourceSystem":"","ExpectedMode":"","ExpectedService":"","ExpectedCarrier":"","CarrierCalendar":"","ExpectedDemandClass":"","ExpectedTotalFulfilmentCost":0,"ExpectedShippingCost":0,"LineFillRate":100,"Party":"Singapore Distribution Center-GOP","PartySite":"Customer Location LG17","ExpectedShipFromOrgList":[{"OrgIdentifier":"GOP:HVGOPE01"}],"PeggingDetailList":[{"ItemIdentifier":"RI-HV-GOP-Computer","ShippingCalendar":"GOP CAL 2012-30","ReceivingCalendar":"GOP CAL 2012-30","ManufacturingCalendar":"GOP CAL 2012-30","BackToBackFlag":false,"AtpDetailList":[{"Quantity":20,"QuantityUom":"Ea","AtpCost":0,"AtpMode":"3","LeadTime":0,"RequiredQuantity":20,"RequiredDateTime":"2020-09-17T23:59:59.000+0000"}],"OrgInfoList":[{"OrgIdentifier":"GOP:HVGOPE01"}]}]}]}],"AlternateAvailabilityOptionsList":[{"OptionRank":1,"OptionSummary":"6","FulfillmentLineResultList":[{"FulfillmentLineIdentifier":"1","TotalPrice":100,"TotalProfit":100,"TotalMargin":100,"TotalValue":0,"NumberOfSplits":0,"NumberOfSubstitutions":0,"FillRate":100,"NumberOfAtpItems":1,"NumberOfCtpItems":0,"SourcingRule":"GOP-EXT-CTP-Tran1","ResultDetailList":[{"SplitLineIdentifier":"","PromisingStatus":"","RequestedDateTime":"2020-09-17T00:00:00.000+0000","PromisingType":"Ship","ExpectedArrivalDateTime":"2020-09-17T23:59:59.000+0000","ExpectedShipDateTime":"2020-09-17T23:59:59.000+0000","ExpectedPickDateTime":"2020-09-17T23:59:59.000+0000","RequestedItem":"RI-HV-GOP-Computer","ExpectedAvailableItem":"RI-HV-GOP-Computer","ExpectedAvailabilityOnRequestedDate":20,"ExpectedAvailableQuantity":20,"ExpectedAvailableQuantityUOM":"Ea","ExpectedDropShipSupplierSourceSystem":"","ExpectedMode":"","ExpectedService":"","ExpectedCarrier":"","CarrierCalendar":"","ExpectedDemandClass":"","ExpectedTotalFulfilmentCost":0,"ExpectedShippingCost":0,"LineFillRate":100,"Party":"Singapore Distribution Center-GOP","PartySite":"Customer Location LG17","ExpectedShipFromOrgList":[{"OrgIdentifier":"GOP:HVGOPE02"}],"PeggingDetailList":[{"ItemIdentifier":"RI-HV-GOP-Computer","ShippingCalendar":"GOP CAL 2012-30","ReceivingCalendar":"GOP CAL 2012-30","ManufacturingCalendar":"GOP CAL 2012-30","BackToBackFlag":false,"AtpDetailList":[{"Quantity":20,"QuantityUom":"Ea","AtpCost":0,"AtpMode":"3","LeadTime":0,"RequiredQuantity":20,"RequiredDateTime":"2020-09-17T23:59:59.000+0000"}],"OrgInfoList":[{"OrgIdentifier":"GOP:HVGOPE02"}]}]}]}]}]}}]}]},"locations": [{"name": "Bardon", "deliveryDate": "April 12", "day": "Friday"}, {"name": "Bristol", "deliveryDate": "April 14", "day": "Sunday"},{"name": "Location 3", "deliveryDate": "April 15" , "day": "Monday"}, {"name": "Location 4", "deliveryDate": "April 16", "day": "Tuesday"}, {"name": "Romford", "deliveryDate": "April 17" , "day": "Wednesday"}]}');
                    
                    //       MockHttpResponseGenerator MHRG = new MockHttpResponseGenerator();
                    //    response = MHRG.respond(request);    
                }
                else{
                    if(request.getEndpoint()!=null){  response.setStatusCode(200); response.setStatus('OK');  response.setBody('{"CheckAvailabilityOutput": {"PromisingSystem": "NewGop","PromisingInstance": "GOP","PromiseDateTime": "2020-09-17T00:00:00.000+0000","FulfillmentLineEntryResultList": [{"FulfillmentLineReplyList":[{"FulillmentLineIdentifier":"1","NumberOfAltOptions":1,"DefaultAvailabilityOption":{"OptionRank":0,"OptionSummary":"0","FulfillmentLineResultList":[{"FulfillmentLineIdentifier":"1","TotalPrice":100,"TotalProfit":100,"TotalMargin":100,"TotalValue":0,"NumberOfSplits":0,"NumberOfSubstitutions":0,"FillRate":100,"NumberOfAtpItems":1,"NumberOfCtpItems":0,"SourcingRule":"GOP-EXT-CTP-Tran1","ResultDetailList":[{"SplitLineIdentifier":"","PromisingStatus":"","RequestedDateTime":"2020-09-17T00:00:00.000+0000","PromisingType":"Ship","ExpectedArrivalDateTime":"2020-09-17T23:59:59.000+0000","ExpectedShipDateTime":"2020-09-17T23:59:59.000+0000","ExpectedPickDateTime":"2020-09-17T23:59:59.000+0000","RequestedItem":"RI-HV-GOP-Computer","ExpectedAvailableItem":"RI-HV-GOP-Computer","ExpectedAvailabilityOnRequestedDate":20,"ExpectedAvailableQuantity":20,"ExpectedAvailableQuantityUOM":"Ea","ExpectedDropShipSupplierSourceSystem":"","ExpectedMode":"","ExpectedService":"","ExpectedCarrier":"","CarrierCalendar":"","ExpectedDemandClass":"","ExpectedTotalFulfilmentCost":0,"ExpectedShippingCost":0,"LineFillRate":100,"Party":"Singapore Distribution Center-GOP","PartySite":"Customer Location LG17","ExpectedShipFromOrgList":[{"OrgIdentifier":"GOP:HVGOPE01"}],"PeggingDetailList":[{"ItemIdentifier":"RI-HV-GOP-Computer","ShippingCalendar":"GOP CAL 2012-30","ReceivingCalendar":"GOP CAL 2012-30","ManufacturingCalendar":"GOP CAL 2012-30","BackToBackFlag":false,"AtpDetailList":[{"Quantity":20,"QuantityUom":"Ea","AtpCost":0,"AtpMode":"3","LeadTime":0,"RequiredQuantity":20,"RequiredDateTime":"2020-09-17T23:59:59.000+0000"}],"OrgInfoList":[{"OrgIdentifier":"GOP:HVGOPE01"}]}]}]}],"AlternateAvailabilityOptionsList":[{"OptionRank":1,"OptionSummary":"6","FulfillmentLineResultList":[{"FulfillmentLineIdentifier":"1","TotalPrice":100,"TotalProfit":100,"TotalMargin":100,"TotalValue":0,"NumberOfSplits":0,"NumberOfSubstitutions":0,"FillRate":100,"NumberOfAtpItems":1,"NumberOfCtpItems":0,"SourcingRule":"GOP-EXT-CTP-Tran1","ResultDetailList":[{"SplitLineIdentifier":"","PromisingStatus":"","RequestedDateTime":"2020-09-17T00:00:00.000+0000","PromisingType":"Ship","ExpectedArrivalDateTime":"2020-09-17T23:59:59.000+0000","ExpectedShipDateTime":"2020-09-17T23:59:59.000+0000","ExpectedPickDateTime":"2020-09-17T23:59:59.000+0000","RequestedItem":"RI-HV-GOP-Computer","ExpectedAvailableItem":"RI-HV-GOP-Computer","ExpectedAvailabilityOnRequestedDate":20,"ExpectedAvailableQuantity":20,"ExpectedAvailableQuantityUOM":"Ea","ExpectedDropShipSupplierSourceSystem":"","ExpectedMode":"","ExpectedService":"","ExpectedCarrier":"","CarrierCalendar":"","ExpectedDemandClass":"","ExpectedTotalFulfilmentCost":0,"ExpectedShippingCost":0,"LineFillRate":100,"Party":"Singapore Distribution Center-GOP","PartySite":"Customer Location LG17","ExpectedShipFromOrgList":[{"OrgIdentifier":"GOP:HVGOPE02"}],"PeggingDetailList":[{"ItemIdentifier":"RI-HV-GOP-Computer","ShippingCalendar":"GOP CAL 2012-30","ReceivingCalendar":"GOP CAL 2012-30","ManufacturingCalendar":"GOP CAL 2012-30","BackToBackFlag":false,"AtpDetailList":[{"Quantity":20,"QuantityUom":"Ea","AtpCost":0,"AtpMode":"3","LeadTime":0,"RequiredQuantity":20,"RequiredDateTime":"2020-09-17T23:59:59.000+0000"}],"OrgInfoList":[{"OrgIdentifier":"GOP:HVGOPE02"}]}]}]}]}]}}]}]},"locations": [{"name": "Bardon", "deliveryDate": "April 12", "day": "Friday"}, {"name": "Bristol", "deliveryDate": "April 14", "day": "Sunday"},{"name": "Location 3", "deliveryDate": "April 15" , "day": "Monday"}, {"name": "Location 4", "deliveryDate": "April 16", "day": "Tuesday"}, {"name": "Romford", "deliveryDate": "April 17" , "day": "Wednesday"}]}');
                    }
                }
            }
            system.debug('response co>>'+response);
            System.debug('StatusCode: ' + response.getStatusCode());
            System.debug('Status: ' + response.getStatus());
            System.debug('Body: ' + response.getBody());
            return response;           
        } catch (exception e) { return response;
                              }
    } 
}