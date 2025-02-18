import { LightningElement, api } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import getBranchPhone from '@salesforce/apex/BLN_CallBranchController.getBranchPhone';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class Bln_CallBranch extends LightningElement {
    @api Error;
    @api phone;
    
    connectedCallback() {
      getBranchPhone({ userId: USER_ID })
      .then((result) => {
        window.location=`tel:${result}`;
        this.dispatchEvent(new CloseActionScreenEvent());
        this.Error = '';
      })
      .catch((error) => {
        this.Error = 'Branch Phone number not found';
      });
    }

}