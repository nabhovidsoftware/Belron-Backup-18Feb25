import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createCaseRecord from '@salesforce/apex/Bln_PortalEnquiryFormController.createCaseRecord';
import isVRNRegistered from '@salesforce/apex/Bln_PortalEnquiryFormController.isVRNRegistered';

// import dependentPicklistValues from '@salesforce/apex/Bln_PortalEnquiryFormController.getDependentPicklistValues';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CASE_OBJECT from '@salesforce/schema/Case';
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import SUBTYPE_FIELD from '@salesforce/schema/Case.BLN_SubType__c';
import portalEnqSuccessMsg from "@salesforce/label/c.BLN_PortalEnqSuccessMsg";
import portalEnqErrorMsg from "@salesforce/label/c.BLN_PortalEnqErrorMsg";
import subtypeValues from "@salesforce/label/c.BLN_EnquiryPortalSubtypeVal";
import portaVrnErrorMsg from "@salesforce/label/c.BLN_PortaVrnErrorMsg";


export default class Bln_PortalEnquiryForm extends NavigationMixin(LightningElement) {

    contactName  ;
    contactEmail ;
    contactPhone;
    contactAddress;
    vrn;
    description;
    subtype;
    parentCaseId;
    subTypeOptions;
    fileData = {};
    invoiceNumber;
    paymentInvoicingFlag = false;
    invoicingFlag = false;
    user;
    isLoading = false;
    label = {
        portalEnqSuccessMsg,
        portalEnqErrorMsg,
        portaVrnErrorMsg,
        subtypeValues

    }
    @wire(getRecord, { recordId: USER_ID, fields: ['User.Id', 'User.Phone', 'User.Name', 'User.Street' , 'User.City' , 'User.State', 'User.Country' , 'User.PostalCode'] })
    wiredUser({ error, data }) {
        if (data) {
           this.contactName = data.fields.Name.value;
           this.contactPhone = data.fields.Phone.value;
                this.contactAddress = data.fields.Street.value || '';
                this.contactAddress += ' ' + (data.fields.City.value || '');
                this.contactAddress += ' ' + (data.fields.State.value || '');
                this.contactAddress += ' ' + (data.fields.Country.value || '');
                this.contactAddress += ' ' + (data.fields.PostalCode.value || '');
             
        } else if (error) {
            console.error('Error fetching user information:', error);
        }
    }
    connectedCallback(){
    // dependentPicklistValues({ objectType: CASE_OBJECT.objectApiName, controllingFieldName: TYPE_FIELD.fieldApiName, dependentFieldName : SUBTYPE_FIELD.fieldApiName , specificControllerValue: 'Enquiry'})
    // .then(result => {
    //          if(result){
                
    //             console.log('result',result);
    //             this.subTypeOptions=[];
    //             const enquiryList = result.Enquiry;
    //             enquiryList.forEach(element => {
    //                 this.subTypeOptions.push({ label: element, value: element });
    //             });
    //         }

    //         })
    //         .catch(error => {
    //             // Handle error
    //             console.log('error',error);
    //         });
        this.subTypeOptions = []; // Initialize titleOptions as an empty array
        // const insuranceFormTitleArray = this.label.subtypeValues.split(',');    
        this.label.subtypeValues.split(',').forEach(element => {
            this.subTypeOptions.push({ label: element, value: element });
        });
      }
   
  
      handleChange(event) {
        // Extract the field name and value from the event
        const fieldName = event.target.dataset.fieldname;
        const value = event.target.value;
        if (fieldName === 'contactName') {
            this.contactName = value;
        } else if (fieldName === 'contactAddress') {
            this.contactAddress = value;
        } else if (fieldName === 'contactPhone') {
            this.contactPhone = value;
        } else if (fieldName === 'vrn') {
            this.vrn = value;
        } else if (fieldName === 'invoiceNumber') {
            this.invoiceNumber = value;
        } else if (fieldName === 'parentId') {
            this.parentCaseId = value;
        } else if (fieldName === 'subtype') {
            this.subtype = value;
            if (this.subtype === 'Payment') {
                this.paymentInvoicingFlag = true;
                this.invoicingFlag = false; // Set to false when subtype is Payment
                this.invoiceNumber = '';
            } else if (this.subtype === 'Invoicing') {
                this.invoicingFlag = true;
                this.paymentInvoicingFlag = true;

            } else {
                this.paymentInvoicingFlag = false;
                this.invoicingFlag = false; // Set to false when subtype is not Payment or Invoicing
                this.invoiceNumber = '';
                this.parentCaseId = '';
            }
        } else if (fieldName === 'description') {
            this.description = value;
        }
    }
    
    handleFileUpload(event){
        const fileRecord = event.target.files[0]; // Access the file directly from the event
        this.fileData = {};
       let reader = new FileReader();
   
       reader.onload = () => {
           let base64String = reader.result.split(',')[1]; // Extract base64 string
            this.fileData = {
               fileName: fileRecord.name,
               base64Data: base64String
           };
           
       };
       reader.readAsDataURL(fileRecord);
   
    }

    handleSubmit() {
        if (!this.description) {
            this.template.querySelector('lightning-input[data-fieldname="description"]').focus();
        }
        if(this.paymentInvoicingFlag){
            if(!this.vrn){
                this.template.querySelector('lightning-input[data-fieldname="vrn"]').focus();
            }
        }
        if(!this.subtype){
            this.template.querySelector('lightning-combobox[data-fieldname="subtype"]').focus();
        }
        if(!this.description || (this.paymentInvoicingFlag && !this.vrn) || !this.subtype){
            return ;
        }
        if(this.vrn){
            isVRNRegistered({ vrn: this.vrn})
           .then(result=>{
               if(result!=null){
                this.caseHandler(result);
            }
               else{
                this.showToast('Error',this.label.portaVrnErrorMsg,'Error');
            }
           })
           .catch(error=>{
               console.log('Error',error);
           });
        }
        else{ 
            this.caseHandler('');
        }

        
    }
    caseHandler(vehicleId){
        this.isLoading = true;
        
        const caseData = {
            BLN_Vehicle__c: vehicleId,
            BLN_SubType__c: this.subtype,
            Description: this.description,
            ParentId: this.parentCaseId,
            BLN_InvoiceNumber__c : this.invoiceNumber
        };
        
        createCaseRecord({ caseData: caseData , base64Data : this.fileData.base64Data , fileName: this.fileData.fileName})
            .then(result => {
                // console.log('result',JSON.stringify(result));
                this.isLoading=false;
                if(Object.keys(result).length>0) {
                 this.showToast('Success',this.label.portalEnqSuccessMsg + ' ' +result.CaseNumber, 'success');
                 this.navigateToRecordPage(result.Id);
                }
                else{
                    this.showToast('Error',this.label.portalEnqErrorMsg, 'error');

                }
            })
            .catch(error => {
                console.error('Error creating case:', error);
                this.showToast('Error',this.label.portalEnqErrorMsg, 'error');
            });
      }
      
      navigateToRecordPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

      showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
           title: title,
           message: message,
           variant: variant
        });
        this.dispatchEvent(toastEvent);
      }
}