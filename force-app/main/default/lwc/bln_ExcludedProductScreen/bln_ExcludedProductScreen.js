import { LightningElement,api,track,wire } from 'lwc';
import ExcludedWorkType from "@salesforce/schema/ServiceTerritory.BLN_ExcludedWorkType__c";
import ExcludedProductCategory from "@salesforce/schema/ServiceTerritory.BLN_ExcludedProductCategory__c";
import ExcludedProduct from "@salesforce/schema/ServiceTerritory.BLN_ExcludedProduct__c";
import { getRecord } from 'lightning/uiRecordApi';
import saveExcludeList from '@salesforce/apex/BLN_ExcludeList.saveExcludeList'; 

const fields = [ExcludedProduct, ExcludedProductCategory, ExcludedWorkType];
class optionObject{
    constructor(value){ 
        this.value = value;
        this.label = value.replace(/%/g, '');
        if(value.endsWith('%')){
            this.labelWithOperation = 'CONTAINS: ' + this.label;
        }else if (value.startsWith('%')){
            this.labelWithOperation = 'BEGINS WITH: ' + this.label;
        }
        else this.labelWithOperation = 'EQUALS: ' + this.label;
    }
}
export default class Bln_ExcludedProductScreen extends LightningElement {
    @api recordId;
    @track workTypes=[];
    @track productCategories=[];
    @track products=[];
    @track workTypeFlag=false;
    @track productCategoryFlag=false;
    @track productFlag=false;
    @track disabled = true;
    @track dataValues;
    @track isCorrectProfile = true;

    @wire(getRecord, { recordId: "$recordId", fields: fields })
    wiredRecord({ error, data }) {
        if (error) {
        } else if (data) {
            if(data.fields && data.fields.BLN_ExcludedWorkType__c && data.fields.BLN_ExcludedWorkType__c.value){
                var tempArr = data.fields.BLN_ExcludedWorkType__c.value.split(';');
                for (var x = 0; x < tempArr.length; x++){
                    this.workTypes.push(new optionObject(tempArr[x]));
                }
            }
            if(data.fields && data.fields.BLN_ExcludedProductCategory__c && data.fields.BLN_ExcludedProductCategory__c.value){
                var tempArr = data.fields.BLN_ExcludedProductCategory__c.value.split(';');
                for (var x = 0; x < tempArr.length; x++){
                        this.productCategories.push(new optionObject(tempArr[x]));
                    }
            }
            if(data.fields && data.fields.BLN_ExcludedProduct__c && data.fields.BLN_ExcludedProduct__c.value){
                var tempArr = data.fields.BLN_ExcludedProduct__c.value.split(';');
                for (var x = 0; x < tempArr.length; x++){
                    this.products.push(new optionObject(tempArr[x]));
                }             
            }
            this.workTypeFlag = true;
            this.productCategoryFlag = true;
            this.productFlag = true;
            this.dataValues = data;  
        }
    }
    handleSelectWorkTypeList(event){
        this.workTypes = event.detail;
    }
    handleSelectproductCategoryList(event){
        this.productCategories = event.detail;
    }
    handleSelectproductList(event){
        this.products = event.detail;
    }
    handleSave(event){
        this.disabled = true;
        var selectedWorkTypes = [];
        var selectedCategory = [];
        var selectedProducts = [];
        for (var x = 0; x < this.workTypes.length; x++){
            selectedWorkTypes.push(this.workTypes[x].value);
        }  
        for (var x = 0; x < this.productCategories.length; x++){
            selectedCategory.push(this.productCategories[x].value);
        }  
        for (var x = 0; x < this.products.length; x++){
            selectedProducts.push(this.products[x].value);
        }  
        saveExcludeList({ recordId: this.recordId, selectedWorkTypes: selectedWorkTypes,selectedCategory: selectedCategory,selectedProducts: selectedProducts })
        .then(result => {
        }).catch(error => {
            console.error('Error:--', error);
        });
        window.location.reload()
    }
    handleCancel(event){
        window.location.reload();    
    }
    handleEdit(event){
        this.disabled = false;
    }
}