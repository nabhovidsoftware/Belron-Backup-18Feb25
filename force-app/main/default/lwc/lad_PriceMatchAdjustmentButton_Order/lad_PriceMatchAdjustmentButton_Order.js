import { LightningElement, api, track, wire } from 'lwc';
import buttonName from '@salesforce/label/c.LAD_Price_Match_Adjustment';
import invokePriceAdjustment from '@salesforce/apex/LAD_OrderSummaryCreation.invokePriceAdjustment';
import returnOrderSummaryId from '@salesforce/apex/LAD_OrderSummaryCreation.returnOrderSummaryId';
import returnOrderItemSummary from '@salesforce/apex/LAD_OrderSummaryCreation.returnOrderItemSummary';
import updateOrderItemSummary from '@salesforce/apex/LAD_OrderSummaryCreation.updateOrderItemSummary';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import Reason_Field from "@salesforce/schema/LAD_Reason_for_Price_Adjustment__c.LAD_Reason_of_Price_Adjustment__c";
import LAD_Reason_for_Price_Adjustment__c from '@salesforce/schema/LAD_Reason_for_Price_Adjustment__c';
import Toast from 'lightning/toast';



export default class LAD_Price_Match_Or_Adjustmen_Button extends NavigationMixin(LightningElement) {
    @api orderSummaryId;

    @track showModal = false;
    buttonLabel = buttonName;
    isLoading = false;
    dataSet;
    selectAllVariant = 'base';
    selectAllName = 'utility:add';
    conditionForSelection = ['Ordered', 'Awaiting Shipping', 'Ready to release', 'Backordered'];
    @track recordtypeId;
    @track options;

    @wire(getObjectInfo, { objectApiName: LAD_Reason_for_Price_Adjustment__c })
    objectInfo({
        error, data
    }) {
        if (data) {
            console.log(31, data);
            console.log(JSON.stringify(data.recordTypeInfos));
            for (const key in data.recordTypeInfos) {
                console.log(key);
                console.log(data.recordTypeInfos[key].name);
                if (data.recordTypeInfos[key].name == 'Price Adjustment') {
                    this.recordtypeId = key;
                }
            }
            console.log(34, this.recordtypeId);
        } else if (error) {
            console.log(error);
        }
    }

    get isButtonVisible(){
        let check=false;
        this.dataSet.map(i=>{
            if(this.conditionForSelection.includes(i.LAD_Status__c)){
                check=true;
            }
        })
        return check;
    }

    @wire(getPicklistValues, { recordTypeId: '$recordtypeId', fieldApiName: Reason_Field })
    picklistResults({ error, data }) {
        console.log(37);

        console.log(data);
        this.options = undefined;
        if (data) {
            console.log(38, data);
            this.options = data.values;
        } else if (error) {
            console.log(45);
            console.log(39, error);
        }
    }


    openModal() {
        this.showModal = true;

    }

    connectedCallback() {
        returnOrderItemSummary({ orderSummaryId: this.orderSummaryId })
            .then(result => {
                console.log(result);
                this.dataSet = result;
                this.handleUiInterface();
            })
            .catch(error => {
                console.log(error);
            })
    }


    handleUiInterface() {
        this.dataSet = this.dataSet.map(i => {
            i.buttonVariant = 'base';
            i.iconName = 'utility:add';
            i.background = 'background-color: white;';
            i.adjustedPrice = null;
            i.isPriceAdjustmentFieldDisabled = true;
            i.reasonForPriceAdjustment = null;
            i.price = i.TotalPrice / i.Quantity;
            i.background = !this.conditionForSelection.includes(i.LAD_Status__c) ? 'background-color: #e5e5e5;' : 'background-color: white;';
            i.isDisabled = !this.conditionForSelection.includes(i.LAD_Status__c) ? true : false;

            return i;
        })
    }

    handleSelectIcon(event) {
        console.log(event.target.dataset.id);
        this.dataSet = this.dataSet.map(i => {
            if (i.isDisabled != true && i.Id == event.target.dataset.id) {
                i.buttonVariant = i.buttonVariant == 'base' ? 'brand' : 'base';
                i.iconName = i.buttonVariant == 'brand' ? 'utility:check' : 'utility:add';
                i.background = !this.conditionForSelection.includes(i.LAD_Status__c) ? 'background-color: #e5e5e5;' : 'background-color: white;';
                i.isDisabled = !this.conditionForSelection.includes(i.LAD_Status__c) ? true : false;
            }
            return i;
        })
        this.handleEnablePriceField();
    }

    handleEnablePriceField() {
        this.dataSet = this.dataSet.map(i => {
            if (i.buttonVariant == 'brand') {

                i.isPriceAdjustmentFieldDisabled = false;
            } else {
                i.isPriceAdjustmentFieldDisabled = true;

            }
            return i;
        })
    }

    handleAdjustedPrice(event) {
        this.dataSet = this.dataSet.map(i => {
            if (i.Id == event.target.dataset.id) {
                i.adjustedPrice = event.target.value;
            }
            return i;
        })
        console.log(this.dataSet);
    }

    handleSelectAll() {
        let areAllSelected = this.selectAllVariant == 'base' ? true : false;
        this.selectAllVariant = areAllSelected == true ? 'brand' : 'base';
        this.selectAllName = areAllSelected == true ? 'utility:check' : 'utility:add';
        console.log('areAllSelected>>', areAllSelected, this.selectAllVariant, this.selectAllName);

        console.log(this.selectAllVariant);
        this.dataSet = this.dataSet.map(i => {
            if (i.isDisabled != true) {
                i.buttonVariant = this.selectAllVariant;
                i.iconName = i.buttonVariant == 'brand' ? 'utility:check' : 'utility:add';

            }
            return i;
        })
        console.log(this.dataSet);
        this.handleEnablePriceField();

    }

    navigateURL(summaryId) {
        const pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: summaryId,
                objectApiName: 'OrderSummary',
                actionName: 'view'
            }
        };
        this[NavigationMixin.GenerateUrl](pageReference)
            .then(url => {
                console.log('Generated URL:', url);

                // Redirect to the generated URL
                window.open(url, "_self");
            })
            .catch(error => {
                console.error('Error generating URL:', error);
                this.isLoading = false;

            });
    }
    handleCloseModal() {
        this.showModal = false;
        console.log('Modal closed');
    }


    fetchUpdatedOrderSummaryId(orderId) {
        returnOrderSummaryId({ orderId: orderId })
            .then(result => {
                console.log('result>>', result);
                if (result != null) {
                    this.updateOrderProductSummary(result);
                } else {
                    setTimeout(() => {
                        this.fetchUpdatedOrderSummaryId(orderId);
                    }, 1000);
                }

            }).catch(error => {
                console.log(error);
                this.isLoading = false;

            })
    }


    updateOrderProductSummary(orderSummaryId){
        let wrapper=[];
        this.dataSet.map(i => {
            console.log(201, i);
           
                wrapper.push({
                    'orderItemId': i.OriginalOrderItemId,
                    'status': i.LAD_Status__c,
                   
                });
            
        });
        updateOrderItemSummary({lineItemWrapper:wrapper,orderSummaryId:orderSummaryId})
        .then(result=>{
            this.navigateURL(orderSummaryId);
        })
        .catch(error=>{
            console.log(error);
            this.isLoading = false;
        })
    }

    handlePriceAdjustment() {
        console.log(this.dataSet);
        this.isLoading = true;
        let dataWrap = [];

        // Iterate over each item in dataSet
        this.dataSet.map(i => {
            console.log(201, i);
            // Check if item meets the criteria
            if (i.adjustedPrice != null) {
                // Add the valid item to dataWrap
                console.log(203, i);
                dataWrap.push({
                    'orderItemId': i.OriginalOrderItemId,
                    'finalPrice': i.adjustedPrice,
                    'reasonForPriceAdjustment': i.reasonForPriceAdjustment,
                    'originalPrice': i.price,
                    'quantity': i.Quantity
                });
            }
        });

        let selectedRecords = this.dataSet.filter(i => i.buttonVariant == 'brand').length;
        console.log( 235,this.dataSet.filter(i => i.buttonVariant == 'brand'));
        let reasonSelected = this.dataSet.filter(i => i.reasonForPriceAdjustment != null).length;
        console.log( 237,this.dataSet.filter(i => i.reasonForPriceAdjustment != null));

        let pricesfilled = this.dataSet.filter(i => i.adjustedPrice != null).length;
        console.log(selectedRecords,reasonSelected,pricesfilled);
        if (selectedRecords == 0) {
            this.isLoading = false;
            Toast.show({
                label: 'Error',

                message: 'Please select atleast one item',
                mode: 'dismissable',
                variant: 'error'
            }, this);
        } else if (selectedRecords != reasonSelected && selectedRecords != pricesfilled) {
            this.isLoading = false;
            Toast.show({
                label: 'Error',

                message: 'Please select Reason and fill Adjusted Price for all selected items',
                mode: 'dismissable',

            })
        }
        else {

            this.invokePriceAdjustmentLogic(dataWrap);
        }
    }

    invokePriceAdjustmentLogic(dataWrap) {
        invokePriceAdjustment({ wrapper: dataWrap, orderSummaryId: this.orderSummaryId })
            .then(result => {
                console.log(result);
                this.fetchUpdatedOrderSummaryId(result);
            })
            .catch(error => {
                console.log(error);
            })
    }

    handleReason(event) {
        let record = event.target.dataset.id;
        this.dataSet = this.dataSet.map(i => {
            if (i.Id == record) {
                i.reasonForPriceAdjustment = event.detail.value;;
            }
            return i;
        })
    }
}