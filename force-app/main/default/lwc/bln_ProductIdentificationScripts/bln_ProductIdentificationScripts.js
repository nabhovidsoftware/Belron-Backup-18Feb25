import { LightningElement, api } from 'lwc';
import LightningAlert from 'lightning/alert';
import createTaskRecord from '@salesforce/apex/BLN_FetchKnowledgeArticles.createTaskRecord';
import checkMotabilityAccountNames from '@salesforce/apex/BLN_FetchKnowledgeArticles.checkMotabilityAccountName';
import STATIC_CALIBRATION from '@salesforce/label/c.BLN_StaticCalibration';
import DYNAMIC_CALIBRATION from '@salesforce/label/c.BLN_DynamicCalibration';
import STATIC_AND_DYNAMIC_CALIBRATION from '@salesforce/label/c.BLN_StaticAndDynamicCalibration';
import SPECIALIST_CALIBRATION_REQUIRED from '@salesforce/label/c.BLN_SpecialistCalibrationRequired';
import WIPER from '@salesforce/label/c.BLN_IsWiper';
import MOTABILITY from '@salesforce/label/c.BLN_IsMotabilityAccount';
import BOSCH from '@salesforce/label/c.BLN_IsBosch';


export default class bln_ProductIdentificationScripts extends LightningElement {
    @api caseId;
    @api checkedEvent = false;
    @api displayedArticles = [];
    @api selectedProd;
    @api articleList = [];
    @api isFirstLoadComplete;
    @api selectedProductList = [];
    @api addOnProductList = [];
    @api adasProductList = [];

    label = {
        'STATIC_CALIBRATION': STATIC_CALIBRATION,
        'DYNAMIC_CALIBRATION': DYNAMIC_CALIBRATION,
        'STATIC_AND_DYNAMIC_CALIBRATION': STATIC_AND_DYNAMIC_CALIBRATION, 
        'SPECIALIST_CALIBRATION_REQUIRED': SPECIALIST_CALIBRATION_REQUIRED,
        'WIPER' : WIPER,
        'MOTABILITY' : MOTABILITY,
        'BOSCH' : BOSCH
    }
   
   
    async connectedCallback(){
        this.displayedArticles = JSON.parse(JSON.stringify(this.displayedArticles));
        this.articleList = JSON.parse(JSON.stringify(this.articleList));
        this.adasProductList = JSON.parse(JSON.stringify(this.adasProductList));

        if(!this.isFirstLoadComplete){
            let allProductLst = JSON.parse(JSON.stringify(this.selectedProductList)).concat(JSON.parse(JSON.stringify(this.addOnProductList)));
            console.log('allProductLst -->',JSON.stringify(allProductLst));
            await allProductLst.forEach(element => {
                this.displayArticle(element);
            });
        }
        else{     
            if(this.selectedProd != undefined && this.articleList){
                this.selectedProd = JSON.parse(JSON.stringify(this.selectedProd));

                await this.displayArticle(this.selectedProd);
            } 
        }
        this.dispatchEvent(new CustomEvent('trackarticledisplay', {
            detail: {
                alreadyDisplayedArticles : JSON.stringify(this.displayedArticles)
            }
        }));
    }

    async displayArticle(clickedItem){
        if(!this.displayedArticles.includes('CE Location Job') && clickedItem.isBranchOnlyProduct == true && this.checkedEvent){
                    let currentArticle = this.articleList.find(item => item.Title == 'CE Location Job');
                    if(currentArticle){
                        this.showArticle(this.stripHtmlTags(currentArticle.BLN_Description__c),'info',currentArticle.Title);
                        this.displayedArticles.push('CE Location Job');    
                    }
                }
        if((!this.displayedArticles.includes('Motability Account Script') && clickedItem.productDescription.toLowerCase().includes((this.label.WIPER).toLowerCase()) && this.checkedEvent) 
            || (!this.displayedArticles.includes('Motability Account Script') && clickedItem.productDescription.toLowerCase().includes((this.label.BOSCH).toLowerCase()) && this.checkedEvent)){
                        checkMotabilityAccountNames({caseId : this.caseId})
                            .then(accName => {

                                if(accName && accName.toLowerCase().includes(this.label.MOTABILITY.toLowerCase())){
                                let currentArticle = this.articleList.find(item => item.Title == 'Motability Account Script');
                               if(currentArticle){
                                this.showArticle(this.stripHtmlTags(currentArticle.BLN_Description__c),'info',currentArticle.Title);
                                this.displayedArticles.push('Motability Account Script');
                                }
                            }
                        })
                    this.displayedArticles.push('Motability Account Script');
        }

        let currentAdasProduct = this.adasProductList.find(item => item.BLN_ProductCode__c == clickedItem.belronProductCode);
        if(this.checkedEvent && currentAdasProduct){
            if(!this.displayedArticles.includes('Centre appointment') && ((currentAdasProduct.BLN_Type__c == this.label.STATIC_CALIBRATION) || (currentAdasProduct.BLN_Type__c == this.label.STATIC_AND_DYNAMIC_CALIBRATION))){
                        let currentArticle = this.articleList.find(item => item.Title == 'Centre appointment');
                        if(currentArticle){
                            this.showArticle(this.stripHtmlTags(currentArticle.BLN_Description__c),'info',currentArticle.Title);
                            this.displayedArticles.push('Centre appointment');
                        }
                    }
            if(!this.displayedArticles.includes('Dynamic Appointments') && (currentAdasProduct.BLN_Type__c == this.label.DYNAMIC_CALIBRATION)){
                        let currentArticle = this.articleList.find(item => item.Title == 'Dynamic Appointments');
                        if(currentArticle){
                            this.showArticle(this.stripHtmlTags(currentArticle.BLN_Description__c),'info',currentArticle.Title);
                            this.displayedArticles.push('Dynamic Appointments');
                        }
                    }
            if(!this.displayedArticles.includes('Dealer Referral') && (currentAdasProduct.BLN_Type__c == this.label.SPECIALIST_CALIBRATION_REQUIRED)){
                        let currentArticle = this.articleList.find(item => item.Title == 'Dealer Referral');
                        if(currentArticle){
                            this.showArticle(this.stripHtmlTags(currentArticle.BLN_Description__c),'info',currentArticle.Title);
                            this.displayedArticles.push('Dealer Referral');
                        }
                    }
            } 
        else if(clickedItem.selectProduct && !this.displayedArticles.includes('Removed Advisor') && this.isFirstLoadComplete && currentAdasProduct){
          

                    let currentArticle = this.articleList.find(item => item.Title == 'Removed Advisor');
                    if(currentArticle){
                        this.showArticle(this.stripHtmlTags(currentArticle.BLN_Description__c),'info',currentArticle.Title);
                        this.displayedArticles.push('Removed Advisor');
                    }
                }  
        
   
  
            }  

    async showArticle(msg, theme, heading) {
            await LightningAlert.open({
                message: msg,
                theme: theme,
                label: heading
            });

            createTaskRecord({
                subject : heading,
                description : msg,
                caseId : this.caseId
            })
            .then(result => {
        })
        .catch(error => {
        })
    }

     stripHtmlTags(html) {
         const doc = new DOMParser().parseFromString(html, 'text/html');
         return doc.body.textContent || "";
     }
}