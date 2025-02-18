import { LightningElement , api} from 'lwc';
import errorMsg from '@salesforce/label/c.BLN_ErrorMsg';
import conPidTeamMsg from '@salesforce/label/c.BLN_ConPidTeam';
import {FlowAttributeChangeEvent,FlowNavigationFinishEvent,FlowNavigationNextEvent} from 'lightning/flowSupport';
export default class Bln_CreateDaError extends LightningElement {

    @api finishFlow = false;
    @api returnBom = '';
    @api availableActions = [];
    errorMessage = '';
   
    label = {
    errorMsg,
    conPidTeamMsg
}
  connectedCallback(){
      let checkResult = this.containsKeyword(this.returnBom, 'RESULT');
      if(!checkResult){
        this.errorMessage = this.returnBom;
      }

      let checkQuestion = this.containsKeyword(this.returnBom, 'QUESTIONS');
      if(!checkQuestion){
        this.errorMessage = this.returnBom;
      }
  }

  containsKeyword(string, keyword) {  
    return string.includes(keyword);  
}  

    closeErrorModal(){
        this.dispatchEvent(new FlowAttributeChangeEvent('finishFlow',true));
         if(this.availableActions.find(element => element=='FINISH')){
        this.dispatchEvent(new FlowNavigationFinishEvent());
         }
    }
}