public with sharing class BLN_ProductAvailabilityWrapper {
    public class BomIdWrap {
        public String bomId;
        public Integer quantity;
        public Boolean branch;
        public Boolean mobile;
        public Boolean isSelected;          
    }
    public class PartIdWrap {
        public String partId;
        public Integer quantity;
        public Boolean branch;
        public Boolean mobile;
        public Boolean isSelected;          
    }
    public class LocationWrapper {
        public String costCenterId;
        public String locationId;
        public Boolean mobileLocationIndicator;
        public String countryCode;
        public String excludeProduct;
    }
    public class QuoteLocationWrapper{
        @auraEnabled public boolean isMobileLocation;
        @auraEnabled public String locationGUID;	
        @auraEnabled public String quoteEarliestAppointmentAvailability;	
        @auraEnabled public String quoteId;	
        @auraEnabled public String quotelocation;
        @auraEnabled public Decimal quoteVAT;
        @auraEnabled public Decimal quoteTotal;
        @auraEnabled public Decimal quoteNetTotal;
        @auraEnabled public String quoteWeatherGuard;
        @auraEnabled public Boolean isCPT;
        @auraEnabled public Boolean locDisabled;
        @auraEnabled public Boolean isBranchLocationDefault;
    }
    public class InsuranceDetailsWrapper{
        public Decimal glassLimit;
        public Decimal repairExcess;
        public Decimal replacementExcess;
        public Decimal calibrationExcess;
        public Decimal sundryExcess;
        public Decimal vehicleDamageExcess;
        public Decimal bodyglassExcess;
        public Decimal windscreenExcess;
        public Decimal heatedRearExcess;
    }    
    public class DiscountBandWrapper {
        @auraEnabled
        public String locationName;
        @auraEnabled
        public Decimal discountThresholdA;
        @auraEnabled
        public Decimal discountThresholdB;
        @auraEnabled
        public Decimal discountThresholdC;
        @auraEnabled
        public String locationId;
    }
    public class DisplayDetailsWrapper {
        @auraEnabled
        public List<ProductSelectionWrapper> productDataList;
        @auraEnabled
        public List<DisplayQuoteDetailsWrapper> quoteDetailsDataList;
        @auraEnabled
        public List<DiscountBandWrapper> discountBandDetails;
        @AuraEnabled
        public List<EarliestAvailabilityDetailsWrapper> earliestAvailabilityDetails;
        @AuraEnabled
        public List<InsuranceLiabilityWrapper> liabilityDataList;
        @AuraEnabled
        public List<QuoteWrapper>  quoteDataList;
        @AuraEnabled
        public List<EarliestAvailabilityDetailsWrapper> earliestAvailabilityList;
        @AuraEnabled
        public QuoteLocationWrapper selectedLocation;
        @AuraEnabled
        public List<List<BLN_ProductAvailabilityWrapper.ProductSelectionWrapper>> prodLists;
        @AuraEnabled
        public Boolean hasCompletedAppointments;
        @auraEnabled
        public List<ProductIdentifierWrapper> productIdentifier;
        @auraEnabled
        public List<OrderItemDetails> orderItemDetails;
        @auraEnabled
        public String externalQuoteId;
        @auraEnabled
        public String existingGUId;
        @auraEnabled
        public List<ProductRequiredWrapper> productrequiredWrappList;
        @auraEnabled
        public String appointmentWrapperList;
        @auraEnabled
        public String getQuotePayload;
        @auraEnabled
        public List<AccountRuleParameterWrapper> accountRuleParameters;
        @auraEnabled
        public List<RepairProductValidater> repairProductIdentifier;
        @auraEnabled
        public Integer statusCode;
        @auraEnabled
        public String errorMessage;
    }
    public class EarliestAvailabilityDetailsWrapper{
        @AuraEnabled
        public List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails> earliestDateList;
        @AuraEnabled
        public String quoteId;
        @AuraEnabled
        public String locationId;
        @AuraEnabled
        public String mdmId;
        @AuraEnabled
        public String productCode;
        @AuraEnabled
        public Boolean isStockableProduct;
        @AuraEnabled
        public String bomId;
        @AuraEnabled
        public String bundleName;
        @AuraEnabled
        public Boolean leadingProductIndicator;
        @AuraEnabled
        public Integer lineItemId;
        @AuraEnabled
        public Boolean isSelected;
        public EarliestAvailabilityDetailsWrapper(){
            this.earliestDateList = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>();
            this.quoteId = '';
            this.locationId= '';
            this.mdmId = '';
            this.productCode = '';
            this.isStockableProduct = false;
            this.bomId = '';
            this.bundleName = '';
            this.isSelected = false;
        }
    }
    public class AvailabilityDatesWrapper {
        @AuraEnabled
        public List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails> earliestDates;
        @AuraEnabled
        public String quoteId;
        @AuraEnabled
        public String orderId;     
        public AvailabilityDatesWrapper() {
            this.earliestDates = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>();
            this.quoteId='';
            this.orderId='';
        }
    }
    public class ProductSelectionWrapper {
        @auraEnabled
        public String productCode ;
        @AuraEnabled
        public String mdmId;
        @AuraEnabled
		public String belronProductCode;
        @AuraEnabled
        public String skuCode;
        @auraEnabled
        public Double quantity;
        @auraEnabled
        public String productName;
        @AuraEnabled
        public String productDescription;
        @AuraEnabled
        public String productId;
        @AuraEnabled
        public String prodCategory;
        @AuraEnabled
        public Integer lineItemId;
        @AuraEnabled
        public Integer parentLineItemId;
        @AuraEnabled
        public Boolean partOfBundle;
        @AuraEnabled
        public String bundleHierarchy;
        @AuraEnabled
        public Double netPriceIncludingTax;
        @AuraEnabled
        public Double totalTax;
        @AuraEnabled
        public Double netPrice;
        @auraEnabled
        public String bundleName;
        @AuraEnabled
        public Boolean selectProduct;
        @AuraEnabled
        public Boolean bomMandatory;
        @AuraEnabled
        public String hierarchy;
        @AuraEnabled
        public String bomId;
        @AuraEnabled
        public Boolean leadingProductIndicator;
        @AuraEnabled
        public Boolean isBranchOnlyProduct;
        @AuraEnabled
        public Boolean isADASRecalibrationNeeded;
        @AuraEnabled
        public Boolean isBondedNonBonded;
        @AuraEnabled
        public String orderItemId;
        @AuraEnabled
        public Boolean repairPart;
		@AuraEnabled
        public Boolean isProductSelected;
        @AuraEnabled
        public Boolean hideOnUI;
		@AuraEnabled
        public Double totalIncludingTaxPayableByInsurance;
        @AuraEnabled
        public Double totalPayableByTradeIncludingTax;

        public ProductSelectionWrapper(){
            this.hierarchy = '';
            this.bomId = '';
            this.bundleHierarchy = '';
        }
    }
    public class QuoteWrapper {
        @AuraEnabled
        public String quoteId; 
        @AuraEnabled
        public String locationId;
        @AuraEnabled
        public List<ProductSelectionWrapper> productList;

        public QuoteWrapper(){
            this.quoteId = '';
            this.locationId = '';
            this.productList = new List<ProductSelectionWrapper>();
        }
    }
    public class InsuranceLiabilityWrapper {
        @AuraEnabled
        public String liabilityCategory;
        @AuraEnabled
        public Double totalPayable;
        @AuraEnabled
        public Double totalTaxPayable;
        @AuraEnabled
        public Double totalIncludingTaxPayable;
        
        public InsuranceLiabilityWrapper() {
            this.liabilityCategory = '';
            this.totalPayable = 0.00;
            this.totalTaxPayable = 0.00;
            this.totalIncludingTaxPayable = 0.00;
        }
    }
    public class LineItemIdentifier{
        public Integer lineItemId;
        public String partNumber;
        public String bomId;
        public String bundleName;
        public Integer quantity;
        public Boolean isSelected;
        public String serviceAppointment;
        public String fittingLocation;
        public Boolean isOutOfStock;
        public String stockLocation;
        
        public LineItemIdentifier(){          
            this.lineItemId = 0;
            this.partNumber = '';
            this.bomId = '';
            this.bundleName = '';
            this.quantity = 1;
            this.isSelected = false;
            this.serviceAppointment = null;
            this.fittingLocation = null;
            this.stockLocation = null;
            this.isOutOfStock = false;
        }
    }
    public class DisplayQuoteDetailsWrapper {
        @AuraEnabled
        public String quoteId;
        @AuraEnabled
        public String locationGUID;
        @auraEnabled
        public String quotelocation;
        @AuraEnabled
        public Boolean isMobileLocation;
        @AuraEnabled
        public String excludeProduct;
        @auraEnabled
        public String quoteWeatherGuard;
        @auraEnabled
        public Decimal quoteVAT;
        @auraEnabled
        public Decimal quoteTotal;
        @AuraEnabled
        public Decimal quoteNetTotal;
        @AuraEnabled
        public String quoteEarliestAppointmentAvailability;
        @AuraEnabled
        public Decimal quoteOriginalPrice;
    }
    /*  *@description:This class wrapper used to store screen name and knowledege article */
    public class DisplayLocationWrapper{
        @AuraEnabled public String screenName;
        @AuraEnabled public List<Knowledge__kav> value;
    }
    /*  *@description:This class wrapper used to store Appointment Data */
    public class AppointmentWrapper {
        @AuraEnabled public String serviceLocationName;	
        @AuraEnabled public String serviceLocationId;
        @AuraEnabled public Boolean isPrimaryLocation;
        @AuraEnabled public ServiceLocationLabel[] serviceLocationLabel;
        @AuraEnabled public EarliestAvailablity[] earliestAvailablity;
        @AuraEnabled public Appointments[] appointments;
        @AuraEnabled public String externalQuoteId;
        @AuraEnabled public String caseExternalQuoteIds;
    }
    public class ServiceLocationLabel {
        public string serviceLabel;
        public string product;
        public ProductNames[] productNames;
    }
    public class ServiceLabel {
        @AuraEnabled public String serviceLocation;	
    }
    public class Product {
        public String products;	
    }
    public class ProductNames {
        @AuraEnabled public String productName;	
        @AuraEnabled public String productDescription;
        @AuraEnabled public String productCode;	
        @AuraEnabled public String bundleName;
        @AuraEnabled public String prodCategory {get; set;}
        @AuraEnabled public String bomId {get; set;}
        @AuraEnabled public Boolean leadingProductIndicator {get; set;}	
    }
    public class EarliestAvailablity {
        @AuraEnabled public String serviceName;
        @AuraEnabled public String earliestAvailability;	
        @AuraEnabled public ProductDate[] productDate;
    }
    public class ProductDate {
        @AuraEnabled public String earliestDate;	
        @AuraEnabled public String productCode;	
    }
    public class Appointments {
        @AuraEnabled public String appointmentName;	
        @AuraEnabled public String keyIndex;	
        @AuraEnabled public String locationId;	
        @AuraEnabled public String locationName;
        @AuraEnabled public String earlierAvailabilityDateHeader;
        @AuraEnabled public String earlierAvailabilityStockLocation;	
        @AuraEnabled public String slotSelectedDate;	
        @AuraEnabled public String serviceAppointmentId;
        @AuraEnabled public String serviceAppointmentIdAccepted;
        @AuraEnabled public String slotDate;
        @AuraEnabled public String slotTime;	
        @AuraEnabled public String slotDateTimeStart;	
        @AuraEnabled public String slotDateTimeFinish;
        @AuraEnabled public ProductAvailibilities[] productAvailibilities;
        @AuraEnabled public String fittingLocationId {get; set;}
        @AuraEnabled public Datetime schedStartTime {get; set;}
        @AuraEnabled public Boolean isFirstAppointment {get; set;}
        @AuraEnabled public Boolean isMobileLocation {get; set;}
        @AuraEnabled public String isDropOff {get; set;}
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String woliId {get; set;}
        //@AuraEnabled public Boolean disableCrossButton {get; set;}
    }
    public class ProductAvailibilities {
        @AuraEnabled public Products[] products;
    }
    public class Products {
        @AuraEnabled public String productCode;	
        @AuraEnabled public boolean productEnable;
        @AuraEnabled public Integer quantity;	
        @AuraEnabled public boolean isChecked;
        @AuraEnabled public String bomId;
        @AuraEnabled public Integer lineItemId;
        @AuraEnabled public String bundleName;
        @AuraEnabled public Boolean partOfBundle;
        @AuraEnabled public Boolean isCPTDate;
        @AuraEnabled public String orderItemId;
        @AuraEnabled public String prodCategory {get; set;}
        @AuraEnabled public String stockStatus {get; set;}
        //new mappings
        @AuraEnabled public String bundleHierarchy {get; set;}
        @AuraEnabled public String hierarchy {get; set;}
        @AuraEnabled public Boolean leadingProductIndicator {get; set;}
        @AuraEnabled public Double netPrice {get; set;}
        @AuraEnabled public Double netPriceIncludingTax {get; set;}
        @AuraEnabled public String productName {get; set;}
        @AuraEnabled public String selectProduct {get; set;}
        @AuraEnabled public Integer totalTax {get; set;}
    }
    public class ConsumedWrapper {
        @AuraEnabled public boolean isConsumed;
        @AuraEnabled public String productCodeConsumed;  
    }
    public class OrderItemDetails{
        @auraEnabled
        public String orderItemId;
        @auraEnabled
        public String partCode;
        @auraEnabled
        public OrderItem ordItemRec;
    }
    public class SlotDateTimeToOrderItem{
        // public String orderItemId;
        public Integer lineItemId;
        public String slotDate;
    }
    public class LogicResponseWrapper {
        @AuraEnabled public String erroMessage;
        @AuraEnabled public boolean isSuccessOrFailure;
        @AuraEnabled public List<String> orderItemStringList;
    }
    public class ProductIdentifierWrapper{
        @AuraEnabled public String categoryCode;
        @AuraEnabled public String type;
    }
    public class RepairProductValidater{
        @AuraEnabled public String productCode;
        @AuraEnabled public String branchOnlyMobileOnly;
        @AuraEnabled public boolean isRepairApplied;
    }
    public class RepairProductApplied{
        @AuraEnabled public List<RepairProductValidater> repairProducts;
        @AuraEnabled public boolean isRepairApplied;
    }
    public class ProductRequiredWrapper {
        @auraEnabled
        public String productCode;
        @auraEnabled
        public String productOLIKey;
        @auraEnabled
        public String woliId;
        @auraEnabled
        public Boolean isConsumed;
    }
    public class AccountRuleParameterWrapper {
        @auraEnabled
        public String productCode ;
        @auraEnabled
        public String productCategory;
        @AuraEnabled
        public boolean isDoNotShowAll;
        @AuraEnabled
        public boolean isDoNotShow;
    }
}