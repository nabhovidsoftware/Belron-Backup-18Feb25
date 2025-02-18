import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, getRecordUi } from 'lightning/uiRecordApi';
import updateBillingMethodToCash from '@salesforce/apex/BLN_PDSSeachCalloutController.updateBillingMethodToCash';  
import makeCallout from '@salesforce/apex/BLN_PDSSeachCalloutController.makeCallout';
import getCorp from '@salesforce/apex/BLN_PDSSeachCalloutController.splitBillCorpCallout';
import getPolicyFormat from '@salesforce/apex/BLN_PDSSeachCalloutController.getPolicyFormatApi';
import pdsDirectCall from '@salesforce/apex/BLN_PDSSeachCalloutController.pdsDirectCallout';
import fetchPDS from '@salesforce/apex/BLN_PDSSeachCalloutController.blnPDSsearchAPI';
import getCustomerB2BAccount from '@salesforce/apex/BLN_PDSSeachCalloutController.getCustomerB2BAccount';
import createUpdateRecords from '@salesforce/apex/BLN_PDSSeachCalloutController.createUpdateRecords';
import searchManual from '@salesforce/apex/BLN_PDSSeachCalloutController.searchManual';
import { NavigationMixin, getEnclosingTabId } from 'lightning/navigation';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent, FlowNavigationBackEvent, FlowNavigationPauseEvent } from 'lightning/flowSupport';

import BVTCustom from '@salesforce/customPermission/BLN_BVT';
import NonDirectBilling from '@salesforce/label/c.BLN_NonDirectBilling';
import VehicleRegistrationNumber from '@salesforce/label/c.BLN_VehicleRegistrationNumber';
import PolicyNumber from '@salesforce/label/c.BLN_PolicyNumber';
import IncidentDate from '@salesforce/label/c.BLN_IncidentDate';
import CapturePolicyHolder from '@salesforce/label/c.BLN_CapturePolicyHolder';
import PDSError from '@salesforce/label/c.BLN_PDSError';
import Next from '@salesforce/label/c.BLN_Next';
import ManualSearch from '@salesforce/label/c.BLN_ManualSearch';
import Manual from '@salesforce/label/c.BLN_PdsManual';
import DirectAPI from '@salesforce/label/c.BLN_DirectAPI';
import InputError from '@salesforce/label/c.BLN_InputError';
import NoAccountSelectedError from '@salesforce/label/c.BLN_NoAccountSelectedError';
import PdsClearSelectionError from '@salesforce/label/c.BLN_PdsClearSelectionError';
import NoSearchResultsError from '@salesforce/label/c.BLN_PDSNoSearchResultsError';
import AccountName from '@salesforce/label/c.BLN_AccountName';
import AccountNumber from '@salesforce/label/c.BLN_AccountNumber';
import searchpds from '@salesforce/label/c.BLN_SearchPds';
import ClearSelection from '@salesforce/label/c.BLN_ClearSelection';
import PdsAccepted from '@salesforce/label/c.BLN_PdsAccepted';
import ContinuePds from '@salesforce/label/c.BLN_ContinuePds';
import Corporate_OBJECT from '@salesforce/schema/BLN_Corporate__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import RecordTypeInsurance from '@salesforce/label/c.BLN_InsuranceRecordType';
import RecordTypeSplitBill from '@salesforce/label/c.BLN_SplitBill';
import CorporateRecordType from '@salesforce/label/c.BLN_CorporateFleet';
import NoAccountSiteFoundError from '@salesforce/label/c.BLN_NoAccountSiteFoundError';
import InsuranceRecordType from '@salesforce/label/c.BLN_Insurance';
import Close from '@salesforce/label/c.BLN_CLoseLabel';
import NoteForPolicyFormat from '@salesforce/label/c.BLN_NoteForPolicyFormat';
import { EnclosingTabId, getFocusedTabInfo, getTabInfo, closeTab, IsConsoleNavigation } from 'lightning/platformWorkspaceApi';
import NoValidPolicy from '@salesforce/label/c.BLN_NoValidPolicy';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import IncidentDateError from '@salesforce/label/c.BLN_IncidentDateError';
import MotoristPayViaInsurance from '@salesforce/label/c.BLN_MotoristPayViaInsurance';
import AreTheyPolicyHolder from '@salesforce/label/c.BLN_AreTheyPolicyHolder';
import PermissionBehalfPolicyholder from '@salesforce/label/c.BLN_PermissionBehalfPolicyholder';
import VATRegisteredLabel from '@salesforce/label/c.BLN_VATRegistered';
import VATNumber from '@salesforce/label/c.BLN_VATNumber';
import APIErrorMessage from '@salesforce/label/c.BLN_PdsApiError';
import ErrorMessageForSplitBill from '@salesforce/label/c.BLN_ErrorMessageForSplitBill';
import ErrorPolicyFormatError from '@salesforce/label/c.BLN_ErrorPolicyFormatError';
import createCorporateRecordToastMessage from '@salesforce/label/c.BLN_CreateCorporateRecordToastMessage';
import rejected from '@salesforce/label/c.BLN_Rejected';
import PdsNo from '@salesforce/label/c.BLN_PdsNo';
import VRN from '@salesforce/label/c.BLN_PdsVRN';
import cash from '@salesforce/label/c.BLN_Cash';
import billingMethodInsurance from '@salesforce/label/c.BLN_billingMethod';
import FirstName from '@salesforce/label/c.BLN_FirstName';
import LastName from '@salesforce/label/c.BLN_LastName';
import Back from '@salesforce/label/c.BLN_PdsBack';
import accselect from '@salesforce/label/c.BLN_Pdsaccselect';
import corpselect from '@salesforce/label/c.BLN_Pdscorpselect';
import PdsYes from '@salesforce/label/c.BLN_PdsYes';
import Corporate from '@salesforce/label/c.BLN_PdsCorporate';
import CaptureDataCollect from '@salesforce/label/c.BLN_CaptureDataCollect';
import Insurance from '@salesforce/label/c.BLN_PdsInsurance';
import recordIdName from '@salesforce/label/c.BLN_PdsrecordId';
import CallAderessFlow from '@salesforce/label/c.BLN_PdsCallAderessFlow';
import ResponsePostalCode from '@salesforce/label/c.BLN_PdsResponsePostalCode';
import CallDataCollectFlow from '@salesforce/label/c.BLN_CallDataCollectFlow';
import SiteNameCorporateSite from '@salesforce/label/c.BLN_SiteNameCorporateSite';
import SiteNameInsurerSite from '@salesforce/label/c.BLN_SiteNameInsurerSite';
import ReplacementExcess from '@salesforce/label/c.BLN_ReplacementExcess';
import Y from '@salesforce/label/c.BLN_Y';
import N from '@salesforce/label/c.BLN_N';
import RepairExcess from '@salesforce/label/c.BLN_RepairExcess';
import SplitBillAccountCorporateLegalEnitity from '@salesforce/label/c.BLN_SplitBillAccountCorporateLegalEnitity';
import SplitBillAccountInsurerLegalEntity from '@salesforce/label/c.BLN_SplitBillAccountInsurerLegalEntity';
import Select from '@salesforce/label/c.BLN_Select';
import Salutation from '@salesforce/label/c.BLN_Salutation';
import ProvidedVehicleRegistration from '@salesforce/label/c.BLN_ProvidedVehicleRegistration';
import InsuranceAccount from '@salesforce/label/c.BLN_billingMethod';
import CaptureCorporateLabel from '@salesforce/label/c.BLN_CaptureCorporateIns';
import UnhappyAdressFlow from '@salesforce/label/c.BLN_UnhaapyAddressFlow';
import genericErrorMsg from '@salesforce/label/c.BLN_CreditCheckFailedMessage';
import PolicyLimit from '@salesforce/label/c.BLN_PolicyLimitLabel'; 
import GlassCoverFlagMsg from '@salesforce/label/c.BLN_GlassCoverFlagMsg'; 
import GlassCoverFlagField from '@salesforce/label/c.BLN_GlassCoverFlagField'; 
 
import LightningAlert from 'lightning/alert';
 
import { RefreshEvent } from 'lightning/refresh';

const FIELDS = [
    'Case.BLN_BillingPostCode__c',
    'Case.CreatedDate'
];

export default class Bln_PDSSearch extends NavigationMixin(LightningElement) { //NavigationMixin(LightningElement)

    firstPage = true;
    secondPage = false;
    thirdpage = false;
    isPolicyCall = false;
    scriptError = false;
    isdirectApi = true;
    isSelected = false;

    VRNNumber = '';
    insuranceAccountName = '';
    @api CreatedDateValue = '';
    @api recordId;
    @api personaccountID;
    @api finishFlow = false;
    vehicleRegNumber = '';
    policyNumber = '';
    policyNumberFirstScreen = '';
    incidentDate = '';
    @track error = '';
    noVehicle = false;
    caseCreatedDate = '';
    columns = [];
    corporateFields = [];
    @track finalcolumns = [];
    disablePolicyHolderButton = true;
    @track disableNextButton = false;
    @track disableManualSearch = false;
    @track incDateError = false;
    @api callMotoristFlow = false;
    @api callMotoristFlow1 = false;
    //@api callDataFlow1 = false;
    @api nameSalutation = '';
    @track isCheckboxDisabled = true;
    @api fName = '';
    @api lName = '';
    @api availableActions = [];
    @track openmodel = false;
    @track recordTypeId = '';
    @track modalColumns = [];
    @api selectedRow = [];
    @api selectedRowData;
    finalData = [];
    data = [];
    @api vehicleId = '';
    spinnerOn = false;
    corporateId;
    @api caseid;
    @track dataColumns = [];
    fieldsetcolumns = [];
    @track filteredUsersList = [];
    @api corporateObj;
    @api motoristScreen = false;
    @track motoristWantToPay = true;
    @track policyHolder = false;
    permissionToActBehalf = false;
    @track vatRegistered = false;
    @track isNonDirectBilling = false;
    @track vatNumber = '';
    @track corporateTable = false;
    @track maxRow = 1;
    @track isDisabled = '';
    //isDisabled -> pointer-events: none; opacity: 0.8;
    @track motoristScreenNextDisable = true;
    @track copyRows = null;
    @api selectedRowCopy = [];
    //corpFieldsModal = ["BLN_PolicyNumber__c", "BLN_Salutation__c", "BLN_FirstName__c", "BLN_LastName__c", "BLN_VehicleRegistration__c"];
    @track corpRecId = null;
    @track responseSuccess = false;
    @track viewDetails = false;
    @track viewDetailsRec = [];
    @track apiError;
    @track isCloseDisabled = false;
    @track responseAPISuccess = true;
    showManualSearch = false;
    @track value = Corporate;
    @track accountName = '';
    @track accountNumber = '';
    isButtonDisabled = true;
    showError = false;
   
    @track accounts;
    @track showTable = false;
    // @track showTableDetails = 0;
    @track noRecords = 0;
    @track selectedAccount = {};
    @track corporateSelected = {};
    selectedCorporateList;
    @track isContinueDisabled = true;
    showCashButton = false;
    showNoAccountSelectedMessage = false;
    RecordTypeSplitBill;
    CorporateRecordType;
    RecordTypeInsurance;
    @track corporateWrapList = [];
    @track corporateWrapListCopy = [];
    isCorporateSelected = false;
    isCorporateList = false;
    @track selectedCorporateListItem;
    selectedCorporateListItemID;
    userHasInteracted = false;
    BVTCustom = BVTCustom;
    readOnly = true;
    accountNameInput = '';
    @api responsePostalCode = '';
    billPostCode = '';
    @api callAderessFlow = false;
    corporateRecordVariable = false;
    insuranceRecordVariable = false;
    splitBillRecordVariable = false
    previousScreen = false;
    selectedRowCount;
    showCashInsurance = false;
    isVatRegDisable = true;
    corporateAccId = null;
    corporateUnselectedList = [];
    selectedRecordInputList = [];
    isVatResgistered = false;
    replacementExcess = '';
    corporateId = '';
    insuranceId = '';
    selectedOption = Corporate;
    thirdPageCash = false;
    flowApiName = CaptureDataCollect;
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    isQuestionCheck = false;
    isMotoristPayIns = true;
    corporateWrapperList = [];
    fetchCaseRecord = {};
    rowId = 0;
    pdsDirectdata = [];
    isCheckAddressFlow = false;
    unhappyAddressFlow=false;
    //11496
    @api booleanVariableForFlow = false;
    @api callDataCollectFlow = false;
    @api isFlowHeader = false;
    isHandleMotoristScreen = false;
    isManualSearch = false;
    isHandleCoseButton = false;

    //11206
    isGlassCoverFlag = false;

    options = [
        { label: Corporate, value: Corporate },
        { label: Insurance, value: Insurance }
    ];


    label = {
        VehicleRegistrationNumber,
        NonDirectBilling,
        ErrorMessageForSplitBill,
        NoAccountSiteFoundError,
        PolicyNumber,
        IncidentDate,
        CapturePolicyHolder,
        Next,
        ManualSearch,
        Close,
        Back,
        Insurance,
        NoValidPolicy,
        IncidentDateError,
        MotoristPayViaInsurance,
        AreTheyPolicyHolder,
        PermissionBehalfPolicyholder,
        VATRegisteredLabel,
        VATNumber,
        APIErrorMessage,
        InputError,
        NoAccountSelectedError,
        PdsClearSelectionError,
        AccountName,
        AccountNumber,
        searchpds,
        ClearSelection,
        ContinuePds,
        NoSearchResultsError,
        VRN,
        cash,
        ReplacementExcess,
        RepairExcess,
        SiteNameCorporateSite,
        SiteNameInsurerSite,
        SplitBillAccountCorporateLegalEnitity,
        SplitBillAccountInsurerLegalEntity,
        Select,
        Salutation,
        FirstName,
        accselect,
        corpselect,
        ProvidedVehicleRegistration,
        LastName,
        NoteForPolicyFormat,
        CaptureCorporateLabel,
        PolicyLimit,
        GlassCoverFlagMsg,
        GlassCoverFlagField
    };


    get inputAddressVarible() {
        return [

            {
                name: recordIdName,
                type: 'String',
                value: this.recordId

            },
            {
                name: CallAderessFlow,
                type: 'Boolean',
                value: this.callAderessFlow
            },
            {
                name: ResponsePostalCode,
                type: 'String',
                value: this.responsePostalCode
            },
            {
                name: CallDataCollectFlow,
                type: 'Boolean',
                value: this.callDataCollectFlow
            },
            {
                name: UnhappyAdressFlow,
                type: 'Boolean',
                value: this.unhappyAddressFlow
            }


        ];
    }

    get inputVariablesDataCollect() {
        return [

            {
                name: recordIdName,
                type: 'String',
                value: this.recordId
            },
            {
                name: CaptureDataCollect,
                type: 'Boolean',
                value: this.booleanVariableForFlow
            }

            
        ];
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    caseRecord({ error, data }) {
        if (data) {
            this.billPostCode = getFieldValue(data, 'Case.BLN_BillingPostCode__c');
           this.createdDateOfCase = getFieldValue(data, 'Case.CreatedDate');
          }
    }


    onClickNext() {

        this.firstPage = false;
        this.spinnerOn = true;
        this.isManualSearch = false;
        makeCallout({ vrn: this.vehicleRegNumber, lossDate: this.incidentDate })
            .then((result) => {
               var wrap = JSON.parse(result);
                let row = 0;
                if (wrap.corporateWrapList) {
                    this.corporateWrapList = wrap.corporateWrapList;
                    this.corporateWrapList.forEach(ele => {
                        ele.row = row;
                        row++
                    });
                    this.responseSuccess = true;
                    this.showManualSearch = false;
                    this.corporateTable = false;
                    this.error = '';
                }
                if (this.corporateWrapList.length == 0) {
                    this.responseSuccess = false;
                    this.error = NoValidPolicy;
                   
                }
                if (wrap.errors) {
                    /* if (wrap.errors[0].title != null && wrap.errors[0].title != "" && wrap.errors[0].title != undefined) { 
                         this.apiError = wrap.errors[0].title; 
                     }
                     else { 
                         this.apiError = this.label.APIErrorMessage; 
                     }
                     this.error = '';
                     this.responseSuccess = false;
                     this.responseAPISuccess = false;*/
                }

                this.corporateWrapListCopy = this.objConvert(this.corporateWrapList);
                this.spinnerOn = false;
            })
            .catch((error) => {

                this.spinnerOn = false;
                this.showToast('Error', 'Please try again later', 'Error');
            });


    }
    onClickManualSearch() {
        
        this.firstPage = false;
        this.secondPage = true;
        this.showManualSearch = true;
        this.isButtonDisabled = true;
        this.isManualSearch = true;
        if (this.selectedOption === Corporate) {
            this.isCorporateSelected = true;
        } else if (this.selectedOption === Insurance) {
            this.isCorporateSelected = false;
            // this.handleLoad();
        }
        //Autopopulate value for account Name
        searchManual({ cs: this.fetchCaseRecord })
            .then((result) => {
                if (result) {
                    
                    this.accountName = result;
                    this.isButtonDisabled = false;
                    
                }
                else {
                    this.isButtonDisabled = true;
                }
            })



    }

    handleOptionChange(event) {
        this.selectedOption = event.detail.value;
        if (this.selectedOption == Corporate) {
            this.isCorporateSelected = true;
            this.showError = false;
            this.showTable = false;
            //this.accounts = [];
            //this.accountName = '';
            //this.isButtonDisabled = true;
            this.showCashButton = false;
        } else {
            this.isCorporateSelected = false;
            this.showError = false;
            this.showTable = false;
           // this.accounts = [];
            //this.accountName = '';
            //this.isButtonDisabled = true;
           this.showCashButton = false;
        }
        
    }

    handleInputChange(event) {
        this.userHasInteracted = true;
        if (event.target.dataset.label === AccountName) {
            this.accountName = event.target.value;
        } else if (event.target.dataset.label === AccountNumber) {
            this.accountNumber = event.target.value;
        } else if (event.target.dataset.label === PolicyNumber) {
            this.policyNumber = event.target.value;
            console.log('policyNumber', this.policyNumber);
            } else if (event.target.dataset.label === ReplacementExcess) {
            this.replacementExcess = event.target.value;
           
        }

        this.isButtonDisabled = !(this.accountName || this.accountNumber);
      
        if (this.accountName == '' && this.accountNumber == '') {
            this.showError = true;
        } else if (!(this.accountName == '' && this.accountNumber == '')) {
            this.userHasInteracted = false;
            this.showError = false;
        }

        if (this.policyNumber != '' && this.replacementExcess != '') {

            this.isButtonDisabled = false;
            this.isContinueDisabled = false;
            
        } else {
            //this.isButtonDisabled = true;
            this.isContinueDisabled = true;
        }
        this.scriptError = false;
        this.showTable = false;
        this.showNoAccountSelectedMessage = false;
        this.showCashInsurance = false;
        this.showCashButton = false;
        //this.accounts = [];
    }

    handleSearch() {
        
        getCustomerB2BAccount({ accountName: this.accountName, accountNumber: this.accountNumber, selectedOption: this.selectedOption })
            .then(result => {
                if (result) {
                    
                    this.accounts = result.map((account, index) => {
                        
                        return account;
                    });
                    if (this.isButtonDisabled == false && (this.accounts && this.accounts.length > 0)) {
                        this.showTable = true;
                        this.showNoAccountSelectedMessage = true;
                        this.showCashInsurance = true;
                        this.isContinueDisabled = true;
                    } else {
                        this.showTable = false;
                        this.showCashInsurance = true;
                        this.showCashButton = true;
                    };



                }
            })
            .catch(error => {
                console.error('Error in fetching data', error);
            });

    }



    handleRadioChange(event) {
    
        var selectedValue = event.target.checked;
        var selectedTarget = event.target.value;
        
        this.isContinueDisabled = !selectedValue;
        this.showNoAccountSelectedMessage = !selectedValue;
        if (event.target.name == 'accountSelect') {
            if (selectedValue) {
                this.accounts.forEach(res => {
                    if (res.Id == selectedTarget) {
                        res.selected = true;
                        this.selectedAccount = res;
                    }
                });
            }
        }


        if (event.target.name == 'corpSelect') {
           
            this.isCloseDisabled = true;
            //var rowNumber = 0;
            //rowNumber = event.currentTarget.dataset.row;
            
           
            var selectedTargetValue = event.target.dataset.row;
            this.rowId = selectedTargetValue;
            



           
            this.corporateWrapList.forEach(res => {
                if (res.row == selectedTargetValue) {
                   
                    res.attachToCase = true;
                    
                    this.corporateSelected = res;
                  

                    /*FOUK-10513*/
                    if((JSON.stringify(this.corporateSelected.insuranceSiteAccountName) != null && JSON.stringify(this.corporateSelected.insuranceLegalEntityName) != null) && (this.corporateSelected.corporateSiteName == null && this.corporateSelected.corporateLegalEntityName == null)){
                       
                        this.corporateTable = true;
                        
                    }else {
                        this.corporateTable = false;
                    }
                    /* FOUK-10513*/
                } else {
                    res.attachToCase = false;
                }
            });

             /* FOUK-10513*/
             
            this.corporateWrapList.forEach(element => {
              

                if (element.row == this.rowId) {
                    element.attachToCase = true;
                    if (element.vatRegFlag == 'Y') {
                        this.vatRegistered = true;
                    }
                    else {
                        this.vatRegistered = false;
                    }
                   //adding logic under FOUK-11206
                    if(element.glassCoverFlag == 'N'){
                        this.isGlassCoverFlag = true;
                        LightningAlert.open({
                            message: this.label.GlassCoverFlagMsg,
                            theme: 'warning', 
                            label: 'alert', 
                          });
                    }
                    //FOUK-11206 End
                }
            }); /* FOUK-10513*/
        }


    }

    handleSelect(event) {

        this.isQuestionCheck = false;
        this.isCheckAddressFlow = false;
        let vatRegistered = event.currentTarget.dataset.vatflag;
        let responsePostcode = event.currentTarget.dataset.postcode;
        let salutation = event.currentTarget.dataset.salutation;
        let fName = event.currentTarget.dataset.firstname;
        let lName = event.currentTarget.dataset.lastname;
        let insuranceid = event.currentTarget.dataset.insuranceid;
        let corporateid = event.currentTarget.dataset.corporateid;
        this.rowId = event.currentTarget.dataset.row;

        this.motoristScreenNextDisable = false;
        this.vatRegistered = vatRegistered == PdsYes ? true : false;
        this.responsePostalCode = responsePostcode;
        this.nameSalutation = salutation;
        this.fName = fName;
        this.lName = lName;
        this.insuranceId = insuranceid;
        this.corporateId = corporateid;

        if (this.insuranceId != null && this.insuranceId != undefined && this.insuranceId != '') {
            this.corporateTable = true;
            // this.motoristScreen = true;
        } else {
            this.corporateTable = false;
            // this.motoristScreen = false;
        }

        this.corporateWrapList.forEach(element => {
            if (element.row == this.rowId) {
                element.attachToCase = true;
                if (element.vatRegFlag == 'Y') {
                    this.vatRegistered = true;
                }
                else {
                    this.vatRegistered = false;
                }

                 //adding logic under FOUK-11206
                 if(element.glassCoverFlag == 'N'){
                    this.isMotoristPayIns = false;
                    LightningAlert.open({
                        message: this.label.GlassCoverFlagMsg,
                        theme: 'warning', 
                        label: 'alert', 
                      });
                }
                //FOUK-11206 End
            }
        });
      
       if(this.isMotoristPayIns == true){
        this.fetchCaseRecord.BLN_BillingMethod__c = InsuranceAccount;
       } else{
        this.fetchCaseRecord.BLN_BillingMethod__c = cash;
       } 
      console.log('fetchCaseRecord321',JSON.stringify(this.fetchCaseRecord));
    }

    objConvert(obj) {
        return JSON.parse(JSON.stringify(obj));
    }


    handleSelection(event) {
        console.log('event.target.name',event.target.name)
        if (event.target.name == accselect) {
            
            this.selectedAccount = null;

            this.isContinueDisabled = true;
            this.showNoAccountSelectedMessage = true;

            this.accounts.forEach(res => {
                res.selected = false;
            });

        } else if (event.target.name == corpselect) {
            this.isContinueDisabled = true;
            this.isCloseDisabled = false;
            this.showNoAccountSelectedMessage = true;
            this.corporateTable = false;
            this.corporateWrapList.forEach(corp => {
                corp.attachToCase = false;

            });

        }
    }



    handleincidentchange(event) {
        this.incidentDate = event.detail.value;


    }
    handlePolicyNumberChange(event) {
        this.policyNumberFirstScreen = event.target.value;

    }



    handleContinue() {
        this.isContinueDisabled = true;
        this.isHandleCoseButton = false;
        //this.isButtonDisabled = true;
       // this.isHandleMotoristScreen = true;
       
        if (this.selectedAccount.BLN_MDMAccountID__c == undefined) {
            this.selectedAccount.BLN_MDMAccountID__c = null;
        } else if (this.replacementexcess == '') {
            this.replacementexcess = null;
        }
       
        if (this.selectedAccount) {

            this.secondPage = false;
            this.thirdpage = false;
            if (this.isCorporateSelected == true) {
                this.spinnerOn = true;

                getCorp({ accountMDMID: this.selectedAccount.BLN_MDMAccountID__c, lossDate: this.incidentDate /* previously this.createdDate */ })
                    .then((result) => {
                        console.log('result from getCorp',result);
                        this.isPolicyCall = false;
                        this.thirdpage = false;
                        this.isCloseDisabled = false;
                        //this.spinnerOn =false;
                       
                        var wrap = JSON.parse(result);
                        if (wrap.corporateWrapList.length === 0) {
                            if (this.selectedAccount.BLN_NonDirectBilling__c == true) {

                                this.thirdpage = true;
                                this.thirdPageCash = true;
                               
                                this.corporateWrapList = false;

                            } else {
                                this.thirdpage = true;
                                this.isNonDirectBilling = true;
                                this.corporateWrapList = false;
                                this.isCorporateSelected = true;


                            }

                        } else {
                            this.thirdpage = true;
                            let row = 0;
                            this.corporateWrapList = wrap.corporateWrapList;
                            this.spinnerOn = false;
                            this.corporateWrapList.forEach(res => {

                                res.row = row;
                                row++
                            })

                        }
                        this.spinnerOn = false;
                    })

                    .catch(error => {
                        console.error('Error in fetching data', error);
                        this.spinnerOn = false;
                    });
            } else if (this.isCorporateSelected == false && (this.policyNumber == null || this.policyNumber == '') && (this.replacementExcess == null || this.replacementExcess == '')) {
                this.spinnerOn = true;
                pdsDirectCall({ vrn: this.vehicleRegNumber, lossDate: this.incidentDate, vehicleId: this.vehicleId, accountMDMID: this.selectedAccount.BLN_MDMAccountID__c})
                    .then((result) => {
                        console.log('result from pdsDirectCall',result);
                       console.log('this.selectedAccount.BLN_MDMAccountID__c', this.selectedAccount.BLN_MDMAccountID__c);
                        var wrap = JSON.parse(result);
                      
                        if (wrap.corporateWrapList.length === 0) {
                            
                            this.isdirectApi = false;
                            this.thirdpage = false;
                            this.isPolicyCall = true;
                            this.isCloseDisabled = false;
                            this.spinnerOn = false;
                            this.isButtonDisabled = false;
                        } else {
                            this.isdirectApi = true;
                            this.thirdpage = true;
                            this.isPolicyCall = false;
                            this.isCloseDisabled = false;
                           
                           let row = 0;
                            this.corporateWrapList = wrap.corporateWrapList;
                            this.corporateWrapList.forEach(res => {
                                res.row = row;
                                row++
                            })

                        }
                        this.spinnerOn = false;
                        console.log('corporateWrapList',JSON.stringify(this.corporateWrapList));
                    }).catch(error => {
                        console.error('Error in fetching data', error);

                    });

            } else if (this.isCorporateSelected == false && (this.policyNumber != '' || this.policyNumber != null) && (this.replacementExcess != null || this.replacementExcess != '')) {
                //this.isPolicyCall = true;
                this.isPolicyCall = false;
                this.spinnerOn = true;
                console.log('this.policyNumber', this.policyNumber);
               
                getPolicyFormat({ accountMDMID: this.selectedAccount.BLN_MDMAccountID__c, policyno: this.policyNumber, replacementexcess: this.replacementExcess, lossDate: this.incidentDate })
                    .then((result) => {
                        console.log('result from getPolicyFormat',result);
                        var wrap = JSON.parse(result);
                  
                        if (wrap.corporateWrapList.length === 0) {
                           
                            if (this.selectedAccount.BLN_NonDirectBilling__c == true) {
                              
                                this.thirdpage = false;
                                this.isCloseDisabled = false;
                                this.thirdPageCash = true;
                                
                                
                                
                                    this.dispatchEvent(

                                        new ShowToastEvent({
                                            title: 'Error',
                                            message: ErrorPolicyFormatError,
                                            variant: 'info',
                                            mode: 'sticky'
                                        }),
                                    );
                                
                                this.corporateWrapList = false;



                            } else {
                                
                                this.thirdpage = false;
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error',
                                        message: ErrorPolicyFormatError,
                                        variant: 'info',
                                        mode: 'sticky'
                                    }),
                                );


                            }
                            
                            this.isPolicyCall = true;
                            this.scriptError = true;
                            this.isContinueDisabled = false;


                        } else {
                           
                            this.thirdpage = true;
                            this.thirdPageCash = false;
                            let row = 0;
                            this.corporateWrapList = wrap.corporateWrapList;
                            this.corporateWrapList.forEach(res => {
                                res.row = row;
                                row++
                            })

                        }
                        this.spinnerOn = false;
                    }).catch(error => {
                        console.error('Error in fetching data', error);

                    });
            }
        }

        console.log('corwrapList4321',JSON.stringify(this.corporateWrapList));
    }

    @wire(getObjectInfo, { objectApiName: Corporate_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            // Returns a map of record type Ids
            const rtis = data.recordTypeInfos;
            Object.keys(rtis).forEach(element => {
                if (rtis[element].name == CorporateRecordType) {
                    this.CorporateRecordType = element;
                } else if (rtis[element].name == RecordTypeInsurance) {
                    this.RecordTypeInsurance = element;

                } else if (rtis[element].name == RecordTypeSplitBill) {
                    this.RecordTypeSplitBill = element;
                }
            });
        }
        if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }


    createUpdRecord(corpWrapList, cs) {
         if (corpWrapList && corpWrapList.length > 0 && cs.Id != null)
            console.log('corpWrapList', JSON.stringify(corpWrapList), cs);
            createUpdateRecords({ corporateWrapperList: JSON.stringify(corpWrapList), cs: cs })
                .then(result => {
                    console.log('this.result', JSON.stringify(result));
                    if (result == true) {
                        this.spinnerOn = false;
                       this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: createCorporateRecordToastMessage,
                                variant: 'success',
                            }),
                        );
                        if( this.isHandleCoseButton == true){
                            this.navigateToCaseRecord();
                            this.closeTab();
                            return;
                        }
                    if(this.isManualSearch = false){    
                    if(this.isHandleMotoristScreen == true){
                        if (this.responsePostalCode == this.billPostCode) {
                            this.corporateTable = false;
                            this.callAderessFlow = false;
                            this.booleanVariableForFlow = true;
                            this.callDataCollectFlow = false;
                            this.isFlowHeader = true;
                            //////
                            this.motoristScreen = true;
                            this.responseSuccess = false;
                          
                
                        } else if (this.responsePostalCode != null) {
                            this.corporateTable = false;
                            this.booleanVariableForFlow = false;
                            this.callDataCollectFlow = true;
                            this.motoristScreen = true;
                            this.callAderessFlow = true;
                            this.isFlowHeader = true;
                         
                            this.responseSuccess = false;
                        } 
                    }
                } else{
                    this.corporateTable = false;
                    this.booleanVariableForFlow = false;
                    this.callDataCollectFlow = true;
                    this.motoristScreen = true;
                    this.callAderessFlow = true;
                    this.isFlowHeader = true;
                    this.responseSuccess = false;
                }

                       if(this.booleanVariableForFlow != true){
                        if (this.callAderessFlow == false) {
                         this.navigateToCaseRecord();
                         /*this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow", true));
                         if (this.availableActions.find(element => element == 'NEXT')) {
                            const navigateNextEvent = new FlowNavigationNextEvent();
                           this.dispatchEvent(navigateNextEvent)
                          }*/
                           this.closeTab();
                        }
                    }




                      //  this.dispatchEvent(new FlowAttributeChangeEvent("callAderessFlow", this.callAderessFlow));
                      //  this.dispatchEvent(new FlowAttributeChangeEvent("resPostalCode", this.ResponsePostalCode));

                    //    if (this.availableActions.find(element => element == 'FINISH')) {
                    //          const navigateNextEvent = new FlowNavigationFinishEvent();
                    //         this.dispatchEvent(navigateNextEvent)
                    //       }
                    } else{
                        this.spinnerOn = false;
                        this.dispatchEvent(
                             new ShowToastEvent({
                                 title: 'Error',
                                 message: genericErrorMsg,
                                 variant: 'error',
                             }),
                         );

                         this.navigateToCaseRecord();
                           this.closeTab();   
                    }
                  
                    
                })
                .catch(error => {
                    this.spinnerOn = false;
                    console.error('unhappyPathCorporate error', JSON.stringify(error));
                })
              
    }

    handleCashButtonHappyPath(){
        updateBillingMethodToCash({ recordId: this.recordId })  
        .then(() => {  
          
            this.dispatchEvent(  
                new ShowToastEvent({  
                    title: 'Success',  
                    message: 'Billing Method updated to Cash',  
                    variant: 'success'  
                })  
            ); 
            getFocusedTabInfo().then((tabInfo) => {
                closeTab(tabInfo.tabId);
            }) 
        })
      
    }
    handleSearchButton() {
        this.spinnerOn = true;
        this.isHandleMotoristScreen = false;
        this.isHandleCoseButton = true;
        var corpWrap = {};
        var corpWrapList = [];
        // this.fetchCaseRecord.BLN_BillingMethod__c = cash;
        if (this.incidentDate) {
            this.fetchCaseRecord.BLN_IncidentDate__c = this.incidentDate;
        }
       //code added under FOUK-12530
        if(this.selectedAccount.BLN_NonDirectBilling__c == true){
            this.fetchCaseRecord.BLN_BillingMethod__c = cash;
        }

        corpWrap.insuranceLegalEntitySFId = this.selectedAccount.Id;
        console.log(' corpWrap.insuranceLegalEntitySFId',  corpWrap.insuranceLegalEntitySFId);
        
            corpWrap.knownAs = this.accountName;
            corpWrap.isPolicyValid = PdsNo;
            
            corpWrap.policyConfirmation = rejected;
            corpWrap.origin = Manual;
            corpWrap.policyNumber  = this.policyNumber;
            corpWrap.glassExcessAmount = this.replacementExcess;

            corpWrap.attachToCase = true;
            //corpWrap.insuranceLegalEntitySFId = this.selectedAccount.Id;





        
        corpWrapList.push(corpWrap);
        this.createUpdRecord(corpWrapList, this.fetchCaseRecord);
    }

    handleCashButton() {
        this.spinnerOn = true;
        this.isHandleMotoristScreen = false;
        this.isHandleCoseButton = true;
        var corpWrap = {};
        var corpWrapList = [];
        this.fetchCaseRecord.BLN_BillingMethod__c = cash;
        console.log('this.fetchCaseRecord.BLN_BillingMethod__c', this.fetchCaseRecord.BLN_BillingMethod__c);
        if (this.incidentDate) {
            this.fetchCaseRecord.BLN_IncidentDate__c = this.incidentDate;
        }
        if (this.accountName) {
            corpWrap.knownAs = this.accountName;
            corpWrap.isCorporateSelected = this.isCorporateSelected;
            corpWrap.isPolicyValid = PdsNo;
            
            corpWrap.policyConfirmation = rejected;
            corpWrap.origin = Manual;
            corpWrap.attachToCase = true;
        }

        if (this.selectedAccount && this.isCorporateSelected == true) {
            corpWrap.corporateLegalEntitySFId = this.selectedAccount.Id;
        } else if(this.selectedAccount && this.isCorporateSelected == false){
            corpWrap.insuranceLegalEntitySFId = this.selectedAccount.Id;
        }
      
        
        console.log('corpWrap', corpWrap);
        corpWrapList.push(corpWrap);
        this.createUpdRecord(corpWrapList, this.fetchCaseRecord);
    }
    handleInsuranceButton() {
        this.spinnerOn = true;
        this.isHandleMotoristScreen = false;
        this.isHandleCoseButton = true;
        var corpWrap = {};
        var corpWrapList = [];
        this.fetchCaseRecord.BLN_BillingMethod__c = billingMethodInsurance;
        if (this.incidentDate) {
            this.fetchCaseRecord.BLN_IncidentDate__c = this.incidentDate;
        }
        if (this.selectedAccount ) {
            corpWrap.insuranceLegalEntitySFId = this.selectedAccount.Id;
        }
      
        if (this.accountName) {
            corpWrap.knownAs = this.accountName;
            corpWrap.isCorporateSelected = this.isCorporateSelected;
            corpWrap.isPolicyValid = PdsNo;
           
            corpWrap.policyConfirmation = rejected;
            corpWrap.origin = Manual;
            corpWrap.attachToCase = true;
        }
        corpWrapList.push(corpWrap);
        this.createUpdRecord(corpWrapList, this.fetchCaseRecord);
    }



    handleCloseButton() {
        var corpWrap = {};
        var corpWrapList = [];
        this.spinnerOn = true;
        this.isHandleMotoristScreen = false;
        this.isHandleCoseButton = true;
        if (this.incidentDate) {
            this.fetchCaseRecord.BLN_IncidentDate__c = this.incidentDate;
        }
        // added under FOUK-12530
        if(this.selectedAccount.BLN_NonDirectBilling__c == true){
            this.fetchCaseRecord.BLN_BillingMethod__c = cash;
        }
           
      
            corpWrap.knownAs = this.accountName;
            corpWrap.isCorporateSelected = this.isCorporateSelected;
            corpWrap.isPolicyValid = PdsNo;
            corpWrap.policyConfirmation = rejected;
            if(corpWrap.isCorporateSelected == true){
            corpWrap.corporateLegalEntitySFId = this.selectedAccount.Id;
            } else if (corpWrap.isCorporateSelected == false){
                corpWrap.insuranceLegalEntitySFId = this.selectedAccount.Id;
                console.log(' corpWrap.insuranceLegalEntitySFId',  corpWrap.insuranceLegalEntitySFId);
            }
            

            if (this.isdirectApi == true && this.isCorporateSelected == false) {
                corpWrap.origin = DirectAPI;
            } else {
                corpWrap.origin = Manual;
            }
           
            corpWrap.attachToCase = true;
       
        corpWrapList.push(corpWrap);
        this.createUpdRecord(corpWrapList, this.fetchCaseRecord);

    }


    handleContinueButton() {
        this.spinnerOn = true;
        this.isHandleMotoristScreen = false;
        this.callAderessFlow = false;
        this.isHandleCoseButton = false;


        //this.fetchCaseRecord.BLN_BillingMethod__c = billingMethodInsurance;
        if (this.incidentDate) {
            this.fetchCaseRecord.BLN_IncidentDate__c = this.incidentDate;
        }


        this.corporateWrapList.forEach(corp => {

            corp.knownAs = this.accountName;
            corp.isCorporateSelected = this.isCorporateSelected;

            corp.isPolicyValid = PdsYes;
            if (this.isdirectApi == true && this.isCorporateSelected == false) {
                corp.origin = DirectAPI;
            } else {
                corp.origin = Manual;
            }

           

           
           
            if (corp.isCorporateSelected) {
                if (this.selectedAccount) {
                    corp.corporateLegalEntitySFId = this.selectedAccount.Id;
                   console.log('corporateSelected.corporateSiteSFNonDirectBilling + this.selectedAccount.BLN_NonDirectBilling__c', this.corporateSelected.corporateSiteSFNonDirectBilling , this.selectedAccount.BLN_NonDirectBilling__c);
                    if (this.corporateSelected.corporateSiteSFNonDirectBilling == true) {
                        
                        this.fetchCaseRecord.BLN_BillingMethod__c = cash;
                    } else if (this.corporateSelected.corporateSiteSFNonDirectBilling == false  && this.isGlassCoverFlag == false) {
                        this.fetchCaseRecord.BLN_BillingMethod__c = billingMethodInsurance;
                    }
                }
            } else if(this.isCorporateSelected == false) {
                console.log('this.isCorporateSelected', this.isCorporateSelected);
                console.log('this.isCorporateSelected.insuraceSiteSFNonDirectBilling', this.corporateSelected.insuraceSiteSFNonDirectBilling); 
                if (this.corporateSelected.insuraceSiteSFNonDirectBilling == true ) {
                   
                    this.fetchCaseRecord.BLN_BillingMethod__c = cash;
                } else if (this.corporateSelected.insuraceSiteSFNonDirectBilling == false && this.isGlassCoverFlag == false) {
                    this.fetchCaseRecord.BLN_BillingMethod__c = billingMethodInsurance;
                }

            }

            if (corp.attachToCase) {

                corp.policyConfirmation = PdsAccepted;
            }
            else {

                corp.policyConfirmation = rejected;
            }
         
        });
        this.createUpdRecord(this.corporateWrapList, this.fetchCaseRecord);
        this.thirdpage = false;
     //   this.spinnerOn = false;
      //  this.callAderessFlow = true;
      //  this.unhappyAddressFlow = true; // comment this variable under FOUK-12397
        //this.booleanVariableForFlow = true;
    console.log('createupdaterecord123456',JSON.stringify(this.corporateWrapList));
    }


    handleMotoristScreen() {
        this.spinnerOn = true;
        this.isHandleMotoristScreen = true;
        //let postCode = this.billPostCode != null ? this.billPostCode.replace(/\s/g, '') : null;

        if (this.responsePostalCode == null) { 
                this.motoristScreenNextDisable = true;
        }
      
        this.corporateWrapList.forEach(corp => {

            corp.origin = 'PDS';
            if (corp.attachToCase) {

                corp.policyConfirmation = PdsAccepted;
            }
            else {

                corp.policyConfirmation = rejected;
            }
        });
        if (this.incidentDate) {
            this.fetchCaseRecord.BLN_IncidentDate__c = this.incidentDate;
        }
        this.createUpdRecord(this.corporateWrapList, this.fetchCaseRecord);
        console.log('this.createUpdRecord', this.createUpdRecord);

        if (this.isCheckAddressFlow == true) {
            this.callAderessFlow = false;
        }

    }


    handleBack() {
        if (this.thirdpage) {
           
            this.thirdpage = false;
            this.corporateTable = false;

            if (this.isdirectApi == false && this.isCorporateSelected == false) {
               
                this.isPolicyCall = true;
                this.secondPage = false;
            } else {
        
                this.thirdPageCash = false;
                this.secondPage = true;
            }
            this.previousScreen = true;
            this.accountNumber = this.accountNumber;
            this.accountName = this.accountName;
            this.value = this.selectedOption;
            this.showNoAccountSelectedMessage = false;
            this.isContinueDisabled = false;
            //this.insuranceAccountName=this.accountName;
            this.accounts.forEach(res => {
                
                if (res.Id == this.selectedAccount.Id) {
                    res.selected = true;
                }
            });
           
        } else if (this.secondPage) {
            
            this.secondPage = false;
            this.firstPage = true;
            this.incidentDate = this.incidentDate;
            this.policyNumberFirstScreen = this.policyNumberFirstScreen;
            this.value = this.selectedOption;
            this.AccountName = this.AccountName;
            this.AccountNumber = this.AccountNumber;
            this.corporateTable = false;

        } else if (this.isPolicyCall) {
           
            this.isPolicyCall = false;
            this.secondPage = true;
            this.thirdpage = false;
            this.previousScreen = true;
            this.accountName = this.accountName;
            this.value = this.selectedOption;
            this.showNoAccountSelectedMessage = false;
            this.isContinueDisabled = false;
            this.policyNumber = '';
            this.replacementExcess = '';
            this.showTable = true;
            this.scriptError = false;
            this.accounts.forEach(res => {
                
                if (res.Id == this.selectedAccount.Id) {
                    res.selected = true;
                }
            });


        } else if (this.firstPage == false) {
            
            this.firstPage = true;
            this.corporateTable = false;
        }
    }

 

    @wire(IsConsoleNavigation) isConsoleNavigation;

    async closeTab() {
        try {
            if (this.isConsoleNavigation) {
                const { tabId } = await getFocusedTabInfo();
                await closeTab(tabId);
                if(this.callDataCollectFlow == true && this.isHandleMotoristScreen == true){
                this.dispatchEvent(new RefreshEvent());
                const flowApiName = 'BLN_CaptureDataCollect';
                this.openModal();

                //Navigate to the flow
                this[NavigationMixin.Navigate]({

                    type:'standard__component',
                    attributes:{
                        componentName: 'c__bln_dataCollectFlow'
                    }
                });
            }}
            
        } catch (error) {
            console.error('Error closing tab:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'There was an error closing the tab.',
                    variant: 'error',
                }),
            );
        }
    }

    connectedCallback() {
        this.caseid = this.recordId;
       

        this.fetchCaseDetails();


        if (this.personaccountID != null) {
            this.callMotoristFlow1 = false;
        }
        if (this.personaccountID != null) {
            this.openmodel = true;
        }


        //this.showCashButton = false;
    }


    fetchCaseDetails() {
       

        fetchPDS({ recordId: this.recordId }).then(result => {
            

            this.fetchCaseRecord = result;
            let responseData = result;


            if (!responseData.BLN_Vehicle__c) {
                this.error = PDSError;
                this.noVehicle = true;
            } else {
                if (!responseData.BLN_VRN__c) {
                    this.disableNextButton = true;

                }
                this.vehicleRegNumber = responseData.BLN_VRN__c;
                this.incidentDate = responseData.CreatedDate;
                if (this.BVTCustom) {

                    this.readOnly = false;
                } else {

                    this.readOnly = true;
                }
                this.caseCreatedDate = responseData.CreatedDate;
                this.vehicleId = responseData.BLN_Vehicle__c;
                this.firstPage = true;
            }

        })
            .catch(error => {
                this.showToast('Error', 'Please try again later', 'Error');
                //console.error('Error fetching case details: ' + JSON.stringify(error));
            });
    }

    
   

    handleChange(event) {
        this.incidentDate = event.detail.value;
       
        if (this.caseCreatedDate >= this.incidentDate) {
            //this.template.querySelector('.incident-date-error').classList.add('slds-hide');
            //if (this.vehicleRegNumber != null) {
            this.disableNextButton = false;
            this.disableManualSearch = false;
            this.incDateError = false;
            //}
        } else {
            //this.template.querySelector('.incident-date-error').classList.remove('slds-hide');
            this.disableNextButton = true;
            this.disableManualSearch = true;
            this.incDateError = true;
        }
    }


    handleClose() {
        if (this.recordId) {
           /* this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Case',
                    actionName: 'view'
                }
            });*/
            this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow', true));
            if (this.availableActions.find((element) => element == 'NEXT')) {
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent)
            }
            else {
                this.dispatchEvent(new FlowNavigationFinishEvent());
            }
        }
      getFocusedTabInfo().then((tabInfo) => {
            closeTab(tabInfo.tabId);
        })
    }


    handleClear() {

        const radioButtons = this.template.querySelectorAll('.checkedradio');

        radioButtons.forEach(button => {
            button.checked = false;
        });
        this.isMotoristPayIns = false;
        this.motoristWantToPay = false;
        this.corporateTable = false;
        this.vatRegistered = false;
        this.responsePostalCode = '';
        this.recordTypeId = '';
        this.nameSalutation = '';
        this.fName = '';
        this.lName = '';
    }

    openmodal() {
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false
        this.viewDetails = false;
    }



    motoristCheckbox(event) {
        this.motoristWantToPay = this.motoristWantToPay == true ? false : true;
        if (this.motoristWantToPay == false) {
            this.vatRegistered = false;
        }

        this.vatRegistered = false;


        if (this.motoristWantToPay == true) {

            this.selectedRow = this.selectedRowCopy;
        }
        else {

            this.selectedRow = [];

            event.preventDefault();
        }
    }


    handleQuestionCheckBox(event) {

        this.isVatResgistered
        if (event.target.name == 'vatRegisterCheck') {
            this.corporateWrapList.forEach(result => {

                if (result.attachToCase == true) {
                    if (event.detail.checked) {
                        result.vatRegFlag = Y;
                    }
                    else {
                        result.vatRegFlag = N;
                    }
                }
            });

         
        }

        if (event.target.name == 'motoristCheckbox') {
            let isGlassCoverInsurance = true;

            if (!event.detail.checked) {
                // this.corporateTable = false;
                this.isQuestionCheck = true;
                this.motoristWantToPay = false;
                this.isMotoristPayIns = false;
                this.fetchCaseRecord.BLN_BillingMethod__c = cash;
                this.corporateWrapList.forEach(result => {
                    result.vatRegFlag = N;
                });

               
                this.corporateWrapList.forEach(element => {
                    if (element.row == this.rowId) {
                        element.attachToCase = false;
                        if(element.glassCoverFlag == 'N'){
                            isGlassCoverInsurance = false;  //added under 11206
                        }

                    }
                });

                const radioButtons = this.template.querySelectorAll('.checkedradio');

                radioButtons.forEach(button => {
                    button.checked = false;
                });

                this.isCheckAddressFlow = true;


            } else {
                this.corporateWrapList.forEach(element => {
                    if (element.row == this.rowId) {
                        if(element.glassCoverFlag == 'N'){
                            isGlassCoverInsurance = false;  //added under 11206
                        }
                       
                    }
                });
                this.isQuestionCheck = false;
                this.isMotoristPayIns = true;
                this.motoristWantToPay = true;
               if(isGlassCoverInsurance == true){ // added under 11206
                this.fetchCaseRecord.BLN_BillingMethod__c = InsuranceAccount;
               }
            }

            this.corporateWrapListCopy.forEach(element => {
                if (element.row == this.rowId) {

                    if (element.vatRegFlag == 'Y') {
                        this.vatRegistered = true;
                    }
                    else {
                        this.vatRegistered = false;
                    }
                }
            });

            

        }
        console.log('fetchCaseRecord',JSON.stringify(this.fetchCaseRecord));
    }

    vatNumberEnter(event) {
        this.vatNumber = event.detail.value;
    }

    navigateToCaseRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }


    showToast(title, detail, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: detail,
                variant: variant,
            })
        );
    }


    closeErrorModal(event) {
        getFocusedTabInfo().then((tabInfo) => {
            closeTab(tabInfo.tabId);
        });
    }

}