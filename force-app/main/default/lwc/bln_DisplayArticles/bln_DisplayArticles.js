import { LightningElement,api,track ,wire} from 'lwc';
import knowledgeArticleFlowName from '@salesforce/label/c.BLN_KnowledgeArticleflow';

export default class Bln_DisplayArticles extends LightningElement {
    @api recordId; 
    @track showArticles = false;
    @track specialVehicleFlag = false;
    @api caseid;
    @api accountid;

    get inputVariables() {
        return [
            {
                name: 'CaseId',
                type: 'String',
                value: this.recordId
            },
            {
                name: 'accountid',
                type: 'String',
                value: this.recordId
            }
        ];
    }
    label = {
        knowledgeArticleFlowName
    }
}