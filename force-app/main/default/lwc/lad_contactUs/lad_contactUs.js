/** @description :  This component is used to create a contact us form and supply the 
 *                  inputs to the LAD_contactUsForm to create cases
*   @Story :        FOUK-9936
*   @author:        (ashwin.r.raja@pwc.com (IN))
*   @CreatedDate:   09-09-2024
*/


import { LightningElement, track } from 'lwc';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import getAccId  from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import Id from '@salesforce/user/Id';
import createCases  from '@salesforce/apex/LAD_contactUsForm.createCases';
import Toast from 'lightning/toast';
import uploadFile from '@salesforce/apex/LAD_contactUsForm.uploadFile';
import fetchData from '@salesforce/apex/LAD_contactUsForm.fetchData';

export default class Lad_contactUs extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track accountName = '';
    @track accountNumber = '';
    @track email = '';
    @track phoneNumber = '';
    @track description = '';
    @track accountId = null;
    @track data = [];
    @track type='';
    @track reason='';
    @track isLoading = false;
    isGuest = (Id == null || Id == undefined)? true:false;
    recordId;
    fileData;
    valid = 0;

    connectedCallback(){
        getAccId({userid:Id})
        .then(result => {
            this.accountId=result;
            console.log("account id="+result+" userID"+Id);
            this.fetchDetails();
        })
        .catch(error=>{
            console.log(error);
        })
    }

    fetchDetails(){
        let variable = effectiveAccount.accountId!=null & effectiveAccount.accountId!=undefined? effectiveAccount.accountId:this.accountId
        fetchData({userId: Id, accountId:variable})
        .then(result=>{
            console.log('ccb>>'+JSON.stringify(result));
            this.accountId = variable;
            this.accountName = result.accountName;
            this.accountNumber = result.accountNumber;
            this.firstName = result.firstName;
            this.lastName = result.lastName;
            this.phoneNumber = result.phoneNumber;
            this.email = result.email;
            console.log('accountname from ccb>>'+this.accountName);
        })
        .catch(error =>{
            console.log('Error>>'+error.message);
        })
    }

    handleValidation() {
        this.valid = 0;
        let fnameCmp = this.template.querySelector(".firstName");
        let lnameCmp = this.template.querySelector(".lastName");
        let companyCmp = this.template.querySelector(".companyName");
        let accountNoCmp = this.template.querySelector(".accountNumber");
        let phoneCmp = this.template.querySelector(".phoneNumber");
        let emailCmp = this.template.querySelector(".email");
        let typeCmp = this.template.querySelector(".type");
        let subtypeCmp = this.template.querySelector(".subType");
        let descCmp = this.template.querySelector(".Description");

        if (this.firstName == null || this.firstName == undefined) {
            fnameCmp.setCustomValidity("Please provide the first name value");
            this.valid = 0;
        } 
        else {
            fnameCmp.setCustomValidity("");
            this.valid++;
        }
        fnameCmp.reportValidity();

        if (this.lastName == null || this.lastName == undefined) {
            lnameCmp.setCustomValidity("Please provide the last name value");
            this.valid = 0;
        } 
        else {
            lnameCmp.setCustomValidity("");
            this.valid++;
        }
        lnameCmp.reportValidity();

        if (this.accountName == null || this.accountName == undefined) {
            companyCmp.setCustomValidity("Please provide a valid value for company.");
            this.valid = 0;
        } 
        else {
            companyCmp.setCustomValidity("");
            this.valid++;
        }
        companyCmp.reportValidity();

        if (!phoneCmp.value) {
            phoneCmp.setCustomValidity("Please provide a valid Phone Number");
            this.valid = 0;
        } 
        else {
            phoneCmp.setCustomValidity("");
            this.valid++;
        }
        phoneCmp.reportValidity();

        if(!this.isGuest){
            if (this.accountNumber == null || this.accountNumber == undefined) {
            accountNoCmp.setCustomValidity("Please provide an Account");
            this.valid = 0;
        } 
        else {
            accountNoCmp.setCustomValidity("");
            this.valid++;
        }
        accountNoCmp.reportValidity();
        }
        
        if (!emailCmp.value) {
            emailCmp.setCustomValidity("Please provide an Email");
            this.valid = 0;
        } 
        else {
            emailCmp.setCustomValidity("");
            this.valid++;
        }
        emailCmp.reportValidity();

        if (!typeCmp.value) {
            typeCmp.setCustomValidity("Please provide Type");
            this.valid = 0;
        } 
        else {
            typeCmp.setCustomValidity("");
            this.valid++;
            if (!subtypeCmp.value) {
                subtypeCmp.setCustomValidity("Please provide Sub-Type");
                this.valid = 0;
            } 
            else {
                subtypeCmp.setCustomValidity("");
                this.valid++;
            }
            subtypeCmp.reportValidity();
        }
        typeCmp.reportValidity();

        if (!descCmp.value) {
            descCmp.setCustomValidity("Provide a Message");
            this.valid = 0;
        } 
        else {
            descCmp.setCustomValidity("");
            this.valid++;
        }
        descCmp.reportValidity();

        if(this.valid == 9 || (this.valid == 8 && this.isGuest)){
            this.handleClick();
        }
    }

    get caseType() {
        if(!this.isGuest){
            return [
                { label: 'General Enquiry', value: 'General Enquiry' },
                { label: 'Account Enquiry', value: 'Account Enquiry' },
                { label: 'Feedback', value: 'Feedback' },
            ];
        }
        else if(this.isGuest){
            return [
                { label: 'General Enquiry', value: 'General Enquiry' },
                { label: 'Feedback', value: 'Feedback' },
            ];
        }
    }

    get caseReason() {
        if(this.type == 'General Enquiry' && !this.isGuest)
        {
            return [
                { label: 'Service', value: 'Service'},
                { label: 'Pricing', value: 'Pricing'},
                { label: 'Product', value: 'Product'},
                { label: 'Laddaw® Location', value: 'Laddaw®  Location'},
                { label: 'Website', value: 'Website'},
            ];
        }
        else if(this.type == 'General Enquiry' && this.isGuest){
            return [
                { label: 'New Customer', value: 'New Customer'},
                { label: 'Pricing', value: 'Pricing'},
                { label: 'Product', value: 'Product'},
                { label: 'Laddaw® Location', value: 'Laddaw®  Location'},
                { label: 'Website', value: 'Website'},
            ];
        }
        else if(this.type == 'Account Enquiry' && !this.isGuest){
            return [
                { label: 'Credit Limit', value: 'Credit Limit' },
                { label: 'Payment Terms', value: 'Payment Terms' },
                { label: 'Payment', value: 'Payment' },
                { label: 'Pricing', value: 'Pricing' },
                { label: 'Service', value: 'Service' },
            ];
        }
        else if(this.type == 'Feedback' && !this.isGuest){
            return [
                { label: 'Service', value: 'Service' },
                { label: 'Pricing', value: 'Pricing' },
                { label: 'Product', value: 'Product' },
                { label: 'Laddaw® Location', value: 'Laddaw®  Location' },
                { label: 'Communication', value: 'Communication' },
            ];
        }
        else if(this.type == 'Feedback' && this.isGuest){
            return [
                { label: 'Service', value: 'Service' },
                { label: 'Laddaw® Location', value: 'Laddaw®  Location' },
                { label: 'Laddaw® Vehicle', value: 'Laddaw®  Vehicle' },
            ];
        }
    }

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
    }

    handleAccountNameChange(event){
        this.accountName = event.target.value;
    }

    handleAccountNumberChange(event){
        this.accountNumber = event.target.value;
    }

    handlePhoneNumberChange(event){
        this.phoneNumber = event.target.value;
    }

    handleEmailChange(event){
        this.email = event.target.value;
    }

    handleType(event) {
        this.type = event.detail.value;
    }

    handleReason(event) {
        this.reason = event.detail.value;
    }

    handleDescriptionChange(event){
        this.description = event.detail.value;
    }

    openfileUpload(event) {
         const file = event.target.files[0]
         var reader = new FileReader()
         reader.onload = () => {
             var base64 = reader.result.split(',')[1]
             this.fileData = {
                 'filename': file.name,
                 'base64': base64
             }
             console.log(this.fileData)
         }
         reader.readAsDataURL(file)
     }
     
     handleClick(){
        console.log('valid>>'+this.valid);
        this.isLoading= true;
        let caseData = {
            firstName: this.firstName,
            lastName: this.lastName,
            type: this.type,
            reason: this.reason,
            accountName: this.accountName,
            accountId: this.accountId,
            phoneNumber: this.phoneNumber,
            email: this.email,
            description: this.description
        };

        createCases({ casesData: caseData, userId: Id })
            .then(result => {
                this.isLoading = false;
                this.recordId = result;
                console.log('recordId'+ result);
                console.log('sucess case id:'+result+' case value:'+this.type+' accountId:'+this.accountId);  
                Toast.show({
                    label: 'Thank you!',
                    message: 'We have received your case. Our customer support team will contact you soon.',
                    mode: 'dismissible',
                    variant: 'success'
                }, this);              
                this.uploadFile();
                this.clearForm();
            })
            .catch(error => {
                this.isLoading = false;
                console.log('Error', error, 'error');
                this.clearForm();
            });
     }

     uploadFile() {
            const {base64, filename} = this.fileData
            uploadFile({ base64, filename, recordId:this.recordId })
            .then(result=>{
                this.fileData = null
            })
            .catch(error => {
                console.log('Error:', error.body.message, 'error');
            });
    }

    clearForm() {
        this.firstName = '';
        this.lastName = '';
        this.value='';
        this.type='';
        this.reason='';
        this.accountName='';
        this.accountId='';
        this.description='';
        this.email='';
        setTimeout(()=>{window.location.reload();},3000);
    }
}