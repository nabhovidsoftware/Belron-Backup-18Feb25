import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createTask from '@salesforce/apex/BLN_InsuranceDetailFormController.createTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insuranceSuccessMsg from "@salesforce/label/c.BLN_InsuranceToastSuccessMsg";
//import insuranceFormTitle from "@salesforce/label/c.BLN_SalutationLabel";


export default class Bln_InsuranceDetailForm  extends NavigationMixin(LightningElement) {
    //@track titleValue = '';
    @track firstName = '';
    @track lastName = '';
    @track addressLine1 = '';
    @track addressLine2 = '';
    @track postcode = '';
    @track policyBrand = '';
    @track policyUnderwriter = '';
    @track certificateNumber = '';
    @track glassClaimExcess = '£ 0.00';
    @track expiryDate = '';
    @track vatRegistered = '';
    @track insuranceCertificate;
    @track isSubmitDisabled = true;
    caseId;
    fileRecord
    isLoading = false;
    //titleOptions;
    fileData = {};
    label = {
        insuranceSuccessMsg
       // insuranceFormTitle

    };
    @track vatRegisteredOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

    connectedCallback() {
        // this.titleOptions = []; // Initialize titleOptions as an empty array
        // const insuranceFormTitleArray = this.label.insuranceFormTitle.split(',');    
        // insuranceFormTitleArray.forEach(element => {
        //     this.titleOptions.push({ label: element, value: element });
        // });
    
        const urlParams = new URLSearchParams(window.location.search);
        this.caseId = urlParams.get('CaseId');
    
        window.addEventListener('click', this.handleAnyClick.bind(this));
    }
    disconnectedCallback() {
        // Remove the click event listener when the component is removed from the DOM
        window.removeEventListener('click', this.handleAnyClick);
    }
    handleChange(event) {
        const fieldName = event.target.dataset.fieldname;
        const value = event.target.value;
        //console.log('value'+value);
        switch(fieldName) {
            //     case 'title':
            //     this.titleValue = value;
            //     this.isSubmitDisabled = !this.allMandatoryFieldsFilled();
            //     break;
            case 'firstName':
                this.firstName = value;
                this.isSubmitDisabled = !this.allMandatoryFieldsFilled();
                break;
            case 'lastName':
                this.lastName = value;
                this.isSubmitDisabled = !this.allMandatoryFieldsFilled();
                break;
            case 'addressLine1':
                this.addressLine1 = value;
                this.isSubmitDisabled = !this.allMandatoryFieldsFilled();

                break;
            case 'addressLine2':
                this.addressLine2 = value;
                this.isSubmitDisabled = !this.allMandatoryFieldsFilled();

                break;
            case 'postcode':
                this.postcode = value;
                this.isSubmitDisabled = !this.allMandatoryFieldsFilled();

                break;
            case 'policyBrand':
                this.policyBrand = value;
                this.isSubmitDisabled = !this.allMandatoryFieldsFilled();

                break;
            case 'policyUnderwriter':
                this.policyUnderwriter = value;
                this.isSubmitDisabled = !this.allMandatoryFieldsFilled();

                break;
            case 'certificateNumber':
                this.certificateNumber = value;
                this.isSubmitDisabled = !this.allMandatoryFieldsFilled();

                break;
            case 'glassClaimExcess':
                this.glassClaimExcess = value;
                this.isSubmitDisabled = !this.allMandatoryFieldsFilled();
                break;
            case 'expiryDate':
                this.expiryDate = value;
                this.isSubmitDisabled = !this.allMandatoryFieldsFilled();

                break;
            case 'vatRegistered':
                this.vatRegistered = value;
                this.isSubmitDisabled = !this.allMandatoryFieldsFilled();

                break;
        }
    }
    handleAnyClick(event){
            // Extract numerical value from the input using regular expression
            const regex = /(?:^| )(£)?(\d+(\.\d+)?)/;
            const match = this.glassClaimExcess.match(regex);
            // If there are no matches or the first match is not a valid number, default to '0.00'
            if (!match || isNaN(parseFloat(match[2]))) {
                this.glassClaimExcess =  '£ 0.00';
            }
            // Round the numerical value to two decimal places
            const roundedValue = parseFloat(match[2]).toFixed(2);
            // Format the rounded value as a currency string with Euro symbol
            this.glassClaimExcess = '£ ' + roundedValue;
        
    }
    
    handleFileUpload(event) {
    
     this.fileRecord = event.target.files[0]; // Access the file directly from the event
     this.isSubmitDisabled = !this.allMandatoryFieldsFilled();
    

    let reader = new FileReader();

    reader.onload = () => {
        let base64String = reader.result.split(',')[1]; // Extract base64 string
         this.fileData = {
            fileName: this.fileRecord.name,
            base64Data: base64String
        };
        
    };
    reader.readAsDataURL(this.fileRecord);

}

    allMandatoryFieldsFilled() {
        if (
            //this.titleValue &&
            this.firstName &&
            this.lastName &&
            this.addressLine1 &&
            this.postcode &&
            this.policyBrand &&
            this.policyUnderwriter &&
            this.certificateNumber &&
            this.expiryDate &&
            this.vatRegistered
            
        ) {
            return true;
        } else {
            return false;
        }
    }

   
    
    handleSubmit() {
        this.isLoading = true;
        const description = //`Policyholder title - ${this.titleValue}\n`
             `Policyholder first name - ${this.firstName}\n`
            + `Policyholder last name - ${this.lastName}\n`
            + `Policyholder address line 1 - ${this.addressLine1}\n`
            + `Policyholder address line 2 - ${this.addressLine2}\n`
            + `Policyholder postcode - ${this.postcode}\n`
            + `Policy brand - ${this.policyBrand}\n`
            + `Policy underwriter - ${this.policyUnderwriter}\n`
            + `Certificate/policy number - ${this.certificateNumber}\n`
            + `Glass claim excess - ${this.glassClaimExcess}\n`
            + `Expiry date of policy - ${this.expiryDate}\n`
            + `Is the Policyholder VAT registered? - ${this.vatRegistered}`;
        //Call Apex method to create Task
        createTask({ caseId: this.caseId, description: description, base64Data : this.fileData.base64Data , fileName: this.fileData.fileName})
            .then(result => {
               
                this.isLoading=false;
               if(result===true){
                this.showToast('Success', this.label.insuranceSuccessMsg, 'success');
                this.handleBack();
               }


            })
            .catch(error => {
                // Handle error
                console.log('error',error);
            });
    }
  
  


    handleBack() {
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.caseId,
            objectApiName: 'Case',
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