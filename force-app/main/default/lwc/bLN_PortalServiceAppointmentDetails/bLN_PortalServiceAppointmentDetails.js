/**
 * -----------------------------------------------------------------------------  
 * @description   : Used for Shown Details of a ServiceAppointment, like Case Number, Status etc..
 * @author        : Sourabh Bhattacharjee  
 * @story         : FOUK-7607/FOUK-11879/FOUK-8026
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
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchSArecord from '@salesforce/apex/BLN_PortalServiceAppointmentDController.fetchSArecord';
import getCurrentUserAccountName from '@salesforce/apex/BLN_PortalServiceAppointmentDController.getCurrentUserAccountName';
import fetchParentAndChildCases from '@salesforce/apex/BLN_PortalServiceAppointmentDController.fetchParentAndChildCases'; // Added import
import getMatchingNoShowCriteria from '@salesforce/apex/BLN_NoShowCriteriaChecker.getMatchingNoShowCriteria';
import checkAccess from '@salesforce/apex/BLN_PortalServiceAppointmentDController.checkAccess';
/*r 2.1 work
import checkInsuranceCheck from '@salesforce/apex/BLN_PortalServiceAppointmentDController.checkBvtTask';
import checkInsuranceTaskCheck from '@salesforce/apex/BLN_PortalServiceAppointmentDController.checkInsuranceTask';
import getFiles from '@salesforce/apex/BLN_DisplayDocStoreRecordsController.getFileDetails';
import getItemId from '@salesforce/apex/BLN_PortalServiceAppointmentDController.fetchItemId';
*/
import BLN_LOGO from '@salesforce/resourceUrl/BLN_ChatLogo';
import BLN_LOGO1 from '@salesforce/resourceUrl/BLN_PhoneLogo';
import BLN_LOGOHEAD from '@salesforce/resourceUrl/BLN_LOGOREDYELLOW';
import BLN_PortalCaseId from '@salesforce/label/c.BLN_PortalCaseId';
import BLN_Iconsuccess from '@salesforce/resourceUrl/BLN_Success';
import BLN_Iconcalender from '@salesforce/resourceUrl/BLN_Calender';
import BLN_Iconclock from '@salesforce/resourceUrl/BLN_Clock';
import BLN_Iconinfo from '@salesforce/resourceUrl/BLN_INFO';
import BLN_Iconshipping from '@salesforce/resourceUrl/BLN_Shipping';
import BLN_Iconinprogress from '@salesforce/resourceUrl/BLN_Inprogress';
import BLN_Iconinsuance from '@salesforce/resourceUrl/BLN_Insurance';


export default class BLN_PortalServiceAppointmentDetails extends NavigationMixin(LightningElement) {
    @api successUrl;
    @api isAppointmentNotCompleted;
    @api infourl;
    BLN_Iconsuccess;
    BLN_Iconshipping;
    BLN_Iconinprogress;
    BLN_Iconinsuance;
    @api headUrl;
    @api chatUrl;
    @api phUrl;
    @api recordId;
    @api caseId;
    @api sId;
    @track isModalOpen = false; //FOUK:8452
    @track showRebookModal = false;//FOUK:8452
    @track matchingCriteria = []; //FOUK :8205
    @track hasMatch;//  = false;//FOUK :8205
    @track noMatch = false;//FOUK :8205
    @track docStoreRecordList;
    appointments;
    error;
    subscription = null;
    accountName;
    label = { BLN_PortalCaseId }
    portalServiceAppointment;
    isLoading = true;
    parentAndChildCases; // Added property for parent and child cases
    //FOUK :8205 START
    @api criteriaA;
    @api MatchFoundB;
    @track noShowData = [];
    @track status;
    appointmentId;
    itemId;
    showInsuranceButton = false;
    showReport = false;
    isCommunity = true;
    @track fileList = [];
    onreload = false;
    childError;
    hasError;
    stack;
    currentPageInfo;

    //**Used for Handling Child Component Errors */
    errorCallback(error, stack) {
        this.hasError = true;
        this.childError = error;
        console.log('ERR coming from child---', JSON.parse(JSON.stringify(this.childError)));
    }
    //FOUK :8205 END
    @wire(getCurrentUserAccountName)
    wiredAccountName({ error, data }) {
        if (data) {
            this.accountName = data;
        } else if (error) {
            console.error('Error fetching current user account name:', error.body.message);
        }
    }

    connectedCallback() {
        this.calenderurl = BLN_Iconcalender;
        this.clockurl = BLN_Iconclock;
        this.infourl = BLN_Iconinfo;
        this.successUrl = BLN_Iconsuccess;
        this.headUrl = BLN_LOGOHEAD;
        this.chatUrl = BLN_LOGO;
        this.phUrl = BLN_LOGO1;
        this.fetchData();
        const currentUrl = window.location.href;
        const url = new URL(currentUrl);
        const searchParams = new URLSearchParams(url.search);
        const sid = searchParams.get('sid');
        this.appointmentId = sid;
        if(this.recordId && this.appointmentId){
            this.checkRecordAccess();
        }
        this.fetchParentAndChildCasesData(); // Call method to fetch parent and child cases
        //this.fetchMatchingNoShowCriteria(); // FOUK :8205
    }

    checkRecordAccess(){
       checkAccess({ caseId: this.recordId,appId:this.appointmentId })
            .then(response => {
                console.log('RES fr checkAccess--->',response);
            })
            .catch(error => {
                console.error('Error checking rec acccess:', error.body.message);
            });  
    }
    /*r2.1 work
    showButton() {
        checkInsuranceCheck({ caseId: this.recordId })
            .then(response => {
                if (response == false) {
                    console.log('showInsuranceButton', this.showInsuranceButton);
                    this.showInsuranceButton = true;
                }
            })
            .catch(error => {
                console.error('Error fetching instask:', error.body.message);
            });
    }
    checkInsTask() {
        checkInsuranceTaskCheck({ caseId: this.recordId })
            .then(response => {
                if (response == true) {
                    this.showInsuranceButton = false;
                }
            })
            .catch(error => {
                console.error('Error fetching InsuranceTaskCheck:', error.body.message);
            });
    }

    fetchItemId() {
        getItemId({ appointmentId: this.appointmentId })
            .then(result => {
                this.itemId = result;
                console.log('this.itemId---', this.itemId);
                this.fetchFiles();
            })
            .catch(error => {
                console.error('Error fetching fetchItemId:', error.body.message);
            });
    }


    fetchFiles() {
        getFiles({ parentId: this.itemId, isCommunity: this.isCommunity })
            .then(result => {
                result = JSON.parse(JSON.stringify(result));
                console.log(result.fileList.length + '--res---', result);
                if (result.fileList.length > 0) {
                    this.showReport = true;
                } else {
                    this.showReport = false;
                }

                // Transform the fileList array
                this.fileList = result.fileList.map(file => {
                    return {
                        ...file,
                        BLN_FileType__c: file.BLN_FileType__c.toLowerCase(),
                        BLN_FileSize__c: (file.BLN_FileSize__c / 1000).toFixed(2).toString()
                    };
                });

                console.log(this.fileList.length + '--fileList---', JSON.stringify(this.fileList));
            })
            .catch(error => {
                console.log('error fetching report', error.body.message);
            });
    }*/

    fetchData() {
        const windowLocation = window.location.href;
        fetchSArecord({ recordId: this.recordId, windowLocation: windowLocation })
            .then(result => {
                this.portalServiceAppointment = JSON.parse(result);
                this.sId = this.portalServiceAppointment.SAid;
                this.isLoading = false;
                // FOUL:9102 STARTS Check status and perform actions based on 'dispatch'
                const arrivalWindowStart = new Date(this.portalServiceAppointment.aWstarttime);
                const today = new Date();
                today.setHours(0, 0, 0, 0); // Set current date time to start of the day
                // Extract date part from arrivalWindowStart
                const arrivalWindowStartDay = new Date(arrivalWindowStart.getFullYear(), arrivalWindowStart.getMonth(), arrivalWindowStart.getDate());
                // Compare status and date
                if (this.portalServiceAppointment.saStatus === 'Dispatched' ||
                    this.portalServiceAppointment.saStatus === 'Completed' ||
                    this.portalServiceAppointment.saStatus === 'Canceled' ||
                    arrivalWindowStartDay < today) {
                    // Example method to open modal
                    this.showRebookModal = false; // Hide rebook Change Appointment
                }
                else {
                    this.showRebookModal = true; // Show rebook modal
                }
            })
            .catch(error => {
                console.error('error fetchData---', JSON.stringify(error));
                this.isLoading = false;
            });
    }

    //SA status
    get iconName() {
        switch (this.portalServiceAppointment.portalStatusName) {
            case 'Glass is on the Way':
                return '/SelfServe/resource/1720075767000/BLN_Shipping';
            case 'Technician is on the way':
                return '/SelfServe/resource/1720075767000/BLN_Shipping';
            case 'In Progress':
                return '/SelfServe/resource/1720075885000/BLN_Inprogress?';
            case 'Technician has arrived':
                return '/SelfServe/resource/1719989051000/BLN_Success';
            case 'Appointment not completed':
                return '/SelfServe/resource/1717676220000/BLN_EscalationLogo?';
            case 'Appointment cancelled':
                return '/SelfServe/resource/1717676220000/BLN_EscalationLogo?';
            case 'Appointment booked':
                return '/SelfServe/resource/1719989051000/BLN_Success';
            case 'Appointment completed':
                return '/SelfServe/resource/1719989051000/BLN_Success';
            default:
                return '/SelfServe/resource/1719989051000/BLN_Success';
        }
    }

    get colourName() {
        switch (this.portalServiceAppointment.portalStatusName) {
            case 'Appointment not completed':
                return 'background-color: rgb(255, 236, 235);';
            case 'Appointment cancelled':
                return 'background-color: rgb(255, 236, 235);';
            default:
                return 'background-color: rgb(229, 245, 222);';
        }
    }

    // Getter methods to conditionally check portalStatusName for rendering in HTML
    get isAppointmentNotCompleted() {
        return this.portalServiceAppointment && this.portalServiceAppointment.portalStatusName === 'Appointment not completed' && this.hasMatch === true;
    }

    get isAppointmentCancelled() {
        return this.portalServiceAppointment && this.portalServiceAppointment.portalStatusName === 'Appointment cancelled';
    }

    get isTechnicianOnTheWay() {
        return this.portalServiceAppointment && this.portalServiceAppointment.portalStatusName === 'Technician is on the way';
    }
    get isPortalStatus() {
        return this.portalServiceAppointment && this.portalServiceAppointment.portalStatusName !== null;
    }

    get newshedule() {
        return this.portalServiceAppointment && this.hasMatch === true && ((this.portalServiceAppointment.saStatus === 'Failed After Arrive') || (this.portalServiceAppointment.saStatus === 'Failed Before Arrive'));
    }
    fetchParentAndChildCasesData() {
        fetchParentAndChildCases({ recordId: this.recordId })
            .then(result => {
                this.parentAndChildCases = JSON.parse(result);
            })
            .catch(error => {
                console.error('Error fetching parent and child cases:', error);
            });
    }


    get iconNamecomplaint() {
        switch (this.parentAndChildCases.summarizedStatus) {
            case 'New':
                return '/SelfServe/resource/1720087320000/BLN_INFO';
            case 'In Progress':
                return '/SelfServe/resource/1720075885000/BLN_Inprogress?';
            case 'Closed':
                return '/SelfServe/resource/1719989051000/BLN_Success';
            default:
                return 'standard:question_post';
        }
    }
    get colourNamecomplaint() {
        switch (this.parentAndChildCases.summarizedStatus) {
            case 'Closed':
                return 'background-color: rgb(229, 245, 222);';
            default:
                return 'background-color: rgb(255, 220, 0);';
        }
    }
    //FOUK:8452 code start here
    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    fetchMatchingNoShowCriteria() {
        const windowLocation = window.location.href;
        getMatchingNoShowCriteria({ windowLocation: windowLocation })
            .then(result => {
                // Parse the result
                const parsedResult = JSON.parse(result);
                this.noShowData = parsedResult;
                this.hasMatch = this.noShowData.some(item => item.matchFound);
                this.status = this.noShowData.length > 0 ? this.noShowData[0].Status : null;
            })
            .catch(error => {
                console.error('Error fetching matching criteria:', error);
            });
    }
    navigateToInsuranceForm() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Insurance_Details__c',
            },
            state: {
                caseId: this.recordId
            }
        });
    }

    handlerefresh() {
        this.onreload = true;
        if (this.onreload = true) {
            window.location.reload();
        }
    }

    //**For Navigating to Reports */
    handleLinkNavigation(event) {
        const link = event.currentTarget.getAttribute('data-link');
        console.log('Link---', link);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: link
            }
        });
    }
}