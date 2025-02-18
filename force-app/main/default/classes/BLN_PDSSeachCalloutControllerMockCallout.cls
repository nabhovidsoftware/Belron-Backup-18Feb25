public class BLN_PDSSeachCalloutControllerMockCallout implements HttpCalloutMock{
	public HTTPResponse respond(HTTPRequest req) {

        String accId = [select Id From Account LIMIT 1].Id;

         if (req.getEndpoint()=='callout:BLN_CreditsafeRequest/'+'gbl/sfdc/v1/accounts/123/split-billings'+'?accountMDMID='+ accId +'&lossDate='+'2024-01-01')
        {
            string jsonString= '{"data": ['+
            ' {'+
             '  "policyNumber": "213131233",'+
              ' "glassExcessAmount": 120.0,'+
               '"glassLimitAmount": 120.0,'+
               '"repairExcessAmount": 25.0,'+
              ' "repairLimitAmount": 120.0,'+
               '"windscreenExcessAmount": 120.0,'+
               '"bodyglassExcessAmount": 25.0,'+
               '"heatedRearExcessAmount": 25.0,'+
               '"adasExcessAmount": 120.0,'+
               '"insuranceSiteAccountID": "TBD",'+
               '"corporateLegalEntityID": "012606988176",'+
               '"corporateCountryGroupingID": "TBD",'+
               '"vatPayingParty": "Account",'+
               '"excessPayingParty": "Account"   }    ]}';

            String contentType = 'application/x-www-form-urlencoded';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', contentType);
            res.setBody(jsonString);
            res.setStatusCode(200);
            return res;  
        }
        else{
        // Create a mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"status": "success", "message": "Mock response"}');
        return res;
        }
    }
}