import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RebookResponse from '@salesforce/apex/BLN_ManageStockSourceController.getAppoinmentAndProduct';
import Product from '@salesforce/apex/BLN_ManageStockSourceController.getProductLineItem';
import Location from '@salesforce/apex/BLN_ManageStockSourceController.getLocation';
import { NavigationMixin } from 'lightning/navigation';
import ProductName from "@salesforce/label/c.BLN_Product_Name";
import StockStatus from "@salesforce/label/c.BLN_Stock_Status";
import StockLocation from "@salesforce/label/c.BLN_Stock_Location";
import EarliestAvailability from "@salesforce/label/c.BLN_Earliest_Availability";
import ErrorMessage from "@salesforce/label/c.BLN_Error_Message";
import CollectManually from "@salesforce/label/c.BLN_Collect_Manually";
import MDCStockCollect from "@salesforce/apex/BLN_ManageStockSourceController.getAppointmentId";
import makeCallout from "@salesforce/apex/BLN_ManageStockSourceController.makeStockCallout"
export default class BLN_ManageStockSourceLocationAn extends NavigationMixin(LightningElement) {
    @api recordId;
    @api caseId
    @api caseRecId;
    @api caseRecordId;
    @api testCaseId;
    @api adressList = [];
    stackLocationIdWithDate = new Map();
    productCodeStackLocIdWithDate = new Map();
    productCodeWithOption = new Map();
    orderIdWithStatus = new Map();
    orderItemIdWithProductCodeMap = new Map();
    appointmentIdWithProductCodeMap = new Map();
    buttonVisibility = false;
    productCodeWithOptiontest
    appointmentList = [];
    orderItemIdList = [];
    disbaled;
    stockLocId = ''
    appointmentId = ''
    productCode = '';
    earlyAvlDate = '';
    label = {
        ProductName,
        StockStatus,
        StockLocation,
        EarliestAvailability,
        CollectManually,
        ErrorMessage
    }
    spinner = true;
    guidCode = new Set()
    connectedCallback() {
        console.log('26---', this.recordId);
        Product({ caseId: this.recordId })
            .then(result => {
                this.orderIdWithStatus = new Map(Object.entries(result));
                this.orderIdWithStatus = result;
                if (this.orderIdWithStatus) {
                    this.getLocationData();
                }
            })
    }

    getData() {
        RebookResponse({ caseId: this.recordId })
            .then(result => {
                let options = [];
                result.quoteDetailsDataList.forEach(locationDet => {
                    options.push({ value: locationDet.locationGUID, label: locationDet.quotelocation })
                })
                this.appointmentList = JSON.parse(result.appointmentWrapperList);
                const productCodeWithEarliestDateMap = new Map();
                const productcodeWithProductNameMap = new Map();
                result.earliestAvailabilityList.forEach(proCode => {
                    proCode.earliestDateList.forEach(date => {
                        this.productCodeStackLocIdWithDate.set(proCode.mdmId + '-' + date.stockLocationId, date.availableFromDate);
                    })
                    if (proCode.earliestDateList.length > 0) {
                        productCodeWithEarliestDateMap.set(proCode.mdmId, proCode.earliestDateList[0].availableFromDate);
                    }
                })

                this.appointmentList.forEach(element => {
                    element.serviceLocationLabel.forEach(prod => {
                        prod.productNames.forEach(productName => {
                            productcodeWithProductNameMap.set(productName.productCode, productName.productName);
                        })
                    })
                    element.appointments.forEach(elm => {
                        let productCodeList = [];
                        elm.productAvailibilities.forEach(el => {
                            el.products.forEach(prod => {
                                productCodeList.push(prod.productCode);
                                this.orderItemIdWithProductCodeMap.set(prod.productCode, prod.orderItemId);
                                prod.earlyAvlDate = this.productCodeStackLocIdWithDate?.get(prod.productCode + '-' + this.productCodeWithOption?.get(prod.productCode)[0].value) //this.productCodeWithOption.get(prod.productCode)//productCodeWithEarliestDateMap.get(prod.productCode)?.split('T')[0];
                                prod.productName = productcodeWithProductNameMap.get(prod.productCode)
                                prod.status = this.orderIdWithStatus[prod.orderItemId]?.BLN_StockStatus__c;
                                prod.option = this.productCodeWithOption.get(prod.productCode);
                                prod.defaultLocation = this.productCodeWithOption?.get(prod.productCode)[0].value;
                                this.guidCode.add(this.productCodeWithOption?.get(prod.productCode)[0].value);
                                if (this.productCodeWithOption.get(prod.productCode)?.length == 0) {
                                    prod.disbaled = true;
                                }
                                this.buttonVisibility = true;
                                this.spinner = false;
                            })
                        })
                        this.appointmentIdWithProductCodeMap.set(elm.serviceAppointmentId, productCodeList);
                    })

                });
                console.log('this.appointmentList', this.appointmentList);

            }).catch(error => {
                console.log('error', error);
            })
    }

    getLocationData() {
        RebookResponse({ caseId: this.recordId })
            .then(result => {
                let visibility = false;
                result.earliestAvailabilityList.forEach(proCode => {
                    let locationIdList = [];
                    proCode.earliestDateList.forEach(locationId => {
                        locationIdList.push(locationId.stockLocationId);
                    })
                    if (locationIdList) {
                        Location({ stackLocationIdList: locationIdList })
                            .then(loc => {
                                if(proCode != null && proCode.mdmId != undefined) {
                                    this.productCodeWithOption.set(proCode.mdmId, loc);
                                    console.log(' this.productCodeWithOption---', this.productCodeWithOption);
                                    
                                }
                                visibility = true;
                            })
                    }
                })
                if (visibility = true) {
                    this.getData();
                }
            })
    }

    handleChangeLocation(event) {
        this.guidCode.clear();
        let productCode = event.target.dataset.id;
        let stackLocId = event.target.value;
        this.appointmentId = event.target.dataset.appid
        this.stockLocId = stackLocId;
        this.earlyAvlDate = this.productCodeStackLocIdWithDate.get(productCode + '-' + stackLocId);
        let target = this.template.querySelector(`[data-procode="${productCode}"]`).value = this.productCodeStackLocIdWithDate.get(productCode + '-' + stackLocId);
        if (!this.orderItemIdList?.includes(this.orderItemIdWithProductCodeMap.get(productCode))) {
            this.orderItemIdList.push(this.orderItemIdWithProductCodeMap.get(productCode));
        }
        this.appointmentIdWithProductCodeMap.get(this.appointmentId).forEach(prodCode => {
            let guidId = this.template.querySelector(`[data-id="${prodCode}"]`).value;
            this.guidCode.add(guidId);
        })
        // this.handleOnchangeCheckbox();
    }

    handleOnchangeCheckbox(event) {
        let prodCode = event.target.dataset.productcode;
        this.stockLocId = event.target.dataset.dateloctaion;
        this.disbaled = this.template.querySelector(`[data-productcode="${prodCode}"]`).checked;
        if (!this.orderItemIdList?.includes(this.orderItemIdWithProductCodeMap.get(prodCode))) {
            this.orderItemIdList.push(this.orderItemIdWithProductCodeMap.get(prodCode));
        }
        this.appointmentId = event.target.dataset.appid;
        this.earlyAvlDate = this.template.querySelector(`[data-procode="${prodCode}"]`).value;
    }


    navigateToFlow() {
        try {
            console.log('url ', `/flow/BLN_Rebook/?recordId=${this.recordId}`);
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: `/flow/BLN_Rebook?recordId=${this.recordId}`
                }
            });
        } catch (error) {
            console.log(error);
        }
    }

    handleClickOnConfirmChanges() {
        if (this.guidCode.size == 1) {
            console.log('continue');
            if (this.stockLocId && this.disbaled) {
                this.spinner = true;
                this.getMDCStockAppointementId();
            }
            else if (this.disbaled != true) {
                this.makeCalloutToEBS('REQUISITION');
                this.spinner = true;
            }
            else if (this.disbaled) {
                this.spinner = true;
                this.getMDCStockAppointementId();
            }           
        }
        // else if (this.disbaled) {
        //     this.spinner = true;
        //     this.getMDCStockAppointementId();
        // }
        else {
            this.showToastMessage('Error', this.label.ErrorMessage, 'error');
        }

    }

    getMDCStockAppointementId() {
        console.log(this.stockLocId, 'appointmentId', this.appointmentId, 'earlyDate---', this.earlyAvlDate);
        const date = new Date(this.earlyAvlDate);
        console.log('date----', date);
        MDCStockCollect({ appointmentId: this.appointmentId, locationId: this.stockLocId })
            .then(result => {
                console.log('result---->>', result);
                if (this.stockLocId && this.disbaled) {
                    this.makeCalloutToEBS('RESERVATION');
                }
                else if (this.disbaled != true) {
                    this.makeCalloutToEBS('REQUISITION');
                }

            })
    }

    makeCalloutToEBS(action) {
        console.log('197---orderItemIdList--', this.orderItemIdList);
        makeCallout({ orderItemItemList: this.orderItemIdList, actionType: action })
            .then(res => {
                console.log('res', res);
                this.showToastMessage('success', 'Stock Movement request has been successfully raised', 'success')
                this.spinner = false;
            }).catch(error=>{
                this.showToastMessage('Error', 'Error occure on Stock Movement request', 'error');
            })
    }

    showToastMessage(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

}