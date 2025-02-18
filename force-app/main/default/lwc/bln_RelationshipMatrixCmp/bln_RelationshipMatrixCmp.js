import { LightningElement, api, wire } from 'lwc';
import getRelationships from "@salesforce/apex/BLN_RelationshipMatrixController.getRelationships";
import RelationshipHealth from '@salesforce/schema/BLN_Relationship__c.BLN_RelationshipHealth__c';
import getRelationshipId from "@salesforce/apex/BLN_RelationshipMatrixController.getRelationshipId";
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Bln_RelationshipMatrixCmp extends LightningElement {
   @api recordId;
   openmodel= false;
   relationId;
   refreshData;
   healthIndicator;
   relationshipHealthField = RelationshipHealth;
   relationshipList = [];
   contactUserRelationshipList = [];
   dynamicColumns=[];


   @wire(getRelationships, { recordId: '$recordId' })
   wiredRelationships(result) {
       this.refreshData = result;
       if (result.data) {
           this.relationshipList = [];
           this.dynamicColumns = [{label: 'Contact Name',fieldName: 'ContactName'},{label: 'Contact Position',fieldName: 'BLN_ContactPosition__c',type: 'text'},{label: 'Contact Decision Power',fieldName: 'BLN_ContactDecisionPower__c',type: 'text'},{label: 'Contact Attitude Towards Belron',fieldName: 'BLN_ContactAttitudeTowardsBelron__c',type: 'text'}];
           for (const key in result.data) {
               if (result.data.hasOwnProperty(key)) {
                   const relationObj = {
                       Id: result.data[key][0].BLN_ContactName__c,
                       ContactName: result.data[key][0].BLN_ContactName__r.Name,
                       BLN_ContactPosition__c: result.data[key][0].BLN_ContactPosition__c,
                       BLN_ContactDecisionPower__c: result.data[key][0].BLN_ContactDecisionPower__c,
                       BLN_ContactAttitudeTowardsBelron__c: result.data[key][0].BLN_ContactAttitudeTowardsBelron__c,
                       contactUrl: '/lightning/r/Contact/' + result.data[key][0].BLN_ContactName__c + '/view',
                   };
                   const regex = /src="([^"]*)"/;
                   result.data[key].forEach(record => {
                       const match = record.BLN_RelationshipHealthIndicator__c.match(regex);
                       if (match) {
                           relationObj[record.BLN_UserName__r.Name] = match[1];
                       }
                       const exists = this.dynamicColumns.some(column => column.fieldName === record.BLN_UserName__r.Name);
                       if (!exists) {
                        this.dynamicColumns.push({
                               label: record.BLN_UserName__r.Name,
                               fieldName: record.BLN_UserName__r.Name,
                           });
                       }
                   });
                   this.relationshipList.push(relationObj);
                   console.log('this.relationshipList', this.relationshipList);
               }
           }
           this.changeListFormation();
       } else if (result.error) {
           console.error('Error retrieving relationships:',result.error);
       }
   }
   changeListFormation() {
    this.contactUserRelationshipList=[];
       this.relationshipList.forEach(item => {
           const relation = [];
           this.dynamicColumns.forEach(column => {
               const value = item[column.fieldName];
               if (value && typeof value === 'string' && value.startsWith('/resource')) {
                relation.push({
                       label: column.label,
                       value: value,
                       Id: item.Id
                   });
               } else if (column.fieldName === 'ContactName') {
                relation.push({
                       label: column.label,
                       value: value,
                       Url: item.contactUrl
                   });
               } else {
                relation.push({
                       label: column.label,
                       value: value,
                   });
               }
           });
           this.contactUserRelationshipList.push(relation);
       });
    }

    closeModal(){
    this.openmodel = false;
    }
 
    onClickHandler(event) {
        console.log('hi');
       const contactId = event.currentTarget.dataset.id;
       const userName = event.currentTarget.dataset.label;
       console.log('contactId',contactId);
       console.log('userName',userName);
       getRelationshipId({contactId: contactId, userName: userName})
           .then((result) => {
               this.relationId = result;
               this.openmodel = true;
           })
           .catch((error) => {
               console.error('Error fetching relationship id:', error);
           });
          
    }
    handleSubmit(event) {
       // Optionally, perform any actions before updating the record
       event.preventDefault();
       // Trigger the form submission
       const fields = event.detail.fields;
       this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    handleSuccess(event) {
        this.closeModal();
        refreshApex(this.refreshData);
        this.showToast('', 'Record Updated Successfully', 'success');
     }
 
     showToast(title, message, variant) {
       const toastEvent = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant
       });
       this.dispatchEvent(toastEvent);
     }
 
    //FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY
    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
        }
        this.tableScrolled(event);
    }
 
    tableScrolled(event) {
        if (this.enableInfiniteScrolling) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('showmorerecords', {
                    bubbles: true
                }));
            }
        }
        if (this.enableBatchLoading) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('shownextbatch', {
                    bubbles: true
                }));
            }
        }
    }
 
    //#region ***************** RESIZABLE COLUMNS *************************************/
    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
    }
 
    handlemousedown(e) {
        if (!this._initWidths) {
            this._initWidths = [];
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            tableThs.forEach(th => {
                this._initWidths.push(th.style.width);
            });
        }
 
        this._tableThColumn = e.target.parentElement;
        this._tableThInnerDiv = e.target.parentElement;
        while (this._tableThColumn.tagName !== "TH") {
            this._tableThColumn = this._tableThColumn.parentNode;
        }
        while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
            this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
        }
        this._pageX = e.pageX;
 
        this._padding = this.paddingDiff(this._tableThColumn);
 
        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
    }
 
    handlemousemove(e) {
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;
 
            this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';
 
            this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;
 
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            let tableBodyRows = this.template.querySelectorAll("table tbody tr");
            let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
            tableBodyRows.forEach(row => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
                rowTds.forEach((td, ind) => {
                    rowTds[ind].style.width = tableThs[ind].style.width;
                });
            });
        }
    }
 
    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
        });
    }
    
 
    paddingDiff(col) {
 
        if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
            return 0;
        }
 
        this._padLeft = this.getStyleVal(col, 'padding-left');
        this._padRight = this.getStyleVal(col, 'padding-right');
        return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));
 
    }
 
    getStyleVal(elm, css) {
        return (window.getComputedStyle(elm, null).getPropertyValue(css))
    }

   
}