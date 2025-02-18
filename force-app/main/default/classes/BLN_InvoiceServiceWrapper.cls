@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.EmptyStatementBlock, PMD.TooManyFields, PMD.ExcessiveParameterList')
global class BLN_InvoiceServiceWrapper {
	
	global class InvoiceServiceRequestWrapper {
		global MotoristSalesOpportunityRequestWrapper motoristSalesOpportunity;
		
		global InvoiceServiceRequestWrapper() {
			motoristSalesOpportunity = new MotoristSalesOpportunityRequestWrapper();
		}
		
		global InvoiceServiceRequestWrapper(MotoristSalesOpportunityRequestWrapper oppWrapper) {
			motoristSalesOpportunity = oppWrapper;
		}
	}
	
	global class InvoiceServiceResponseWrapper {
		global MotoristSalesOpportunityResponseWrapper motoristSalesOpportunity;
		
		global InvoiceServiceResponseWrapper() {
			motoristSalesOpportunity = new MotoristSalesOpportunityResponseWrapper();
		}
		
		global InvoiceServiceResponseWrapper(MotoristSalesOpportunityResponseWrapper oppWrapper) {
			motoristSalesOpportunity = oppWrapper;
		}
	}
	
	global virtual class MotoristSalesOpportunityWrapper {
		public String caseId;
		public Boolean reapplyReceiptInd;
		public LocationWrapper location;
		
		public MotoristSalesOpportunityWrapper() {
			location = new LocationWrapper();
		}

		public BLN_InvoiceServiceWrapper.MotoristSalesOpportunityResponseWrapper cloneSpecial() {
			BLN_InvoiceServiceWrapper.MotoristSalesOpportunityResponseWrapper  oppWrapper = new BLN_InvoiceServiceWrapper.MotoristSalesOpportunityResponseWrapper();
			oppWrapper.caseId = this.caseId;
			oppWrapper.reapplyReceiptInd = this.reapplyReceiptInd;
			oppWrapper.location.locationName = this.location.locationName;

			return oppWrapper;
		}
	}
	
	global class MotoristSalesOpportunityRequestWrapper extends MotoristSalesOpportunityWrapper {
		public List<SalesInvoiceRequestWrapper> salesInvoice;
		
		public MotoristSalesOpportunityRequestWrapper() {
			salesInvoice = new List<SalesInvoiceRequestWrapper>();
		}
	}
	
	global class MotoristSalesOpportunityResponseWrapper extends MotoristSalesOpportunityWrapper {
		public List<SalesInvoiceResponseWrapper> salesInvoice;
		
		public MotoristSalesOpportunityResponseWrapper() {
			salesInvoice = new List<SalesInvoiceResponseWrapper>();
		}
	}
	
	global virtual class SalesInvoiceWrapper {
		public String salesInvoiceTransactionNumber;
		public String initialSalesTransactionId;
		public String relatedSalesInvoiceId;
		public String revisionNumber;
		public String salesInvoiceId;
		public String billToPartyId;
		public String shipToPartyId;
		public String salesInvoiceDate;
		public Boolean creditMemoFlag;
		public Boolean printingOptionFlag;
		public String createdDate;
		public String totalMotoristToPay;
		public PartyWrapper party;
		public CreditRebillReasonTypeWrapper creditRebillReasonType;
		public DebtorReasonTypeWrapper debtorReasonType;
		public DeliveryMethodTypeWrapper deliveryMethodType;
		public IsoCurrencyWrapper isoCurrency;
		public InternalOrganisationWrapper internalOrganisation;
		
		
		public SalesInvoiceWrapper() {
			party = new PartyWrapper();
			creditRebillReasonType = new CreditRebillReasonTypeWrapper();
			debtorReasonType = new DebtorReasonTypeWrapper();
			deliveryMethodType = new DeliveryMethodTypeWrapper();
			isoCurrency = new IsoCurrencyWrapper();
			internalOrganisation = new InternalOrganisationWrapper();
		}
		
		public BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper cloneSpecial() {
			BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper clonedInvoice = new BLN_InvoiceServiceWrapper.SalesInvoiceResponseWrapper();
			clonedInvoice.salesInvoiceTransactionNumber = this.salesInvoiceTransactionNumber;
			clonedInvoice.initialSalesTransactionId = this.initialSalesTransactionId;
			clonedInvoice.relatedSalesInvoiceId = this.relatedSalesInvoiceId;
			clonedInvoice.revisionNumber = this.revisionNumber;
			clonedInvoice.salesInvoiceId = this.salesInvoiceId;
			clonedInvoice.billToPartyId = this.billToPartyId;
			clonedInvoice.shipToPartyId = this.shipToPartyId;
			clonedInvoice.salesInvoiceDate = this.salesInvoiceDate;
			clonedInvoice.creditMemoFlag = this.creditMemoFlag;
			clonedInvoice.printingOptionFlag = this.printingOptionFlag;
			clonedInvoice.createdDate = this.createdDate;
			clonedInvoice.totalMotoristToPay = this.totalMotoristToPay;
			clonedInvoice.party.partyAddress = this.party.partyAddress.clone();
			clonedInvoice.creditRebillReasonType.creditRebillReasonTypeCode = this.creditRebillReasonType.creditRebillReasonTypeCode;
			clonedInvoice.debtorReasonType.debtReasonTypeCode = this.debtorReasonType.debtReasonTypeCode;
			clonedInvoice.deliveryMethodType.deliveryMethodTypeName = this.deliveryMethodType.deliveryMethodTypeName;
			clonedInvoice.isoCurrency.isoCurrencyCode = this.isoCurrency.isoCurrencyCode;
			clonedInvoice.internalOrganisation.organisationCode = this.internalOrganisation.organisationCode;
			clonedInvoice.internalOrganisation.organisationName = this.internalOrganisation.organisationName;
			
			return clonedInvoice;
		}
	}
	
	global class SalesInvoiceRequestWrapper extends SalesInvoiceWrapper {
		public Decimal insurerLimit;
		public String appliedExcessType;
		public Decimal repairExcess;
		public Decimal bodyGlassExcess;
		public Decimal replacementExcess;
		public Decimal heatedRearExcess;
		public Decimal rearWindscreenExcess;
		public Decimal aDASExcess;
		public Decimal vehicleDamageExcess;
		public Decimal windscreenExcess;
		public String excessPayingParty;
		public String limitPayingParty;
		public String vATRegisteredFlag;
		public List<SalesInvoiceLineRequestWrapper> salesInvoiceLine;
		
		public SalesInvoiceRequestWrapper() {
			salesInvoiceLine = new List<SalesInvoiceLineRequestWrapper>();
		}
		
		public Decimal getExcessValue(String excessType, Boolean negativeLiability) {
			Decimal excessValue = 0;
			if (excessType == 'Repair' && this.repairExcess != null) {
				excessValue = this.repairExcess;
			} else if (excessType == 'Replacement' && this.replacementExcess != null) {
				excessValue = this.replacementExcess;
			} else if (excessType == 'ADAS' && this.aDASExcess != null) {
				excessValue = this.aDASExcess;
			}
			
			if (negativeLiability) {
				return excessValue * (-1);
			}
			return excessValue;
		}
	}
	
	global class SalesInvoiceResponseWrapper extends SalesInvoiceWrapper {
		public List<SalesInvoiceLineResponseWrapper> salesInvoiceLine;
		
		public SalesInvoiceResponseWrapper() {
			salesInvoiceLine = new List<SalesInvoiceLineResponseWrapper>();
		}
	}
	
	global class PartyWrapper {
		public List<PartyAddressWrapper> partyAddress;
		
		public PartyWrapper() {
			partyAddress = new List<PartyAddressWrapper>();
		}
	}
	
	global class PartyAddressWrapper {
		public String partyId;
		public String addressId;
	}
	
	global class CreditRebillReasonTypeWrapper {
		public String creditRebillReasonTypeCode;
	}
	
	global class DebtorReasonTypeWrapper {
		public String debtReasonTypeCode;
	}
	
	global class DeliveryMethodTypeWrapper {
		public String deliveryMethodTypeName;
	}
	
	global class IsoCurrencyWrapper {
		public String isoCurrencyCode;
	}
	
	global class InternalOrganisationWrapper {
		public String organisationCode;
		public String organisationName;
	}
	
	global virtual class SalesInvoiceLineWrapper {
		public String salesInvoiceLineTransactionNumber;
		public String initialSalesTransactionId;
		public String salesInvoiceLineId;
		public String relatedSalesInvoiceLineId;
		public Decimal salesLineAmount;
		public String quantityInvoiced;
		public Decimal unitSellingPrice;
		public String productBelronId;
		public Decimal taxableAmount;
		public JobProductWrapper jobProduct;
		public TaxCodeWrapper taxCode;
		public SalesTransactionTypeWrapper salesTransactionType;
		
		public SalesInvoiceLineWrapper() {
			jobProduct = new JobProductWrapper();
			taxCode = new TaxCodeWrapper();
			salesTransactionType = new SalesTransactionTypeWrapper();
		}
		
		public BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper cloneSpecial() {
			BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper clonedLine = new BLN_InvoiceServiceWrapper.SalesInvoiceLineResponseWrapper();
			clonedLine.salesInvoiceLineTransactionNumber = this.salesInvoiceLineTransactionNumber;
			clonedLine.initialSalesTransactionId = this.initialSalesTransactionId;
			clonedLine.salesInvoiceLineId = this.salesInvoiceLineId;
			clonedLine.relatedSalesInvoiceLineId = this.relatedSalesInvoiceLineId;
			clonedLine.salesLineAmount = this.salesLineAmount;
			clonedLine.quantityInvoiced = this.quantityInvoiced;
			clonedLine.unitSellingPrice = this.unitSellingPrice;
			clonedLine.productBelronId = this.productBelronId;
			clonedLine.taxableAmount = this.taxableAmount;
			clonedLine.jobProduct.productBelronId = this.jobProduct.productBelronId;
			clonedLine.jobProduct.product.productDescriptionLanguage = this.jobProduct.product.productDescriptionLanguage.clone();
			clonedLine.taxCode.taxCode = this.taxCode.taxCode;
			clonedLine.salesTransactionType.salesTransactionTypeId = this.salesTransactionType.salesTransactionTypeId;
			
			return clonedLine;
		}
	}
	
	global class SalesInvoiceLineRequestWrapper extends SalesInvoiceLineWrapper {
		public String vATPayableBy;
		public String payableBy;
	}
	
	global class SalesInvoiceLineResponseWrapper extends SalesInvoiceLineWrapper {
		public String liabilityTransferFlag;
		
		public SalesInvoiceLineResponseWrapper() {}
		public SalesInvoiceLineResponseWrapper(String productBelronId, Decimal unitSellingPrice, String salesInvoiceLineTransactionNumber) {
			this.productBelronId = productBelronId;
			this.unitSellingPrice = unitSellingPrice;
			this.taxableAmount = 0;
			this.salesInvoiceLineTransactionNumber = salesInvoiceLineTransactionNumber;
			this.liabilityTransferFlag = 'true';
		}

		public SalesInvoiceLineResponseWrapper(String productBelronId, Decimal unitSellingPrice, String salesInvoiceLineTransactionNumber, 
		String salesInvoiceLineId, BLN_InvoiceServiceWrapper.TaxCodeWrapper taxCode, String quantityInvoiced, 
		BLN_InvoiceServiceWrapper.SalesTransactionTypeWrapper paymentType, String productTechnicalDescription) {
			this.productBelronId = productBelronId;
			this.unitSellingPrice = unitSellingPrice;
			this.taxableAmount = 0;
			this.salesLineAmount = Integer.valueof(quantityInvoiced) * unitSellingPrice;
			this.salesInvoiceLineTransactionNumber = salesInvoiceLineTransactionNumber;
			this.taxCode = taxCode;
			this.salesTransactionType = paymentType;
			this.quantityInvoiced = quantityInvoiced;
			this.salesInvoiceLineId = salesInvoiceLineId;
			this.liabilityTransferFlag = 'true';
			ProductDescriptionLanguageWrapper productDescription = new ProductDescriptionLanguageWrapper();
			productDescription.productTechnicalDescription = productTechnicalDescription;
			this.jobProduct.product.productDescriptionLanguage.add(productDescription);
		}
	}
	
	global class JobProductWrapper {
		public String productBelronId;
		public ProductWrapper product;
		
		public JobProductWrapper() {
			product = new ProductWrapper();
		}
	}
	
	global class ProductWrapper {
		public List<ProductDescriptionLanguageWrapper> productDescriptionLanguage;
		
		public ProductWrapper() {
			productDescriptionLanguage = new List<ProductDescriptionLanguageWrapper>();
		}
	}
	
	global class ProductDescriptionLanguageWrapper {
		public String productTechnicalDescription;
	}
	
	global class TaxCodeWrapper {
		public String taxCode;
	}
	
	global class SalesTransactionTypeWrapper {
		public Integer salesTransactionTypeId;
	}
	
	global class LocationWrapper {
		public String locationName;
	}
	
	global class ErrorOperationResult {
		public String message;
		public Boolean isSuccess;
		
		public ErrorOperationResult(String message) {
			this.isSuccess = false;
			this.message = message;
		}
	}
	
	global static BLN_InvoiceServiceWrapper.InvoiceServiceRequestWrapper parse(String jsonString) {
		BLN_InvoiceServiceWrapper.InvoiceServiceRequestWrapper payloadWrapper;
		try {
			payloadWrapper = (BLN_InvoiceServiceWrapper.InvoiceServiceRequestWrapper) JSON.deserialize(jsonString, BLN_InvoiceServiceWrapper.InvoiceServiceRequestWrapper.class);
		} catch (Exception e) {
			throw new BLN_InvoiceWebService.InvoiceServiceException(Label.BLN_InvoiceServiceParseError);
		}
		
		return payloadWrapper;
	}
}