@SuppressWarnings('PMD.EmptyStatementBlock, PMD.ExcessiveParameterList')
public without sharing class BLN_InvoiceServiceHelper {
	private static Map<String, String> partyCodes = new Map<String, String>{
		'Insurer' => '01',
		'Motorist' => '04',
		'Corporate' => '03'
	};
	
	private static final String INSURER = 'Insurer';
	private static final String MOTORIST = 'Motorist';
	private static final String CORPORATE = 'Corporate';
	private static final String ACCOUNT = 'Account';
	private static final String SECONDARY = 'Secondary';
	private static final String MOTORIST_EXCESS = 'MotoristExcess';
	private static final String MOTORIST_PAYMENT = 'MotoristPayment';
	private static final String PAID_BY_CORPORATE = 'PaidByCorporate';
	private static final String MOTORIST_LIMIT = 'MotoristLimit';
	private static final String MOTORIST_LIMIT_PAYMENT = 'MotoristLimitPayment';
	private static final String NO_EXCESS = 'NoExcess';
	
	private static final Map<String, String> SETTINGS = new Map<String, String>();
	private static final Map<String, String> SETTINGS_LABEL = new Map<String, String>();
	private static final List<BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper> GENERATED_INVOICES
		= new List<BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper>();
	
	private static Decimal insurerSum = 0;
	
	public static List<BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper> createLines(BLN_InvoiceServiceWrapper.MotoristSalesOpportunityRequestWrapper invoiceData) {
		for (BLN_InvoiceServiceSetting__mdt setting : BLN_InvoiceServiceSetting__mdt.getAll().values()) {
			SETTINGS.put(setting.QualifiedApiName, setting.Value__c);
			SETTINGS_LABEL.put(setting.Value__c,setting.Label);
		}
		
		for (BLN_InvoiceServiceWrapper.SalesInvoiceRequestWrapper salesInvoice : invoiceData.salesInvoice) {
			createInsurerInvoice(salesInvoice);
			createMotoristInvoice(salesInvoice);
			createCorporateInvoice(salesInvoice);
		}
		
		return GENERATED_INVOICES;
	}
	
	private static void createInsurerInvoice(BLN_InvoiceServiceWrapper.SalesInvoiceRequestWrapper parentInvoice) {
		BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper generatedInvoice = createInvoice(partyCodes.get(SETTINGS.get(INSURER)), parentInvoice);
		BLN_InvoiceServiceWrapper.TaxCodeWrapper taxCode;
		String quantityInvoiced;
		BLN_InvoiceServiceWrapper.SalesTransactionTypeWrapper paymentType; 
		for (BLN_InvoiceServiceWrapper.SalesInvoiceLineRequestWrapper salesInvoiceLine : parentInvoice.salesInvoiceLine) {
			generatedInvoice.salesInvoiceLine.addAll(createLine(salesInvoiceLine, SETTINGS.get(INSURER), generatedInvoice.salesInvoiceId));
			taxCode = salesInvoiceLine.taxCode;
			quantityInvoiced = salesInvoiceLine.quantityInvoiced;
			paymentType = salesinvoiceline.salesTransactionType;
		}
		

		if (String.isNotBlank(parentInvoice.appliedExcessType) && parentInvoice.appliedExcessType != SETTINGS.get(NO_EXCESS)) {
			generatedInvoice.salesInvoiceLine.addAll(createExcessLines(parentInvoice, generatedInvoice.salesInvoiceTransactionNumber,
				parentInvoice.excessPayingParty != SETTINGS.get(INSURER), taxCode, quantityInvoiced, paymentType));
		}
		if (parentInvoice.insurerLimit < insurerSum) {
			String productId = SETTINGS.get(MOTORIST_LIMIT_PAYMENT);			
			generatedInvoice.salesInvoiceLine.add(new BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper(productId, 
				parentInvoice.insurerLimit - insurerSum, generatedInvoice.salesInvoiceTransactionNumber, 
				parentInvoice.salesInvoiceId + '_MLP', taxCode, quantityInvoiced, paymentType, SETTINGS_LABEL.get(productId)));
		}
		
		if (!generatedInvoice.salesInvoiceLine.isEmpty()) {
			GENERATED_INVOICES.add(generatedInvoice);
		}
	}
	
	private static void createMotoristInvoice(BLN_InvoiceServiceWrapper.SalesInvoiceRequestWrapper parentInvoice) {
		BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper generatedInvoice = createInvoice(partyCodes.get(SETTINGS.get(MOTORIST)), parentInvoice);
		BLN_InvoiceServiceWrapper.TaxCodeWrapper taxCode;
		String quantityInvoiced;
		BLN_InvoiceServiceWrapper.SalesTransactionTypeWrapper paymentType; 
		for (BLN_InvoiceServiceWrapper.SalesInvoiceLineRequestWrapper salesInvoiceLine : parentInvoice.salesInvoiceLine) {
			generatedInvoice.salesInvoiceLine.addAll(createLine(salesInvoiceLine, SETTINGS.get(MOTORIST), generatedInvoice.salesInvoiceId));
			taxCode = salesInvoiceLine.taxCode;
			quantityInvoiced = salesInvoiceLine.quantityInvoiced;
			paymentType = salesinvoiceline.salesTransactionType;
		}
		
		if (String.isNotBlank(parentInvoice.appliedExcessType) && parentInvoice.appliedExcessType != SETTINGS.get(NO_EXCESS)
			&& (parentInvoice.excessPayingParty == SETTINGS.get(MOTORIST) || parentInvoice.excessPayingParty == null)) {
			generatedInvoice.salesInvoiceLine.addAll(createExcessLines(parentInvoice, generatedInvoice.salesInvoiceTransactionNumber, 
			false, taxCode, quantityInvoiced, paymentType));
		}
		
		if (parentInvoice.insurerLimit < insurerSum
			&& (parentInvoice.limitPayingParty == SETTINGS.get(MOTORIST) || parentInvoice.limitPayingParty == null)) {
			String productId = SETTINGS.get(MOTORIST_LIMIT);
			generatedInvoice.salesInvoiceLine.add(new BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper(productId, 
				insurerSum - parentInvoice.insurerLimit, generatedInvoice.salesInvoiceTransactionNumber, 
				parentInvoice.salesInvoiceId + '_ML', taxCode, quantityInvoiced, paymentType, SETTINGS_LABEL.get(productId)));
		}
		
		if (!generatedInvoice.salesInvoiceLine.isEmpty()) {
			GENERATED_INVOICES.add(generatedInvoice);
		}
	}
	
	private static void createCorporateInvoice(BLN_InvoiceServiceWrapper.SalesInvoiceRequestWrapper parentInvoice) {
		BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper generatedInvoice = createInvoice(partyCodes.get(SETTINGS.get(CORPORATE)), parentInvoice);
		//partyCodes.put(CORPORATE, code);
		BLN_InvoiceServiceWrapper.TaxCodeWrapper taxCode;
		String quantityInvoiced;
		BLN_InvoiceServiceWrapper.SalesTransactionTypeWrapper paymentType; 
		for (BLN_InvoiceServiceWrapper.SalesInvoiceLineRequestWrapper salesInvoiceLine : parentInvoice.salesInvoiceLine) {
			generatedInvoice.salesInvoiceLine.addAll(createLine(salesInvoiceLine, SETTINGS.get(CORPORATE), generatedInvoice.salesInvoiceId));
			taxCode = salesInvoiceLine.taxCode;
			quantityInvoiced = salesInvoiceLine.quantityInvoiced;
			paymentType = salesinvoiceline.salesTransactionType;
		}
		if (String.isNotBlank(parentInvoice.appliedExcessType) && parentInvoice.appliedExcessType != SETTINGS.get(NO_EXCESS)
			&& (parentInvoice.excessPayingParty == SETTINGS.get(CORPORATE)
			|| parentInvoice.excessPayingParty == SETTINGS.get(ACCOUNT)
			|| parentInvoice.excessPayingParty == SETTINGS.get(SECONDARY))) {
			generatedInvoice.salesInvoiceLine.addAll(createExcessLines(parentInvoice, generatedInvoice.salesInvoiceTransactionNumber, false, taxCode, quantityInvoiced, paymentType));
		}
		if (parentInvoice.insurerLimit < insurerSum && (
			parentInvoice.limitPayingParty == SETTINGS.get(CORPORATE)
			|| parentInvoice.limitPayingParty == SETTINGS.get(ACCOUNT)
			|| parentInvoice.limitPayingParty == SETTINGS.get(SECONDARY))) {
			String productId = SETTINGS.get(MOTORIST_LIMIT);
			generatedInvoice.salesInvoiceLine.add(new BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper(productId, 
				insurerSum - parentInvoice.insurerLimit, generatedInvoice.salesInvoiceTransactionNumber, 
				parentInvoice.salesInvoiceId + '_ML', taxCode, quantityInvoiced, paymentType, SETTINGS_LABEL.get(productId)));
		}
		
		if (!generatedInvoice.salesInvoiceLine.isEmpty()) {
			GENERATED_INVOICES.add(generatedInvoice);
		}
	}
	
	private static List<BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper> createLine(BLN_InvoiceServiceWrapper.SalesInvoiceLineRequestWrapper salesInvoiceLine, String party, String parentInvoiceSalesId) {
		List<BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper> generatedInvoiceLines = new List<BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper>();
		if (salesInvoiceLine.payableBy == party && salesInvoiceLine.vATPayableBy == party) {
			generatedInvoiceLines.add(createInvoiceLine(partyCodes.get(party), salesInvoiceLine, false, false, '', parentInvoiceSalesId));
		} else if (salesInvoiceLine.payableBy == party) {
			generatedInvoiceLines.add(createInvoiceLine(partyCodes.get(party), salesInvoiceLine, true, false, 'true', parentInvoiceSalesId));
		} else if (salesInvoiceLine.vATPayableBy == party) {
			generatedInvoiceLines.add(createInvoiceLine(partyCodes.get(party), salesInvoiceLine, false, false, '', parentInvoiceSalesId));
			generatedInvoiceLines.add(createInvoiceLine(partyCodes.get(party), salesInvoiceLine, true, true, 'true', parentInvoiceSalesId));
		}
		
		return generatedInvoiceLines;
	}
	
	private static BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper createInvoice(String partyCode, BLN_InvoiceServiceWrapper.SalesInvoiceWrapper parentInvoice) {
		BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper invoice = parentInvoice.cloneSpecial();
		if (String.isNotEmpty(partyCode)) {
			invoice.salesInvoiceTransactionNumber = parentInvoice.salesInvoiceTransactionNumber.split('/')[0] + '/' + partyCode;
		}
		
		return invoice;
	}
	
	private static BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper createInvoiceLine(String partyCode,
		BLN_InvoiceServiceWrapper.SalesInvoiceLineWrapper parentInvoiceLine, Boolean doCalculate, Boolean negativeLiability,
		String liabilityTransferFlag, String parentInvoiceSalesId) {
		BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper invoiceLine;
		invoiceLine = new BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper();
		BLN_InvoiceServiceWrapper.ProductDescriptionLanguageWrapper productDescription = new BLN_InvoiceServiceWrapper.ProductDescriptionLanguageWrapper();

		if (negativeLiability) {
			invoiceLine = new BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper();
			invoiceLine.unitSellingPrice = parentInvoiceLine.unitSellingPrice * (-1);
			invoiceLine.productBelronId = partyCode == partyCodes.get(SETTINGS.get(INSURER)) ? SETTINGS.get(MOTORIST_PAYMENT) : SETTINGS.get(PAID_BY_CORPORATE);
			invoiceLine.taxCode = parentInvoiceLine.taxCode;
			invoiceLine.quantityInvoiced = parentInvoiceLine.quantityInvoiced;
			invoiceLine.salesTransactionType = parentInvoiceLine.salesTransactionType;
			invoiceLine.salesLineAmount = invoiceLine.unitSellingPrice * Integer.valueof(invoiceLine.quantityInvoiced);
			invoiceLine.salesInvoiceLineId = partyCode == partyCodes.get(SETTINGS.get(INSURER)) ? parentInvoiceSalesId + '_MP' : parentInvoiceSalesId + '_PBC';
			productDescription.productTechnicalDescription = SETTINGS_LABEL.get(invoiceLine.productBelronId);
			invoiceLine.jobProduct.product.productDescriptionLanguage.add(productDescription);
		} else {
			invoiceLine = parentInvoiceLine.cloneSpecial();
		}
		if (String.isNotEmpty(partyCode)) {
			invoiceLine.salesInvoiceLineTransactionNumber = parentInvoiceLine.salesInvoiceLineTransactionNumber.split('/')[0] + '/' + partyCode;
		}
		if (doCalculate) {
			invoiceLine.taxableAmount = 0;
		}
		if (partyCode == partyCodes.get(SETTINGS.get(INSURER))) {
			insurerSum += invoiceLine.unitSellingPrice;
		}
		invoiceLine.liabilityTransferFlag = liabilityTransferFlag;
		return invoiceLine;
	}
	
	private static List<BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper> createExcessLines(BLN_InvoiceServiceWrapper.SalesInvoiceRequestWrapper parentInvoice,
		String transactionNumber, Boolean negativeLiability, BLN_InvoiceServiceWrapper.TaxCodeWrapper taxCode, String quantityInvoiced, BLN_InvoiceServiceWrapper.SalesTransactionTypeWrapper paymentType ) {
		List<BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper> excessLines = new List<BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper>();
		String productId = negativeLiability ? SETTINGS.get(MOTORIST_PAYMENT) : SETTINGS.get(MOTORIST_EXCESS);
		String salesInvoiceLineId = negativeLiability ? parentInvoice.salesInvoiceId + '_MP' : parentInvoice.salesInvoiceId + '_ME';
		//BLN_InvoiceServiceWrapper.SalesInvoiceLineRequestWrapper salesInvoiceLine = parentInvoice.salesInvoiceLine;
		
		for (String excessType : parentInvoice.appliedExcessType.split(',')) {
			Decimal excessValue = parentInvoice.getExcessValue(excessType, negativeLiability);
			if (excessValue != 0) {
				excessLines.add(new BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper(productId, excessValue, transactionNumber, salesInvoiceLineId, taxCode, quantityInvoiced, paymentType, SETTINGS_LABEL.get(productId)));
				if (transactionNumber.endsWith(partyCodes.get(SETTINGS.get(INSURER)))) {
				insurerSum += excessValue;
			}
		}
		}
		return excessLines;
	}
}