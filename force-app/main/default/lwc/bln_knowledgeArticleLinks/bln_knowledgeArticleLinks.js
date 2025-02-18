import { LightningElement,api,wire } from 'lwc';
import getKnowledgeArticles from '@salesforce/apex/BLN_ProductAvailability.displayLocation';
import  geturl  from '@salesforce/label/c.BLN_OrgUrl';
import { NavigationMixin } from 'lightning/navigation';;
import  knowledgeArticlesLabel  from '@salesforce/label/c.BLN_KnowledgeArticles';

export default class Bln_knowladgeArticleLinks extends NavigationMixin(LightningElement) {
    @api screenname;
    @api knowladgearticleobj;
    @api recordid;
    @api url;
    
    label={
        knowledgeArticlesLabel
    }
    NavigatetoKA(event){
        event.preventDefault();
        let recordId=event.target.dataset.id;
        this.url=geturl+`/r/Knowledge__kav/${recordId}/view`;
        history.pushState(null, '', this.url);
        window.dispatchEvent(new Event('popstate'));
  
    }
}