/**
 * @description       : 
 * @author            : Sourabh Bhattacharjee
 * @group             : 
 * @last modified on  : 08-14-2024
 * @last modified by  : Sourabh Bhattacharjee 
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   08-14-2024   Sourabh Bhattacharjee   Initial Version
**/
import { LightningElement, api, wire } from 'lwc';
import getCaseRecord from '@salesforce/apex/BLN_ShowVideoController.getCaseRecord';

export default class Bln_PortalVideo extends LightningElement {
    @api recordId;
    showReplacementVideo = false;
    showDefaultVideo = false;
    noVideo = false;

    connectedCallback() {
        this.fetchCaseRecord();
    }

    fetchCaseRecord() {
        getCaseRecord({ recordId: this.recordId, windowLocation: window.location.href })
            .then(result => {
                // console.log('Case Data:', JSON.stringify(result));
                //  console.log('Case Data BLN_ServiceType__c:', JSON.stringify(result.Status));
                this.handleCaseData(result);
            })
            .catch(error => {
                console.error('Error fetching case data', error);
            });
    }

    handleCaseData(caseData) {
        // Accessing Service Appointments and WorkTypeFormula__c
        if (caseData.serviceAppointments && caseData.serviceAppointments.length > 0) {
            const workTypeFormula = caseData.serviceAppointments[0].WorkTypeFormula__c;
            if (workTypeFormula === 'Repair') {  
                this.showDefaultVideo = true; 
                console.log('Work Type Formula Portal video:', workTypeFormula); 
            } else {  
                this.showReplacementVideo = true;  
                console.log('Work Type Formula Portal video:', workTypeFormula);
            }  
            
            //console.log('Work Type Formula Portal video:', workTypeFormula);
            // if (workTypeFormula === 'Repair') {
            //     this.showDefaultVideo = true;
            // } else if (
            //     workTypeFormula === 'Replacement' ||
            //     workTypeFormula === 'Replacement & Recalibration' ||
            //     workTypeFormula === 'Side & Rear' ||
            //     workTypeFormula === 'Recalibration' ||
            //     workTypeFormula === 'Sunroof' ||
            //     workTypeFormula === 'No Work Required'
            // ) {
            //     //console.log('Work Type Formula Portal video:', workTypeFormula);
            //     this.showReplacementVideo = true;
            // }
            // else {
            //     this.noVideo = true;
            // }
        }
        else {
            console.error('No Service Appointments found.', error);
        }
    }
}