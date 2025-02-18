/** @description :  This component is used to show return items on portal and create a return order based on user input
*   @Story :        FOUK-9948; FOUK-9903; FOUK-9893; FOUK-9259; FOUK-9256; FOUK-10184; FOUK-9897; FOUK-10185
*   @author:        (ashwin.r.raja@pwc.com (IN))
*   @CreatedDate:   08/10/2024
*/

import { LightningElement, api, track, wire } from 'lwc';
import getOrderItems from '@salesforce/apex/LAD_ReturnOrderHandler.getOrderItems';
import createReturnCase from '@salesforce/apex/LAD_ReturnOrderHandler.createReturnCase';
import createReturnOrder from '@salesforce/apex/LAD_ReturnOrderHandler.createReturnOrder';
import getUserInfo from '@salesforce/apex/LAD_ReturnOrderHandler.getUserInfo';
import checkReturnPeriod from '@salesforce/apex/LAD_ReturnOrderHandler.checkReturnPeriod';
import Id from '@salesforce/user/Id';
import returnOverridePermission from '@salesforce/customPermission/LAD_Return_Override_Permission';
import InternalPortal from '@salesforce/customPermission/LAD_Laddaw_Internal_Portal';
import removeDateFormat from '@salesforce/resourceUrl/RemoveDateFormatStyle';
import { loadStyle } from 'lightning/platformResourceLoader';
import returnReason from "@salesforce/schema/LAD_Return_Item__c.LAD_Return_Reason__c";
import returnMethod from "@salesforce/schema/LAD_Return_Item__c.LAD_Return_Method__c";
import returnOverride from "@salesforce/schema/LAD_Return_Item__c.LAD_ReturnOverrideReason__c";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import getAccId from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import returnItem from '@salesforce/schema/LAD_Return_Item__c';
import Toast from 'lightning/toast';

export default class Lad_ReturnItems extends LightningElement {
    @api orderId;
    @track isLoading = false;
    @track selectedRecords;
    @track accountId;
    @api userId = Id;
    @track orderItems = [];
    @track order =[];
    @track selectedRecords = [];
    @track reason;
    @track method;
    @track overrideReason
    @track recordtypeId;
    @track returnMethod ='';
    @track returnAddress='';
    @track returnDate;
    @track returnReason='';

    addressOptions = [];
    showModal = false;
    overrideReasonScreen = false
    nonReturnable = true;
    showUserInfo = false;
    showOrderItems = false;
    showModal = false;
    selectAllVariant = 'base';
    selectAllName = 'utility:add';
    userInfo = [];


    @wire(getObjectInfo, { objectApiName: returnItem })
    objectInfo({ error, data }) {
        if (data) {
            console.log('object data' + JSON.stringify(data));
            this.recordtypeId = data.defaultRecordTypeId;
        } else if (error) {
            console.log('object error' + JSON.stringify(error));
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordtypeId', fieldApiName: returnReason })
    returnReason({ error, data }) {
        this.reason = undefined;
        if (data) {
            console.log('fetchpicklistdata1' + JSON.stringify(data));
            this.reason = data.values;
        } else if (error) {
            console.log('in picklist fetch error 1' + JSON.stringify(error));
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordtypeId', fieldApiName: returnMethod })
    returnMethod({ error, data }) {
        this.method = undefined;
        if (data) {
            console.log('fetchpicklistdata2' + JSON.stringify(data));
            this.method = data.values;
        } else if (error) {
            console.log('in picklist fetch error 2' + JSON.stringify(error));
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordtypeId', fieldApiName: returnOverride})
    returnOverride({ error, data }) {
        this.overrideReason = undefined;
        if (data) {
            console.log('fetchpicklistdata3' + JSON.stringify(data));
            this.overrideReason = data.values;
        } else if (error) {
            console.log('in picklist fetch error 3' + JSON.stringify(error));
        }
    }

    get returnPeriodOverride() {
        return returnOverridePermission && InternalPortal && this.userInfo.role!='MDC User';
    }

    renderedCallback() {
        Promise.all([
            loadStyle(this, removeDateFormat) //specified filename
        ]).then(() => {
            window.console.log('Files loaded.');
        }).catch(error => {
            window.console.log("Error " + error.body.message);
        });
    }

    connectedCallback() {
        getAccId({ userid: Id })
            .then(result => {
                this.accountId = result;
                console.log("account id=" + result);
                console.log("userId>>" + this.userId);
                this.getRecords();
            })
            .catch(error => {
                console.log(error);
            })
    }

    getRecords() {
        let variable = effectiveAccount.accountId != null & effectiveAccount.accountId != undefined ? effectiveAccount.accountId : this.accountId;
        getUserInfo({ userId: Id, accountId: variable })
            .then(result => {
                this.userInfo = JSON.parse(JSON.stringify(result));
                console.log('userInfo>>' + JSON.stringify(this.userInfo));
            }
            )
        getOrderItems({ orderId: this.orderId })
            .then(result => {
                console.log('orderitemslist from apex>>>' + JSON.stringify(result.returnOrderItems));
                this.nonReturnable = result.nonReturnable;
                console.log('nonReturnable>>' + this.nonReturnable);
                this.isLoading = false;
                this.orderItems = JSON.parse(JSON.stringify(result.returnOrderItems));
                this.order = JSON.parse(JSON.stringify(result));

                this.orderItems.forEach(i => {
                    //i.quantityReturned = i.quantity;
                    i.reasonClass = 'reason-' + i.Id;
                    i.dateClass = 'date-' + i.Id;
                    i.methodClass = 'method-' + i.Id;
                    i.addressClass = 'address-' + i.Id;
                    i.quantityClass = 'quantity-'+ i.Id;
                    i.returnOverrideReason = '';
                    i.returnComment = '';
                    if (i.nonReturnable === true) {
                        i.isDisabled = true;
                        i.background = 'background-color: #e5e5e5;';
                        i.buttonVariant = 'base';
                        i.iconName = 'utility:close';
                    }
                    else {
                        i.isDisabled = false;
                        i.background = 'background-color: white;';
                        i.buttonVariant = 'base';
                        i.iconName = 'utility:add';
                        i.addressOptions = [];
                    }
                })
                console.log('order items>>' + JSON.stringify(this.orderItems));
            }).catch(error => {
                this.isLoading = false;
                console.log("in error" + JSON.stringify(error));
            })
    }

    openModal() {
        this.showModal = true;
        this.overrideReasonScreen = false;
        this.showUserInfo = true;
        this.showOrderItems = false;
    }

    closeModal() {
        this.orderItems.forEach(item=> {
            if(item.nonReturnable===false){
                item.buttonVariant = 'base';
                item.iconName = 'utility:add';
                item.returnAddress ='';
                item.returnDate = '';
                item.addressOptions = '';
                item.returnMethod = '';
            }
        })
        this.selectAllVariant = 'base';
        this.selectAllName = 'utility:add';
        this.showModal = false;
        this.overrideReasonScreen = false;
        this.showUserInfo = false;
        this.showOrderItems = false;
    }

    nextScreen() {
        this.overrideReasonScreen = false;
        this.showUserInfo = false;
        this.showOrderItems = true;
    }

    handleSelectIcon(event) {
        console.log(event.target.dataset.id);
        this.orderItems.forEach(i => {
            if (i.isDisabled != true && i.Id == event.target.dataset.id) {
                i.buttonVariant = i.buttonVariant == 'base' ? 'brand' : 'base';
                i.iconName = i.buttonVariant == 'brand' ? 'utility:check' : 'utility:add';
            }
            return i;
        })

    }

    handleSelectAll() {
        let areAllSelected = this.selectAllVariant == 'base' ? true : false;
        this.selectAllVariant = areAllSelected == true ? 'brand' : 'base';
        this.selectAllName = areAllSelected == true ? 'utility:check' : 'utility:add';
        console.log('areAllSelected>>', areAllSelected, this.selectAllVariant, this.selectAllName);

        console.log(this.selectAllVariant);
        this.orderItems.forEach(i => {
            if (i.isDisabled != true) {
                i.buttonVariant = this.selectAllVariant;
                i.iconName = i.buttonVariant == 'brand' ? 'utility:check' : 'utility:add';

            }
            return i;
        })
        console.log(JSON.stringify(this.orderItems));

    }
    
    handleMassReturnReason(event){
        this.returnReason = event.detail.value;
        console.log('return Reason>>', this.returnReason);
    }
    handleMassDate(event){
        this.returnDate = event.detail.value;
        console.log('return Reason>>', this.returnDate);
    }
    handleMassReturnMethod(event){
        this.returnMethod = event.detail.value;
        if (event.detail.value == 'Laddaw Collect') {
            this.addressOptions = [];
            for (let key in this.order.laddawCollectAddress) {
                this.addressOptions.push({ label: this.order.laddawCollectAddress[key], value: key });
            }
            console.log('addressOptions>>' + JSON.stringify(this.addressOptions));
            if(this.addressOptions.length==0){
                Toast.show({
                    label: 'Warning',

                    message: 'No address options available for Laddaw collect',
                    mode: 'dismissible',
                    variant: 'warning'
                }, this);
            }
        }
        else{
            this.addressOptions = [];
        }
        console.log('return Reason>>', this.returnMethod);
    }

    handleMassAddress(event){
        this.returnAddress = event.detail.value;
        console.log('return Address>>', this.returnAddress);
    }

    handleMassAction(){
        console.log('inside mass action');
        this.orderItems.forEach(i => {
            if(i.buttonVariant==='brand'){
                i.returnDate = this.returnDate;
                i.returnMethod = this.returnMethod;
                if(i.returnMethod=='Laddaw Collect'){
                    i.addressOptions = this.addressOptions;
                }
                else{
                    i.addressOptions = [];
                    i.returnAddress = '';
                    for (let key in i.returnAddressList) {
                        i.addressOptions.push({ label: i.returnAddressList[key], value: key });
                    }
                }
                i.returnAddress = this.returnAddress;
                i.returnReason = this.returnReason;
            }
            return i;
        })
        console.log('order Items from mass action>>>', JSON.stringify(this.orderItems));
    }

    handleReturnReason(event) {
        let record = event.target.dataset.id;
        this.orderItems.forEach(i => {
            if (i.Id == record) {
                i.returnReason = event.detail.value;
            }
            return i;
        })
    }

    handleDate(event) {
        let record = event.target.dataset.id;
        this.orderItems.forEach(i => {
            if (i.Id == record) {
                i.returnDate = event.detail.value;

            }
            return i;
        })
    }

    handleQuantity(event) {
        let record = event.target.dataset.id;
        this.orderItems.forEach(i => {
        if (i.Id == record) {
            i.quantityReturned = event.detail.value;
        }
        return i;
        })
    }
    
    handleReturnMethod(event) {
        let record = event.target.dataset.id;
        console.log('return method>>' + event.detail.value);
        this.orderItems.forEach(i => {
            if (i.Id == record) {
                i.returnMethod = event.detail.value;

                if (event.detail.value == 'Laddaw Collect') {
                    i.addressOptions = [];
                    i.returnAddress = '';
                    for (let key in this.order.laddawCollectAddress) {
                        i.addressOptions.push({ label: this.order.laddawCollectAddress[key], value: key });
                    }
                    console.log('addressOptions>>' + JSON.stringify(i.addressOptions));

                    if(i.addressOptions.length==0){
                        Toast.show({
                            label: 'Warning',
        
                            message: 'No address options available for Laddaw collect',
                            mode: 'dismissible',
                            variant: 'warning'
                        }, this);
                    }
                }
                else if (event.detail.value != 'Laddaw Collect') {
                    i.addressOptions = [];
                    i.returnAddress = '';
                    for (let key in i.returnAddressList) {
                        i.addressOptions.push({ label: i.returnAddressList[key], value: key });
                    }
                    console.log('addressOptions>>' + JSON.stringify(i.addressOptions));
                }
            }
            return i;
        })
    }

    setSelectedRecords() {
        this.selectedRecords = [];
        console.log('updated orderitems>>' + JSON.stringify(this.orderItems));
        this.orderItems.forEach(i => {
            if (i.iconName == 'utility:check') {
                let temp = {
                    Id: i.Id,
                    productName: i.productName,
                    productId: i.productId,
                    quantity: i.quantity,
                    returnReason: i.returnReason,
                    returnDate: i.returnDate,
                    quantity: i.quantity,
                    quantityReturned: i.quantityReturned,
                    quantityReturnable: i.quantityReturnable,
                    returnMethod: i.returnMethod,
                    returnAddress: i.returnAddress,
                    returnOverrideReason: i.returnOverrideReason,
                    returnComment: i.returnComment,
                };
                this.selectedRecords.push(temp);
            }
        });
    }

    handleReturnAddress(event) {
        let record = event.target.dataset.id;
        this.orderItems.forEach(i => {
            if (i.Id == record) {
                i.returnAddress = event.detail.value;
            }
            return i;
        })
    }

    handleOverrideReason(event) {
        let record = event.target.dataset.id;
        this.selectedRecords.forEach(i => {
            if (i.Id == record) {
                i.returnOverrideReason = event.detail.value;
            }
            return i;
        })
    }

    handleComment(event){
        let record = event.target.dataset.id;
        this.selectedRecords.forEach(i => {
            if (i.Id == record) {
                i.returnComment = event.detail.value;
            }
            return i;
        })
    }

    async handleValidation() {
        console.log(this.orderItems);
        let pastDate = false;
        let dateValidation = [];
        this.orderItems.forEach(i => {
            let validateReason = this.template.querySelector("." + i.reasonClass);
            let validateDate = this.template.querySelector("." + i.dateClass);
            let validateQuantity = this.template.querySelector("." + i.quantityClass);
            let validateMethod = this.template.querySelector("." + i.methodClass);
            let validateAddress = this.template.querySelector("." + i.addressClass);
            validateReason.setCustomValidity("");
            validateDate.setCustomValidity("");
            validateMethod.setCustomValidity("");
            validateAddress.setCustomValidity("");
            validateQuantity.reportValidity("");
            validateReason.reportValidity();
            validateDate.reportValidity();
            validateMethod.reportValidity();
            validateAddress.reportValidity();
            validateQuantity.reportValidity();
            i.validEntry = 0;

            if (i.buttonVariant === 'brand') {
                if (!validateReason.value) {
                    validateReason.setCustomValidity("Please provide a reason for return");
                    i.validEntry = 0;
                }
                else {
                    validateReason.setCustomValidity("");
                    i.validEntry++;
                }
                validateReason.reportValidity();

                
                if (!validateDate.value) {
                    validateDate.setCustomValidity("Please provide a return Date");
                    i.validEntry = 0;
                }
                else {
                    validateDate.setCustomValidity("");
                    i.validEntry++;
                }
                validateDate.reportValidity();

                if (validateQuantity.value>i.quantityReturnable) {
                    validateQuantity.setCustomValidity("The quantity returned should be less than or equal to the quantity available to return");
                    i.validEntry = 0;
                }
                else if(validateQuantity.value<=0 || !validateQuantity.value || validateQuantity.value%1 != 0){
                    validateQuantity.setCustomValidity("Please enter a valid quantity to return");
                    i.validEntry = 0;
                }
                else {
                    validateQuantity.setCustomValidity("");
                    i.validEntry++;
                }
                validateQuantity.reportValidity();

                if (!validateMethod.value) {
                    validateMethod.setCustomValidity("Please provide a return method");
                    i.validEntry = 0;
                }
                else {
                    validateMethod.setCustomValidity("");
                    i.validEntry++;
                }
                validateMethod.reportValidity();

                
                if (!validateAddress.value) {
                    validateAddress.setCustomValidity("Please provide a return address");
                    i.validEntry = 0;
                }
                else {
                    validateAddress.setCustomValidity("");
                    i.validEntry++;
                }
                validateAddress.reportValidity();

                dateValidation.push({
                    returnReason: i.returnReason,
                    returnDate: i.returnDate,
                    invoiceDate: i.invoiceDate,
                    key: i.dateClass,
                    validDate: 0,
                })
            }
            console.log('valid inside loop>>', i.validEntry);
        })

        console.log('datelist>>>', dateValidation);
        
        const response = await checkReturnPeriod({ dateList: dateValidation, orderId: this.orderId });
        if (response) {
            response.forEach(i => {
                let Date = this.template.querySelector("." + i.key);
                let wrongDate = i.validDate;
                console.log('in here');
                console.log('key:', i.key, ' wrongDate>>', wrongDate);
                if (wrongDate === 1) {
                    console.log('inside date more than 21');
                    Date.setCustomValidity("Past the return period for the provided reason");
                }
                else if (wrongDate === 2) {
                    console.log('inside less than invoice date');
                    Date.setCustomValidity("Return Date should be ahead of Invoiced Date");
                }
                else if (wrongDate === 0) {
                    console.log('inside true');
                    Date.setCustomValidity("");
                }
                Date.reportValidity();
            })
        }

        this.selectedRecords = [];
       
        console.log('response from apex>>', response);
        this.orderItems.forEach(i => {
            if(i.buttonVariant==='brand'){
                let search = response.filter(item => item.key === i.dateClass);
                if (search[0].validDate === 1) {
                    console.log('inside past return');
                    i.validDate = false;
                    pastDate = true;
                    i.validEntry++;
                }
                else if (search[0].validDate === 2) {
                    console.log('in valid date 2');
                    i.validEntry = 0;
                }
                else{
                    console.log('inside else');
                    i.validDate = true;
                    i.validEntry++;
                }
                this.selectedRecords.push(i);
            }
        })

        console.log('length of selected records>>>', this.selectedRecords.length);
        console.log('selected records from validation>>>', JSON.stringify(this.selectedRecords));

        const validEntries = this.selectedRecords.filter(item => item.validEntry === 6);
        console.log('valid entries>>', validEntries, 'valid entry length>>>', validEntries.length);
        console.log('past Date>>', pastDate);
        if (this.selectedRecords.length == 0) {
            Toast.show({
                label: 'Error',

                message: 'Kindly select atleast 1 product',
                mode: 'dismissible',
                variant: 'error'
            }, this);
        } else if (this.selectedRecords.length != 0 && pastDate && this.returnPeriodOverride && validEntries.length==this.selectedRecords.length) {
           
            Toast.show({
                label: 'Error',

                message: 'Past the return period for the provided reason. Provide a reason for override',
                mode: 'dismissible',
                variant: 'error'
            }, this);
            this.overrideReasonScreen = true;
            this.showOrderItems = false;
        } else if(validEntries.length==this.selectedRecords.length && !pastDate){
            this.overrideReasonScreen = true;
            this.showOrderItems=false;
        }else{
            Toast.show({
                label: 'Error',

                message: 'Kindly fix all the issues',
                mode: 'dismissible',
                variant: 'error'
            }, this);
        }
    }

    handleOverrideReturn() {
        let valid = false;
        let errorMessage = '';
        this.selectedRecords.forEach(i => {
            if (i.validDate === false && (i.returnOverrideReason===null || i.returnOverrideReason===undefined || i.returnOverrideReason ==='')) {
                valid = false;
                errorMessage = "Cannot submit without providing a return override reason";
            } else {
                valid = true;
            }
        })

        if (valid === true) {
            this.createReturnOrder();
        } else if (valid === false) {
            Toast.show({
                label: 'Error',

                message: errorMessage,
                mode: 'dismissible',
                variant: 'error'
            }, this);
        }
    }

    createReturnOrder() {
        let variable = effectiveAccount.accountId != null & effectiveAccount.accountId != undefined ? effectiveAccount.accountId : this.accountId;
        //this.setSelectedRecords();
        this.overrideReasonScreen = false;
        this.showUserInfo = false;
        this.showOrderItems = false;
        this.isLoading = true
        let caseRecords = [];
        console.log('selectedRecords>>', this.selectedRecords)
        this.selectedRecords.forEach(i => {
            if (i.returnReason == 'UK11' || i.returnReason == 'UK12') {
                caseRecords.push(i);
            }
        })
        console.log('caseRecords>>', caseRecords, 'caserecords.length>>',caseRecords.length);
        if(caseRecords.length>0){
            createReturnCase({ accountId: variable, caseDetails: caseRecords })
            .then(result => {
                console.log('case created');
            })
            .catch(error => {
                console.log('case error>>' + JSON.stringify(error))
            })
        }
        console.log('selectedRecords>>' + JSON.stringify(this.selectedRecords));
        let returnOrder = {
            orderId: this.orderId,
            userId: Id,
            accountId: variable,
            returnOrderItems: this.selectedRecords,
        }

        createReturnOrder({ order: returnOrder })
            .then(result => {
                this.showModal = false;
                this.isLoading = false;
                Toast.show({
                    label: 'Success',
                    message: 'Return has been initiated successfully',
                    mode: 'sticky',
                    variant: 'success'
                })
                setTimeout(()=>{window.location.reload();},3000);
            })
            .catch(error => {
                this.isLoading = false;
                console.log('Error creating object>>' + JSON.stringify(error));
            })
    }
}