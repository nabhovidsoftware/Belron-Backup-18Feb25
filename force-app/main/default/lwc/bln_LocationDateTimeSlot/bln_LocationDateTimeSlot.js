import { LightningElement,track, api } from 'lwc';
//import getLocationDetails from '@salesforce/apex/BLN_ProductAvailability.otherProducts'
import createAppoitment from '@salesforce/apex/BLN_AppointmentCreateUpdate.createAppointmentData'
import updateDate from '@salesforce/apex/BLN_AppointmentCreateUpdate.updateAppointment'
import getSlots from '@salesforce/apex/BLN_AppointmentCreateUpdate.getMobileSlots'
import getSlotTwo from '@salesforce/apex/BLN_AppointmentCreateUpdate.getBranchSlots'
import EarlyAppoitment from '@salesforce/label/c.BLN_EarliestAppointmentAvailable';
import WeatherGuard from '@salesforce/label/c.BLN_WeatherGuardAppointmentAvailability';
import Discount from '@salesforce/label/c.BLN_QuoteDiscount';
import Vat from '@salesforce/label/c.BLN_QuoteVAT';
import Total from '@salesforce/label/c.BLN_QuoteTotal';
import EnterDate from '@salesforce/label/c.BLN_EnterDate';
import orderId from '@salesforce/label/c.BLN_OrderIdLabel';
import NoSlotAvailable from '@salesforce/label/c.BLN_NoSlotAvailable';
import slotBooked from '@salesforce/apex/BLN_AppointmentBooking.bookAppointment';
//import showProduct from '@salesforce/apex/BLN_ProductAvailability.createOrderItems';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
import LightningAlert from 'lightning/alert';
import UnableCreateSa from '@salesforce/label/c.BLN_UnableCreateSa';
import SelectProduct from '@salesforce/label/c.BLN_SelectProduct';
export default class Bln_LocationDateTimeSlot extends LightningElement {
    @track slots;
    @track date1 ;
    @track date2 ;
    @track date3 =new Date();
    @track whiteStyle="height:2rem;width:11.6rem; border:1px solid black;"; //background:white
    @track locStyle = "height:3rem;width:58.3rem; border:1px solid black;background:Darkgreen";"slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester";
    @track boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester slds-listbox__item";
    @track product = [];
    @track appSlots = [];
    @track checkUncheck; 
    @track checkUncheckDateSlot;
    @api weatherTrue;
    @api weathersTrue;
    @track dateString;
    @api closecalender;
    @api recordid;
    @track checkSelectSlot = false;
    @api backArray;
    @api isreceivedata = false;
    @api maindatemap = [];
    @api childslotmap = [];
    @api quotedetails = [];
    @api quoteDetailsDataList = [];
    @api earlistAvailibilityDetailsList = [];
    @api slotdatafromparent = [];
    @api caseid = '';
    @api productdatalist = [];
    @track quoteDetailsDataListCopy;
    @api insurancerows = [];
    @api selectedrows = [];
    dateSlotShow=true;
    showSpinner = true;
    today;
    firstDate;
    leftArrowDisabled = false;
    dateStringCheck;
    dateSlotProduct = [];
    divelement;
    @track dateMap = [];
    dateValue;
    location;
    earlyAppoitment = '';
    earlyAppoitmentNullCheck = '';
    CheckLocation;
    weatherAppoitment;
    vat;
    total;
    earlyAppoitmentSlot = '';
    weatherAppoitmentSlot;
    earlyAppoitmentMainDate = '';
    weatherAppoitmentMainDate;
    checkUncheckLoc = '';
    isInsurance = false;
    appoitmentDates = '';
    myDate;
    finalSlotMap = [];
    serviceAppId='';
    tenDates = [];
    rightArrowDisabled = false;
    slotDateCheck;
    quoteRangeLocation = '';
    quoterangeBoolean = true;
    startSlotTime = '';
    endSlotTime = '';
    orderId = '';
    @api slotstartparent = '';
    @api slotendparent = '';
    @api saidparent = '';
    //trial dates logic variable
    @track startIndex = 0;
    @track endIndex = 2;
    noSlotBoolean = false;
   //trial date logic variable
   @track otherThanDiscountList = [];
   @track arreyMap = [];
    @track testArrey = [{value:'9-9.30' ,booked:'true'},{value:'9.30-10'},{value:'10-10.30'},{value:'10.30-11'},{value:'11-11.30',booked:'true'},{value:'11.30-12'},{value:'12-12.30'},{value:'12.30-13'},{value:'13-13.30',booked:'true'},{value:'13.30-14'},{value:'14-14.30'},{value:'14.30-15'},{value:'15-15.30'},{value:'15.30-16'},
    {value:'16-16.30'},{value:'16.30-17', booked:'true'},{value:'17-17.30'},{value:'17.30-18'},{value:'18-18.30'},{value:'18.30-19'}];

    availabilityDetails = {

        'availabilityDetails':[
            {
                "stockLocationId": "9y8avfh9",
                "availableFromDate": "2024-02-27T10:00:00+00:00"
            },
            {
                "stockLocationId": "8917vqoalZ",
                "availableFromDate": "2024-02-28T10:00:00+00:00"
            },
            {
                "stockLocationId": "8917vqoalv",
                "availableFromDate": "2024-02-29T10:00:00+00:00"
            }
        ]
    }

    timeSlot = {
     'ts' :  [
            {
                "endTime": "2024-01-25T08:30:00.000Z",
                "startTime": "2024-01-25T08:00:00.000Z"
            },
            {
                "endTime": "2024-01-25T11:00:00.000Z",
                "startTime": "2024-01-25T10:30:00.000Z"
            },
            {
                "endTime": "2024-01-25T13:00:00.000Z",
                "startTime": "2024-01-25T12:30:00.000Z"
            },
            {
                "endTime": "2024-01-25T13:30:00.000Z",
                "startTime": "2024-01-25T13:00:00.000Z"
            },
            {
                "endTime": "2024-01-25T14:00:00.000Z",
                "startTime": "2024-01-25T13:30:00.000Z"
            },
            {
                "endTime": "2024-01-25T14:30:00.000Z",
                "startTime": "2024-01-25T14:00:00.000Z"
            },
            {
                "endTime": "2024-01-25T15:00:00.000Z",
                "startTime": "2024-01-25T14:30:00.000Z"
            }
        ]
    }
      testList1 =[];
      testList2 =[];
      testList3 =[];
      testList4 =[];
      testList5 =[];
      startDateParam =[];
      endDateParam =[];
    
      label = {
        EarlyAppoitment,
        WeatherGuard,
        Discount,
        Vat,
        Total,
        EnterDate,
        orderId,
        NoSlotAvailable,
        UnableCreateSa,
        SelectProduct
      }

    connectedCallback() {
       console.log('earlistAvailibilityDetailsList', JSON.stringify(this.earlistAvailibilityDetailsList));
       console.log('slotdatafromparent123', JSON.stringify(this.slotdatafromparent));
       console.log('productdatalist in Child', JSON.stringify(this.productdatalist));
       if(this.slotstartparent != '' && this.slotendparent != '' && this.saidparent != ''){
        this.serviceAppId = this.saidparent;
        this.endSlotTime = this.slotendparent;
        this.startSlotTime = this.slotstartparent;
       }
        this.quoteDetailsDataListCopy = JSON.parse(JSON.stringify(this.quoteDetailsDataList));
        this.showSpinner = false;
        //this.dateUpdate();
       /* let currDate = new Date();
        let isoFormattedDate=currDate.toISOString().replace('Z','+00:00');
        console.log('slot',isoFormattedDate);*///2024-01-05T09:24:21.539+00:00
        console.log('quoteDetailsfrom Parent', JSON.stringify(this.quoteDetailsDataListCopy));
        this.quoteDetailsDataListCopy.forEach(element => {
 //           console.log((element.quoteEarliestAppointmentAvailability).substring(0,element.quoteEarliestAppointmentAvailability.indexOf('T')));
            element.quoteEarliestAppointmentAvailability = this.formatDate(new Date((element.quoteEarliestAppointmentAvailability).substring(0,element.quoteEarliestAppointmentAvailability.indexOf('T'))));
        });
        console.log('quoteDetailsfrom Parent2', JSON.stringify(this.quoteDetailsDataListCopy));
        let timestampString  = "2023-11-06T10:00:00+00:00";
        const timestamp = new Date(timestampString);
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        let updatedDate = new Intl.DateTimeFormat('en-US', options).format(timestamp);
        console.log('updatedDate'+ updatedDate);
           
       console.log('Test Arrey', JSON.stringify(this.testArrey));
      let currDate = new Date().toJSON();//2024-01-05T09:24:21.539Z
      console.log('datesfor slot',currDate);
      console.log('DateSlotsInConnectedCallback', JSON.stringify(this.timeSlot.ts));
   
        const date = new Date();

let day = date.getDate();
let month = date.getMonth() + 1;
let year = date.getFullYear();

    let currentDate = `${year}-${month}-${day}`;
    currentDate = currentDate +'T10:00:00+00:00';
console.log(currentDate);

let tomorrowDate = `${year}-${month}-${day + 1}`;
tomorrowDate = tomorrowDate +'T10:00:00+00:00';
console.log(tomorrowDate);

let dayAfterTomorrowDate = `${year}-${month}-${day + 2}`;
dayAfterTomorrowDate = dayAfterTomorrowDate +'T10:00:00+00:00';
console.log(dayAfterTomorrowDate);
     
   
       if(this.recordid != 'Insurance / Account'){
          this.isInsurance = true;
       }else{
        this.isInsurance = false;
       
       }

     
       
    
  
        this.searchLoactionDetails();

        

       if(this.isreceivedata == true){
        this.receiveQuotData();
     }


// for(let i = 0; i < 5; i++) {
//     this.testList1.push(this.testArrey[i]);
//   }
//    this.arreyMap.push({
//        row: '1',
//        List:JSON.parse(JSON.stringify(this.testList1))
//    })
//  for(let i = 5; i < 10; i++) {
//     this.testList2.push(this.testArrey[i]);
//     }
//   this.arreyMap.push({
//        row: '2',
//        List:JSON.parse(JSON.stringify(this.testList2))
//    })
//  for(let i = 10; i < 15; i++) {
//     this.testList3.push(this.testArrey[i]);
//     }
//    this.arreyMap.push({
//        row: '3',
//        List:JSON.parse(JSON.stringify(this.testList3))
//    })
// for(let i = 15; i < 20; i++) {
//     this.testList4.push(this.testArrey[i]);
//     }
//    this.arreyMap.push({
//        row: '4',
//        List:JSON.parse(JSON.stringify(this.testList4))
//    })
    //this.childataSend();

  //Trial Code Start
//   let timslotArreystartTime = [];
//   let timeslotArreyendTime = [];

//   this.timeSlot.ts.forEach( element => {
//     const timestampStart = element.startTime;
//     const dateObject = new Date(timestampStart);
//     const timeString = dateObject.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
   
//     let formattedTime = timeString.replace(/\s?[AP]M$/i,'');
//     console.log('Time Format start',formattedTime);
//     timslotArreystartTime.unshift(formattedTime);
//   });

//   this.timeSlot.ts.forEach( element => {
//     const timestampEnd = element.endTime;
//     const dateObject = new Date(timestampEnd);
//     const timeString = dateObject.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
//     let formattedTime = timeString.replace(/\s?[AP]M$/i,'');
//     console.log('Time Format start',formattedTime);
//     timeslotArreyendTime.unshift(formattedTime);
//   });
//    let finalSlotMap = [];
//   for(let i = 0; i<= timslotArreystartTime.length; i++){
//     let startTime = timslotArreystartTime[i];
//     let endTime = timeslotArreyendTime[i];
//     finalSlotMap.unshift(startTime +'-'+endTime);
//   }
//   finalSlotMap.splice(0,1);
//   finalSlotMap.reverse(); 

//   console.log('TimeSlotFormatstart', JSON.stringify(timslotArreystartTime));
//   console.log('TimeSlotFormatend', JSON.stringify(timeslotArreyendTime));
//   console.log('final Slot Map', JSON.stringify(finalSlotMap));
}

formatDate(dateObject){
    const day = dateObject.getDate();
    const dayWithSuffix = this.addSuffixToDay(day);
    const formattedDate = new Intl.DateTimeFormat('en-US',{
        year:'numeric',
        month:'long',
        day:'numeric'}).format(dateObject);
    return formattedDate.replace(String(day),dayWithSuffix);
   }
    
    addSuffixToDay(day){
        if(day>=11 && day<=13){
            return day +'th';
        }
        switch(day % 10){
            case 1: 
                return day + 'st';
            case 2: 
                return day + 'nd';
            case 3: 
                return day + 'rd';
            default:
                return day+ 'th';
        }
    }




  @api showWeatherAppotment(){
    this.weathersTrue = true;
  }


  
    handleDiv(event){
        alert('div mein'+event.target.label);
        this.whiteStyle = "height:2rem;width:11.6rem; border:1px solid black;background:grey"
    }
       selectedRows = [];

    handleChangeCheck(event){
          const checkedVlue = event.target.checked;
          const selesctedId = event.target.value;
          const selectedRow = this.product.find(row => row.id===parseInt(selesctedId));
          if(checkedVlue){
            this.selectedRows.push(selectedRow);
          }else{
           const index = this.selectedRows.findIndex(row =>row.id === parseInt(selesctedId));
                 if(selesctedId !== null || selesctedId === ''){
                     this.selectedRows.splice(selesctedId,1);
             }
           }
    }

    handleLocation(event){
     if(this.locStyle.endsWith("Darkgreen")){
              this.locStyle ="height:3rem;width:58.3rem; border:1px solid black;background:lightgreen"
     }
    }
 
   

    locationValue(event){
        if(this.selectedrows.length == 0 && this.insurancerows.length == 0){
            LightningAlert.open({
                message:  this.label.SelectProduct,//'Error While Create The Service Appointment',
                theme: 'error', // a red theme intended for error states
                label: 'Error!', // this is the header text
            });
         return;
       }
        this.showSpinner = true;
        //this.dateMap = [];
        //this.appSlots= [];
        let location = event.currentTarget.dataset.value;
        let quoteId = event.currentTarget.dataset.quoteid;
        this.quoteRangeLocation = location;
        let availableDate;
        let availabilityDetails={};
        this.CheckLocation = event.currentTarget.dataset.value;
        this.quoterangeBoolean = false;
        //custom event for selected location 
        const selectedEvent = new CustomEvent("quoterangelocation", {
            detail: this.quoteRangeLocation
          });
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);

        // if(this.quoteRangeLocation != ''){
        //     setInterval(() => {
        //         this.quoterangeBoolean = true;     
        //     }, 1);
        // }

      this.otherThanDiscountList.forEach(element => {
         if(location == element.quotelocation){
            this.location = element.quotelocation;
            this.vat = element.quoteVAT;
            this.total = element.quoteTotal;
         }
      });

          this.earlistAvailibilityDetailsList.forEach( ele => {
            console.log('elementavailability', JSON.stringify(ele.earliestDates));
                if(quoteId == ele.quoteId){
                    availabilityDetails = {
                        availabilityDetails : ele.earliestDates
                    };

                    this.orderId = ele.orderId;
                    
                }
          });
          console.log('orderId',  this.orderId);


          console.log('availableDate',JSON.stringify(availabilityDetails));

         // this.childataSend();
   if(this.checkUncheckLoc == event.currentTarget.dataset.value){
        this.checkUncheckLoc = '';
    }

    else{
        this.checkUncheckLoc = event.currentTarget.dataset.value;
    }
             this.otherThanDiscountList.forEach(ele => {
             if(ele.quotelocation == this.checkUncheckLoc && this.checkUncheckLoc){ 
                ele.checked = true;
                ele.loccss = "slds-box slds-text-heading_large slds-m-around_small slds-col slds-align_absolute-center slds-size_11-of-12 slds-listbox__item locationCSS true ";
               }else{
                ele.checked = false;
                ele.loccss = "slds-box slds-text-heading_large slds-m-around_small slds-col slds-align_absolute-center slds-size_11-of-12 slds-listbox__item locationCSS";
                ele.earlyCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item baground_color_1";
                ele.weatherCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item baground_color_1";
                ele.showSlots = false;
                ele.dateSlotShow = false;
                ele.weatherDateShow = false;

             if(event.currentTarget.dataset.valcheck != "false"){
                this.location = '';
             }
                 
                this.dateMap.forEach(ele => {
                     ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect  bagroundcolor_slotA";
                    ele.slotWeathercss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect  bagroundcolor_slotA";
               });
            }
           });
        // let values = '8017Z00000519txQAA' this.label.orderId this.orderId;
        console.log('In Loacation Value1' , JSON.stringify(availabilityDetails));
        let trueclasList = event.currentTarget.classList.contains('true');
        if(trueclasList != true){
        createAppoitment({ 
            orderId : this.orderId,
            scmJson : JSON.stringify(availabilityDetails)
        })
        .then( (result)=> {
            if(result.appointmentId){
                this.slots=result;
                //for (var i = 0; i < result.saList.length; i++) {
                    console.log('result1'+JSON.stringify(result));
                    console.log('result12'+JSON.stringify(result.appointmentId));
                   // console.log('SAList Length'+result.saList.length);
                    this.serviceAppId = result.appointmentId;
                    this.showSpinner = false;
                    console.log('serviceAppId'+this.serviceAppId);
                   // this.slot(result);
                    /*getSlots({ 
                        isDependencyCreated : result.isDependencyCreated,
                        sa : result.saList[0],
                        orderId : result.orderId,
                        opName : result.opName
                    })
                    .then( (slots)=> {
                        console.log('slots :: ', JSON.stringify(slots));
                        appSlots = slots;
                        for (var j = 0; j < appSlots.length; j++) {
                            console.log('Slot before :: ' + appSlots[j].startTime + ' --- ' + appSlots[j].endTime);
                        }
                    })
                    .catch( (error)=> {
                        console.log('getslotsError', JSON.stringify(error.message));
                    })*/
                //}
                // if(result.saList.length > 0){
                //     this.dispatchEvent(
                //         new ShowToastEvent({
                //             title: appSlots.length > 0 ? result.variant : 'Warning',
                //             message: appSlots.length > 0 ? result.msg : 'Slots are Not Available!',
                //             variant: appSlots.length > 0 ? result.variant : 'warning'
                //         })
                //     );
                // } else {
                //     this.dispatchEvent(
                //         new ShowToastEvent({
                //             title: result.variant,
                //             message: result.msg,
                //             variant: result.variant
                //         })
                //     );
                // }
            }
        })
        .catch( (error)=> {
            this.showSpinner = false;
            console.log('CreateAppoinmentError123', error);
            LightningAlert.open({
                message:  error.message, //this.label.UnableCreateSa,//'Error While Create The Service Appointment',
                theme: 'error', // a red theme intended for error states
                label: 'Error!', // this is the header text
            });
           
        });
    }else{
        this.showSpinner = false;
    }
    }

    slot(result , isSelectSlot){
     this.appSlots = [];
       console.log('APP SLOTS-->',this.appSlots);
        console.log('SA Id',JSON.stringify(result.appointmentId));
        console.log('Slot Method Result',JSON.stringify(result));

        // getSlots({ 
        //     appointmentId : this.serviceAppId
        // })
        getSlotTwo({
            appointmentId : this.serviceAppId
        })
        .then((slots) => {
            let dateSort;
            this.finalSlotMap = [];
            //appSlots = [];
            console.log('slots ::', slots);
            console.log('slots Length:: ', slots.length);
           // this.appSlots = slots;
           dateSort = slots

           if(dateSort[0].isSuceess == false){
            this.noSlotBoolean = true;
        }else{
            this.noSlotBoolean = false;
        }
            // for (var j = 0; j < this.appSlots.length; j++) {
            //     console.log('Slot before :: ' + this.appSlots[j].startTime + ' --- ' + this.appSlots[j].endTime);
            // }

            if(dateSort.length > 0){
                this.showSpinner = false;
                this.finalSlotMap = [];
                this.startDateParam = [];
                this.endDateParam = [];
/*                this.dispatchEvent(
                       new ShowToastEvent({
                           title: dateSort.length > 0 ? result.variant : 'Warning',
                           message: dateSort.length > 0 ? result.msg : 'Slots are Not Available!',
                           variant: dateSort.length > 0 ? result.variant : 'warning'
                       })
                   );*/

                   let timslotArreystartTime = [];
                   let timeslotArreyendTime = [];
                   
                   let startTimeFilter;
                   let dateParts ;
                   let dateendfilter ;
                   let datePartsa ;
                   let datestartfilter ;
                   let endTimeFilter; 
                    console.log('DATE SORT LIST-->',dateSort);
                   if(isSelectSlot == true){
                    if(dateSort.length != 0){
                        if(dateSort[0].isSuceess != false){
                      dateSort.forEach(ele => {
                       endTimeFilter = ele.endTime;
                    //  startTimeFilter = ele.startTime;
   
                       dateParts = endTimeFilter.split('T');
                        dateendfilter = dateParts[0];
                        console.log('dateendfilter-->',dateendfilter);

                       
                    //    datePartsa = startTimeFilter.split('T');
                    //    datestartfilter = datePartsa[0];
                        
                       if((this.slotDateCheck == dateendfilter)){
                        console.log('SLOT DATE-->',this.slotDateCheck);
                        this.appSlots.push(ele);
                        }
                      });
                    }
                }
                   }
                   console.log('APP SLOTS LIST --> ',this.appSlots);

                   this.appSlots.forEach( element => {
                    this.startDateParam.push(element.startTime);
                     const timestampStart = element.startTime;
                     const dateObject = new Date(timestampStart);
                    // const timeString = dateObject.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    const hours = dateObject.getUTCHours().toString().padStart(2, '0');
                    const minutes = dateObject.getUTCMinutes().toString().padStart(2, '0');
                    const timeString = `${hours}:${minutes}`;
                     let formattedTime = timeString.replace(/\s?[AP]M$/i,'');
                     console.log('Time Format start',formattedTime);
                     timslotArreystartTime.push(formattedTime);
                   });
                 
                   this.appSlots.forEach( element => {
                    this.endDateParam.push(element.endTime);
                     const timestampEnd = element.endTime;
                     const dateObject = new Date(timestampEnd);
                    // const timeString = dateObject.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                    const hours = dateObject.getUTCHours().toString().padStart(2, '0');
                    const minutes = dateObject.getUTCMinutes().toString().padStart(2, '0');
                    const timeString = `${hours}:${minutes}`;
                     let formattedTime = timeString.replace(/\s?[AP]M$/i,'');
                     console.log('Time Format start',formattedTime);
                     timeslotArreyendTime.push(formattedTime);
                   });
                   // let finalSlotMap = [];
                   for(let i = 0; i<=  this.appSlots.length; i++){
                     let startTime = timslotArreystartTime[i];
                     let endTime = timeslotArreyendTime[i];
                     let startTimePara = this.startDateParam[i];
                     let enddatePara = this.endDateParam[i];
                     this.finalSlotMap.push({
                      value : startTime +'-'+endTime,
                      starttime : startTimePara,
                      endtime :  enddatePara                   
                     });
                   }
                   console.log('finalSlotMap beforeSplice:: ', JSON.stringify(this.finalSlotMap));
                 // this.finalSlotMap.splice(0,1);
                 // this.finalSlotMap.splice(-1,1);
                 this.finalSlotMap = this.finalSlotMap.filter(item => item.value != undefined);
                 this.finalSlotMap.splice(-1,1);
                  console.log('finalSlotMap Length:: ', this.finalSlotMap.length);
                  // finalSlotMap.reverse(); 
                 
                   console.log('TimeSlotFormatstart', JSON.stringify(timslotArreystartTime));
                   console.log('TimeSlotFormatend', JSON.stringify(timeslotArreyendTime));
                   console.log('final Slot Map', JSON.stringify(this.finalSlotMap));
                   console.log('final Slot Map0', JSON.stringify(this.finalSlotMap[0]));
                   console.log('final Slot Map1', JSON.stringify(this.finalSlotMap[1]));
                   console.log('final Slot Map2', JSON.stringify(this.finalSlotMap[2]));
                   console.log('final Slot Map3', JSON.stringify(this.finalSlotMap[3]));
                   console.log('final Slot Map4', JSON.stringify(this.finalSlotMap[4]));
               } else {
                    this.showSpinner = false;
/*                    this.dispatchEvent(
                new ShowToastEvent({
                    title: result.variant,
                    message: result.msg,
                    variant: result.variant
                })
                   );*/
               }
     if(isSelectSlot == true){
        this.arreyMap = [];
        this.testList1 = [];
        this.testList2 = [];
        this.testList3 = [];
        this.testList4 = [];
        this.testList5 = [];
        this.otherThanDiscountList.forEach(ele => {
                    ele.showSlots = true;     
            });

            for(let i = 0; i < 5; i++) {
                this.testList1.push(this.finalSlotMap[i]);
              }
              this.testList1 = this.testList1.filter(item => item != null);
               this.arreyMap.push({
                   row: '1',
                   List:JSON.parse(JSON.stringify(this.testList1))
               });

               console.log('arreyMap1',JSON.stringify(this.arreyMap));

             for(let i = 5; i < 10; i++) {
                this.testList2.push(this.finalSlotMap[i]);
                }
                this.testList2 = this.testList2.filter(item => item != null);
              this.arreyMap.push({
                   row: '2',
                   List:JSON.parse(JSON.stringify(this.testList2))
               });
               console.log('arreyMap2',JSON.stringify(this.arreyMap));
             for(let i = 10; i < 15; i++) {
                this.testList3.push(this.finalSlotMap[i]);
                }
                this.testList3 = this.testList3.filter(item => item != null);
               this.arreyMap.push({
                   row: '3',
                   List:JSON.parse(JSON.stringify(this.testList3))
               });
               console.log('arreyMap3',JSON.stringify(this.arreyMap));
            for(let i = 15; i < 20; i++) {
                this.testList4.push(this.finalSlotMap[i]);
                }
                this.testList4 = this.testList4.filter(item => item != null);
               this.arreyMap.push({
                   row: '4',
                   List:JSON.parse(JSON.stringify(this.testList4))
               });
               let testList5 = [];
               for(let i = 20; i < 25; i++) {
                this.testList5.push(this.finalSlotMap[i]);
                }
                this.testList5 = this.testList5.filter(item => item != null);
                console.log('testList5',this.testList5);
               this.arreyMap.push({
                   row: '5',
                   List:JSON.parse(JSON.stringify(this.testList5))
               });
               console.log('arreyMap5',JSON.stringify(this.arreyMap));

               console.log('arreyMap5 Length', this.arreyMap.length);

               this.arreyMap.forEach(element => {
       
                element.List.forEach(ele => {
                      ele.boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item";
                 
                });
           });

           if(this.arreyMap[0].List.length == 0){
             this.noSlotBoolean = true;
           }else{
            this.noSlotBoolean = false;
           }
        }
          
        })
  
        .catch( (error)=> {
            console.log('getslotsError', JSON.stringify(error));

        });

       
    }

    confirmButton(){
        const confirmSend = new CustomEvent('confirm',{
          detail : true
        });
        this.dispatchEvent(confirmSend);

    }

    removeFirst(element, index){
        return index > 0
    }

    // FetchTheRecord From CPQ JSON
    searchLoactionDetails(){
        console.log('quoteDetailsfrom Parent', JSON.stringify(this.quoteDetailsDataList));
        // showProduct({ payload: 'xyz' })
        // .then(result=>{
         
        //    console.log('RES-->',JSON.stringify(result));
           
        //     this.quoteDetails = JSON.parse(JSON.stringify(result.quoteDetailsDataList));
        //      console.log('LocationQuoteDetail-->'+JSON.stringify(this.quoteDetails));
        // }).catch(error=>{
        //     console.log('error occured-->'+error);
            
        //     });	
           
          
      
            this.slots = this.slotdatafromparent;
            console.log('Slot in SearchLoacation', JSON.stringify(this.slots));
        this.otherThanDiscountList = this.quoteDetailsDataListCopy;
        console.log('otherThanDiscountList',JSON.stringify(this.otherThanDiscountList));
          this.otherThanDiscountList.forEach(ele => {
          
                ele.dateSlotShow = false;
                ele.checked = false;
                ele.weatherShow = this.weatherTrue;
                ele.loccss = "slds-box slds-text-heading_large slds-m-around_small slds-col slds-align_absolute-center slds-size_11-of-12 slds-listbox__item locationCSS";
                ele.earlyCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item baground_color_1";
                ele.weatherCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item baground_color_1";
           });
     
     
     
     
     
    //     getLocationDetails({ })
    //     .then((result)=>{
    //           this.dateSlotProduct = result;
    //          this.otherThanDiscountList =  this.dateSlotProduct.filter(this.removeFirst);
    //          console.log('otherThanDiscountList',JSON.stringify(this.otherThanDiscountList));
    //            this.otherThanDiscountList.forEach(ele => {
               
    //             ele.dateSlotShow = false;
    //             ele.checked = false;
    //             ele.weatherShow = this.weatherTrue;
    //             ele.loccss = "slds-box slds-text-heading_large slds-m-around_small slds-col slds-align_absolute-center slds-size_11-of-12 slds-listbox__item locationCSS";
    //             ele.earlyCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item baground_color_1";
    //             ele.weatherCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item baground_color_1";
    //        });
    //  })
    //   .catch((error) => {
          
    //       });

         
     }

     earlyAppoitmentClick(event){
    this.arreyMap = [];
    
      this.earlyAppoitmentNullCheck = event.currentTarget.dataset.id;
         if(this.earlyAppoitmentNullCheck != this.CheckLocation){
             return;
        } 


        let earlyFinish =  event.currentTarget.dataset.id;
        let slotAvailability = event.currentTarget.dataset.name; 
        let earlyAppoinment = event.currentTarget.dataset.value;

        //this.childataSend();         
      if(event.currentTarget.dataset.value != ''){
        this.today = event.currentTarget.dataset.value
        let dateString = this.today;

        console.log('Today',this.today);

       if(dateString.includes("th")){
        dateString = dateString.replace('th', '');
        //date = new Date(dateString);
       }

       if(dateString.includes("st")){
        dateString = dateString.replace('st', '');
        //date = new Date(dateString);
       }

       if(dateString.includes("nd")){
        dateString = dateString.replace('nd', '');
        //date = new Date(dateString);
       }

       if(dateString.includes("rd")){
        dateString = dateString.replace('rd', '');
      //  date = new Date(dateString);
       }

         let date = new Date(dateString);

         let date1 = new Intl.DateTimeFormat( 'en-US' ).format( date );
         let dateParts = date1.split("/");
         let newFormat = dateParts[1] + "/" + dateParts[0];
         this.dateStringCheck = newFormat;

        this.otherThanDiscountList.forEach(ele => {
            if(earlyFinish == ele.quotelocation && slotAvailability == "EarliestAppoitment"){
                ele.dateSlotShow = true;
           }else{
                ele.dateSlotShow = false;
            } 
        });

        this.otherThanDiscountList.forEach(ele => {
            if(earlyFinish == ele.quotelocation && slotAvailability == "WeatherGuard"){
                ele.weatherDateShow = true;
            }else{
                ele.weatherDateShow = false;
            }   
        });

        this.arreyMap.forEach(element => {
            element.List.forEach(ele => {
               ele.checked = false;
                    ele.boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item";
            });
     });

        if(slotAvailability == "EarliestAppoitment"){
            this.earlyAppoitmentMainDate =  earlyAppoinment;
            this.otherThanDiscountList.forEach(ele => {
                 ele.weatherCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item baground_color_1";
            });

        if(this.checkUncheck == event.currentTarget.dataset.value){
            this.checkUncheck = event.currentTarget.dataset.value;
        }
        else{
            this.checkUncheck = event.currentTarget.dataset.value;
        }
            this.otherThanDiscountList.forEach(ele => {
                 if(ele.quoteEarliestAppointmentAvailability == this.checkUncheck && this.checkUncheck && earlyFinish == ele.quotelocation){ 
                    ele.earlyCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item true baground_color";
                   }else{
                    ele.earlyCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item baground_color_1";
                   }
               });
            }

            if(slotAvailability == "WeatherGuard"){
                this.weatherAppoitmentMainDate = earlyAppoinment;
                this.otherThanDiscountList.forEach(ele => {
                     ele.earlyCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item baground_color_1";
                });
                if(this.checkUncheck == event.currentTarget.dataset.value){
                    this.checkUncheck = event.currentTarget.dataset.value;
                }
                else{
                    this.checkUncheck = event.currentTarget.dataset.value;
                }
                   this.otherThanDiscountList.forEach(ele => {
                           if(ele.quoteWeatherGuard == this.checkUncheck && this.checkUncheck){ 
                            ele.weatherCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item true baground_color";
                           }else{
                            ele.weatherCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item baground_color_1";
                           }
                       });
                    }
       
        this.dateUpdate();
      //  this.confirmButton();
    }
   
    }

    dateUpdate(){

        if(this.checkSelectSlot == true){
            return;
        }

        // trial method start
        let dateStringa = this.today;
        dateStringa = dateStringa.replace('th', '');
        let startDate = new Date(dateStringa); 
       // this.tenDates = [];
        let currentData = new Date(startDate);
       
        this.tenDates.push(new Date(currentData));
        for(let i=0; i<=8; i++){
           currentData.setDate(currentData.getDate()+1);
           this.tenDates.push(new Date(currentData));
       }
        console.log('Incremented Date',JSON.stringify(this.tenDates));
    //let date2a = new Intl.DateTimeFormat( 'en-US' ).format( date );
    // let datePartsAa = date2.split("/");
   //  let newFormatAa = datePartsA[1] + "/" + datePartsA[0];
 
   for(let i=0; i<=2; i++){
    //  this.dateMap.push({
    //     dateValue : this.date1,
    //     dateTranfer : date1
    //  });      
}
     //  console.log('datePagination',this.tenDates.slice(this.startIndex, this.endIndex + 1) );
       // trial method end

    this.dateMap = [];
        let dateString = this.today;
        let date;
       if(dateString.includes("th")){
        dateString = dateString.replace('th', '');
        date = new Date(dateString);
       }
       if(dateString.includes("st")){
        dateString = dateString.replace('st', '');
        date = new Date(dateString);
       }
       if(dateString.includes("nd")){
        dateString = dateString.replace('nd', '');
        date = new Date(dateString);
       }
       if(dateString.includes("rd")){
        dateString = dateString.replace('rd', '');
        date = new Date(dateString);
       }
         this.dateString = date;
            this.leftArrowDisabled = true;
      let dateA =   date; 
     let date1 = new Intl.DateTimeFormat( 'en-US' ).format( date );
     let dateParts = date1.split("/");
     let newFormat = dateParts[1] + "/" + dateParts[0];
     this.date1 = newFormat;
     let datea = new Date(date1);
     console.log('datea++',datea);
     this.dateMap.push({
        dateValue : this.date1,
        dateTranfer : date1,
        dateCheck : datea
     })
  
     date.setDate(date.getDate()+1)
     let dateB =   date;
     let date2 = new Intl.DateTimeFormat( 'en-US' ).format( date );
     let datePartsA = date2.split("/");
     let newFormatA = datePartsA[1] + "/" + datePartsA[0];
     this.date2 = newFormatA;
     let dateb = new Date(date2);
     console.log('dateb++',dateb);
     this.dateMap.push({
        dateValue : this.date2,
        dateTranfer : date2,
        dateCheck : dateb
     })
    
     date.setDate(date.getDate()+1)
     let dateC =   date;
     let date3 = new Intl.DateTimeFormat( 'en-US' ).format( date );
     let datePartsB = date3.split("/");
     let newFormatB = datePartsB[1] + "/" + datePartsB[0];
     this.date3 = newFormatB;
     let datec = new Date(date3);
     console.log('datec++',datec);
     this.dateMap.push({
        dateValue : this.date3,
        dateTranfer : date3,
        dateCheck : datec
     })
    
     
     this.dateMap.forEach(ele => {
        ele.slotWeathercss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect  bagroundcolor_slotA";
        ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect  bagroundcolor_slotA";
     });
   
    //this.childataSend();
    }

   
    increaseDates(){
        this.date1 = '';
         this.date2 = '';
         this.date3 = '';
         this.dateMap = [];

   let newDate = this.dateString;
      this.leftArrowDisabled = false;
   let increateDate1 =  newDate.setDate(newDate.getDate()+1)
      console.log('New Date In Increase Date', JSON.stringify(new Date(newDate)));
      console.log('increateDate1', JSON.stringify(new Date(increateDate1)));
      let date1 = new Intl.DateTimeFormat( 'en-US' ).format( newDate );
      let dateParts = date1.split("/");
     let newFormat = dateParts[1] + "/" + dateParts[0];
     this.date1 = newFormat;
     let dated = new Date(date1);
     console.log('dated++',dated);
      this.firstDate = newDate;
      this.dateMap.push({
        dateValue : this.date1,
        dateTranfer : date1,
        dateIncrementCheck : newDate, 
        dateName : 'available',
        dateCheck : dated
     });
   
     let increateDate2 =  newDate.setDate(newDate.getDate()+1)
     console.log('increateDate2', JSON.stringify(new Date(increateDate2)));
      let date2 = new Intl.DateTimeFormat( 'en-US' ).format( newDate );
      let datePartsA = date2.split("/");
     let newFormatA = datePartsA[1] + "/" + datePartsA[0];
     this.date2 = newFormatA;
     let datee = new Date(date2);
     console.log('datee++',datee);
     this.dateMap.push({
        dateValue : this.date2,
        dateTranfer : date2,
        dateIncrementCheck : newDate, 
        dateName : 'available',
        dateCheck : datee
     });

     let increateDate3 =  newDate.setDate(newDate.getDate()+1)
     console.log('increateDate3' , JSON.stringify(new Date(increateDate3)));
      let date3 =new Intl.DateTimeFormat( 'en-US' ).format( newDate ); 
      let datePartsB = date3.split("/");
      let newFormatB = datePartsB[1] + "/" + datePartsB[0];
      this.date3 = newFormatB;
      let datef = new Date(date3);
     console.log('datef++',datef);
      this.dateMap.push({
        dateValue : this.date3,
        dateTranfer : date3,
        dateIncrementCheck : newDate, 
        dateName : 'available',
        dateCheck : datef
     });
     let dateflg = false;
     let dateCheckerArrey = [];
     this.tenDates.forEach(ele => {
        console.log('ElementDate', ele);
        let datetest =new Intl.DateTimeFormat( 'en-US' ).format( ele ); 
        datetest.split("/");
        dateCheckerArrey.push(datetest);
     });
     
    //  this.dateMap.forEach(ele => {
    //     dateCheckerArrey.forEach( element => {
    //       if(ele.dateTranfer != element){
    //            this.rightArrowDisabled = true;
    //       }
    //     })
    //  });
    let flagArrey = [];
    this.dateMap.forEach(ele => {
       if(dateCheckerArrey.includes(ele.dateTranfer)){
        flagArrey.push(false);
        
      }else{
        flagArrey.push(true);
        
      }
    });
    console.log('if else flag',JSON.stringify(flagArrey));

    this.rightArrowDisabled = flagArrey.includes(true);
     if(this.rightArrowDisabled == true){

        this.dateMap[1].dateValue = 'NA'
        this.dateMap[1].dateName = 'NA'
        this.dateMap[2].dateValue = 'NA'  
        this.dateMap[2].dateName = 'NA'
        this.dateMap.forEach(ele => {
            ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12  bagroundcolor_slotA";
               
        });
       
     }

    console.log('dateMap', JSON.stringify(this.dateMap));
    console.log('dateMapCheck', JSON.stringify(dateCheckerArrey));

      this.dateMap.forEach(ele => {
        ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect  bagroundcolor_slotA";
        ele.slotWeathercss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect  bagroundcolor_slotA";  
    });
    //this.childataSend();
  }

  decreaseDates(){
    this.arreyMap = [];
      this.date1 = '';
         this.date2 = '';
         this.date3 = '';
         this.dateMap = [];
         this.rightArrowDisabled = false;
     let newDatea = this.firstDate;

      newDatea.setDate(newDatea.getDate()-5)  
      let date1 = new Intl.DateTimeFormat( 'en-US' ).format( newDatea );
      let dateParts = date1.split("/");
      let newFormat = dateParts[1] + "/" + dateParts[0];
      this.date1 = newFormat;
      let dateg = new Date(date1);
      console.log('dateg++',dateg);
      this.dateMap.push({
        dateValue : this.date1,
        dateTranfer : date1,
        dateCheck : dateg
     });
      if(this.dateStringCheck == this.date1){
        this.leftArrowDisabled = true;
  }else{
     this.leftArrowDisabled = false;
  }
      newDatea.setDate(newDatea.getDate()+1)
      let date2 = new Intl.DateTimeFormat( 'en-US' ).format( newDatea );
      let datePartsA = date2.split("/");
      let newFormatA = datePartsA[1] + "/" + datePartsA[0];
      this.date2 = newFormatA;
      let dateh = new Date(date2);
      console.log('dateh++',dateh);
      this.dateMap.push({
        dateValue : this.date2,
        dateTranfer : date2,
        dateCheck : dateh
     });
       newDatea.setDate(newDatea.getDate()+1)
      let date3 = new Intl.DateTimeFormat( 'en-US' ).format( newDatea );
      let datePartsB = date3.split("/");
      let newFormatB = datePartsB[1] + "/" + datePartsB[0];
      this.date3 = newFormatB;
      let datei = new Date(date3);
      console.log('datei++',datei);
      this.dateMap.push({
        dateValue : this.date3,
        dateTranfer : date3,
        dateCheck : datei
     });


      this.dateMap.forEach(ele => {
        ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect bagroundcolor_slotA";
        ele.slotWeathercss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect  bagroundcolor_slotA";   
    });
    //this.childataSend();
  }

  selectSlot(event){
    
    this.showSpinner = true;
    let isSelectSlot = true;
    let slotDateCheck = event.currentTarget.dataset.datecheck;
   console.log('slotDateCheck',slotDateCheck);
    

   let date = new Date(slotDateCheck);
  let originalDateV = new Date(date.getTime() - (date.getTimezoneOffset() * 60000 )).toISOString();
   
    
   let originalDate = new Date(slotDateCheck);
  console.log('--originalDate-->',originalDate);

        const year = originalDate.getFullYear();
       const month = ('0' + (originalDate.getMonth() + 1)).slice(-2); 
        const day = ('0' + originalDate.getDate()).slice(-2);
        
        this.slotDateCheck = `${year}-${month}-${day}`;

        console.log('SLOT Date Check-->',this.slotDateCheck);

   /*  if( this.earlyAppoitmentNullCheck == ''){
        return;
    } */
    updateDate({
        appointmentId : this.serviceAppId,
        arrivalStartAndEndDate : originalDateV
    })
    .then(  (result)=>{
      console.log('updateAppointmentDate',result);
    })
    .catch((error) => {
        console.log('updateAppointmentDateError',error);
    })
    
    if(event.currentTarget.dataset.click == 'NA'){
          return;
    }
    this.arreyMap = [];
    this.testList1 = [];
    this.testList2 = [];
    this.testList3 = [];
    this.testList4 = [];
    this.testList5 = [];
    console.log('date transfer', event.currentTarget.dataset.transfer);
    console.log('date value', event.currentTarget.dataset.value);
   
   // this.checkSelectSlot = true;
    this.earlyAppoitment = '';
    this.weatherAppoitment = '';
    
    
    let dateValue = event.currentTarget.dataset.transfer;
      let slotAvailability =  event.currentTarget.dataset.name;
  
      if(slotAvailability == "EarliestAppoitmentA"){
        this.earlyAppoitment = dateValue;
    }
    if(slotAvailability == "WeatherGuardA"){
        this.weatherAppoitment = dateValue;
    }
    console.log('Slots in SelectSlots', JSON.stringify(this.slots));

    this.slot(this.slots , isSelectSlot);

    //   this.otherThanDiscountList.forEach(ele => {
    //     if(dateValue != ''){
    //         ele.showSlots = true;
           
    //     }else{
    //         ele.showSlots = false;
    //     }
        
    // })

  
   
    this.arreyMap.forEach(element => {
        element.List.forEach(ele => {
            if(ele.booked == 'true'){
              ele.boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item boxgrey"
            ele.locStyle= "background:grey"
            }else{
            ele.boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item"
            ele.locStyle= "background:white"
            }
        });
 }); 
     
 if(slotAvailability == "EarliestAppoitmentA"){
 if(this.checkUncheckDateSlot == event.currentTarget.dataset.value){
    this.checkUncheckDateSlot = event.currentTarget.dataset.value;
}
else{
    this.checkUncheckDateSlot = event.currentTarget.dataset.value;
}
     this.dateMap.forEach(ele => {
          if(ele.dateValue == this.checkUncheckDateSlot && this.checkUncheckDateSlot){ 
                   ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect true bagroundcolor_slotB";
           }else{
            ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect bagroundcolor_slotA";
           }
       });
    }

    if(slotAvailability == "WeatherGuardA"){
        if(this.checkUncheckDateSlot == event.currentTarget.dataset.value){
            this.checkUncheckDateSlot = event.currentTarget.dataset.value;
        }
        else{
            this.checkUncheckDateSlot = event.currentTarget.dataset.value;
        }
             this.dateMap.forEach(ele => {
                  if(ele.dateValue == this.checkUncheckDateSlot && this.checkUncheckDateSlot){ 
                                     ele.slotWeathercss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect true bagroundcolor_slotB";
                   }else{
                    ele.slotWeathercss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect bagroundcolor_slotA";
                   }
               });
    }
//this.confirmButton()
//this.childataSend();
  
}
// method Use To close the calender
@api closeCalender(){
    this.weatherAppoitmentSlot = '';
    this.earlyAppoitmentSlot = '';
    this.otherThanDiscountList.forEach(ele => {
        ele.dateSlotShow = false; 
        ele.showSlots = false;     
    });

    this.otherThanDiscountList.forEach(ele => {
        ele.weatherDateShow = false;
        ele.showSlots = false;  
    });

    this.arreyMap.forEach(element => {
        element.List.forEach(ele => {
                ele.checked = false;
                ele.boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester boxstyle";
       
        });
 });
 //this.childataSend();
}

/////logic for back button data handle

receiveQuotData(){
     let quoteEarliestAppointmentAvailability;
        let wetherAppoitmentDate;
        console.log('ValueFromParents backArray',  JSON.stringify(this.backArray));
        console.log('B==otherThanDiscountFinal-->687', JSON.stringify(this.otherThanDiscountList));
     console.log('B==backArrayFinal-->687', JSON.stringify(this.backArray)); 
     console.log('B==dateMap-->687', JSON.stringify(this.dateMap));

    window.setTimeout(() => {
        quoteEarliestAppointmentAvailability;
        wetherAppoitmentDate;
    this.otherThanDiscountList.forEach(ele => {
        this.backArray.forEach(element => {
            if(ele.quoteVAT == element.vat){
                this.vat = element.vat;
        }

        if(ele.quoteTotal == element.total){
            this.total = element.total;
    }
        if(ele.quotelocation == element.location){
            ele.quotelocation = element.location;
            this.location = element.location;
            ele.loccss = "slds-box slds-text-heading_large slds-m-around_small slds-col slds-align_absolute-center slds-size_11-of-12 slds-listbox__item locationCSS true";
        }

        if(ele.quoteEarliestAppointmentAvailability == element.earlyAppoitmentMainDate && (ele.quoteEarliestAppointmentAvailability != '' || element.earlyAppoitmentMainDate != '' ) && ele.quotelocation == element.location){
            ele.quoteEarliestAppointmentAvailability = element.earlyAppoitmentMainDate;
           this.earlyAppoitmentMainDate =  element.earlyAppoitmentMainDate;
            ele.earlyCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item true baground_color";
            ele.dateSlotShow = true;
            quoteEarliestAppointmentAvailability = element.earlyAppoitmentMainDate;
            this.earlyAppoitmentSlot = element.earlyAppoitmentSlot;
            this.earlyAppoitment = element.earlyAppoitment;
            
        }

        if(ele.quoteWeatherGuard == element.weatherAppoitmentMainDate && (ele.quoteWeatherGuard != '' || element.weatherAppoitmentMainDate != '')){
            ele.quoteWeatherGuard = element.weatherAppoitmentMainDate;
            this.weatherAppoitmentMainDate = element.weatherAppoitmentMainDate;
            ele.weatherCss = "slds-box slds-col slds-align_absolute-center slds-size_1-of-3 slds-listbox__item true baground_color";
            ele.weatherDateShow = true;
            this.weathersTrue = true;
            this.weatherAppoitment = element.weatherAppoitment;
            this.weatherAppoitmentSlot = element.weatherAppoitmentSlot;
            wetherAppoitmentDate = element.weatherAppoitmentMainDate;
        }


        });
    });

   if(quoteEarliestAppointmentAvailability != '' && quoteEarliestAppointmentAvailability != undefined){
    this.today =  quoteEarliestAppointmentAvailability;
}

      if(wetherAppoitmentDate != '' && wetherAppoitmentDate != undefined){
            this.today =  wetherAppoitmentDate;
     }

     let dateString = this.today;
    dateString = dateString.replace('th', '');
     let date = new Date(dateString);

     let date1 = new Intl.DateTimeFormat( 'en-US' ).format( date );
     let dateParts = date1.split("/");
     let newFormat = dateParts[1] + "/" + dateParts[0];
     this.dateStringCheck = newFormat;

     this.dateUpdate();


     /* f(quoteEarliestAppointmentAvailability != '' && quoteEarliestAppointmentAvailability != undefined){
        this.today =  quoteEarliestAppointmentAvailability;
        
    }
    if(wetherAppoitmentDate != '' && wetherAppoitmentDate != undefined){
        this.today =  wetherAppoitmentDate;
       
    } */

    this.dateMap = JSON.parse(JSON.stringify(this.maindatemap));
  
   console.log('LocationTimeSlot MainDateMap', JSON.stringify(this.dateMap));  
     
   
  

    this.otherThanDiscountList.forEach(ele => {
       this.childslotmap.forEach(element => {
        element.List.forEach(element2 => {
            if(element2.checked == true){
                this.arreyMap = JSON.parse(JSON.stringify(this.childslotmap));
                ele.showSlots = true;
           }
    })
   })
 }); 
},1000);

}

handleCheck(event){
        let weatherAppoitmentSlot;
        let earlyAppoitmentSlot;
        let trueclasList = event.currentTarget.classList.contains('true');
        console.log('trueclasList', trueclasList);
        this.otherThanDiscountList.forEach(ele => {
            ele.showSlots = true;
        });
  //  if(event.currentTarget.dataset.valcheck == 'true'){
     // this.earlyAppoitmentSlot = '';
      //  this.weatherAppoitmentSlot = '';
        //return;
   // }

    
//     if(this.location == this.CheckLocation){
//         return;
//    }
    
    this.otherThanDiscountList.forEach(element => {
        if( element.dateSlotShow == true){
            this.earlyAppoitmentSlot =  event.currentTarget.dataset.id;
        }
        if(element.weatherDateShow == true){
            this.weatherAppoitmentSlot =  event.currentTarget.dataset.id;
        }
     });
     if(trueclasList == true){
        this.earlyAppoitmentSlot = '';
        //  this.weatherAppoitmentSlot = '';
          //return;
      }
    console.log('earlyAppoitmentSlot',this.earlyAppoitmentSlot);
    
  if(this.checkUncheck == event.currentTarget.dataset.id){
         this.checkUncheck = '';
     }
     else{
         this.checkUncheck = event.currentTarget.dataset.id;
     }

    this.arreyMap.forEach(element => {
       
          element.List.forEach(ele => {
                if(ele.value == this.checkUncheck && this.checkUncheck && ele.booked != true){
                    ele.checked = true;
                    ele.boxcss = "slds-box slds-theme_shade slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item true";
                    
                }else{
                    ele.checked = false;
                    ele.boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item";
             }
          });
     }); 

     if(event.currentTarget.dataset.valcheck != "false"){
      // this.earlyAppoitmentSlot = '';
        this.weatherAppoitmentSlot ='';
     }


   if(this.location != '' && (this.earlyAppoitmentMainDate != undefined || this.weatherAppoitmentMainDate != undefined)
	&&(this.earlyAppoitment != undefined || this.weatherAppoitment != undefined) && ( this.earlyAppoitmentSlot != undefined || this.weatherAppoitmentSlot != undefined)){
    this.confirmButton();
   }
 
   //Parameter send to FS Apex class Story No 5400
   this.startSlotTime = event.currentTarget.dataset.starttime;
   this.endSlotTime = event.currentTarget.dataset.endtime;
   this.serviceAppId;

   console.log('startTime', startTime);
   console.log('endTime', endTime);
   console.log('serviceAppId', this.serviceAppId);
     // this.childataSend();
}

// Data Send From bln_LocationDateTimeSlot To bln_ProductSelectionAndAvailability
@api childataSend(){
    if(this.weatherAppoitment != "" && this.weatherAppoitment != undefined){
     
   const selectedEventOne = new CustomEvent('send',{
          detail : {
             location : this.location,
            // earlyAppoitment : this.earlyAppoitment,
             weatherAppoitment : this.weatherAppoitment,
             vat : this.vat,
             total : this.total,
            // earlyAppoitmentSlot : this.earlyAppoitmentSlot,
            weatherAppoitmentSlot : this.weatherAppoitmentSlot,
           // earlyAppoitmentMainDate : this.earlyAppoitmentMainDate,
            weatherAppoitmentMainDate : this.weatherAppoitmentMainDate,
            maindateList : this.dateMap,
            arrayMapChild1 : this.arreyMap,
           
           
          }
     })
     this.dispatchEvent(selectedEventOne);
 } else{
     if(this.earlyAppoitment != "" && this.earlyAppoitment != undefined){
         const selectedEventOne = new CustomEvent('send',{
             detail : {
                location : this.location,
                earlyAppoitment : this.earlyAppoitment,
                //weatherAppoitment : this.weatherAppoitment,
                vat : this.vat,
                total : this.total,
                earlyAppoitmentSlot : this.earlyAppoitmentSlot,
              // weatherAppoitmentSlot : this.weatherAppoitmentSlot,
               earlyAppoitmentMainDate : this.earlyAppoitmentMainDate,
              // weatherAppoitmentMainDate : this.weatherAppoitmentMainDate,
               maindateList : this.dateMap,
               arrayMapChild1 : this.arreyMap,
               slotDataToParent : this.slots,
               slotstarttime : this.startSlotTime,
               slotendtime : this.endSlotTime,
               saId :  this.serviceAppId
             }
        })
        this.dispatchEvent(selectedEventOne);
     }
 }
 }

/* @api slotBooking(){
           if(this.saidparent != '' && this.slotendparent != '' && this.slotstartparent != ''){
            this.startSlotTime = this.slotstartparent,
            this.endSlotTime = this.slotendparent,
            this.serviceAppId = this.saidparent
           }

    slotBooked({
        slotStart : this.startSlotTime,
        slotFinish : this.endSlotTime,
        appointmentId : this.serviceAppId
    })
    .then( (result)=> {
        console.log('SlotBooking',result);
    })
    .catch((error)=>{
        console.log('SlotBookingError',JSON.stringify(error));
    });
 }*/

}