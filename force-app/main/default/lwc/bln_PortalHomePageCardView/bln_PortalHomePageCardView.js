/**
 * @description       :
 * @author            : Sourabh Bhattacharjee
 * @group             :
 * @last modified on  : 12-10-2024
 * @last modified by  : Sourabh Bhattacharjee
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   08-12-2024   Sourabh Bhattacharjee   Initial Version
**/
import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import networkId from '@salesforce/community/Id';
import basePath from '@salesforce/community/basePath';
import communityId from '@salesforce/community/Id';
import siteId from '@salesforce/site/Id';
import getServiceAppointments from '@salesforce/apex/Bln_PortalHomePageCardViewController.getServiceAppointments';
import getCurrentUserAccountName from '@salesforce/apex/Bln_PortalHomePageCardViewController.getCurrentUserAccountName';
import getAppointmentCount from '@salesforce/apex/Bln_PortalHomePageCardViewController.getAppointmentCount';
import BLN_LOGOHEAD from '@salesforce/resourceUrl/BLN_LOGOREDYELLOW';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import AccId from '@salesforce/schema/User.AccountId';
import AccName from '@salesforce/schema/User.Account.Name';
import BLN_Iconcalender from '@salesforce/resourceUrl/BLN_Calender';
import BLN_Iconclock from '@salesforce/resourceUrl/BLN_Clock';

const fields = [ProfileName, AccId, AccName];

export default class Bln_PortalHomePageCardView extends LightningElement {
    calenderurl;
    clockurl;

    @track serviceAppointments;
    @track accountName;
    @track caseId;
    @track serviceAppointmentId;
    headUrl = BLN_LOGOHEAD;
    calenderurl = BLN_Iconcalender;
    clockurl = BLN_Iconclock;
    userProfileName;
    userId;
    accId;
    saId;
    showCard = false;
    noAppointment = false;
    count;
    currentPageName = '';
    showSpinner = true;
    connectedCallback() {
        // this.calenderurl = BLN_Iconcalender;
        // this.clockurl = BLN_Iconclock;
        console.log(this.calenderurl + '-', this.clockurl)
        const urlPath = window.location.pathname; // gets the path part of the URL
        // Split the path to get specific parts
        const pathSegments = urlPath.split('/');
        console.log('Segment---', pathSegments);
    }

    @wire(CurrentPageReference) pageRef;

    get pageInfo() {
        // Check if currentPageReference is available
        if (this.currentPageReference) {
            // Fetch the page URL path or parameters to determine the page name
            const state = this.currentPageReference.state;
            // Typically, you might find the page name in one of these parameters:
            this.currentPageName = state.c__name || state.pageName || state.actionName || 'Unknown Page';

            console.log('Current Community Page:', this.currentPageName);
        }
    }

    @wire(getRecord, { recordId: USER_ID, fields })
    userDetails({ error, data }) {
        if (data) {
            this.userProfileName = data.fields.Profile.value.fields.Name.value;
            this.userId = USER_ID;
            this.accId = data.fields.AccountId.value;
            console.log('accid', this.accId);
            //console.log('accName', data.fields.Account.value.fields.Name.value);
        } else if (error) {
            console.log('error fetching accId---', error.body.message);
        }
    }

    // Wire service to fetch the account name of the current user
    @wire(getCurrentUserAccountName)
    wiredAccountName({ error, data }) {
        if (data) {
            this.accountName = data;
        } else if (error) {
            console.error('Error fetching current user account name:', error.body.message);
        }
    }

    @wire(getAppointmentCount, { accId: '$accId' })
    wiredCount({ error, data }) {
        if (data) {
            this.count = data;
            this.showSpinner = false;
            console.log('Count---', this.count);
            if (this.count > 1) {
                this.showCard = true;
            } else if (this.count == 1) {
                this.showCard = false;
                console.log(this.caseId + '--77-', this.saId);
                let url = `${ window.location.origin }/SelfServe/s/case/${ this.caseId }/detail?sid=${ this.saId }`;
                //  console.log('Generated URL:', url);
                if (this.caseId && this.saId) {
                    window.location.href = url;
                }
            } else if (this.count < 1) {
                this.noAppointment = true;

                console.log(this.count + '--LINE 82---', this.showCard + 'noappp--', this.noAppointment);
            }
        } else if (error) {
            console.error('Error fetching current account count:', error.body.message);
        }
    }
    connectedCallback() {
        const currentPage = this.pageRef?.attributes?.name;
        console.log('currpage', currentPage);
        const before_ = `${ basePath }`.substring(0, `${ basePath }`.indexOf('/s') + 1);
        const communityUrl = `https://${ location.host }${ before_ }`;
        console.log('comur---', communityUrl);

    }

    /* fetchCount() {
         // publish(this.messageContext, SELECTED_CASE_CHANNEL, { caseId: this.recordId })
         getAppointmentCount({ accId: this.accId })
             .then(response => {
                 console.log('response 109', response);

             })
             .catch(error => {
                 console.log('error---', error.body.message);
             });

     }*/

    // Wire service to fetch the service appointments
    @wire(getServiceAppointments)
    wiredserviceAppointment({ error, data }) {
        if (data) {
            console.log(this.showCard + '--Data28----', this.noAppointment + 'data--', data.length);
            if (!this.showCard && data.length == 1) {
                console.log(this.showCard + '--Data28----', this.noAppointment + 'data--', data.length);
                this.caseId = data[0].caseId;
                this.saId = data[0].id;
                //let url = `${ window.location.origin }/SelfServe/s/case/${ this.caseId }/detail?sid=${ this.saId }`;
                //console.log('Generated URL:', url);
                // window.location.href = url;
            } else if (data.length == 0) {
                let urlNoData = `${ window.location.origin }/SelfServe/s/loginmessagepagecompleted`;
                console.log('Generated URL:', urlNoData);
                window.location.href = urlNoData;
                console.log(data.length + 'here---', this.noAppointment)
            }
            this.serviceAppointments = data.map(appointment => ({
                ...appointment,
                formattedArrivalWindowStartDate: this.formatDate(appointment.arrivalWindowStartTime),
                formattedArrivalWindowStartTime: this.formatTime(appointment.arrivalWindowStartTime)
            }));
        } else if (error) {
            console.error('Error fetching serviceAppointments:', error.body.message);
        }
    }

    // Method to format the date
    formatDate(dateTimeStr) {
        const date = new Date(dateTimeStr);
        const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        const monthsOfYear = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        const dayOfWeek = daysOfWeek[date.getUTCDay()];
        const dayOfMonth = date.getUTCDate();
        const month = monthsOfYear[date.getUTCMonth()];
        return `${ dayOfWeek } ${ dayOfMonth } ${ month }`;
    }

    // Method to format the time
    formatTime(dateTimeStr) {
        const date = new Date(dateTimeStr);
        const options = { hour: '2-digit', minute: '2-digit', hour12: false };
        return date.toLocaleTimeString(undefined, options);
    }

    // Handler for the View Details button click
    handleViewDetails(event) {
        event.preventDefault();
        this.caseId = event.currentTarget.dataset.id;
        this.serviceAppointmentId = event.currentTarget.dataset.secondId;
        let url = '/SelfServe/s/case/';
        url += this.caseId + '/detail' + '?sid=' + this.serviceAppointmentId;
        window.location.href = url;
    }
}