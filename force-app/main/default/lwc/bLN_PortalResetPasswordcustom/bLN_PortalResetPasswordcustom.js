/**  
 * -----------------------------------------------------------------------------  
 * @description   : Used for Resetting User Password via B2C Portal  
 * @author        : Sourabh Bhattacharjee  
 * @story         : FOUK-10951/FOUK-12039/FOUK-12037/OUK-12033/FOUK-12018  
 * @last_modified : 12-06-2024  
 * @modified_by   : Sourabh Bhattacharjee  
 * -----------------------------------------------------------------------------  
 * Modifications Log:  
 * -----------------------------------------------------------------------------  
 * Version  | Date       | Author                | Modification  
 * -----------------------------------------------------------------------------  
 * 1.0      | 12-05-2024 | Sourabh Bhattacharjee | Initial Version  
 * -----------------------------------------------------------------------------  
 */  
import { LightningElement, track, wire,api } from 'lwc';  
import { CurrentPageReference } from 'lightning/navigation';  
import { ShowToastEvent } from 'lightning/platformShowToastEvent';  
import resetPassword from '@salesforce/apex/BLN_ForgetPasswordHandler.resetPassword';  
//import getAccountIdFromContactId from '@salesforce/apex/BLN_ForgetPasswordHandler.getPasswordChangeDateForContact'; 
import getPasswordChangeDateForContact from '@salesforce/apex/BLN_ForgetPasswordHandler.getPasswordChangeDateForContact';  
import BLN_LOGOHEAD from '@salesforce/resourceUrl/BLN_LOGOREDYELLOW';
import BLN_eyeicon from '@salesforce/resourceUrl/BLN_eyeicon';
import BLN_LOGO from '@salesforce/resourceUrl/BLN_AutoglassLogo';
import Email from '@salesforce/schema/Contact.Email';
import ACCID from '@salesforce/schema/Contact.AccountId';
import { getRecord } from 'lightning/uiRecordApi';
import errToast from "@salesforce/label/c.BLN_ResetPasswordToast"; 
import ForgotPassword from '@salesforce/label/c.BLN_ForgotPasswordNew';  
import { NavigationMixin } from 'lightning/navigation';
import ForgotLink from "@salesforce/label/c.BLN_ForgotPasswordNew";
import ForgotPasswprdmsg from '@salesforce/label/c.BLN_Portelresetpasswordmsg'; 



const fields = [Email,ACCID];

export default class BLN_PortalResetPasswordcustom extends NavigationMixin(LightningElement) { 

   @track label = {
        ForgotPassword,
        ForgotLink,
        ForgotPasswprdmsg
         
    }
    resetmsg=ForgotPasswprdmsg;
    passwordChangeDate;
    urldate;
    @api logoUrl;
    @api eyeurl; 
    @api headUrl;
    @track newPassword = '';  
    @track confirmPassword = '';  
    @track error = '';  
    @track successMessage = '';  
    @track accountId;  
    @track generatedUrl;   
    contactId = ''; 
    @api conId;
    conEmail;
    accId;	
    debounceTimeout;
    newPasswordType = 'password';  
    newPasswordIcon = 'utility:preview';  
    confirmPasswordType = 'password';  
    confirmPasswordIcon = 'utility:preview';  
    @track label = {errToast};
    @track showErrorMessage = false;
    showSpinner = false;
    @track showOverlay = false; 
    @wire(CurrentPageReference)  
    getStateParameters(currentPageReference) {  
        if (currentPageReference) {  
            this.contactId = currentPageReference.state.ConId;  
        }  
    }  
    connectedCallback() {
        this.headUrl = BLN_LOGOHEAD;
        this.eyeurl = BLN_eyeicon;
        this.logoUrl = BLN_LOGO;
		const urlParams = new URLSearchParams(window.location.search);  
        this.conId = urlParams.get('ConId');
        const systemParam = urlParams.get('system');  
        console.log(systemParam); 
        const decodedTime = decodeURIComponent(systemParam);  
        this.urldate=decodedTime;
        console.log('urldate',this.urldate); 
        console.log(decodedTime); 
        const extractedDate = new Date(decodedTime);  
  
       
        const currentDate = new Date();  

        // Calculate the difference in milliseconds  
        const diffInMilliSeconds = currentDate - extractedDate;  

        // Convert the difference to hours  
        const diffInHours = diffInMilliSeconds / (1000 * 60 * 60);  

      
        if (diffInHours > 15) {  
            this.errorMessage = 'The time in the URL is more than 24 hours ago.';  
            this.showOverlay = true;
            console.error(this.errorMessage);  
            console.log('83 this.showOverlay', this.showOverlay);
        } else {  
            this.errorMessage = ''; 
            this.showOverlay = false; 
            console.log('The time in the URL is within the last 24 hours.'); 
            console.log('84 this.showOverlay', this.showOverlay); 
        }  
    }
  
   
  
     @wire(getRecord, { recordId: '$conId', fields })
    userDetails({ error, data }) {
        console.log('110datad', data)
        if (data) {
            
             this.conEmail=data.fields.Email.value;
             this.accId = data.fields.AccountId.value;
             console.log('this.accId', this.accId);
        } else if (error) {
            console.error('error fetching accId---', error.body.message);
        }
    }
	
   


@wire(getPasswordChangeDateForContact, { contactId: '$conId' })  
wiredPasswordChangeDate({ error, data }) {  
    if (data) {  
        try {  
            // Adjust the format of data to be compatible with JavaScript Date  
            const formattedDate = data.replace(/(\+\d{2})(\d{2})$/, '$1:$2');  
            this.passwordChangeDate = new Date(formattedDate);  
            console.log('this.passwordChangeDate:', this.passwordChangeDate);  
  
            // Assuming this.urldate is a properly initialized variable containing a date string  
            // Ensure `this.urldate` is not undefined and is a valid date string  
            if (!this.urldate) {  
                throw new Error('URL date string is undefined or empty.');  
            }  
  
            // Decode the URL-encoded date string  
            const decodedUrlDateString = decodeURIComponent(this.urldate);  
            console.log(decodedUrlDateString);
            // Create a Date object from the decoded string  
            const urlDate = new Date(decodedUrlDateString);  
            console.log('urlDate175',urlDate);
            // Check if urlDate is a valid Date object  
            if (isNaN(urlDate.getTime())) {  
                throw new Error('Decoded URL date string is not a valid date.');  
            }  
  
            // Compare the two dates  
            if (this.passwordChangeDate > urlDate) {  
                console.error('Password change date is greater than the URL date.');  
                this.showOverlay = true;  
            } else {  
                console.log('Password change date is not greater than the URL date.');  
            }  
        } catch (e) {  
            console.error('Error processing dates:', e.message);  
            this.showOverlay = false;  
        }  
    } else if (error) {  
        console.error('Error retrieving password change date:', error);  
        this.passwordChangeDate = null;  
    }  
}  

	
    handlePasswordChange(event) {  
        this.newPassword = event.target.value;
        this.checkPasswordsMatch();  
        if (this.debounceTimeout) {  
            clearTimeout(this.debounceTimeout);  
        } 
        this.debounceTimeout = setTimeout(() => {  
            this.validatePassword1(this.newPassword);  
        }, 300);   
    }  
  
    handleConfirmPasswordChange(event) {  
        this.confirmPassword = event.target.value; 
        this.checkPasswordsMatch(); 
        if (this.debounceTimeout) {  
            clearTimeout(this.debounceTimeout);  
        } 
        this.debounceTimeout = setTimeout(() => {  
            this.validatePassword2(this.confirmPassword);  
        }, 300); 
    }  
  
    checkPasswordsMatch() {  
        
            this.showErrorMessage = this.newPassword !== this.confirmPassword;  
        }
     
   

  
    async handleResetPassword() {  
        if (this.showErrorMessage) {  
            this.showToast('Error', 'Passwords do not match!', 'error');  
            return;  
        }  
        else{
        this.resetPassword();
        }
    }  

    resetPassword(){
        resetPassword({ contactId: this.contactId, newPassword: this.newPassword})
            .then((result => {
                if(result=='The email failed to send'){
                    this.showToast('Error',this.label.errToast, 'error'); 
                    this.newPassword='';
                    this.confirmPassword='';
                }else{
                    this.showSpinner = true;
                    window.location.href = result;  
                }
            }))
            .catch((error => {
                console.error('ERR while doing password reset--->', error);
            }))
    }
  
    toggleNewPasswordVisibility() {  
        if (this.newPasswordType === 'password') {  
            this.newPasswordType = 'text';  
            this.newPasswordIcon = 'utility:hide';  
        } else {  
            this.newPasswordType = 'password';  
            this.newPasswordIcon = 'utility:preview';  
        }  
    }  
  
    toggleConfirmPasswordVisibility() {  
        if (this.confirmPasswordType === 'password') {  
            this.confirmPasswordType = 'text';  
            this.confirmPasswordIcon = 'utility:hide';  
        } else {  
            this.confirmPasswordType = 'password';  
            this.confirmPasswordIcon = 'utility:preview';  
        }  
    }  
    validatePassword1(password) {  
        const letterPattern = /[a-zA-Z]/;  
        const numberPattern = /[0-9]/;  
        const specialCharacterPattern = /[!@#$%^&*()_+\-={}[\]\\|;:',.?/`~><"]/;  
        console.log('password length is ',password.length);
    if (password.length < 16000) {  
        if (password.length >= 8 &&  
            letterPattern.test(password) && numberPattern.test(password) && specialCharacterPattern.test(password)) {  
            this.newPassword = password;  
        } else {  
            this.showToast('Error', 'Password must be at least 8 characters long and include letters, numbers, and at least one special character.', 'error');  
        }  
    } else {  
        if (!letterPattern.test(password) || !numberPattern.test(password) ||  !specialCharacterPattern.test(password)) {  
            this.showToast('Error', 'Password must include letters, numbers, and at least one special character & should be within 16000 characters.', 'error');  
        } else {  
            this.showToast('Error', 'Password length cannot exceed 16000 characters.', 'error');  
        }  
    }  
    }  
    
    validatePassword2(password) {  
        const letterPattern = /[a-zA-Z]/;  
        const numberPattern = /[0-9]/;  
        const specialCharacterPattern = /[!@#$%^&*()_+\-={}[\]\\|;:',.?/`~><"]/;  
        console.log('password length is ',password.length);
    if (password.length < 16000) {  
        if (password.length >= 8 &&  
            letterPattern.test(password) && numberPattern.test(password) && specialCharacterPattern.test(password)) {  
            this.confirmPassword = password;  
        } else {  
            this.showToast('Error', 'Password must be at least 8 characters long and include letters, numbers, and at least one special character.', 'error');  
        }  
    } else {  
        if (!letterPattern.test(password) || !numberPattern.test(password) ||  !specialCharacterPattern.test(password)) {  
            this.showToast('Error', 'Password must include letters, numbers, and at least one special character & should be within 16000 characters.', 'error');  
        } else {  
            this.showToast('Error', 'Password length cannot exceed 16000 characters.', 'error');  
        }  
    }  
    }  
    
    showToast(title, message, variant) {  
        const event = new ShowToastEvent({  
            title: title,  
            message: message,  
            variant: variant,  
        });  
        this.dispatchEvent(event);  
    }  
    
    // @wire(getAccountIdFromContactId, { contactId:'$conId' })  
    
    // wiredAccountId({ error, data }) {  
    //     if (data) {  
    //         this.accountId = data;  
    //     } else if (error) {  
    //         console.error('Error retrieving account ID:', error);  
    //     }  
        
    // }  
  
    handleGenerateUrl() { 
        if(this.accId){
            //let baseUrl = this.label.ForgotLink;  
            let url =  `${ForgotLink}${this.accId}`;  
            console.log('url', url);
            window.open(url);
         //console.log('url',url);
        
        }else{
            let url =  `${ForgotLink}`;
            let result = url.split('-new')[0] + '-new';  // Keep everything before and including '-new'
            console.log(result);  
            //console.log('url', url);
            window.open(result);
        }
        
    

      }
    
}