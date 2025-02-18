import { LightningElement, api, wire } from 'lwc';
import getCaseRecord from '@salesforce/apex/BLN_ShowVideoController.getCaseRecord';
export default class BLN_ShowPortalVideo extends LightningElement {
    // @api recordId;
    // showReplacementVideo = false;
    // showDefaultVideo = false;
    // NoVideo = false;

    // @wire(getCaseRecord, { recordId: '$recordId' })
    // wiredCase({ error, data }) {
    //     if (data) {
    //         this.handleCaseData(data);
    //         console.log('data BLN_ShowPortalVideo -->',data);
    //     } else if (error) {
    //         console.error('Error fetching case data', error);
            
    //     }
    // }

    // handleCaseData(caseData) {
    //     if (caseData.BLN_WorkType__c === 'Replacement' || caseData.BLN_WorkType__c === 'Replacement / Recalibration' 
    //     || caseData.BLN_WorkType__c === 'Warranty Replacement' || caseData.BLN_WorkType__c === 'Warranty Replacement & Recalibration') {
    //         this.showReplacementVideo = true;
    //     } else if (caseData.BLN_WorkType__c === 'Repair'){
    //         this.showDefaultVideo = true;
    //     }
    //     else {
    //         this.NoVideo =true;
    //     }
        
        
    //     } 
    // handleCaseData(caseData) {
    //     if (caseData && caseData.BLN_ServiceType__c) {
    //         if (
    //             caseData.BLN_ServiceType__c === 'Replacement' || 
    //             caseData.BLN_ServiceType__c === 'Replacement / Recalibration' || 
    //             caseData.BLN_ServiceType__c === 'Warranty Replacement' || 
    //             caseData.BLN_ServiceType__c === 'Warranty Replacement & Recalibration'
    //         ) {
    //             this.showReplacementVideo = true;
    //         } else if (caseData.BLN_ServiceType__c === 'Repair') {
    //             this.showDefaultVideo = true;
    //         } else {
    //             this.NoVideo = true;
    //         }
    //     } else {
    //         console.error('BLN_ServiceType__c is null or undefined');
    //     }
    // }
    
    @api recordId;
    showReplacementVideo = false;
    showDefaultVideo = false;
    noVideo = false;

    connectedCallback() {
        this.fetchCaseRecord();
    }

    fetchCaseRecord() {
        getCaseRecord({ recordId: this.recordId })
            .then(result => {
                this.handleCaseData(result);
            })
            .catch(error => {
                console.error('Error fetching case data', error);
            });
    }

    handleCaseData(caseData) {
        const serviceType = caseData.BLN_ServiceType__c;
        if (
            serviceType === 'Replacement' || 
            serviceType === 'Replacement / Recalibration' || 
            serviceType === 'Warranty Replacement' || 
            serviceType === 'Warranty Replacement & Recalibration'
        ) {
            this.showReplacementVideo = true;
        } else if (serviceType === 'Repair') {
            this.showDefaultVideo = true;
        } else {
            this.noVideo = true;
        }
    }
       
    }