import { LightningElement,api,track,wire } from 'lwc';
import getAccountRuleParameters from '@salesforce/apex/BLN_AccountRuleParameterUtil.getAccountRuleParameters';
import { createRecord,getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import ANSWER_OBJECT from '@salesforce/schema/BLN_DataCollectAnswer__c';
import ANSWER_FIELD from '@salesforce/schema/BLN_DataCollectAnswer__c.BLN_Answer__c';
import CASE_FIELD from '@salesforce/schema/BLN_DataCollectAnswer__c.BLN_Case__c';
import Question_FIELD from '@salesforce/schema/BLN_DataCollectAnswer__c.BLN_Question__c';
// FOUK-10731
import Id_FIELD from '@salesforce/schema/BLN_DataCollectAnswer__c.Id';
import ANSWER_VALIDATION_FIELD from '@salesforce/schema/BLN_AccountRuleParameter__c.BLN_AnswerValidation__c';
import VALIDATION_MESSAGE_FIELD from '@salesforce/schema/BLN_AccountRuleParameter__c.BLN_ValidationMessage__c';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent,FlowNavigationFinishEvent } from 'lightning/flowSupport';
import ARPDataCollect from '@salesforce/label/c.BLN_ARPDataCollect';
import TypeFreeText from '@salesforce/label/c.BLN_TypeFreeText';
import TypeDate from '@salesforce/label/c.BLN_TypeDate';
import TypePicklist from '@salesforce/label/c.BLN_TypePicklist';
import MandatoryErrorMessage from '@salesforce/label/c.BLN_MandatoryErrorMessage';
import CaseClosurevalue from '@salesforce/label/c.BLN_CaseClosurevalue';
import QualitybookingValue from '@salesforce/label/c.BLN_QualitybookingValue';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPreviousAnswers from '@salesforce/apex/BLN_DataCollectAnswers.getPreviousAnswers';
import submitButtonOnClick from '@salesforce/apex/BLN_DataCollectAnswers.submitButtonOnClick';
import CaptureDataCollect from '@salesforce/label/c.BLN_CaptureDataCollectHeader';
import corporateDataCollectLabel from '@salesforce/label/c.BLN_CorporateDataCollect';
import insuranceDataCollectLabel from '@salesforce/label/c.BLN_InsuranceDataCollect';

import { NavigationMixin } from 'lightning/navigation';
//FOUK-9628
import BLN_ONUM from '@salesforce/label/c.BLN_ONUM';
import BLN_IDAT from '@salesforce/label/c.BLN_IDAT';
import BLN_MILE from '@salesforce/label/c.BLN_MILE';

//FOUK-11106 bug
import NoArpErrorMessage from '@salesforce/label/c.BLN_datacollecterror';

//FOUK-10506
import getSiteAccountNames from '@salesforce/apex/BLN_DataCollectAnswers.getSiteAccountNames';
//FOUK-10731
import checkAnswerRecords from '@salesforce/apex/BLN_DataCollectAnswers.checkAnswerRecords';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab, refreshTab, getAllTabInfo } from 'lightning/platformWorkspaceApi';
const CASE_FIELDS = ['Case.BLN_IncidentDate__c', 'Case.BLN_Vehicle__r.BLN_Mileage__c'];


export default class Bln_DataCollectorContainers extends NavigationMixin(LightningElement) {
    @wire(IsConsoleNavigation) isConsoleNavigation;
    @api isCloseTab = false;
@api caserecordId;
@api accountId;
@track accountRuleParameters = [];
@track freeTextParameters = [];
@track freeclosureParameters = [];
@track freeQualityParameters = [];
@track picklistclosureParameters = [];
@track picklistQualityParameters = [];
@track picklistParameters = [];
@track dateParameters = [];
@track dateclosureParameters = [];
@track dateQualityParameters = [];
@api availableActions = [];

@track previousTextValues = {};
@track previousPicklistValues = {};
@track previousDateValues = {};
resultLength;
retrieveAnswers=false;
checkResult;

@api accountId2;
@track listofAccParams1 =[];
@track listofAccParams2 =[];

//FOUK-10506-start
activeSections = ['corporate', 'insurance'];
@track corporateSiteAccountName = '';
@track insuranceSiteAccountName = '';
@track isCorporate = false;
@track isInsurance = false;
@api accountType = '';

//Corporate
@track corporate_freeTextParameters = [];
@track corporate_freeclosureParameters = [];
@track corporate_freeQualityParameters = [];
@track corporate_picklistclosureParameters = [];
@track corporate_picklistQualityParameters = [];
@track corporate_picklistParameters = [];
@track corporate_dateParameters = [];
@track corporate_dateclosureParameters = [];
@track corporate_dateQualityParameters = [];

//Insurance
@track insurance_freeTextParameters = [];
@track insurance_freeclosureParameters = [];
@track insurance_freeQualityParameters = [];
@track insurance_picklistclosureParameters = [];
@track insurance_picklistQualityParameters = [];
@track insurance_picklistParameters = [];
@track insurance_dateParameters = [];
@track insurance_dateclosureParameters = [];
@track insurance_dateQualityParameters = [];

// FOUK-10506-end

//FOUK-11106 bug-start
@track showNoArpMessage = false;
@track showSpinnerARP = true;
//FOUK-11106 bug-end

//FOUK-10731
@track answerRecordsFound;

label = {
ARPDataCollect,
TypeFreeText,
TypeDate,
TypePicklist,
MandatoryErrorMessage,
CaseClosurevalue,
QualitybookingValue,
BLN_ONUM,
BLN_IDAT,
BLN_MILE,
NoArpErrorMessage,
CaptureDataCollect,
corporateDataCollectLabel,
insuranceDataCollectLabel
}

ANSWER_VALIDATION_FIELD = ANSWER_VALIDATION_FIELD;
VALIDATION_MESSAGE_FIELD = VALIDATION_MESSAGE_FIELD;
selectedTextInputValue;
selectedOption;
selectedDate;
BLN_AnswerValidation__c;
BLN_ValidationMessage__c;
@wire(getRecord, { recordId: '$caserecordId', fields: [CASE_FIELD] })
caseRecord;

//Get fields Vehicle--> Mileage and Case--> incident date
@wire(getRecord,{recordId: '$caserecordId', fields: CASE_FIELDS})
caseData;


async connectedCallback() {
    //FOUK-10731-start
    //Call get record to fetch answer records
    await this.checkAnswerRecordsOnCase()
    //FOUK-10731-end
    //FOUK-10506-start
    console.log('accountType ',this.accountType)
    if(this.accountType != ''){
        if(this.accountType == 'corporate'){
            this.isCorporate = true;
            this.isInsurance = false;
        } else if(this.accountType == 'insurance'){
            this.isCorporate = false;
            this.isInsurance = true;
        } else{
            this.isCorporate = true;
            this.isInsurance = true;
        }
    }
    this.getAccountNames()
    //FOUK-10506-end

    if(this.accountId!=null && this.accountId2==null)
    {
        console.log('inside if 1st')

        this.getAccountRuleParameter();
        setTimeout(() => {
        this.retrievePreviousAnswers();
        }, 1000);
    }
    if(this.accountId!=null && this.accountId2!=null)
        {
            console.log('inside if 2nd')
            this.getAccountRuleParameterForSplit();
            setTimeout(() => {
            this.retrievePreviousAnswers();
            }, 1000);
        }


}

    //FOUK-10506
    async getAccountNames(){
        await getSiteAccountNames({accountId: this.accountId, accountId2: this.accountId2, accountType: this.accountType})
        .then(result =>{
            this.corporateSiteAccountName = result.corporateSiteName + ' '+this.label.corporateDataCollectLabel;
            this.insuranceSiteAccountName = result.insuranceSiteName + ' '+this.label.insuranceDataCollectLabel;
        })
    }

    //FOUK-10731
    async checkAnswerRecordsOnCase(){
        console.log('case id for checking ',this.caserecordId)
        // await checkAnswerRecords({caseId: '$caserecordId'})
        await checkAnswerRecords({
            caseId: this.caserecordId,
            accountId: this.accountId,
            accountId2: this.accountId2
        })
        .then(data =>{
            console.log('data from answers ', data)
            this.answerRecordsFound = data;
        }).catch(error =>{
            console.log('error on answers ',error)
        })
    }

    async retrievePreviousAnswers() {
        await getPreviousAnswers({ caseId: this.caserecordId, resultLength:this.resultLength})
            .then(result => {
                console.log('result previous ',result)
                
            
                this.checkResult=result;
                if (result && result.length > 0) {
                    result.forEach(item => {
                        const answer = item.BLN_Answer__c;
                        const parameterId = item.BLN_Question__c;
                        const parameter = this.freeTextParameters.find(param => param.Id === parameterId);
                        const parameter1 = this.freeclosureParameters.find(param => param.Id === parameterId);
                        const parameter2 = this.freeQualityParameters.find(param => param.Id === parameterId);
                        const parameter3 = this.picklistParameters.find(param => param.Id === parameterId);
                        const parameter4 = this.picklistclosureParameters.find(param => param.Id === parameterId);
                        const parameter5 = this.picklistQualityParameters.find(param => param.Id === parameterId);
                        const parameter6 = this.dateParameters.find(param => param.Id === parameterId);
                        const parameter7 = this.dateclosureParameters.find(param => param.Id === parameterId);
                        const parameter8 = this.dateQualityParameters.find(param => param.Id === parameterId);

                        if (parameter) parameter.selectedTextInputValue = answer;
                        if (parameter1) parameter1.selectedTextInputValue = answer;
                        if (parameter2) parameter2.selectedTextInputValue = answer;
                        if (parameter3) parameter3.selectedOption = answer;
                        if (parameter4) parameter4.selectedOption = answer;
                        if (parameter5) parameter5.selectedOption = answer;
                        if (parameter6) parameter6.selectedDate = answer;
                        if (parameter7) parameter7.selectedDate = answer;
                        if (parameter8) parameter8.selectedDate = answer;
                    });
                }
            else {
                this.previousAnswers = [];
            }
            // this.handleSubmit(result);
            })
            .catch(error => {
                console.error('Error fetching previous answers:', error);
            });
    // }
    }
    getAnswerValue(parameterId) {
        const answer = this.previousAnswers.find(answer => answer.BLN_Question__c === parameterId);
        return answer ? answer.BLN_Answer__c : '';
    }

    // Method to get selected text value
    handleTextInputChange(event) {
        this.selectedTextInputValue = event.detail.value;

        const parameterId = event.target.dataset.parameterId;
        const parameterToUpdate = this.freeTextParameters.find(param => param.Id === parameterId);
        const closureparameter= this.freeclosureParameters.find(param => param.Id === parameterId);
        const Qualityeparameter= this.freeQualityParameters.find(param => param.Id === parameterId);
        this.previousTextValues[parameterId] = this.selectedTextInputValue;
        if (parameterToUpdate) {
            parameterToUpdate.selectedTextInputValue = this.selectedTextInputValue;
        }
        if (closureparameter) {
            closureparameter.selectedTextInputValue = this.selectedTextInputValue;
        }
        if (Qualityeparameter) {
            Qualityeparameter.selectedTextInputValue = this.selectedTextInputValue;
        }
    }
    // Method to get selected picklist value
    handlePicklistChange(event) {
        const parameterId = event.target.dataset.parameterId;
            this.selectedOption = event.detail.value;

        const parameterToUpdate = this.picklistParameters.find(param => param.Id === parameterId);
        const closureparameter = this.picklistclosureParameters.find(param => param.Id === parameterId);
        const Qualityeparameter = this.picklistQualityParameters.find(param => param.Id === parameterId);
        this.previousPicklistValues[parameterId] = this.selectedOption;
        if (parameterToUpdate) {
            parameterToUpdate.selectedOption = this.selectedOption;
        }
        if (closureparameter) {
            closureparameter.selectedOption = this.selectedOption;
        }
        if (Qualityeparameter) {
            Qualityeparameter.selectedOption = this.selectedOption;
        }
    }
    // Method to get selected date value
    handleDateChange(event) {
        const parameterId = event.target.dataset.parameterId;
        this.selectedDate = event.target.value;

        const parameterToUpdate = this.dateParameters.find(param => param.Id === parameterId);
        const closureparameter = this.dateclosureParameters.find(param => param.Id === parameterId);
        const Qualityeparameter = this.dateQualityParameters.find(param => param.Id === parameterId);

        if (parameterToUpdate) {
            parameterToUpdate.selectedDate = this.selectedDate;
        }
        if (closureparameter) {
            closureparameter.selectedDate = this.selectedDate;
        }
        if (Qualityeparameter) {
            Qualityeparameter.selectedDate = this.selectedDate;
        }
    }
    // call apex method to get data collect ARP records. and assign the records in different variables based on answer type picklist
    async getAccountRuleParameter() {
    let today = new Date().toISOString().slice(0, 10);
    await getAccountRuleParameters( { arpRecordType: ARPDataCollect, accountId:this.accountId,  jobDate: today})
        .then(async (result) => {
            //FOUK-11106 bug
            this.showSpinnerARP = false;
            // FOUK-11106 bug-start
            console.log('result 11106 ',result)
            if(result == null){
                this.showNoArpMessage = true;
                // FOUK-11106 bug-end
            } else{
                result.map(item =>{
                    if(this.isCorporate == true){
                        item.corporate = true
                        item.insurance = false
                    } else if(this.isInsurance == true){
                        item.corporate = false
                        item.insurance = true
                    }
                    
                })
                
                this.resultLength=result.length;
                this.accountRuleParameters = result;
    
                //FOUK-10731-start
                if(this.answerRecordsFound == false){
                    await this.createAnswerRecords();
                }
                //FOUK-10731-end
    
                this.freeTextParameters = result.filter(parameter => (parameter.BLN_AnswerType__c === TypeFreeText) && (parameter.BLN_Mandatory__c === 'Optional'));
                this.freeclosureParameters = result.filter(parameter => (parameter.BLN_AnswerType__c === TypeFreeText) && parameter.BLN_Mandatory__c === CaseClosurevalue);
                this.freeQualityParameters = result.filter(parameter => (parameter.BLN_AnswerType__c === TypeFreeText) && parameter.BLN_Mandatory__c === QualitybookingValue);
                this.picklistParameters = result.filter(parameter => (parameter.BLN_AnswerType__c === TypePicklist) && (parameter.BLN_Mandatory__c === 'Optional'));
                
                this.picklistParameters.forEach(param => {   
                
                    param.picklistOptions = param.BLN_PicklistValues__c?.split(',').map(option => ({ label: option, value: option }));
                });
    
                this.picklistclosureParameters = result.filter(parameter => (parameter.BLN_AnswerType__c === TypePicklist) && (parameter.BLN_Mandatory__c === CaseClosurevalue));
                this.picklistclosureParameters.forEach(param => {   
                    param.picklistOptions = param.BLN_PicklistValues__c?.split(',').map(option => ({ label: option, value: option }));
                });
    
                this.picklistQualityParameters = result.filter(parameter => (parameter.BLN_AnswerType__c === TypePicklist) && (parameter.BLN_Mandatory__c === QualitybookingValue));
                this.picklistQualityParameters.forEach(param => {   
                    param.picklistOptions = param.BLN_PicklistValues__c?.split(',').map(option => ({ label: option, value: option }));
                });
                this.dateParameters = result.filter(parameter => (parameter.BLN_AnswerType__c === TypeDate) && (parameter.BLN_Mandatory__c === 'Optional'));
                this.dateclosureParameters = result.filter(parameter => (parameter.BLN_AnswerType__c === TypeDate) && (parameter.BLN_Mandatory__c === CaseClosurevalue));
                this.dateQualityParameters = result.filter(parameter => (parameter.BLN_AnswerType__c === TypeDate) && (parameter.BLN_Mandatory__c === QualitybookingValue));
                
                //FOUK-9628 start
                // Free text
                this.freeTextParameters.map(item =>{
                    if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                        item.disableInput = true;
                    } else{
                        item.disableInput = false;
                    }
                })
                this.freeclosureParameters.map(item =>{
                    if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                        item.disableInput = true;
                    } else{
                        item.disableInput = false;
                    }
                })
                this.freeQualityParameters.map(item =>{
                    if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                        item.disableInput = true;
                    } else{
                        item.disableInput = false;
                    }
                })
                this.picklistParameters.map(item =>{
                    if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                        item.disableInput = true;
                    } else{
                        item.disableInput = false;
                    }
                })
                //Picklist
                this.picklistParameters.map(item =>{
                    if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                        item.disableInput = true;
                    } else{
                        item.disableInput = false;
                    }
                })
                this.picklistclosureParameters.map(item =>{
                    if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                        item.disableInput = true;
                    } else{
                        item.disableInput = false;
                    }
                })
                this.picklistQualityParameters.map(item =>{
                    if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                        item.disableInput = true;
                    } else{
                        item.disableInput = false;
                    }
                })
                // Date type
                this.dateParameters.map(item =>{
                    if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                        item.disableInput = true;
                    } else{
                        item.disableInput = false;
                    }
                })
                this.dateclosureParameters.map(item =>{
                    if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                        item.disableInput = true;
                    } else{
                        item.disableInput = false;
                    }
                })
                this.dateQualityParameters.map(item =>{
                    if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                        item.disableInput = true;
                    } else{
                        item.disableInput = false;
                    }
                })
                //FOUK-9628 end
    
    
                //FOUK-10506
                if(this.isCorporate == true){
                    // corporate
                    this.corporate_freeTextParameters = this.freeTextParameters.filter(parameter => parameter.corporate == true);
                    this.corporate_freeclosureParameters = this.freeclosureParameters.filter(parameter => parameter.corporate == true);
                    this.corporate_freeQualityParameters = this.freeQualityParameters.filter(parameter => parameter.corporate == true);
                    
                    this.corporate_picklistParameters = this.picklistParameters.filter(parameter => parameter.corporate == true);
                    this.corporate_picklistclosureParameters = this.picklistclosureParameters.filter(parameter => parameter.corporate == true);
                    this.corporate_picklistQualityParameters = this.picklistQualityParameters.filter(parameter => parameter.corporate == true);
                    
                    this.corporate_dateParameters = this.dateParameters.filter(parameter => parameter.corporate == true);
                    this.corporate_dateclosureParameters = this.dateclosureParameters.filter(parameter => parameter.corporate == true);
                    this.corporate_dateQualityParameters = this.dateQualityParameters.filter(parameter => parameter.corporate == true);
    
                } else if(this.isInsurance == true){
                    //Insurance
                    this.insurance_freeTextParameters = this.freeTextParameters.filter(parameter => parameter.insurance == true);
                    this.insurance_freeclosureParameters = this.freeclosureParameters.filter(parameter => parameter.insurance == true);
                    this.insurance_freeQualityParameters = this.freeQualityParameters.filter(parameter => parameter.insurance == true);
    
                    this.insurance_picklistParameters = this.picklistParameters.filter(parameter => parameter.insurance == true);
                    this.insurance_picklistclosureParameters = this.picklistclosureParameters.filter(parameter => parameter.insurance == true);
                    this.insurance_picklistQualityParameters = this.picklistQualityParameters.filter(parameter => parameter.insurance == true);
    
                    this.insurance_dateParameters = this.dateParameters.filter(parameter => parameter.insurance == true);
                    this.insurance_dateclosureParameters = this.dateclosureParameters.filter(parameter => parameter.insurance == true);
                    this.insurance_dateQualityParameters = this.dateQualityParameters.filter(parameter => parameter.insurance == true);
                }
            }
    })
        .catch(error => {
            //FOUK-11106 bug
            this.showSpinnerARP = false;
            console.error('Error fetching account rule parameters:', error);
            
        });
    }

    async getAccountRuleParameterForSplit() {
        this.isCorporate = true;
        this.isInsurance = true;
        

        let today = new Date().toISOString();
        await getAccountRuleParameters( { arpRecordType: ARPDataCollect, accountId:this.accountId,  jobDate: today})
        .then(result => {
            if(result?.length){
            this.listofAccParams1 = result;
            this.listofAccParams1.map(item =>{
                item.corporate = true
                item.insurance = false
            })
            }
        
        })
        .catch(error => {
            console.error('Error fetching account rule parameters 1:', error);
        });
        
        await getAccountRuleParameters( { arpRecordType: ARPDataCollect, accountId:this.accountId2,  jobDate: today})
        .then(async (result) => {
            if(result?.length){
                this.listofAccParams2 = result;
            this.listofAccParams2.map(item =>{
                item.corporate = false
                item.insurance = true
            })
            }
            //FOUK-11106 bug
            this.showSpinnerARP = false;

            if(this.listofAccParams1.length>0 && this.listofAccParams2.length>0)
            {
                this.listofAccParams2 = this.listofAccParams1.concat(this.listofAccParams2);//add lists
            }
            else if(this.listofAccParams1.length > 0 && this.listofAccParams2.length == 0)
            {
                this.listofAccParams2 = this.listofAccParams1;//amove list1 to list2 if list2 is null, since we pass list2 to other methods.
            }
        })
        .catch(error => {
            //FOUK-11106 bug
            this.showSpinnerARP = false;
            console.error('Error fetching account rule parameters 2:', error);      
        });
        console.log('this.listofAccParams2.length ',this.listofAccParams2.length)
        
        if(this.listofAccParams2.length > 0)
        {
            this.resultLength=this.listofAccParams2.length;
            this.accountRuleParameters = this.listofAccParams2;
            console.log('this.resultLength ',this.resultLength)

            //FOUK-10731-start
            if(this.answerRecordsFound == false){
                await this.createAnswerRecords();
            }
            //FOUK-10731-end

            this.freeTextParameters = this.listofAccParams2.filter(parameter => (parameter.BLN_AnswerType__c === TypeFreeText) && (parameter.BLN_Mandatory__c === 'Optional'));
            this.freeclosureParameters = this.listofAccParams2.filter(parameter => (parameter.BLN_AnswerType__c === TypeFreeText) && parameter.BLN_Mandatory__c === CaseClosurevalue);
            this.freeQualityParameters = this.listofAccParams2.filter(parameter => (parameter.BLN_AnswerType__c === TypeFreeText) && parameter.BLN_Mandatory__c === QualitybookingValue);
            this.picklistParameters = this.listofAccParams2.filter(parameter => (parameter.BLN_AnswerType__c === TypePicklist) && (parameter.BLN_Mandatory__c === 'Optional'));
            
            this.picklistParameters.forEach(param => {   
                    param.picklistOptions = param.BLN_PicklistValues__c?.split(',').map(option => ({ label: option, value: option }));
                
                
            });
        
            this.picklistclosureParameters = this.listofAccParams2.filter(parameter => (parameter.BLN_AnswerType__c === TypePicklist) && (parameter.BLN_Mandatory__c === CaseClosurevalue));
            this.picklistclosureParameters.forEach(param => {   
               
                param.picklistOptions = param.BLN_PicklistValues__c?.split(',').map(option => ({ label: option, value: option }));
                
            });
        
            this.picklistQualityParameters = this.listofAccParams2.filter(parameter => (parameter.BLN_AnswerType__c === TypePicklist) && (parameter.BLN_Mandatory__c === QualitybookingValue));
            this.picklistQualityParameters.forEach(param => {   
               
                param.picklistOptions = param.BLN_PicklistValues__c?.split(',').map(option => ({ label: option, value: option }));
                
            });
            this.dateParameters = this.listofAccParams2.filter(parameter => (parameter.BLN_AnswerType__c === TypeDate) && (parameter.BLN_Mandatory__c === 'Optional'));
            this.dateclosureParameters = this.listofAccParams2.filter(parameter => (parameter.BLN_AnswerType__c === TypeDate) && (parameter.BLN_Mandatory__c === CaseClosurevalue));
            this.dateQualityParameters = this.listofAccParams2.filter(parameter => (parameter.BLN_AnswerType__c === TypeDate) && (parameter.BLN_Mandatory__c === QualitybookingValue));

            //FOUK-9628 start
            // Free text
            this.freeTextParameters.map(item =>{
                if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                    item.disableInput = true;
                } else{
                    item.disableInput = false;
                }
            })
            this.freeclosureParameters.map(item =>{
                if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                    item.disableInput = true;
                } else{
                    item.disableInput = false;
                }
            })
            this.freeQualityParameters.map(item =>{
                if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                    item.disableInput = true;
                } else{
                    item.disableInput = false;
                }
            })
            this.picklistParameters.map(item =>{
                if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                    item.disableInput = true;
                } else{
                    item.disableInput = false;
                }
            })
            //Picklist
            this.picklistParameters.map(item =>{
                if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                    item.disableInput = true;
                } else{
                    item.disableInput = false;
                }
            })
            this.picklistclosureParameters.map(item =>{
                if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                    item.disableInput = true;
                } else{
                    item.disableInput = false;
                }
            })
            this.picklistQualityParameters.map(item =>{
                if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                    item.disableInput = true;
                } else{
                    item.disableInput = false;
                }
            })
            // Date type
            this.dateParameters.map(item =>{
                if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                    item.disableInput = true;
                } else{
                    item.disableInput = false;
                }
            })
            this.dateclosureParameters.map(item =>{
                if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                    item.disableInput = true;
                } else{
                    item.disableInput = false;
                }
            })
            this.dateQualityParameters.map(item =>{
                if(item.BLN_EDITypeCode__c == this.label.BLN_IDAT || item.BLN_EDITypeCode__c == this.label.BLN_MILE || item.BLN_EDITypeCode__c == this.label.BLN_ONUM){
                    item.disableInput = true;
                } else{
                    item.disableInput = false;
                }
            })
            //FOUK-9628 end

            //FOUK-10506
            // corporate
            this.corporate_freeTextParameters = this.freeTextParameters.filter(parameter => parameter.corporate == true);
            this.corporate_freeclosureParameters = this.freeclosureParameters.filter(parameter => parameter.corporate == true);
            this.corporate_freeQualityParameters = this.freeQualityParameters.filter(parameter => parameter.corporate == true);
            
            this.corporate_picklistParameters = this.picklistParameters.filter(parameter => parameter.corporate == true);
            this.corporate_picklistclosureParameters = this.picklistclosureParameters.filter(parameter => parameter.corporate == true);
            this.corporate_picklistQualityParameters = this.picklistQualityParameters.filter(parameter => parameter.corporate == true);
            
            this.corporate_dateParameters = this.dateParameters.filter(parameter => parameter.corporate == true);
            this.corporate_dateclosureParameters = this.dateclosureParameters.filter(parameter => parameter.corporate == true);
            this.corporate_dateQualityParameters = this.dateQualityParameters.filter(parameter => parameter.corporate == true);
            
            //Insurance
            this.insurance_freeTextParameters = this.freeTextParameters.filter(parameter => parameter.insurance == true);
            this.insurance_freeclosureParameters = this.freeclosureParameters.filter(parameter => parameter.insurance == true);
            this.insurance_freeQualityParameters = this.freeQualityParameters.filter(parameter => parameter.insurance == true);
            
            this.insurance_picklistParameters = this.picklistParameters.filter(parameter => parameter.insurance == true);
            this.insurance_picklistclosureParameters = this.picklistclosureParameters.filter(parameter => parameter.insurance == true);
            this.insurance_picklistQualityParameters = this.picklistQualityParameters.filter(parameter => parameter.insurance == true);
            
            this.insurance_dateParameters = this.dateParameters.filter(parameter => parameter.insurance == true);
            this.insurance_dateclosureParameters = this.dateclosureParameters.filter(parameter => parameter.insurance == true);
            this.insurance_dateQualityParameters = this.dateQualityParameters.filter(parameter => parameter.insurance == true);


        } else{
            // FOUK-11106 bug-start
            console.log('result 11106 ',result)
            this.showNoArpMessage = true;
            // FOUK-11106 bug-end
        }
    }

    showToastMessage(variant, title, message) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
    });
    this.dispatchEvent(event);
    }

    // on click of sumbit Answer record creates.
    async handleSubmit(){
        const accountIds = [];
        accountIds.push(this.accountId);
        if(this.accountId2!=null){
            accountIds.push(this.accountId2);
        }

        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
        let MandatoryFieldEmpty = false;
        this.freeQualityParameters.forEach(parameter => {
        if ( !parameter.selectedTextInputValue) {
            MandatoryFieldEmpty = true;      // set mandatory as true
        }
        });
        this.freeclosureParameters.forEach(parameter => {
        if (!parameter.selectedTextInputValue) {
            MandatoryFieldEmpty = true;
        }
        });
        this.picklistclosureParameters.forEach(parameter => {
        if ( !parameter.selectedOption) {
            MandatoryFieldEmpty = true;
        }
        });
        this.picklistQualityParameters.forEach(parameter => {
        if (!parameter.selectedOption) {
            MandatoryFieldEmpty = true;
        }
        });
        this.dateclosureParameters.forEach(parameter => {
        if (!parameter.selectedDate) {
            MandatoryFieldEmpty = true;
        }
        });
        this.dateQualityParameters.forEach(parameter => {
        if (!parameter.selectedDate) {
            MandatoryFieldEmpty = true;
        }
        });
        if (MandatoryFieldEmpty) {
        this.showToastMessage('warning', 'warning', MandatoryErrorMessage);
        }
        const recordsToCreate = [];
        this.freeTextParameters.forEach(parameter => {
        recordsToCreate.push({
            apiName: ANSWER_OBJECT.objectApiName,
            fields: {
                [Question_FIELD.fieldApiName]: parameter.Id, 
                [CASE_FIELD.fieldApiName]: this.caserecordId, 
                [ANSWER_FIELD.fieldApiName]: parameter.selectedTextInputValue 
            }
        });
        });

        this.freeclosureParameters.forEach(parameter => {
        recordsToCreate.push({
            apiName: ANSWER_OBJECT.objectApiName,
            fields: {
                [Question_FIELD.fieldApiName]: parameter.Id, 
                [CASE_FIELD.fieldApiName]: this.caserecordId, 
                [ANSWER_FIELD.fieldApiName]: parameter.selectedTextInputValue 
            }
        });
        });

        this.freeQualityParameters.forEach(parameter => {
        recordsToCreate.push({
            apiName: ANSWER_OBJECT.objectApiName,
            fields: {
                [Question_FIELD.fieldApiName]: parameter.Id, 
                [CASE_FIELD.fieldApiName]: this.caserecordId, 
                [ANSWER_FIELD.fieldApiName]: parameter.selectedTextInputValue 
            }
        });
        });
        this.picklistParameters.forEach(parameter => {
        recordsToCreate.push({
            apiName: ANSWER_OBJECT.objectApiName,
            fields: {
                [Question_FIELD.fieldApiName]: parameter.Id, 
                [CASE_FIELD.fieldApiName]: this.caserecordId, 
                [ANSWER_FIELD.fieldApiName]: parameter.selectedOption 
            }
        });
        });
        this.picklistclosureParameters.forEach(parameter => {
        recordsToCreate.push({
            apiName: ANSWER_OBJECT.objectApiName,
            fields: {
                [Question_FIELD.fieldApiName]: parameter.Id, 
                [CASE_FIELD.fieldApiName]: this.caserecordId, 
                [ANSWER_FIELD.fieldApiName]: parameter.selectedOption 
            }
        });
        });
        this.picklistQualityParameters.forEach(parameter => {
        recordsToCreate.push({
            apiName: ANSWER_OBJECT.objectApiName,
            fields: {
                [Question_FIELD.fieldApiName]: parameter.Id, 
                [CASE_FIELD.fieldApiName]: this.caserecordId, 
                [ANSWER_FIELD.fieldApiName]: parameter.selectedOption 
            }
        });
        });

        this.dateParameters.forEach(parameter => {
        recordsToCreate.push({
            apiName: ANSWER_OBJECT.objectApiName,
            fields: {
                [Question_FIELD.fieldApiName]: parameter.Id, 
                [CASE_FIELD.fieldApiName]: this.caserecordId, 
                [ANSWER_FIELD.fieldApiName]: parameter.selectedDate 
            }
        });
        });

        this.dateclosureParameters.forEach(parameter => {
        recordsToCreate.push({
            apiName: ANSWER_OBJECT.objectApiName,
            fields: {
                [Question_FIELD.fieldApiName]: parameter.Id, 
                [CASE_FIELD.fieldApiName]: this.caserecordId, 
                [ANSWER_FIELD.fieldApiName]: parameter.selectedDate 
            }
        });
        });

        this.dateQualityParameters.forEach(parameter => {
        recordsToCreate.push({
            apiName: ANSWER_OBJECT.objectApiName,
            fields: {
                [Question_FIELD.fieldApiName]: parameter.Id, 
                [CASE_FIELD.fieldApiName]: this.caserecordId, 
                [ANSWER_FIELD.fieldApiName]: parameter.selectedDate 
                
            }
        });

        });

        await this.retrievePreviousAnswers();
        console.log('after previos ans', this.checkResult);
        if (this.checkResult && this.checkResult.length > 0) {

        this.checkResult.forEach((item,index) =>{
            recordsToCreate[index].fields['Id']=item.Id;

        } )
        let answerRecords =[];
        recordsToCreate.forEach( item=>{
            answerRecords.push({

                'fields':{
                    'Id':item.fields.Id,
                    'BLN_Answer__c' : item.fields.BLN_Answer__c,
                    'BLN_Question__c' : item.fields.BLN_Question__c
                }
            }       
            )
        })
            answerRecords.forEach(recordToCreate => {
                if(recordToCreate.fields.Id){
                    updateRecord(recordToCreate) 
                        .then(() => {
                            //Trail Method
                            submitButtonOnClick({caseId: this.caserecordId, accountIds: accountIds}).then(result=>{
                            })
                            .catch(error=>{
                            });

                            console.log('updating records........')
                            if(this.isCloseTab != true){
                            this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
                            if(this.availableActions.find(element => element=='NEXT')){
                            this.dispatchEvent(new FlowNavigationNextEvent()); 
                            }else{
                            this.dispatchEvent(new FlowNavigationFinishEvent()); 
                            } 
                            setTimeout(() => {

                            // window.location.reload();
                            
                            }, 4000);
                        
                            if (this.caserecordId) {
                                this[NavigationMixin.Navigate]({
                                        type: 'standard__recordPage',
                                        attributes: {
                                            recordId: this.caserecordId,
                                            objectApiName: 'Case',
                                            actionName: 'view'
                                    }
                                    
                                    });
                                
                                then(() => {                    
                                        // window.location.reload();
                                    
                                }).catch(error => {
                                        console.error('Error navigating to case page:', error);
                                    });
                            }
                        } else {
                               this.closeTab();
                        }
                        }) 
                        .catch(error => {
                                console.error('Error creating record:', error);
                        });
                  /*  submitButtonOnClick({caseId: this.caserecordId, accountId: this.accountId}).then(result=>{
                        console.log('submitButtonOnClick called........')
                    })
                    .catch(error=>{
                    });*/
                } else{
                    recordToCreate.apiName = ANSWER_OBJECT.objectApiName;
                    recordToCreate.fields[CASE_FIELD.fieldApiName] = this.caserecordId
                    createRecord(recordToCreate)
                        .then(() => {

                             //Trial Method

                          submitButtonOnClick({caseId: this.caserecordId, accountIds: accountIds}).then(result=>{
                        })
                        .catch(error=>{
                         });

                         if(this.isCloseTab != true){
                            this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
                            if(this.availableActions.find(element => element=='NEXT')){
                            this.dispatchEvent(new FlowNavigationNextEvent()); 
                            }else{
                            this.dispatchEvent(new FlowNavigationFinishEvent()); 
                            } 
                         

                            setTimeout(() => {

                            // window.location.reload();
                                
                            }, 4000);
                            
                                if (this.caserecordId) {
                                    this[NavigationMixin.Navigate]({
                                        type: 'standard__recordPage',
                                        attributes: {
                                            recordId: this.caserecordId,
                                            objectApiName: 'Case',
                                            actionName: 'view'
                                        }
                                        
                                    });
                                    
                                    then(() => {                    
                                        // window.location.reload();
                                        
                                    }).catch(error => {
                                        console.error('Error navigating to case page:', error);
                                    });
                                }
                            } else{
                                 this.closeTab();
                            }
                    }) 
                    .catch(error => {
                                console.error('Error creating record:', error);
                    });
                    
                  /*  submitButtonOnClick({caseId: this.caserecordId, accountId: this.accountId}).then(result=>{
                    })
                    .catch(error=>{
                    });*/
                }
            });

        }
        else{
        // Create records using createRecord
        recordsToCreate.forEach(recordToCreate => {
        createRecord(recordToCreate)
            .then(() => {

                //Trial Method
                submitButtonOnClick({caseId: this.caserecordId, accountIds: accountIds}).then(result=>{
                })
                .catch(error=>{
                });


                console.log('Creating Reacords');
               if(this.isCloseTab != true){
                this.dispatchEvent(new FlowAttributeChangeEvent("finishFlow",true));
                if(this.availableActions.find(element => element=='NEXT')){
                this.dispatchEvent(new FlowNavigationNextEvent()); 
                }else{
                this.dispatchEvent(new FlowNavigationFinishEvent()); 
                } 
                setTimeout(() => {

                // window.location.reload();
                    
                }, 4000);
                
                    if (this.caserecordId) {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.caserecordId,
                                objectApiName: 'Case',
                                actionName: 'view'
                            }
                            
                        });
                        
                        then(() => {                    
                            // window.location.reload();
                            
                        }).catch(error => {
                            console.error('Error navigating to case page:', error);
                        });
                    }
                } else {
                   this.closeTab();
                }
        }) 
        .catch(error => {
                    console.error('Error creating record:', error);
        });

        });
        }
        }
        ////FOUK-11496
      /* if(this.isCloseTab == true){
            window.setTimeout(() => {
             this.closeTab();
           },2000);      
    } */
}

    async closeTab() {
        try {
          if (this.isConsoleNavigation) {
            /*const workspaceAPI = this.template.querySelector('lightning-workspace-api');  
                const { tabId, parentTabId } = await workspaceAPI.getFocusedTabInfo();  
                await workspaceAPI.closeTab({ tabId: parentTabId });  
                await workspaceAPI.refreshTab({  
                    tabId: parentTabId,  
                    includeAllSubtabs: false  
                }); */ 

            const { tabId, parentTabId } = await getFocusedTabInfo(); 
               
            await refreshTab(parentTabId, {
                includeAllSubtabs: false
            });  

            await closeTab(tabId); 
               
          }
      } catch (error) {
          console.error('Error closing tab:', error);
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'There was an error closing the tab.',
                  variant: 'error',
              }),
          );
      }
      }

    //Get incident date
    get incidentDate(){
        return getFieldValue(this.caseData.data, 'Case.BLN_IncidentDate__c')
    }

    //Get mileage 
    get mileage(){
        return getFieldValue(this.caseData.data, 'Case.BLN_Vehicle__r.BLN_Mileage__c')
    }

    //FOUK-10731
    async createAnswerRecords(){
        console.log('accountRuleParameters for creation new',this.accountRuleParameters)
        let newAnswerRecords = [];
        this.accountRuleParameters.map(param =>{
            const fields = {};
            fields[Question_FIELD.fieldApiName] = param.Id;
            fields[CASE_FIELD.fieldApiName] = this.caserecordId;
            //check for IDAT code
            if(param.BLN_EDITypeCode__c == this.label.BLN_IDAT){
                fields[ANSWER_FIELD.fieldApiName] = this.incidentDate.split('T')[0];
            }
            //check for MILE code
            if(param.BLN_EDITypeCode__c == this.label.BLN_MILE){
                fields[ANSWER_FIELD.fieldApiName] = this.mileage.toString();
            }

            const recordInput = {
                apiName: ANSWER_OBJECT.objectApiName,
                fields: fields
            };
            newAnswerRecords.push(recordInput);
        })

        newAnswerRecords.map(recordInput =>{
            createRecord(recordInput)
            .then(record=>{
                //Get previous answers to get value prepopulated
                this.retrievePreviousAnswers();
            })
            .catch(error=>{
                console.log('error on create ', error)
            })
        })
    }
}