import { LightningElement,wire} from 'lwc';    
import MultipleUser from '@salesforce/apex/BLN_ForgetPasswordHandler.checkMultiplePersonAccount';    
import SearchPersonAccAndLogin from '@salesforce/apex/BLN_ForgetPasswordHandler.searchPersonAccAndLogin';    
import sendLeadOverlapCompleteNotification from '@salesforce/apex/BLN_ForgetPasswordHandler.sendLeadOverlapCompleteNotification';
import getEmailByAccountId from '@salesforce/apex/BLN_ForgetPasswordHandler.getEmailByAccountId';
import COM_URL from '@salesforce/schema/Account.BLN_Community_URL__c';
import BLN_LOGOHEAD from '@salesforce/resourceUrl/BLN_LOGOREDYELLOW';   
import { getRecord } from 'lightning/uiRecordApi'; 

const fields = [COM_URL];
export default class BLN_ForgetPassword extends LightningElement {  
    headUrl;  
    isMultiplePersonAcc = false; 
    issingleacc =  false; 
    userEmailId = '';    
    bookingRefernce = '';   
    message = ''; // Add this line  
    accountId = ''; // Add this line  
    showModal = false;
    emailError = '';  
    mailSent = false;
    message2 = '';
    message3 = '';
    hidebookingref = false; 
    comUrl;
    
    connectedCallback() {  
        this.headUrl = BLN_LOGOHEAD;
        const urlParams = new URLSearchParams(window.location.search);  
        this.accountId = urlParams.get('accId');  
        console.log('Account ID from URL:', this.accountId);  
        if (this.accountId) {  
            this.fetchEmailByAccountId();  
        }  
    }   

    @wire(getRecord, { recordId: '$accountId', fields })
    userDetails({ error, data }) {
        if (data) {
             console.log('data---', data);
             this.comUrl=data.fields.BLN_Community_URL__c.value;
             console.log('comUrl---', this.comUrl);
        } else if (error) {
            console.log('error fetching accId---', error.body.message);
        }
    }

    // handleKeyDown(event) {  
    //     // Allow: backspace, delete, tab, escape, enter, period, and minus  
    //     if ([46, 8, 9, 27, 13, 110, 190, 189].indexOf(event.keyCode) !== -1 ||  
    //         // Allow: Ctrl+A, Command+A  
    //         (event.keyCode === 65 && (event.ctrlKey === true || event.metaKey === true)) ||  
    //         // Allow: home, end, left, right, down, up  
    //         (event.keyCode >= 35 && event.keyCode <= 40)) {  
    //         // let it happen, don't do anything  
    //         return;  
    //     }  
    //     // Ensure that it is a number and stop the keypress if not  
    //     if ((event.shiftKey || (event.keyCode < 48 || event.keyCode > 57)) &&  
    //         (event.keyCode < 96 || event.keyCode > 105)) {  
    //         event.preventDefault();  
    //     }  
    // }
    
    handleOnChangeEmail(event) {    
        this.userEmailId = event.target.value;    
        console.log('Email updated:', this.userEmailId);    
    }    
    
    handleClickOnResetButton() {    
        console.log('handleClickOnResetButton called25');
        
        console.log('userEmailId26:', this.userEmailId);    
        console.log('bookingRefernce27:', this.bookingRefernce); 
        console.log('accountId28:', this.accountId);  
        if (!this.isValidEmail(this.userEmailId)) {  
            this.emailError = 'Please enter a valid email address';  
            return;  
        } else {  
            this.emailError = '';  
        }  

        if (this.accountId && this.isMultiplePersonAcc === false) {  
            this.checkMultiplePersonAccount(); 
        } else if (this.isMultiplePersonAcc === true) {  
            console.log('No booking reference provided, checking for multiple person accounts');  
            this.searchUserByCase();  
        } else if ((this.bookingReference === '' || this.bookingReference === undefined)&&(this.accountId === null||this.accountId === undefined) ){  
            console.log('No booking reference provided, checking for multiple person accounts');  
            this.checkMultiplePersonAccount();  
        } else {  
            this.searchUserByCasenew();  
            console.log('else 61No booking reference provided, checking for multiple person accounts'); 
        }  
    }  



      
    
    isValidEmail(email) {  
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;  
        return emailRegex.test(email);  
    }  
    checkMultiplePersonAccount() {    
        console.log('checkMultiplePersonAccount called with emailId:', this.userEmailId);    
        MultipleUser({ emailId: this.userEmailId })    
            .then(result => {    
                this.isMultiplePersonAcc = result;    
                console.log('checkMultiplePersonAccount result:', result);  
                
                if (result) {      
                    console.log('Multiple person account found.');      
                    this.updateUrlParam('isMultiplePersonAcc', true);   
                    if (this.accountId === null) {  
                        console.log('Account ID is null.');  
                        searchUserByCase();   
                    } else {  
                        console.log('Account ID is not null.');  
                        this.searchUserByCasenew(); 
                    } 
                     
                } else {      
                    console.log('No multiple person account found.');      
                    this.updateUrlParam('isMultiplePersonAcc', false);   
                    console.log('searchUserByCasenew call 91');   
                    this.searchUserByCasenew(); // Ensure the method is correctly called on the instance  
                }  
            })    
            .catch(error => {    
                console.error('Error in checkMultiplePersonAccount:', error);    
            });    
    }    
    
    get multiUser() {    
        console.log('multiUser getter called');    
        console.log('isMultiplePersonAcc:', this.isMultiplePersonAcc);    
        return this.isMultiplePersonAcc; 
     
    }    

    get hideBookingRef() {  
        return this.isMultiplePersonAcc === true && this.accountId == null;  
    }  

    
    handleChangeBookingRef(event) {    
        this.bookingRefernce = event.target.value;    
        console.log('Booking reference updated:', this.bookingRefernce);    
    }    
    
    searchUserByCase() {    
        console.log('searchUserByCase called with caseNumber:', this.bookingRefernce, 'and emailId:', this.userEmailId);    
        SearchPersonAccAndLogin({ emailId: this.userEmailId, caseNumber: this.bookingRefernce })    
            .then(result => {    
                if (result === 'Case found and email sent') {  
                    this.message = 'Your password reset email has been sent.';   
                    // this.showModal = true; 
                    this.mailSent = true;
                } else if (result === 'No matching case found') {  
                    this.message2 = 'Booking Reference number not found. Please verify and try again.'; 
                    // this.showModal = true;  
                } else {  
                    this.message2 = 'Unexpected result';  
                }  
            })    
            .catch(error => {    
                console.error('Error in searchUserByCase:', error);    
            });    
    }    

    searchUserByCasenew() {    
        console.log('searchUserByCase called with caseNumber88:', this.bookingRefernce, 'and emailId:', this.userEmailId, 'andaccountid',this.accountId);    
        sendLeadOverlapCompleteNotification({ emailId: this.userEmailId,accountId: this.accountId })    
        .then(result => {      
            console.log('result 131:',result);    
            if (result === 'Email sent') {  
                this.message = 'Your password reset email has been sent.';     
                // this.showModal = true;  
                this.mailSent = true; 
            } else {  
                this.message3 = 'There was an error sending the password reset email. Please try again later.';     
                
            }  
        })   
            .catch(error => {    
                console.error('Error in searchUserByCase:', error);    
            });    
    }

    closeModal() {  
        this.showModal = false;  
        window.close(); // Close the tab  
    }  
    handleCancel() {
        window.history.back();
    }

    updateUrlParam(key, value) {  
        const url = new URL(window.location);  
        url.searchParams.set(key, value);  
        window.history.pushState({}, '', url);  
    }  
    fetchEmailByAccountId() {  
        getEmailByAccountId({ accountId: this.accountId })  
            .then(result => {  
                this.userEmailId = result;  
                console.log('Email fetched from account:', this.userEmailId);  
            })  
            .catch(error => {  
                console.error('Error fetching email by account ID:', error);  
            });  
    }  

    handleBackToLogin(){
        if(this.accountId){
            window.location.href = this.comUrl;
        }else{
            let urlNoData = `${ window.location.origin }/SelfServe/BLRCommunityLoginPage`;
            window.location.href = urlNoData;
        }
    }
}