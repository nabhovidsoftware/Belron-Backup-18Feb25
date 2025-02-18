/** @description :  This component is used to do an advanced search on vehicle parts based on
 *                  VRN or Vehicle Characteristics.
*  @author:         (binayak.debnath@pwc.com (IN))
*  @story:          FOUK-7858; FOUK-7857; FOUK-7851; FOUK-8516; FOUK-8515; FOUK-7845; FOUK-7859; FOUK-7862; FOUK-9965; FOUK-9966
*/
import { LightningElement, api, track } from 'lwc';
import basePath from '@salesforce/community/basePath';
import LAD_AdvacnedSearchButtonLabel from '@salesforce/label/c.LAD_AdvacnedSearchButtonLabel';
import LAD_AdvacnedSearchTitle from '@salesforce/label/c.LAD_AdvacnedSearchTitle';
import LAD_VRNfieldLabel from '@salesforce/label/c.LAD_VRNfieldLabel';
import LAD_AlphanumericError from '@salesforce/label/c.LAD_AlphanumericError';
import LAD_SearchButtonLabel from '@salesforce/label/c.LAD_SearchButtonLabel';
import LAD_SearchByCharsfieldLabel from '@salesforce/label/c.LAD_SearchByCharsfieldLabel';
import LAD_ContinueButtonLabel from '@salesforce/label/c.LAD_ContinueButtonLabel';
import LAD_VehicleDetailsSuccess from '@salesforce/label/c.LAD_VehicleDetailsSuccess';
import LAD_VehicleDetailsError from '@salesforce/label/c.LAD_VehicleDetailsError';
import LAD_VehicleSchematicsSuccess from '@salesforce/label/c.LAD_VehicleSchematicsSuccess';
import LAD_VehicleSchematicsError from '@salesforce/label/c.LAD_VehicleSchematicsError';
import LAD_ProdQuestionSuccess from '@salesforce/label/c.LAD_ProdQuestionSuccess';
import LAD_ProdQuestionError from '@salesforce/label/c.LAD_ProdQuestionError';
import LAD_GlobalSearchTag from '@salesforce/label/c.LAD_GlobalSearchTag';
import LAD_SelectResponseError from '@salesforce/label/c.LAD_SelectResponseError';

//Search
import VRNSearchEligibility from '@salesforce/apex/LAD_AdvancedSearchAPI.VRNSearchEligibility';
import updateVrnUsage from '@salesforce/apex/LAD_AdvancedSearchAPI.updateVrnUsage';
import fetchByChars from '@salesforce/apex/LAD_FetchVehicleType.fetchByChars';
import callDVLA from '@salesforce/apex/LAD_AdvancedSearchAPI.callDVLA';
import Toast from 'lightning/toast';
//Schematics
import callGPSSchematics from '@salesforce/apex/LAD_AdvancedSearchAPI.callGPSSchematics';
import BLN_BackSchematic from '@salesforce/resourceUrl/BLN_BackSchematic';
import BLN_BackLeft from '@salesforce/resourceUrl/BLN_BackLeft';
import BLN_BackRight from '@salesforce/resourceUrl/BLN_BackRight';
import BLN_Front from '@salesforce/resourceUrl/BLN_Front';
import BLN_FrontLeft from '@salesforce/resourceUrl/BLN_FrontLeft';
import BLN_FrontRight from '@salesforce/resourceUrl/BLN_FrontRight';
import BLN_Left from '@salesforce/resourceUrl/BLN_Left';
import BLN_Right from '@salesforce/resourceUrl/BLN_Right';
import BLN_Top from '@salesforce/resourceUrl/BLN_Top';
import BLN_WhiteBG from '@salesforce/resourceUrl/BLN_WhiteBG';
import repairLabel from '@salesforce/label/c.BLN_RepairQuestions';
import areyousure from '@salesforce/label/c.BLN_AreYouSure';
import display from '@salesforce/label/c.BLN_Display';
import holeType from '@salesforce/label/c.BLN_HoleType';
import holeId from '@salesforce/label/c.BLN_HoleId';
import cancel from '@salesforce/label/c.BLN_Cancel';
import confirm from '@salesforce/label/c.BLN_QuoteConfirm';
import errorMsg from '@salesforce/label/c.BLN_ErrorMsg';
import ErrorOccurred from '@salesforce/label/c.BLN_ErrorOccurred';
import leftLabel from '@salesforce/label/c.BLN_Left';
import rightLabel from '@salesforce/label/c.BLN_Right';
import backLabel from '@salesforce/label/c.BLN_Back';
import frontLabel from '@salesforce/label/c.BLN_Front';
//Product Identification
import callGPSbomId from '@salesforce/apex/LAD_AdvancedSearchAPI.callGPSbomId';
import callGPSanswer from '@salesforce/apex/LAD_AdvancedSearchAPI.callGPSanswer';
import NoProductId from '@salesforce/label/c.BLN_NoProductId';
import AddProductId from '@salesforce/label/c.BLN_AddProductId';
import PIdNote from '@salesforce/label/c.BLN_PIDNote';
import Questions from '@salesforce/label/c.BLN_Questions';
import bomIderrorMsg from '@salesforce/label/c.BLN_GPSBomIdErrorMsg';
import resultLabel from '@salesforce/label/c.BLN_ResultLabel';
import questionLabel from '@salesforce/label/c.BLN_QuestionLabel';
import Id from '@salesforce/user/Id';
//FOUK-9965 & FOUK-9966: Search Record
import InternalPortal from '@salesforce/customPermission/LAD_Laddaw_Internal_Portal';
import insertSearchRecord from '@salesforce/apex/LAD_AdvancedSearchAPI.insertSearchRecord';
import getAccId from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import { effectiveAccount } from 'commerce/effectiveAccountApi';



export default class Lad_AdvancedSearch extends LightningElement {

    isLoading = false;

    accountId;

    LAD_labels = {
        LAD_VehicleDetailsSuccess,
        LAD_VehicleDetailsError,
        LAD_VehicleSchematicsSuccess,
        LAD_VehicleSchematicsError,
        LAD_ProdQuestionSuccess,
        LAD_ProdQuestionError,
        LAD_GlobalSearchTag,
        LAD_SelectResponseError,
        LAD_AdvacnedSearchButtonLabel,
        LAD_AdvacnedSearchTitle,
        LAD_VRNfieldLabel,
        LAD_AlphanumericError,
        LAD_SearchButtonLabel,
        LAD_SearchByCharsfieldLabel,
        LAD_ContinueButtonLabel
    }

    //Search
    showSearchScreen = true;

    showModal = false;
    vehicleList = [];
    makeList = [];
    modelList = [];
    bodyList = [];
    yearList = [];
    makeValue;
    modelValue;
    bodyValue;
    yearValue;
    makeDisabled = false;
    modelDisabled = true;
    bodyDisabled = true;
    yearDisabled = true;
    disableCharSearch = true;
    vrnValue;
    disableVRNSearch = true;

    //Schematics
    vehicleImage = '';
    showSchematicsScreen = false;
    label = {
        repairLabel,
        holeType,
        display,
        areyousure,
        holeId,
        cancel,
        confirm,
        ErrorOccurred,
        leftLabel,
        rightLabel,
        backLabel,
        frontLabel,
        errorMsg,
        NoProductId,
        AddProductId,
        PIdNote,
        Questions,
        bomIderrorMsg,
        resultLabel,
        questionLabel
    }



    visibleInfoPopup = false;
    selctedVehicalHoleId;
    transactionId;
    selectedVehicalHoleType;
    selectedDisplayType;
    modalContent;
    cellKey;
    disableSchematicsContinue = true;

    BACK = BLN_BackSchematic;
    BACK_LEFT = BLN_BackLeft;
    BACK_RIGHT = BLN_BackRight;
    FRONT = BLN_Front;
    FRONT_LEFT = BLN_FrontLeft;
    FRONT_RIGHT = BLN_FrontRight;
    LEFT = BLN_Left;
    RIGHT = BLN_Right;
    TOP = BLN_Top;
    WhiteBG = BLN_WhiteBG;

    schematicImgMap = new Map([
        ["BACK", this.BACK],
        ["BACK_LEFT", this.BACK_LEFT],
        ["BACK_RIGHT", this.BACK_RIGHT],
        ["FRONT", this.FRONT],
        ["FRONT_LEFT", this.FRONT_LEFT],
        ["FRONT_RIGHT", this.FRONT_RIGHT],
        ["LEFT", this.LEFT],
        ["RIGHT", this.RIGHT],
        ["TOP", this.TOP],
        ["BACKGROUND", this.WhiteBG],
    ]);

    @track VehicleHoleId = [];
    @track glassImageMapping = [];

    //Product Identification
    showProductIdScreen = false;
    disableQuestionContinue = true;
    get radioOptions() {
        return [
            { label: "Yes", value: "true" },
            { label: "No", value: "false" },
            { label: "Don't Know/Not Sure", value: 'null' }
        ]
    }
    question_transactionId;
    question_statement;
    question_response;



    userId = Id;
    disableVRN = true;
    vrnLimit;
    vrnUsage;

    get internalUser() {
        return InternalPortal;
    }

    connectedCallback() {
        getAccId({ userid: this.userId })
            .then(result => {
                if (result) {
                    this.accountId = result;
                }
                if (effectiveAccount.accountId !== null && effectiveAccount.accountId !== undefined) {
                    this.accountId = effectiveAccount.accountId;
                    console.log('SWITCHED ACCOUNT ', this.accountId);
                }
                this.fetchVehicleTypes();

                setTimeout(this.fetchViability(), 1000);
            })
            .catch(error => {
                console.error('ERROR IN FETCHING ACCOUNT ID ', error);
            })



    }

    fetchViability() {
        console.log('userId', this.userId);
        VRNSearchEligibility({ accountId: this.accountId })
            .then(result => {
                console.log('test', result, this.userId);
                const { disableVRN, vrnLimit, vrnUsage } = result;
                if (disableVRN == false) {
                    this.disableVRN = false;
                }
                console.log(vrnLimit, vrnUsage);
                this.vrnLimit = vrnLimit != undefined ? vrnLimit : Number.MAX_VALUE;
                this.vrnUsage = vrnUsage != undefined ? vrnUsage : 0;
                console.log(this.vrnLimit, this.vrnUsage);


            })
            .catch(error => {
                console.log(error, this.userId);
                console.log('userId', this.userId);

            })
    }

    fetchVehicleTypes() {
        fetchByChars({})
            .then(result => {
                console.log(JSON.stringify(result));
                this.vehicleList = JSON.parse(JSON.stringify(result));

                for (let obj of this.vehicleList) {
                    if (obj.make) {
                        let option = {
                            label: obj.make,
                            value: obj.make
                        }
                        this.makeList.push(option);
                    }
                }
                this.makeList = this.removeDuplicates(this.makeList);
                console.log(JSON.stringify(this.modelList));
            })
    }

    handleShowModal() {
        this.showModal = true;
    }
    handleCloseModal() {
        this.showModal = false;
        this.bodyDisabled = true;
        this.yearDisabled = true;
        this.modelDisabled = true;
        this.bodyValue = null;
        this.yearValue = null;
        this.makeValue = null;
        this.modelValue = null;
        this.modelList = [];
        this.bodyList = [];
        this.yearList = [];
        this.disableCharSearch = true;
        this.disableVRNSearch = true;

        this.vrnValue = null;

        this.showSchematicsScreen = false;
        this.showSearchScreen = true;

        this.visibleInfoPopup = false;
        this.cellKey = null;
        this.selctedVehicalHoleId = null;
        this.selectedDisplayType = null;
        this.selctedVehicalHoleId = null;
        this.vehicleHoleId = null;
        this.transactionId = null;

        this.glassImageMapping = [];
        this.VehicleHoleId = [];

        this.showProductIdScreen = false;
        this.question_transactionId = null;
        this.question_statement = null;
        this.question_response = null;
    }

    handleVRNChange(event) {
        const alphaNumeric = /^[a-zA-Z0-9]+$/;
        this.vrnValue = (event.target.value).toUpperCase();
        console.log(this.vrnValue)
        if (this.vrnValue && alphaNumeric.test(this.vrnValue)) {
            this.disableVRNSearch = false;
        }
        else {
            this.disableVRNSearch = true;
        }
    }

    handleMakeChange(event) {
        //Destroy Prior values and options
        this.bodyDisabled = true;
        this.yearDisabled = true;
        this.bodyValue = null;
        this.yearValue = null;
        this.modelValue = null;
        this.modelList = [];
        this.bodyList = [];
        this.yearList = [];
        this.disableCharSearch = true;

        this.makeValue = event.target.value;

        for (let obj of this.vehicleList) {
            if (obj.make === event.target.value && obj.model) {
                let option = {
                    label: obj.model,
                    value: obj.model
                }
                this.modelList = [...this.modelList, option];
            }
        }
        this.modelList = this.removeDuplicates(this.modelList);

        this.modelDisabled = false;
    }

    handleModelChange(event) {
        this.modelValue = event.target.value;
        for (let obj of this.vehicleList) {
            if (obj.model == event.target.value && obj.body) {
                let option = {
                    label: obj.body,
                    value: obj.body
                }
                this.bodyList = [...this.bodyList, option];
            }
        }
        this.bodyList = this.removeDuplicates(this.bodyList);

        this.bodyDisabled = false;
    }
    handleBodyChange(event) {
        this.bodyValue = event.target.value;
        for (let obj of this.vehicleList) {
            if (obj.body == event.target.value && obj.year) {
                let option = {
                    label: `${obj.year}`,
                    value: `${obj.year}`
                }
                this.yearList = [...this.yearList, option];
            }
        }
        this.yearList = this.removeDuplicates(this.yearList);

        this.yearDisabled = false;
    }

    handleYearChange(event) {
        this.yearValue = event.target.value;
        this.disableCharSearch = false;
    }

    removeDuplicates(array) {
        const unique = new Set();
        return array.filter(item => {
            if (unique.has(item.value)) {
                return false;
            }
            else {
                unique.add(item.value);
                return true;
            }
        })
    }

    async handleSearchVRN() {
        //FOUK-9965 & FOUK-9966
        let object = {
            userId: this.userId,
            accountId: this.accountId,
            recordType: 'LAD_DVLA_Search',
            isInternal: this.internalUser
        }
        insertSearchRecord({ paramsList: [object] });
        this.isLoading = true;
        const response = await VRNSearchEligibility()
        console.log(this.vrnUsage, this.vrnLimit);
        if (this.vrnUsage < this.vrnLimit) {
            callDVLA({ inputText: this.vrnValue })
                .then(result => {

                    this.handleUpdateVRNUsage();



                console.log(JSON.stringify(result));
                if (Object.keys(result[0]).includes('Error')) {
                    Toast.show({
                        label: 'Error',
                        message: result[0].Error,
                        mode: 'dismissible',
                        variant: 'error'
                    }, this);

                    this.isLoading = false;

                }
                else {
                    Toast.show({
                        label: 'Success',
                        message: this.LAD_labels.LAD_VehicleDetailsSuccess,
                        mode: 'dismissible',
                        variant: 'success'
                    }, this);

                    let vehicleDetails = JSON.parse(JSON.stringify(result));
                    this.handleSchematicsFromGPS(vehicleDetails);
                }
            }).catch(error => {
                console.log('CATCH----> ', error);
                this.isLoading = false;
                Toast.show({
                    label: 'Error',
                    message: error.body.message,
                    mode: 'dismissible',
                    variant: 'error'
                }, this);
            });
    }
        else {
            this.isLoading = false;
            Toast.show({
                label: 'Error',
                message: 'You have exceeded your VRN search monthly usage limit. Please contact the Hub to discuss.',
                mode: 'dismissible',
                variant: 'error'
            }, this);
        }
    }

    handleUpdateVRNUsage() {
        updateVrnUsage({ accountId: this.accountId })
            .then(result => {
                if (result) {
                    this.vrnUsage = result;
                }
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleSearchVehicleChar() {
        //FOUK-9965 & FOUK-9966
        let object = {
            userId: this.userId,
            recordType: 'LAD_Vehicle_Characteristics_Search',
            isInternal: this.internalUser
        }
        insertSearchRecord({ paramsList: [object] });
        this.isLoading = true;
        let vehicleDetails = [];
        let obj = {
            Make: this.makeValue,
            Model: this.modelValue,
            BodyType: this.bodyValue,
            Year: this.yearValue
        }

        vehicleDetails.push(obj);
        this.handleSchematicsFromGPS(vehicleDetails);
    }

    //Schematics from GPS Section 
    handleSchematicsFromGPS(vehicleDetails) {
        console.log('VEHICLE DETAILS--->', vehicleDetails);
        callGPSSchematics({
            make: vehicleDetails[0].Make,
            model: vehicleDetails[0].Model,
            bodyType: vehicleDetails[0].BodyType,
            year: vehicleDetails[0].Year,
            vin: vehicleDetails[0].Vin ?? null,
        })
            .then(result => {


                console.log('SCHEMATICS', JSON.stringify(result));
                if (result) {
                    Toast.show({
                        label: 'Success',
                        message: this.LAD_labels.LAD_VehicleSchematicsSuccess,
                        mode: 'dismissible',
                        variant: 'success'
                    }, this);

                    this.handleSchematicData(result);
                }
                else {

                    this.isLoading = false;
                    Toast.show({
                        label: 'Error',
                        message: this.LAD_labels.LAD_VehicleSchematicsError,
                        mode: 'dismissible',
                        variant: 'error'
                    }, this);
                }

            })
            .catch(error => {
                this.isLoading = false;
                Toast.show({
                    label: 'Error',
                    message: error.body.message,
                    mode: 'dismissible',
                    variant: 'error'
                }, this);
            })
    }

    handleSchematicData(result) {
        console.log('RESULT', result);
        let parsedResult = {};
        parsedResult = JSON.parse(result);
        console.log('parsedResult54321', parsedResult);


        let data = parsedResult?.hoverMap;
        this.vehicleImage = parsedResult?.vehicleImage;
        console.log('tarzenTheCar321', this.vehicleImage);
        this.transactionId = data[0][0].transactionId;
        console.log('transaction id new', this.transactionId);


        for (let keyVal in data) {
            let innerList = [];
            for (let innerKeyVal in data[keyVal]) {
                innerList.push({
                    key: innerKeyVal,
                    cellIndex: innerKeyVal + keyVal + data[keyVal][innerKeyVal].vhid,
                    displayTypeImg: this.schematicImgMap.get(data[keyVal][innerKeyVal].displayType),
                    vehicalId: data[keyVal][innerKeyVal].vhid != 0 ? data[keyVal][innerKeyVal].vhid : '',
                    vehicalType: data[keyVal][innerKeyVal].vtype != "BACKGROUND" ? data[keyVal][innerKeyVal].vtype : '',
                    displayType: data[keyVal][innerKeyVal].displayType,
                    highlightStatus: "no-highlight",
                });

                if (data[keyVal][innerKeyVal].vhid != 0) {
                    this.VehicleHoleId.push(data[keyVal][innerKeyVal].vhid);
                }
            }
            this.glassImageMapping.push({ key: keyVal, value: innerList });
        }
        console.log('GLASSIMGMAPPING--->', JSON.stringify(this.glassImageMapping));

        this.showSearchScreen = false;
        this.showSchematicsScreen = true;

        window.setTimeout(() => {
            this.isLoading = false;

        }, 2000);

    }

    get getBackgroundImage() {

        if (this.vehicleImage != '') {
            return `background-repeat:no-repeat;background-size:contain;background-image:url("${this.vehicleImage}")`;
        }
    }

    closeModal() {
        this.visibleInfoPopup = false;
        this.cellKey = null;
        this.selctedVehicalHoleId = null;
        this.selectedDisplayType = null;
        this.selctedVehicalHoleId = null;
        this.vehicleHoleId = null;
        this.disableSchematicsContinue = true;
    }

    highlightSet(highlightStatus) {
        this.disableSchematicsContinue = highlightStatus == 'yes-highlight' ? false : true;
        this.glassImageMapping.forEach(outerRows => {
            outerRows.value.forEach(innerElements => {
                innerElements.highlightStatus = innerElements.cellIndex == this.cellKey ? highlightStatus : "no-highlight";
            })
        })
    }

    showInfoPopup(event) {
        let statusFlag = this.cellKey === event.target.dataset.cellkey ? true : false;
        this.cellKey = event.target.dataset.cellkey;
        this.selectedDisplayType = event.target.dataset.displaytype;
        this.selectedVehicalHoleType = event.target.dataset.vehicaltype;
        this.selctedVehicalHoleId = event.target.dataset.vehicalid;
        this.visibleInfoPopup = this.selctedVehicalHoleId != null && this.selctedVehicalHoleId != undefined && this.selctedVehicalHoleId != 0 && this.selctedVehicalHoleId != "0" && !statusFlag ? true : false;
        this.modalContent = `${this.label.areyousure} \n ${this.label.holeId} ${this.selctedVehicalHoleId} / ${this.label.display} ${this.selectedDisplayType} / ${this.label.holeType} ${this.selectedVehicalHoleType}`;
        this.holetype = event.target.dataset.vehicaltype;

        if (statusFlag) {
            this.closeModal();
            this.highlightSet("no-highlight");
        }
    }

    modalConfirmAction() {
        this.vehicleHoleId = this.selctedVehicalHoleId;
        this.highlightSet("yes-highlight");
        this.visibleInfoPopup = false;

        console.log('DETAILS----> ', this.vehicleHoleId, this.transactionId);
    }

    handleContinueFromSchematics() {
        this.isLoading = true;

        let innerList = [this.transactionId, this.vehicleHoleId];
        let outerList = [innerList];
        console.log(JSON.stringify(outerList));
        callGPSbomId({ listOfBom: outerList })
            .then(result => {
                this.isLoading = false;
                console.log('BOM ID--->', JSON.stringify(result));
                if (result?.length > 0) {
                    let data = result[0];

                    if (data.includes(this.label.questionLabel)) {
                        this.showSchematicsScreen = false;
                        this.showProductIdScreen = true;
                    Toast.show({
                        label: 'Success',
                        message: this.LAD_labels.LAD_ProdQuestionSuccess,
                        mode: 'dismissible',
                        variant: 'success'
                    }, this);

                        this.question_transactionId = data[0];
                        this.question_statement = data[2];
                    }
                    else if (data.includes(this.label.resultLabel)) {
                        console.log('FINAL--->', JSON.stringify(data));
                        let searchTag = basePath + this.LAD_labels.LAD_GlobalSearchTag;

                        for (let i = 1; i < data.length; i++) {
                            searchTag += i == 1 ? data[i] : `&${data[i]}`;
                        }

                        let redirectUrl = window.location.host + searchTag;
                        console.log(redirectUrl);
                        location.replace(searchTag);
                    }
                }
                else {
                    Toast.show({
                        label: 'Error',
                        message: this.LAD_labels.LAD_ProdQuestionError,
                        mode: 'dismissible',
                        variant: 'error'
                    }, this);
                    this.handleCloseModal();
                }

            })
            .catch(error => {
                this.isLoading = false;
                Toast.show({
                    label: 'Error',
                    message: error.body.message,
                    mode: 'dismissible',
                    variant: 'error'
                }, this);
                this.handleCloseModal();
            })
    }

    storeResponse(event) {
        this.question_response = event.detail.value;
        this.disableQuestionContinue = false;
        console.log("TRN ID-->", this.question_transactionId);
        console.log("Q--->", this.question_response);
    }

    continueAction() {
        console.log("-----------CONTINUE---------");
        this.disableQuestionContinue = true;
        this.isLoading = true;
        this.answersApiCallback(this.question_response, this.question_transactionId);
    }

    /*  cancelAction() {
         console.log("---------------Cancel------------");
         this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow', true));
         this.dispatchEvent(new FlowNavigationNextEvent());
     } */

    answersApiCallback(answer, transactionId) {
        console.log("Ans-->", answer);
        console.log("TRN-->", transactionId);
        if (answer != undefined && transactionId != undefined) {
            callGPSanswer({ ans: answer, transId: transactionId })
                .then(data => {
                    this.isLoading = false;
                    console.log(JSON.stringify(data));
                    if (data.length <= 1) {
                        Toast.show({
                            label: 'Error',
                            message: 'No Products found',
                            mode: 'dismissible',
                            variant: 'error'
                        }, this);
                        this.handleCloseModal();
                    }
                    console.log("RESPONSE", data[0]);

                    if (data[0] == this.label.resultLabel) {
                        console.log('FINAL--->', JSON.stringify(data));
                        let searchTag = basePath + this.LAD_labels.LAD_GlobalSearchTag;

                        for (let i = 1; i < data.length; i++) {
                            searchTag += i == 1 ? data[i] : `&${data[i]}`;
                        }

                        let redirectUrl = window.location.host + searchTag;
                        console.log(redirectUrl);
                        location.replace(searchTag);
                    }
                    else {
                        this.question_transactionId = data[1];
                        this.question_statement = data[2];
                        this.question_response = null;
                        this.isLoading = false;
                    }
                })
                .catch(error => {
                    Toast.show({
                        label: 'Error',
                        message: error,
                        mode: 'dismissible',
                        variant: 'error'
                    }, this);
                })
        } else {
            this.isLoading = false;
            Toast.show({
                label: 'Error',
                message: this.LAD_labels.LAD_SelectResponseError,
                mode: 'dismissible',
                variant: 'error'
            }, this);
        }
    }
}