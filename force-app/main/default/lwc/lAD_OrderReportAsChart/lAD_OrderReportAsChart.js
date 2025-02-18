import { effectiveAccount } from 'commerce/effectiveAccountApi';
import { LightningElement, api, track } from 'lwc';

import chartjs from '@salesforce/resourceUrl/lwcc__chartjs_v280';

import {loadScript} from 'lightning/platformResourceLoader';

import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getAllOppsByStage from '@salesforce/apex/LAD_CsvController.getAllOppsByStage';
import getAccId  from '@salesforce/apex/LAD_ReturnAssociatedLocationDetails.getAccId';
import Id from '@salesforce/user/Id';

export default class LAD_OrderReportAsChart extends LightningElement {
    @api accountId;


    connectedCallback()
    {   
        getAccId({userid:Id})
        .then(result => {
            this.accountId=result;
            this.fetchDetails();
        })
        .catch(error=>{
            console.log(error);
        })
    }
    fetchDetails()
    {   let variable = effectiveAccount.accountId!=null & effectiveAccount.accountId!=undefined? effectiveAccount.accountId:this.accountId
        console.log(variable);
        getAllOppsByStage({accountId:variable}) 
        .then(result => {

            for(var key in JSON.parse(JSON.stringify(result))) {
                this.updateChart(result[key].count,result[key].label);
            }
            this.error=undefined;
        })
        .catch(error => {
            console.log(error);
        });
        
  }
  chart;
  chartjsInitialized = false;
  config={
      type : 'doughnut',
      data :{
          datasets :[
          {
              data: [],
              backgroundColor :[
                  'rgb(255,99,132)',
                  'rgb(255,159,64)',
                  'rgb(255,205,86)',
                  'rgb(75,192,192)',
                  'rgb(153,102,204)',
                  'rgb(179,158,181)',
                  'rgb(188,152,126)',
                  'rgb(123,104,238)',
                  'rgb(119,221,119)',],
              label:'Dataset 1'
          }
           ],
      labels:[]
      },
      options: {
          responsive : true,
          legend : {
              position :'right',
              label : 'Month'
          },
          animation:{
              animateScale: true,
              animateRotate : true
          }
      }
  };

  renderedCallback() {
      if(this.chartjsInitialized) {
          return;
      }
      this.chartjsInitialized = true;
      Promise.all([
          loadScript(this,chartjs)
          ]).then(() =>{
              const ctx = this.template.querySelector('canvas.donut')
              .getContext('2d');
              this.chart = new window.Chart(ctx, this.config);
          })
          .catch(error =>{
              this.dispatchEvent(
                  new ShowToastEvent({
                      title : 'Error loading ChartJS',
                      message : error.message,
                      variant : 'error',
              }),
          );
      });
  }

  updateChart(count,label){
      this.chart.data.labels.push(label);
      this.chart.data.datasets.forEach((dataset) => {
          dataset.data.push(count);
      });
      this.chart.update();
  }
}