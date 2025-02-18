/** @description :  This component is used PreChat functinallity of webChat, Allow Guest users to fill information and 
 *                   Autopopulate email field of Registed User
*   @Story :        FOUK-9174; 
*   @author:        (punam.patil@pwc.com (IN))
*   @CreatedDate:   29-07-2024
*/


import { LightningElement, api, track,wire } from 'lwc';
import Id from '@salesforce/user/Id';
import userEmail from '@salesforce/apex/LAD_userEmailforpreChat.getUserEmail';


export default class LAD_PrechatForm extends LightningElement {
    @api configuration = {};
    @track fields = [];
    @track hiddenFields=[];
   
    
   userId = Id;
   CurrentUserEmailId; 
  
    
    connectedCallback() {

       
        
        if(this.configuration.forms){
            //console.log('Record'+this.record);
            console.log('userId'+this.userId);
            //console.log('Email'+this.currentUserEmail);
                    
               
            const prechatForm = this.configuration.forms.find(form => form.formType === 'PreChat');
            console.log('prechatForm',prechatForm);
            if (prechatForm) {
                
                this.fields = JSON.parse(JSON.stringify(prechatForm.formFields)).sort((a, b) => a.order - b.order);
                this.hiddenFields=JSON.parse(JSON.stringify(prechatForm.hiddenFormFields));
                console.log('fields',this.fields );
            }
        }
       

        this.fields = this.addChoiceListValues(this.fields);
    }


   
    //This method is used to get the choice list values of the fields
    addChoiceListValues(fields){
        
        fields.forEach(fld => {
            if(fld.type === 'ChoiceList'){
               
               

                fld.isChoiceList = true;
                const matchingChoice = this.configuration.choiceListConfig.choiceList.find(choice => choice.choiceListId === fld.choiceListId);
                console.log('list',matchingChoice);
                if(matchingChoice){
                    
                    fld.choiceListValues = matchingChoice.choiceListValues.map( (x) =>{ return {...x, value : x.choiceListValueName}}) || [];
                    console.log('fld.choiceListValues',fld.choiceListValues);
                    if (this.userId != null){
                    fld.value = 'Yes';
                    this.fields.forEach(fld => {
                        if(fld.name  === '_email'){    
                            fld.visible = true;
                            console.log('Email');
                            //console.log(userEmail.id,userEmail.value);
                           
                            userEmail({userId: this.userId}).then(result => {
                                console.log('here');
                               this.CurrentUserEmailId=JSON.parse(JSON.stringify(result));
                                  fld.value= this.CurrentUserEmailId;
                                 
                                  console.log('Id',fld.value);
                                  //this.count=1;
                             }).catch(error => {console.error('JSon error',error);});
            
                            
                            
                    }                    
                       else if(fld.name  === '_lastName'){    
                        fld.visible = false;
                    }
                    else if(fld.name  === '_firstName'){    
                        fld.visible = false;
                    }
                    else if(fld.name  === 'Company'){    
                        fld.visible = false;
                    }
                    else if(fld.name  === 'Phone Number'){    
                        fld.visible = false;
                    }
                })
                
            }
            else{
                fld.value = 'No';
                    this.fields.forEach(fld => {
                        if(fld.name  === '_email'){    
                            fld.visible = true;
                            console.log('Email');
                            //console.log(userEmail.id,userEmail.value);     
                    }                    
                       else if(fld.name  === '_lastName'){    
                        fld.visible = true;
                    }
                    else if(fld.name  === '_firstName'){    
                        fld.visible = true;
                    }
                    else if(fld.name  === 'Company'){    
                        fld.visible = true;
                    }
                    else if(fld.name  === 'Phone Number'){    
                        fld.visible = true;
                    }
                })
            }
            }
            
            
            } else {
                
                fld.isChoiceList = false;
            }
        });
        return fields;
    }

    //This method is used to display the fields based on the selection of choice list value of the exciting booking field
    handleChange(event){
        const fieldName = event.target.name;
        const fieldValue = event.detail.value;
        const changedField = this.fields.find(fld => fld.name === event.target.name);
        changedField.value = fieldValue;
        console.log('changedField',changedField, changedField.value);

        if(fieldValue === 'Yes' )
        {
            this.fields.forEach(fld => {
                console.log('fld.name',fld.name);
        if(fld.name  === '_email'){    
                fld.visible = true;
                fld.value=this.CurrentUserEmailId; 
        }   else if(fld.name  === '_lastName'){    
            fld.visible = false;
            fld.value= null;
        }
        else if(fld.name  === '_firstName'){    
            fld.visible = false;
            fld.value= null;
        }
        else if(fld.name  === 'Company'){    
            fld.visible = false;
            fld.value= null;
        }
        else if(fld.name  === 'Phone Number'){    
            fld.visible = false;
            fld.value= null;
        }
    
    })     

       }
        else if(fieldValue === 'No' )
        {
            this.fields.forEach(fld => {
                if(fld.name  === '_email'){    
                        fld.visible = true;
                        fld.value= null;
                }   else if(fld.name  === '_lastName'){    
                    fld.visible = true;
                }
                else if(fld.name  === '_firstName'){    
                    fld.visible = true;
                }
                else if(fld.name  === 'Company'){    
                    fld.visible = true;
                }
                else if(fld.name  === 'Phone Number'){    
                    fld.visible = true;
                }
        })
    }
     
    }

    //This method is created to send the values to the omni routing flow once the user click on Start Conversion button
    onClickStartConversation() {
        
       let hldfld=[];
        const prechatData = {};
        this.fields.forEach(field => {
            if(field.value){
               
                prechatData[field.name] = String(field.value);
                console.log('prechatdata',prechatData);
            }
        });
       hldfld=this.hiddenMethod();
       //console.log('hldfld',hldfld);
        hldfld.forEach(row => {
            this.hiddenFields.forEach(hFld => {
                if(row.name == hFld.name){
                    
                    hFld[0] = row.value;
                }
            });
        })
        this.hiddenFields.forEach(hiddenFld => {
            prechatData[hiddenFld.name] = (hiddenFld.value);
       });
        this.dispatchEvent(new CustomEvent(
            'prechatsubmit',
            {
                detail: { value: prechatData }
            }
            
        ));
        
        
    }

   
    //This method is used to get the details of hidden fields
    hiddenMethod(){
        let hField=[];
        
         hField.push({name: 'User_Id', value:this.userId});
        return hField;
       
    }


}