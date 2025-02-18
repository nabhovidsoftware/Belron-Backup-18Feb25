@IsTest
public with sharing class BLN_InvoiceWebServiceTest {
	@IsTest
	static void testWebServiceOneParty() {
		RestRequest request = buildMock('Insurer', 'Insurer', 'Insurer', 'Insurer', '', '', '', 2000);
		RestResponse response = new RestResponse();
		RestContext.request = request;
		RestContext.response = response;
		
		Test.startTest();
		BLN_InvoiceWebService.calculateInvoicesFromMule();
		Test.stopTest();
		
		BLN_InvoiceServiceWrapper.InvoiceServiceResponseWrapper invoiceData = parseResponse(response.responseBody.toString());
		Assert.areEqual(1, invoiceData.motoristSalesOpportunity.salesInvoice.size(), 'Only one invoice should be generated (Insurer)');
		Assert.areEqual(2, invoiceData.motoristSalesOpportunity.salesInvoice[0].salesInvoiceLine.size(), 'Two fully copied lines should be generated');
		Assert.areEqual('123456/01', invoiceData.motoristSalesOpportunity.salesInvoice[0].salesInvoiceTransactionNumber, 'Transaction code should be pointing to Insurer (01)');
	}
	
	@IsTest
	static void testWebService2Party() {
		RestRequest request = buildMock('Motorist', 'Insurer', 'Insurer', 'Motorist', '', '', '', 2000);
		RestResponse response = new RestResponse();
		RestContext.request = request;
		RestContext.response = response;
		
		Test.startTest();
		BLN_InvoiceWebService.calculateInvoicesFromMule();
		Test.stopTest();
		
		BLN_InvoiceServiceWrapper.InvoiceServiceResponseWrapper invoiceData = parseResponse(response.responseBody.toString());
		Assert.areEqual(2, invoiceData.motoristSalesOpportunity.salesInvoice.size(), '2 Invoices should be generated (Insurer, Motorist');
		for (BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper salesInvoice : invoiceData.motoristSalesOpportunity.salesInvoice) {
			Assert.areEqual(3, salesInvoice.salesInvoiceLine.size(), '3 Invoice Lines should be generated for each party');
		}
	}
	
	@IsTest
	static void testWebServiceMotoristExcess() {
		RestRequest request = buildMock('Motorist', 'Insurer', 'Insurer', 'Motorist', 'Repair,ADAS', 'Motorist', '', 2000);
		RestResponse response = new RestResponse();
		RestContext.request = request;
		RestContext.response = response;
		
		Test.startTest();
		BLN_InvoiceWebService.calculateInvoicesFromMule();
		Test.stopTest();
		BLN_InvoiceServiceWrapper.InvoiceServiceResponseWrapper invoiceData = parseResponse(response.responseBody.toString());
		Assert.areEqual(2, invoiceData.motoristSalesOpportunity.salesInvoice.size(), '2 Invoices should be generated (Insurer, Motorist)');
		for (BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper salesInvoice : invoiceData.motoristSalesOpportunity.salesInvoice) {
			Assert.areEqual(5, salesInvoice.salesInvoiceLine.size(), '5 Invoice Lines should be generated for each party');
		}
	}
	
	@IsTest
	static void testWebServiceInsurerExcess() {
		RestRequest request = buildMock('Motorist', 'Insurer', 'Insurer', 'Motorist', 'Repair,ADAS', 'Insurer', '', 2000);
		RestResponse response = new RestResponse();
		RestContext.request = request;
		RestContext.response = response;
		
		Test.startTest();
		BLN_InvoiceWebService.calculateInvoicesFromMule();
		Test.stopTest();
		
		BLN_InvoiceServiceWrapper.InvoiceServiceResponseWrapper invoiceData = parseResponse(response.responseBody.toString());
		Assert.areEqual(2, invoiceData.motoristSalesOpportunity.salesInvoice.size(), '2 Invoices should be generated (Insurer, Motorist)');
		for (BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper salesInvoice : invoiceData.motoristSalesOpportunity.salesInvoice) {
			if (salesInvoice.salesInvoiceTransactionNumber == '123456/01') {
				Assert.areEqual(5, salesInvoice.salesInvoiceLine.size(), '5 lines should be generated for Insurer');
			} else {
				Assert.areEqual(3, salesInvoice.salesInvoiceLine.size(), '3 lines should be generated for Motorist');
			}
		}
	}
	
	@IsTest
	static void testWebServiceWrongPayload() {
		RestRequest request = new RestRequest();
		request.addHeader('httpMethod', 'POST');
		request.requestURI = '/services/apexrest/InvoiceService/';
		RestResponse response = new RestResponse();
		RestContext.request = request;
		RestContext.response = response;
		
		Test.startTest();
		BLN_InvoiceWebService.calculateInvoicesFromMule();
		Test.stopTest();
		
		BLN_InvoiceServiceWrapper.ErrorOperationResult errorResponse = parseErrorResponse(response.responseBody.toString());
		Assert.isFalse(errorResponse.isSuccess, 'Should fail because the payload is incorrect');
	}
	
	private static RestRequest buildMock(String vatLiable1, String liable1, String vatLiable2, String liable2, String appliedExcessType,
		String excessLiable, String limitLiable, Decimal policyLimit) {
		RestRequest request = new RestRequest();
		request.addHeader('httpMethod', 'POST');
		request.requestURI = '/services/apexrest/InvoiceService/';
		request.requestBody = Blob.valueOf(getPayload(vatLiable1, liable1, vatLiable2, liable2, appliedExcessType,
			excessLiable, limitLiable, policyLimit));
		
		return request;
	}
	
	private static String getPayload(String vatLiable1, String liable1, String vatLiable2, String liable2, String appliedExcessType,
		String excessLiable, String limitLiable, Decimal policyLimit) {
		BLN_InvoiceServiceWrapper.SalesInvoiceLineRequestWrapper lineWrapper1 = new BLN_InvoiceServiceWrapper.SalesInvoiceLineRequestWrapper();
		lineWrapper1.salesInvoiceLineTransactionNumber = '123456/01';
		lineWrapper1.initialSalesTransactionId = 'initialTransactionId';
		lineWrapper1.salesInvoiceLineId = 'lineId';
		lineWrapper1.relatedSalesInvoiceLineId = 'relatedLineId';
		lineWrapper1.salesLineAmount = 1000;
		lineWrapper1.quantityInvoiced = '2';
		lineWrapper1.unitSellingPrice = 700;
		lineWrapper1.productBelronId = 'productBelronId';
		lineWrapper1.taxableAmount = 100;
		lineWrapper1.vATPayableBy = vatLiable1;
		lineWrapper1.payableBy = liable1;
		lineWrapper1.jobProduct.productBelronId = 'jobProductBelronId';
		lineWrapper1.jobProduct.product.productDescriptionLanguage.add(new BLN_InvoiceServiceWrapper.ProductDescriptionLanguageWrapper());
		lineWrapper1.jobProduct.product.productDescriptionLanguage[0].productTechnicalDescription = 'Technical Description';
		lineWrapper1.taxCode.taxCode = 'taxCode';
		lineWrapper1.salesTransactionType.salesTransactionTypeId = 1;
		BLN_InvoiceServiceWrapper.SalesInvoiceLineRequestWrapper lineWrapper2 = new BLN_InvoiceServiceWrapper.SalesInvoiceLineRequestWrapper();
		lineWrapper2.salesInvoiceLineTransactionNumber = '123456/01';
		lineWrapper2.initialSalesTransactionId = 'initialTransactionId';
		lineWrapper2.salesInvoiceLineId = 'lineId';
		lineWrapper2.relatedSalesInvoiceLineId = 'relatedLineId';
		lineWrapper2.salesLineAmount = 1000;
		lineWrapper2.quantityInvoiced = '2';
		lineWrapper2.unitSellingPrice = 500;
		lineWrapper2.productBelronId = 'productBelronId';
		lineWrapper2.taxableAmount = 200;
		lineWrapper2.vATPayableBy = vatLiable2;
		lineWrapper2.payableBy = liable2;
		lineWrapper2.jobProduct.productBelronId = 'jobProductBelronId';
		lineWrapper2.jobProduct.product.productDescriptionLanguage.add(new BLN_InvoiceServiceWrapper.ProductDescriptionLanguageWrapper());
		lineWrapper2.jobProduct.product.productDescriptionLanguage[0].productTechnicalDescription = 'Technical Description';
		lineWrapper2.taxCode.taxCode = 'taxCode';
		lineWrapper2.salesTransactionType.salesTransactionTypeId = 1;
		
		BLN_InvoiceServiceWrapper.SalesInvoiceRequestWrapper invoiceWrapper = new BLN_InvoiceServiceWrapper.SalesInvoiceRequestWrapper();
		invoiceWrapper.salesInvoiceTransactionNumber = '123456/01';
		invoiceWrapper.initialSalesTransactionId = 'initialSalesTransactionId';
		invoiceWrapper.relatedSalesInvoiceId = 'relatedSalesInvoiceId';
		invoiceWrapper.revisionNumber = '1';
		invoiceWrapper.salesInvoiceId = 'salesInvoiceId';
		invoiceWrapper.billToPartyId = 'billToPartyId';
		invoiceWrapper.shipToPartyId = 'shipToPartyId';
		invoiceWrapper.salesInvoiceDate = '2023-01-01';
		invoiceWrapper.creditMemoFlag = true;
		invoiceWrapper.printingOptionFlag = false;
		invoiceWrapper.createdDate = '2023-01-01';
		invoiceWrapper.party.partyAddress.add(new BLN_InvoiceServiceWrapper.PartyAddressWrapper());
		invoiceWrapper.party.partyAddress[0].partyId = 'partyId';
		invoiceWrapper.party.partyAddress[0].addressId = 'addressId';
		invoiceWrapper.creditRebillReasonType.creditRebillReasonTypeCode = 'creditRebillReasonTypeCode';
		invoiceWrapper.debtorReasonType.debtReasonTypeCode = 'debtReasonTypeCode';
		invoiceWrapper.deliveryMethodType.deliveryMethodTypeName = 'deliveryMethodTypeName';
		invoiceWrapper.isoCurrency.isoCurrencyCode = 'isoCurrencyCode';
		invoiceWrapper.internalOrganisation.organisationCode = 'organisationCode';
		invoiceWrapper.internalOrganisation.organisationName = 'organisationName';
		invoiceWrapper.salesInvoiceLine.add(lineWrapper1);
		invoiceWrapper.salesInvoiceLine.add(lineWrapper2);
		invoiceWrapper.insurerLimit = policyLimit;
		invoiceWrapper.appliedExcessType = appliedExcessType;
		invoiceWrapper.repairExcess = 20;
		invoiceWrapper.replacementExcess = 30;
		invoiceWrapper.bodyGlassExcess = 15;
		invoiceWrapper.heatedRearExcess = 10;
		invoiceWrapper.rearWindscreenExcess = 5;
		invoiceWrapper.aDASExcess = 25;
		invoiceWrapper.vehicleDamageExcess = 35;
		invoiceWrapper.windscreenExcess = 40;
		invoiceWrapper.excessPayingParty = excessLiable;
		invoiceWrapper.limitPayingParty = limitLiable;
		invoiceWrapper.vATRegisteredFlag = 'N';
		
		BLN_InvoiceServiceWrapper.MotoristSalesOpportunityRequestWrapper oppWrapper = new BLN_InvoiceServiceWrapper.MotoristSalesOpportunityRequestWrapper();
		oppWrapper.caseId = '0012345';
		oppWrapper.reapplyReceiptInd = true;
		oppWrapper.location.locationName = 'locationName';
		oppWrapper.salesInvoice.add(invoiceWrapper);
		
		BLN_InvoiceServiceWrapper.InvoiceServiceRequestWrapper wrapper = new BLN_InvoiceServiceWrapper.InvoiceServiceRequestWrapper();
		wrapper.motoristSalesOpportunity = oppWrapper;
		
		return JSON.serialize(wrapper);
	}
	
	private static BLN_InvoiceServiceWrapper.InvoiceServiceResponseWrapper parseResponse(String jsonString) {
		return (BLN_InvoiceServiceWrapper.InvoiceServiceResponseWrapper) JSON.deserialize(jsonString, BLN_InvoiceServiceWrapper.InvoiceServiceResponseWrapper.class);
	}
	
	private static BLN_InvoiceServiceWrapper.ErrorOperationResult parseErrorResponse(String jsonString) {
		return (BLN_InvoiceServiceWrapper.ErrorOperationResult) JSON.deserialize(jsonString, BLN_InvoiceServiceWrapper.ErrorOperationResult.class);
	}
}