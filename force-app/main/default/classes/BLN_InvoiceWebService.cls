@RestResource(UrlMapping='/InvoiceService/*')
global without sharing class BLN_InvoiceWebService {
	public class InvoiceServiceException extends Exception {}
	
	@HttpPost
	global static void calculateInvoicesFromMule() {
		Datetime reqTime = System.now();
		RestRequest request = RestContext.request;
		BLN_InvoiceServiceWrapper.InvoiceServiceRequestWrapper invoiceData;
		RestResponse restResponse = RestContext.response;
		try {
			invoiceData = BLN_InvoiceServiceWrapper.parse(request.requestBody.toString());
			if (invoiceData == null || invoiceData.motoristSalesOpportunity.salesInvoice.isEmpty()) {
				throw new InvoiceServiceException(Label.BLN_InvoiceServiceBlankData);
			}
			
			BLN_InvoiceServiceWrapper.MotoristSalesOpportunityResponseWrapper oppWrapper = invoiceData.motoristSalesOpportunity.cloneSpecial();
			oppWrapper.salesInvoice.addAll(BLN_InvoiceServiceHelper.createLines(invoiceData.motoristSalesOpportunity));
			BLN_InvoiceServiceWrapper.InvoiceServiceResponseWrapper invoiceDataCalculated = new BLN_InvoiceServiceWrapper.InvoiceServiceResponseWrapper(oppWrapper);
			
			restResponse.statusCode = 200;
			restResponse.responseBody = Blob.valueOf(JSON.serialize(invoiceDataCalculated));
		} catch (Exception e) {
			restResponse.responseBody = Blob.valueOf(JSON.serialize(new BLN_InvoiceServiceWrapper.ErrorOperationResult(e.getMessage())));
			restResponse.statusCode = 400;
		}
		
		BLN_IntegrationLoggerHandler.logCalloutDetailsRest(invoiceData?.motoristSalesOpportunity?.caseId, 'Salesforce', reqTime, System.now(), request, restResponse, 'POST');
	}
}