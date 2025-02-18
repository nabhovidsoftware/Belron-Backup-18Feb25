public without sharing class BLN_PProductAvailabilityWrapper {

    public class BomIdWrap {
        public String bomId;
        public Integer quantity;
        public Boolean branch;
        public Boolean mobile;          
    }
    
    public class PartIdWrap {
        public String partId;
        public Integer quantity;
        public Boolean branch;
        public Boolean mobile;          
    }
    
    public class LocationWrapper {
        public String costCenterId;
        public String locationId;
        public Boolean mobileLocationIndicator;
        public String countryCode;
        public String excludeProduct;
        
    }
    
    public class InsuranceDetailsWrapper{
        public Integer glassLimit;
        public Integer repairExcess;
        public Integer replacementExcess;
        public Integer calibrationExcess;
        public Integer sundryExcess;
        public Decimal vehicleDamageExcess;
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
        public List<AvailabilityDatesWrapper> earliestAvailabilityDetails;
        @AuraEnabled
        public List<InsuranceLiabilityWrapper> liabilityDataList;
        @AuraEnabled
        public List<EarliestAvailabilityDetailsWrapper> earliestAvailabilityList;
    }
    
    public class EarliestAvailabilityDetailsWrapper{
        @AuraEnabled
        public List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails> earliestDateList;
        @AuraEnabled
        public String quoteId;
        @AuraEnabled
        public String productCode;
        @AuraEnabled
        public String bundleName;
        
        public EarliestAvailabilityDetailsWrapper(){
            this.earliestDateList = new List<BLN_ProductResponseWrapper.ResponseAvailabilityDetails>();
            this.quoteId = '';
            this.productCode = '';
            this.bundleName = '';
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
        @auraEnabled
        public Double quantity;
        @auraEnabled
        public String productName;
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
        public Boolean isBondedNonBonded;
        @AuraEnabled
        public String orderItemId;
        
        public ProductSelectionWrapper(){
            this.hierarchy = '';
            this.bomId = '';
            this.bundleHierarchy = '';
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
        @AuraEnabled public String productCode;	
        @AuraEnabled public String bundleName;	
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
        @AuraEnabled public String slotSelectedDate;	
        @AuraEnabled public String serviceAppointmentId;	
        @AuraEnabled public String slotDate;
        @AuraEnabled public String slotTime;	
        @AuraEnabled public String slotDateTimeStart;	
        @AuraEnabled public String slotDateTimeFinish;
        @AuraEnabled public ProductAvailibilities[] productAvailibilities;
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
    }

}