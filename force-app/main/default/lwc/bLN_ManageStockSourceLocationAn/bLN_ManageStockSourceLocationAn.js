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
import makeCallout from "@salesforce/apex/BLN_ManageStockSourceController.makeStockCallout";
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
export default class BLN_ManageStockSourceLocationAn extends NavigationMixin(LightningElement) {
    @api recordId;
    @api caseId
    @api caseRecId;
    @api caseRecordId;
    @api testCaseId;
    @api adressList = [];
    orderitemLocationMap = new Map();
    stackLocationIdWithDate = new Map();
    productCodeStackLocIdWithDate = new Map();
    productCodeWithOption = new Map();
    orderIdWithStatus = new Map();
    orderItemIdWithProductCodeMap = new Map();
    appointmentIdWithProductCodeMap = new Map();
    productCodeWithOutofStockMap = new Map();
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
    //FOUK-11609 Variable
    stockLocationIdList = [];
    stockLocationIdVsprodMap = new Map();
    productCodeWithSAIdMap = new Map();
    orderItemIdWithCollectFlag = new Map();

    connectedCallback() {
        this.spinner = true;
        Product({ caseId: this.recordId })
            .then(result => {
                if(result){
                this.orderIdWithStatus = new Map(Object.entries(result));
                this.orderIdWithStatus = result;
                if (this.orderIdWithStatus) {
                    this.getLocationData();
                }
                }
            })
    }

    getData() {
        this.spinner = true;
        RebookResponse({ caseId: this.recordId })
            .then(result => {
                let options = [];
                result.quoteDetailsDataList.forEach(locationDet => {
                    options.push({ value: locationDet.locationGUID, label: locationDet.quotelocation })
                });
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
                    });
                    console.log('appointmentList12345' + JSON.stringify(this.appointmentList));
                    element.appointments.forEach(elm => {
                        let productCodeList = [];
                        elm.productAvailibilities.forEach(el => {
                            
                            el.products.forEach(prod => {
                                productCodeList.push(prod.productCode);
                                this.orderItemIdWithProductCodeMap.set(prod.productCode, prod.orderItemId);
                                try {
                                    if (this.productCodeWithOption.has(prod.productCode)&& this.productCodeStackLocIdWithDate.has(prod.productCode + '-' + this.productCodeWithOption.get(prod.productCode)[0]?.value)) {
                                    prod.earlyAvlDate = this.productCodeStackLocIdWithDate?.get(prod.productCode + '-' + this.productCodeWithOption?.get(prod.productCode)[0]?.value) //this.productCodeWithOption.get(prod.productCode)//productCodeWithEarliestDateMap.get(prod.productCode)?.split('T')[0];
                                }
                                    prod.productName = productcodeWithProductNameMap.get(prod.productCode);                                
                                    prod.status = this.orderIdWithStatus[prod.orderItemId]?.BLN_StockStatus__c;
                                    console.log(prod.productCode, '---', this.productCodeWithOption?.get(prod.productCode), '------>>', this.productCodeWithOption?.get(prod.productCode)?.length == 0, '---111', this.productCodeWithOption.has(prod.productCode));
                                    console.log('this.productCodeWithOutofStockMap---', this.productCodeWithOutofStockMap);

                                    if ((this.productCodeWithOutofStockMap.has(prod.productCode) && this.productCodeWithOutofStockMap.get(prod.productCode)) || (this.productCodeWithOption.has(prod.productCode) && this.productCodeWithOption?.get(prod.productCode)?.length == 0)) {                                        
                                        prod.disbaledloc = 'disabled';
                                        prod.promiseDate = this.orderIdWithStatus[prod.orderItemId]?.BLN_PromiseDate__c;
                                        prod.isOutOfStock = true;
                                    }
                                    let opt = this.productCodeWithOption.has(prod.productCode)?this.productCodeWithOption.get(prod.productCode):'';
                                    if(opt){
                                    opt.forEach(loc => {
                                        if (loc.value == prod.stockLocation) {
                                            loc.selected = true;
                                        }
                                        else{
                                            loc.selected = false;
                                        }
                                    });
                                    prod.option = opt;
                                    }
                                    if (this.productCodeWithOption?.has(prod.productCode)) {
                                        prod.defaultLocation = this.productCodeWithOption?.get(prod.productCode)[0]?.value;
                                        //this.guidCode.add(this.productCodeWithOption?.get(prod.productCode)[0].value);
                                    }   
                                    if (this.productCodeWithOption?.get(prod.productCode)?.length == 0) {
                                        prod.disbaled = true;
                                    }
                                    this.buttonVisibility = true;
                                } catch (error) {
                                    console.log('error', error);
                                }
                            })
                        });
                        console.log(' this.appointmentList---', this.appointmentList);
                        
                        this.appointmentIdWithProductCodeMap.set(elm.serviceAppointmentId, productCodeList);
                        this.spinner = false;
                    });
                });
                console.log('AppointmentList123456', JSON.stringify(this.appointmentList));
                if (!this.buttonVisibility) {
                    this.spinner = false;
                    this.showToastMessage('Cannot perform source stock location action for this case.', '', 'info');
                    this.closeTab();
                }
            }).catch(error => {
                this.spinner = false;
                console.log('error', error);
            })
    }

    async getLocationData() {
        RebookResponse({ caseId: this.recordId })
            .then(result => {
                let visibility = false;     
                this.spinner = true;           
                console.log('result.earliestAvailabilityList---->>', result.earliestAvailabilityList);
                result.earliestAvailabilityList.forEach(proCode => {
                    let locationIdList = [];
                    proCode.earliestDateList.forEach(locationId => {
                        locationIdList.push(locationId.stockLocationId);
                        this.productCodeWithOutofStockMap.set(proCode.mdmId, locationId.isOutOfStock);

                    });
                    if (locationIdList) {
                        Location({ stackLocationIdList: locationIdList })
                            .then(loc => {
                                // if(proCode != null && proCode.mdmId != undefined && loc.length!=0) {
                                if(proCode != null && proCode.mdmId != undefined) {
                                    this.productCodeWithOption.set(proCode.mdmId, loc);
                                }
                                visibility = true;
                                this.spinner = false;
                            })
                    }
                });
                setTimeout(() => {
                    if (visibility == true) {
                        this.getData();
                    }
                    else{
                        this.spinner = false;
                        this.showToastMessage('Cannot perform source stock location action for this case.', '', 'info');
                        this.closeTab();
                    }
                }, 1000)

            }).catch(error => {
                this.spinner = false;
                console.log('error', error);
                this.showToastMessage('Cannot perform source stock location action for this case.', '', 'info');
                this.closeTab();
            })
    }

    async closeTab() {
        const { tabId } = await getFocusedTabInfo();
        await closeTab(tabId);
    }

    handleChangeLocation(event) {
        this.guidCode.clear();
        let productCode = event.target.dataset.id;
        let stackLocId = event.target.value;
        this.appointmentId = event.target.dataset.appid;
        this.stockLocId = stackLocId;
        this.earlyAvlDate = this.productCodeStackLocIdWithDate.get(productCode + '-' + stackLocId);
        let target = this.template.querySelector(`[data-procode="${productCode}"]`).value = this.productCodeStackLocIdWithDate.get(productCode + '-' + stackLocId);
        if (!this.orderItemIdList?.includes(this.orderItemIdWithProductCodeMap.get(productCode))) {
            this.orderItemIdList.push(this.orderItemIdWithProductCodeMap.get(productCode));
        }
        this.orderitemLocationMap.set(this.orderItemIdWithProductCodeMap.get(productCode), stackLocId);
        this.stockLocationIdVsprodMap.set(productCode, this.orderitemLocationMap.get(this.orderItemIdWithProductCodeMap.get(productCode)));
        console.log(' this.stockLocationIdVsprodMap----224--', this.stockLocationIdVsprodMap);
    }

    handleOnchangeCheckbox(event) {
        let prodCode = event.target.dataset.productcode;
        this.stockLocId = event.target.dataset.dateloctaion;
        console.log('this.stockLocId----', this.stockLocId);
        this.disbaled = this.template.querySelector(`[data-productcode="${prodCode}"]`).checked;
        if (!this.orderItemIdList?.includes(this.orderItemIdWithProductCodeMap.get(prodCode))) {
            this.orderItemIdList.push(this.orderItemIdWithProductCodeMap.get(prodCode));
        }
        //new changes under 11609
        if (this.orderitemLocationMap.get(this.orderItemIdWithProductCodeMap.get(prodCode))) {
            console.log('255');
            this.stockLocationIdVsprodMap.set(prodCode, this.orderitemLocationMap.get(this.orderItemIdWithProductCodeMap.get(prodCode)));
        } else {
            console.log('260');
            this.orderitemLocationMap.set(this.orderItemIdWithProductCodeMap.get(prodCode), this.stockLocId);
            this.stockLocationIdVsprodMap.set(prodCode, this.stockLocId);
        }        
        if (this.stockLocationIdVsprodMap.has(prodCode)) {
            if (this.disbaled == false) {
                this.stockLocationIdVsprodMap.delete(prodCode);
            }
        }
        this.orderItemIdWithCollectFlag.set(this.orderItemIdWithProductCodeMap.get(prodCode), this.disbaled);
        console.log(this.disbaled,'<---->',this.orderItemIdWithCollectFlag,'stockLocationIdVsprodMap1234', this.stockLocationIdVsprodMap);
        this.appointmentId = event.target.dataset.appid;
        this.earlyAvlDate = this.template.querySelector(`[data-procode="${prodCode}"]`).value;
    }

    navigateToFlow() {
        try {
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
        this.stockLocationIdList = [];
        let valueFromStockMap = this.stockLocationIdVsprodMap.values();
        this.stockLocationIdList = Array.from(valueFromStockMap);
        console.log('StockLocationIdsConfirmChange', JSON.stringify(this.stockLocationIdList));
        if (this.orderitemLocationMap && this.orderItemIdList && this.orderitemLocationMap.size != 0 && this.orderItemIdList.length != 0 && this.orderitemLocationMap.size == this.orderItemIdList.length) {
            // console.log('continue');
            if (this.stockLocationIdList != 0 && this.disbaled) {
                this.spinner = true;
                this.getMDCStockAppointementId();
            }
            else if (this.disbaled != true) {
                this.getMDCStockAppointementId();
                this.spinner = true;
            }
            else if (this.disbaled) {
                this.spinner = true;
                this.getMDCStockAppointementId();
            }           
        }
        else {
            this.showToastMessage('Error', this.label.ErrorMessage, 'error');
        }
    }

    getMDCStockAppointementId() {
        const date = new Date(this.earlyAvlDate);
        for (const key of this.stockLocationIdVsprodMap.keys()) {
            MDCStockCollect({ appointmentId: this.appointmentId, locationId: this.stockLocationIdVsprodMap.get(key) })
                .then(result => {
                    console.log('SA:---->> ', result);
                    this.productCodeWithSAIdMap.set(key, result);

                }).catch(error => {
                    console.log(JSON.stringify(error));
                })
        }
        let IntervalId = setInterval(() => {
            if (this.productCodeWithSAIdMap.size == this.stockLocationIdVsprodMap.size) {
                if (this.stockLocationIdList.length != 0 && this.disbaled) {
                    this.makeCalloutToEBS('RESERVATION');
                }
                else if (this.disbaled != true) {
                    this.makeCalloutToEBS('REQUISITION');
                }
                clearInterval(IntervalId);
            }
        }, 500);
        console.log('stockLocationIdListInGetMDC', JSON.stringify(this.stockLocationIdList));


    }

    makeCalloutToEBS(action) {
        let ordMap = this.mapToObject(this.orderitemLocationMap);
        let saMap = Object.fromEntries(this.productCodeWithSAIdMap);
        let flagMap = this.mapToObject(this.orderItemIdWithCollectFlag);
        console.log(flagMap, '----ordMap--11--', saMap);
        makeCallout({orderItemItemList: this.orderItemIdList, orderitemLocationMap: JSON.stringify(ordMap), productWithSA: JSON.stringify(saMap),collectFlagMap :JSON.stringify(flagMap) })
            .then(res => {
                console.log('res', res);
                this.showToastMessage('success', 'Stock Movement request has been successfully raised', 'success')
                this.spinner = false;
            }).catch(error=>{
                console.log('error ',error);
                this.showToastMessage('Error', 'Error occure on Stock Movement request', 'error');
                this.spinner = false;
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

    mapToObject(map) {  
        let obj = {};  
        for (let [key, value] of map.entries()) {  
            obj[key] = value;  
        }  
        return obj;  
    }  
}