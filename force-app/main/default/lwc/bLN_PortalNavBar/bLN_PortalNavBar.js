/**
 * @description       : B2C portal Navigtion Bar with Header with menu options
 * @author            : Sourabh Bhattacharjee
 * @group             :
 * @last modified on  : 01-17-2025
 * @last modified by  : Sourabh Bhattacharjee
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   09-12-2024   Sourabh Bhattacharjee   Initial Version
**/
import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import BLN_LOGO from '@salesforce/resourceUrl/BLN_AutoglassLogo';
import BLN_USERLOGO from '@salesforce/resourceUrl/BLN_UserautoglassLogo';
import BLN_DROPLOGO from '@salesforce/resourceUrl/BLN_UserdropdownLogo';
import BLN_NAVARROWLOGO from '@salesforce/resourceUrl/BLN_NavBarArrow';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import AccId from '@salesforce/schema/User.AccountId';
import AccName from '@salesforce/schema/User.Account.Name';
import COM_URL from '@salesforce/schema/User.Account.BLN_Community_URL__c';
import getAppointmentCount from '@salesforce/apex/Bln_PortalHomePageCardViewController.getAppointmentCount';
import getServiceAppointments from '@salesforce/apex/Bln_PortalHomePageCardViewController.getServiceAppointments';
import { NavigationMixin } from "lightning/navigation";

const fields = [ProfileName, AccId, AccName, COM_URL];

export default class BLN_PortalNavBar extends NavigationMixin(LightningElement) {
    @api logoUrl;
    @api userUrl;
    @api dropUrl;
    navBarArrowImage;
    currentPageName = '';
    userProfileName;
    userId;
    accId;
    accName;
    hideNavText = true;
    value = '';
    comUrl;
    isHome = false;
    count;
    caseId;
    serviceAppointmentId;
    hidePortion = false;
    logoPointer;



    @wire(getRecord, { recordId: USER_ID, fields })
    userDetails({ error, data }) {
        if (data) {
            this.userProfileName = data.fields.Profile.value.fields.Name.value;
            this.userId = USER_ID;
            this.accId = data.fields.AccountId.value;
            this.accName = data.fields.Account.value.fields.Name.value;
            this.comUrl = data.fields.Account.value.fields.BLN_Community_URL__c.value;
        } else if (error) {
            console.error('error fetching accId---', error.body.message);
        }
    }

    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {
        this.checkUrl();
        this.navBarArrowImage = BLN_NAVARROWLOGO;
        this.logoUrl = BLN_LOGO;
        this.userUrl = BLN_USERLOGO;
        this.dropUrl = BLN_DROPLOGO;
        const currentUrl = window.location.href;
    
        // Check if the URL contains 'SelfServe/s/case'
        if (
            currentUrl.includes('/SelfServe/s/forgot-password-new') ||
            currentUrl.includes('/SelfServe/s/reset-password-custom') ||
            currentUrl.includes('/SelfServe/s/loginmessagepagecompleted')||
            currentUrl.includes('/SelfServe/s/forget-password-new')
        ) {
            this.hidePortion = true;
        }
        if (this.hidePortion == true) {
            this.logoPointer = "cursor:none; pointer-events: none;"
        } else {
           // this.logoPointer = "cursor:default";
            this.logoPointer = "cursor:pointer"
        }
    }

    @wire(getAppointmentCount, {
        accId: '$accId'
    })
    wiredCount({ error, data }) {
        if (data) {
            this.count = data;
        } else if (error) {
            console.error('Error fetching current account count:', error.body.message);
        }
    }

    // Wire service to fetch the service appointments
    @wire(getServiceAppointments)
    wiredserviceAppointment({ error, data }) {
        if (data) {
            if (data.length == 1) {

                this.caseId = data[0].caseId;
                this.serviceAppointmentId = data[0].id;
            }
        } else if (error) {
            console.error('Error fetching serviceAppointments:', error.body.message);
        }
    }


    checkUrl() {
        const currentUrl = window.location.href;
        // Check if the URL contains 'SelfServe/s/case'
        if (currentUrl.includes('/SelfServe/s/case')) {
            this.value = '  Appointment details';
        } else if (currentUrl.includes('/SelfServe/s/profile')) {
            this.value = '  Account';
        } else if (currentUrl.includes('/SelfServe/s/settings')) {
            this.value = '  Password';
        } else if (currentUrl.includes('/SelfServe/s/insurance-details')) {
            this.value = '  Insurance Form';
        }
        else if (currentUrl.includes('/SelfServe/s/article/Did')) {
            this.value = ' How do I make a complaint?';
        } else if (currentUrl.includes('/SelfServe/s/worldpayportalpage')) {
            this.value = 'Payment';
        } else if (currentUrl.includes('/SelfServe/s/article/Is')) {
            this.value = 'Is the work covered by a guarantee?';
        } else if (currentUrl.includes('/SelfServe/s/article/How')) {
            this.value = 'How long will it be before I can drive my vehicle?';
        }
        else {
            this.isHome = true;
        }
    }

  handleLogoClick() {  
        window.open('https://www.autoglass.co.uk/', '_blank');  
    }  
    handleHomeClick() {
        const baseUrl = window.location.origin;
        // Append the desired path to the base URL
        const fullUrl = `${ baseUrl }/SelfServe/s/`;
        if (this.count == 1) {
            let url1 = `${ window.location.origin }/SelfServe/s/case/${ this.caseId }/detail?sid=${ this.serviceAppointmentId }`;
            if (this.caseId && this.serviceAppointmentId) {
                window.location.href = url1;
            }
        } else if (this.count == 0) {
            let urlNoData = `${ window.location.origin }/SelfServe/s/loginmessagepagecompleted`;
            window.location.href = urlNoData;
        } else {
            window.location.href = fullUrl;
        }
    }
    handleProfileView() {
        const baseUrl = window.location.origin;
        const path = '/SelfServe/s/profile/';
        const identifier = this.userId;
        const fullUrl = `${ baseUrl }${ path }${ identifier }`;
        window.location.href = fullUrl;
    }
    handlePasswordView() {
        const baseUrl = window.location.origin;
        const path = '/SelfServe/s/settings/';
        const identifier = this.userId;
        const fullUrl = `${ baseUrl }${ path }${ identifier }`;
        window.location.href = fullUrl;
    }
    handleLogout() {
        const LOGOUTPAGEREF = {
            type: "comm__loginPage",
            attributes: {
                actionName: "logout"
            }
        };

        this[NavigationMixin.Navigate](LOGOUTPAGEREF);
        setTimeout(() => {
            // URL of the custom logout page
            const customLogoutUrl = this.comUrl; // Replace with your custom logout page URL
            window.location.href = customLogoutUrl;
        }, 1000);

    }
}