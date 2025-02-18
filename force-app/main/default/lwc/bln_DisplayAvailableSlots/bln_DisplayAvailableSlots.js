import { LightningElement, track, api, wire } from 'lwc';
import NoSlotAvailable from '@salesforce/label/c.BLN_NoSlotAvailable';
import WaitingDropOff from '@salesforce/label/c.BLN_WaitingDropOff';
import Waiting from '@salesforce/label/c.BLN_Waiting';
import DropOff from '@salesforce/label/c.BLN_DropOff';
import SelectSlot from '@salesforce/label/c.BLN_SelectSlot';
import SlotColumns from '@salesforce/label/c.BLN_SlotColumns';
import updateDate from '@salesforce/apex/BLN_AppointmentCreateUpdate.updateAppointment';
import getBranchSlots from '@salesforce/apex/BLN_AppointmentCreateUpdate.getBranchSlots';
import getMobileSlots from '@salesforce/apex/BLN_AppointmentCreateUpdate.getMobileSlots';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from "lightning/confirm";
import getAfterHour from '@salesforce/apex/BLN_AfterHoursUtility.afterHourUtility';
import { getRecord,getFieldValue} from 'lightning/uiRecordApi';
import arrivalWindowStartTime from "@salesforce/schema/ServiceAppointment.ArrivalWindowStartTime";
import forceAppointment from "@salesforce/schema/ServiceAppointment.BLN_IsForcedAppointment__c";
import forceDropOff from'@salesforce/label/c.BLN_ForceAppointmentLabel'
const fields = [arrivalWindowStartTime, forceAppointment];
import LightningAlert from 'lightning/alert';
import checkPermission from '@salesforce/customPermission/BLN_ForceAppointment';

export default class Bln_DisplayAvailableSlots extends LightningElement {

  label = {
    NoSlotAvailable,
    WaitingDropOff,
    Waiting,
    DropOff,
    SelectSlot,
    SlotColumns,
    forceDropOff
  }
 

  @api saList; //added by vedita
  @api isCashJourney;
  @api jsonProductData; //added by vedita
  @api selectedSlotApp;
  @track slots;
  @track date1;
  @track date2;
  @track date3 = new Date();
  @track whiteStyle = "height:2rem;width:11.6rem; border:1px solid black;"; //background:white
  @track locStyle = "height:3rem;width:58.3rem; border:1px solid black;background:Darkgreen"; "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester";
  @track boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_4-of-12 tester slds-listbox__item";
  @track product = [];
  @track appSlots = [];
  @track checkUncheck;
  @track checkUncheckDateSlot;
  @track dateString;
  @track checkSelectSlot = false;
  @track selectSlotDate;
  @track finalSlot = [];
  @api openModal;
  @api appointmentId;
  @track slotArray = [];
  @api isMobileLocation;
  @track dateMap = [];
  @track arreyMap = [];
  @api currentPayload;
  @api selectedProductList;
  
  /*Re-booking Start*/
  @api isChangeProduct;
  @api oldSlotDetails;
  @api oldAppointmentId;
  @api isRebooking = false;
  isDateChange = false;
  rebookReasonValue = '';
  rebookSubReasonOptionValue = '';
  isRebookingRequestModel = false;
  datePart = '';
  timeRange = '';
  startTime = '';
  endTime = '';
  /*Re-booking END*/
  @api caseId;
  @api setProductDataList;
  @api productDataList=[];
  finalSlotMap = [];
  tenDates = [];
  testList1 = [];
  rightArrowDisabled = false;
  slotDateCheck;
  startSlotTime = '';
  endSlotTime = '';
  orderId = '';
  isDropOff = '';
  endDate;
  startDate;
  selectUnselectSlot;
  showSpinner = false;
  today;
  firstDate;
  currentError;
  leftArrowDisabled = false;
  dateStringCheck;
  dateValue;
  isInsurance = false;
  myDate;
  isShowModal = true;
  confirmDisabled = false;
  isDisable = true;
  @track subSection = false;
  @track showModal = false; // added by vedita
  showModalBk = true;
  timeOptions =[];
  EndtimeOptions=[];
  @track forceAppt = false;
  @track noslotcheck = false;
  noSlotBoolean = false;
  startSelectedTime;
  selectedOptionValue = 'Waiting';
  endSelectedTime;
  checkPermissionName = false;
  @api getQuotePayload = [];
  //FOUK-12389 Variable added
  @track showPopUp1 = false;
  
  @wire (getRecord, {
    recordId: "$appointmentId",
    fields: fields
  })
  SARecord;

  connectedCallback() {
    this.generateTimeSlots();
    this.isShowModal = this.openModal;
    //FOUK-12389 Making the showPopUp1 to true along with isShowModal
    this.showPopUp1 = this.isShowModal;
    const startingDate = this.selectedSlotApp.earlierAvailabilityPrepDateTime ;

    if(checkPermission){
      this.checkPermissionName = true;
      }

    if (startingDate != null) {
      this.today = startingDate;
    }
    //this.selectedOptionValue = 'Waiting';
    this.dateUpdate();
  }

  dateUpdate() {
    let dateStringa = this.today;
    dateStringa = dateStringa.replace('th', '');
    let startDate = new Date(dateStringa);
    let currentData = new Date(startDate);
    this.tenDates.push(new Date(currentData));
    for (let i = 0; i <= 8; i++) {
      currentData.setDate(currentData.getDate() + 1);
      this.tenDates.push(new Date(currentData));
    }

    this.dateMap = [];
    let dateString = this.today;
    let date = new Date(dateString);
    this.dateString = date;
    this.leftArrowDisabled = true;
    let dateA = date;
    let date1 = new Intl.DateTimeFormat('en-US').format(date);
    let dateParts = date1.split("/");
    let newFormat = dateParts[1] + "/" + dateParts[0];
    this.date1 = newFormat;
    this.dateStringCheck = newFormat;
    let datea = new Date(date1);
    this.dateMap.push({
      dateValue: this.date1,
      dateTranfer: date1,
      dateCheck: datea
    })

    date.setDate(date.getDate() + 1)
    let dateB = date;
    let date2 = new Intl.DateTimeFormat('en-US').format(date);
    let datePartsA = date2.split("/");
    let newFormatA = datePartsA[1] + "/" + datePartsA[0];
    this.date2 = newFormatA;
    let dateb = new Date(date2);
    this.dateMap.push({
      dateValue: this.date2,
      dateTranfer: date2,
      dateCheck: dateb
    })

    date.setDate(date.getDate() + 1)
    let dateC = date;
    let date3 = new Intl.DateTimeFormat('en-US').format(date);
    let datePartsB = date3.split("/");
    let newFormatB = datePartsB[1] + "/" + datePartsB[0];
    this.date3 = newFormatB;
    let datec = new Date(date3);
    this.dateMap.push({
      dateValue: this.date3,
      dateTranfer: date3,
      dateCheck: datec
    })

    this.dateMap.forEach(ele => {
      ele.slotWeathercss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect  bagroundcolor_slotA";
      ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect  bagroundcolor_slotA";
    });
  }
  increaseDates() {
    this.date1 = '';
    this.date2 = '';
    this.date3 = '';
    this.dateMap = [];

    let newDate = this.dateString;
    this.leftArrowDisabled = false;
    let increateDate1 = newDate.setDate(newDate.getDate() + 1)
    let date1 = new Intl.DateTimeFormat('en-US').format(newDate);
    let dateParts = date1.split("/");
    let newFormat = dateParts[1] + "/" + dateParts[0];
    this.date1 = newFormat;
    let dated = new Date(date1);
    this.firstDate = newDate;
    this.dateMap.push({
      dateValue: this.date1,
      dateTranfer: date1,
      dateIncrementCheck: newDate,
      dateName: 'available',
      dateCheck: dated
    });

    let increateDate2 = newDate.setDate(newDate.getDate() + 1)
    let date2 = new Intl.DateTimeFormat('en-US').format(newDate);
    let datePartsA = date2.split("/");
    let newFormatA = datePartsA[1] + "/" + datePartsA[0];
    this.date2 = newFormatA;
    let datee = new Date(date2);
    this.dateMap.push({
      dateValue: this.date2,
      dateTranfer: date2,
      dateIncrementCheck: newDate,
      dateName: 'available',
      dateCheck: datee
    });

    let increateDate3 = newDate.setDate(newDate.getDate() + 1);
    let date3 = new Intl.DateTimeFormat('en-US').format(newDate);
    let datePartsB = date3.split("/");
    let newFormatB = datePartsB[1] + "/" + datePartsB[0];
    this.date3 = newFormatB;
    let datef = new Date(date3);
    this.dateMap.push({
      dateValue: this.date3,
      dateTranfer: date3,
      dateIncrementCheck: newDate,
      dateName: 'available',
      dateCheck: datef
    });
    let dateflg = false;
    let dateCheckerArrey = [];
    this.tenDates.forEach(ele => {
      let datetest = new Intl.DateTimeFormat('en-US').format(ele);
      datetest.split("/");
      dateCheckerArrey.push(datetest);
    });
/*
    let flagArrey = [];
    this.dateMap.forEach(ele => {
      if (dateCheckerArrey.includes(ele.dateTranfer)) {
        flagArrey.push(false);

      } else {
        flagArrey.push(true);
      }
    });

    this.rightArrowDisabled = flagArrey.includes(true);
    if (this.rightArrowDisabled == true) {

      this.dateMap[1].dateValue = 'NA'
      this.dateMap[1].dateName = 'NA'
      this.dateMap[2].dateValue = 'NA'
      this.dateMap[2].dateName = 'NA'
      this.dateMap.forEach(ele => {
        ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12  bagroundcolor_slotA";

      });

    }*/
    this.dateMap.forEach(ele => {
      ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect  bagroundcolor_slotA";
      ele.slotWeathercss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect  bagroundcolor_slotA";
    });

  }
  decreaseDates() {
    this.arreyMap = [];
    this.date1 = '';
    this.date2 = '';
    this.date3 = '';
    this.dateMap = [];
    this.rightArrowDisabled = false;
    let newDatea = this.firstDate;

    newDatea.setDate(newDatea.getDate() - 5)
    let date1 = new Intl.DateTimeFormat('en-US').format(newDatea);
    let dateParts = date1.split("/");
    let newFormat = dateParts[1] + "/" + dateParts[0];
    this.date1 = newFormat;
    let dateg = new Date(date1);

    this.dateMap.push({
      dateValue: this.date1,
      dateTranfer: date1,
      dateCheck: dateg
    });
    if (this.dateStringCheck == this.date1) {
      this.leftArrowDisabled = true;
    } else {
      this.leftArrowDisabled = false;
    }
    newDatea.setDate(newDatea.getDate() + 1)
    let date2 = new Intl.DateTimeFormat('en-US').format(newDatea);
    let datePartsA = date2.split("/");
    let newFormatA = datePartsA[1] + "/" + datePartsA[0];
    this.date2 = newFormatA;
    let dateh = new Date(date2);

    this.dateMap.push({
      dateValue: this.date2,
      dateTranfer: date2,
      dateCheck: dateh
    });
    newDatea.setDate(newDatea.getDate() + 1)
    let date3 = new Intl.DateTimeFormat('en-US').format(newDatea);
    let datePartsB = date3.split("/");
    let newFormatB = datePartsB[1] + "/" + datePartsB[0];
    this.date3 = newFormatB;
    let datei = new Date(date3);

    this.dateMap.push({
      dateValue: this.date3,
      dateTranfer: date3,
      dateCheck: datei
    });


    this.dateMap.forEach(ele => {
      ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect bagroundcolor_slotA";
      ele.slotWeathercss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect  bagroundcolor_slotA";
    });
  }

  get options() {
    return [
      { label: Waiting, value: Waiting },
      { label: DropOff, value: DropOff }
    ];
  }

  handleSlotOptionChange(event) {
    this.selectedOptionValue = event.target.value;

  }

  /*This method will show Branch slots */
  showBranchSlots(dateSort, selectedDate) {
    this.arreyMap = [];
    let timslotArreystartTime = [];
    let timeslotArreyendTime = [];
    if (dateSort.length == 0 || dateSort == '') {
      this.showSpinner = false;
      this.noSlotBoolean = true;
    }

    if (dateSort.length > 0) {
      this.finalSlotMap = [];
      this.startDateParam = [];
      this.endDateParam = [];

      let dateParts;
      let dateendfilter;
      let datePartsa;
      let datestartfilter;
      let endTimeFilter;
      if (dateSort.length != 0) {
        this.showSpinner = false;
        dateSort.forEach(ele => {
          endTimeFilter = ele.endTime;

          dateParts = endTimeFilter.split('T');
          dateendfilter = dateParts[0];
          this.appSlots.push(ele);
        });
      }
    }
    if (this.appSlots.length > 0) {
      this.appSlots.forEach(element => {
        this.startDateParam.push(element.startTime);
        const timestampStart = element.startTime;
        const dateObject = new Date(timestampStart);
        const hours = dateObject.getUTCHours().toString().padStart(2, '0');
        const minutes = dateObject.getUTCMinutes().toString().padStart(2, '0');
        const timeString = `${hours}:${minutes}`;
        let formattedTime = timeString.replace(/\s?[AP]M$/i, '');

        timslotArreystartTime.push(formattedTime);
      });

      this.appSlots.forEach(element => {
        this.endDateParam.push(element.endTime);
        const timestampEnd = element.endTime;
        const dateObject = new Date(timestampEnd);
        const hours = dateObject.getUTCHours().toString().padStart(2, '0');
        const minutes = dateObject.getUTCMinutes().toString().padStart(2, '0');
        const timeString = `${hours}:${minutes}`;
        let formattedTime = timeString.replace(/\s?[AP]M$/i, '');

        timeslotArreyendTime.push(formattedTime);
      });

      for (let i = 0; i <= this.appSlots.length; i++) {
        let startTime = timslotArreystartTime[i];
        let endTime = timeslotArreyendTime[i];
        let startTimePara = this.startDateParam[i];
        let enddatePara = this.endDateParam[i];
        this.finalSlotMap.push({
          value: startTime + '-' + endTime,
          starttime: startTimePara,
          endtime: enddatePara
        });
      }
    }

    this.finalSlotMap = this.finalSlotMap.filter(item => item.value != undefined);
    this.finalSlotMap.splice(-1, 1);
    let newArray = [];

    let selectedStartDate = selectedDate.split('T');
    this.finalSlotMap.forEach(ele => {
      let startTime = ele.starttime.split('T');
      if (startTime[0] == selectedStartDate[0]) {
        newArray.push(ele);
      }

    })
    this.finalSlotMap = newArray;
    newArray = [];
    if (this.finalSlotMap.length == 0) {
      this.noSlotBoolean = true;
      //FOUK-7148
            if(this.noSlotBoolean == true && this.checkPermissionName == true){
            this.noslotcheck = true;
            this.showSpinner = false;
          }
    }

    if (this.finalSlotMap.length > 0) {
      this.noslotcheck = false;
      for (let i = 0; i < this.finalSlotMap.length;) {
        let testList1 = [];
        for (let j = 0; j < SlotColumns && i < this.finalSlotMap.length; j++) {
          testList1.push(this.finalSlotMap[i]);
          i++;
        }

        testList1 = testList1.filter(item => item != null);
        this.arreyMap.push({
          row: this.row,
          List: JSON.parse(JSON.stringify(testList1))

        });
        this.row++;

      }
      this.arreyMap.forEach(element => {
        element.List.forEach(ele => {
          ele.boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item";

        });
      });
    }

    dateSort = [];
    this.appSlots = [];
    return this.arreyMap;
  }

  /*This method will show Mobile slots */
  showMobileSlots(dateSort, selectedDate) {
    if (dateSort.length == 0 || dateSort == '') {
      this.showSpinner = false;
      this.noSlotBoolean = true;
    }

    if (dateSort.length > 0) {
      this.finalSlotMap = [];
      this.showSpinner = false;

      dateSort.forEach(ele => {
        this.finalSlotMap.push({
          value: ele.slotStart + '-' + ele.slotEnd,
          starttime: ele.slotDate,
          endtime: ele.slotDate
        });
      });
    }


    // this.finalSlotMap = this.finalSlotMap.filter(item => item.value != undefined);
    // this.finalSlotMap.splice(-1, 1);
    let newArray = [];

    let selectedStartDate = selectedDate.split('T');
    this.finalSlotMap.forEach(ele => {
      let slotStartDate = ele.starttime;
      if (slotStartDate == selectedStartDate[0]) {
        newArray.push(ele);
      }

    })
    this.finalSlotMap = newArray;
    newArray = [];
    if (this.finalSlotMap.length == 0) {
      this.noSlotBoolean = true;
      if(this.noSlotBoolean == true && this.checkPermissionName == true){
        this.noslotcheck = true;
        this.showSpinner = false;
      }
    }

    if (this.finalSlotMap.length > 0) {
      this.noslotcheck = false;
      for (let i = 0; i < this.finalSlotMap.length;) {
        let testList1 = [];
        for (let j = 0; j < SlotColumns && i < this.finalSlotMap.length; j++) {
          testList1.push(this.finalSlotMap[i]);
          i++;
        }
        testList1 = testList1.filter(item => item != null);
        this.arreyMap.push({
          row: this.row,
          List: JSON.parse(JSON.stringify(testList1))

        });
        this.row++;

      }
      this.arreyMap = this.arreyMap;
      this.arreyMap.forEach(element => {
        element.List.forEach(ele => {
          ele.boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item";

        });
      });
    }

    dateSort = [];
    this.appSlots = [];
    return this.arreyMap;
  }

  /*This method will show slots branch/mobile slots by clicking on date*/
  selectSlot(event) {
    this.showSpinner = true;
    this.arreyMap = [];
    this.noSlotBoolean = false;
    const slotDateCheck = event.currentTarget.dataset.datecheck;
    let date = new Date(slotDateCheck);

    this.selectSlotDate = new Date(date.getTime() - (date.getTimezoneOffset() * 60000)).toISOString();

    let newDateArray = [];
    updateDate({
      appointmentId: this.appointmentId,
      arrivalStartAndEndDate: this.selectSlotDate,
      isDropOff : this.selectedOptionValue == 'Drop Off' ? true : false
    })
      .then((result) => {
      if (this.isMobileLocation == false || this.isMobileLocation == undefined) {
      getBranchSlots({
        appointmentId: this.appointmentId
      })
        .then((slots) => {
          let dateSort = [];
          if (slots.isSuceess == false) {
            this.showSpinner = false;
            this.noSlotBoolean = true; 
            if(this.noSlotBoolean == true && this.checkPermissionName == true){
              this.noslotcheck = true;
              this.showSpinner = false;
            }
          }
          else{
            this.noSlotBoolean = false;
            if(this.selectedOptionValue == 'Waiting'){
              dateSort = slots.waitingSlots;
              this.isDropOff = false;
            } 
            else {
              dateSort = slots.dropOffSlots;
              this.isDropOff = true;
            }
            this.finalSlot = dateSort;
            newDateArray = this.showBranchSlots(this.finalSlot, this.selectSlotDate);
          }
        })
        .catch(error => {
          this.currentError = error;
        })
    }
    else {
      getMobileSlots({
        appointmentId: this.appointmentId
      })
        .then((slots) => {
          let slotReturnValue = slots[0].isSuceess;
          if (slots[0].msg == "Could not find relevant slots") {
            this.showSpinner = false;
            this.noSlotBoolean = true;
            
            if(this.noSlotBoolean == true && this.checkPermissionName == true){
              this.noslotcheck = true;
              this.showSpinner = false;
            }
          } 
          else {
            this.noSlotBoolean = false;
            this.finalSlot = slots;
            let mobileSlots = [];

            mobileSlots = this.showMobileSlots(this.finalSlot, this.selectSlotDate);
          }
        })
        .catch(error => {
          this.currentError = error;
        })
      }
    })
    .catch((error) => {
      this.currentError = error;
    })

    if (this.checkUncheckDateSlot == event.currentTarget.dataset.value) {
      this.checkUncheckDateSlot = event.currentTarget.dataset.value;
    }
    else {
      this.checkUncheckDateSlot = event.currentTarget.dataset.value;
    }
    this.dateMap.forEach(ele => {
      if (ele.dateValue == this.checkUncheckDateSlot && this.checkUncheckDateSlot) {
        ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect true bagroundcolor_slotB";
      } else {
        ele.slotcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 boxeffect bagroundcolor_slotA";
      }
    });
  }


  handleCheck(event) {
    if (this.checkUncheck == event.currentTarget.dataset.id) {
      this.checkUncheck = '';
    }
    else {
      this.checkUncheck = event.currentTarget.dataset.id;
    }

    this.arreyMap.forEach(element => {

      element.List.forEach(ele => {
        if (ele.value == this.checkUncheck && this.checkUncheck) {
          ele.checked = true;
          // ele.boxcss = "slds-box slds-theme_shade slds-col  slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item true";
          ele.boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item slds-align_absolute-center  tester boxstyle slds-listbox__item true";

        } else {
          ele.checked = false;
          // ele.boxcss = "slds-box slds-col  slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item";
          ele.boxcss = "slds-box slds-col slds-m-around_xxx-small slds-align_absolute-center slds-size_3-of-12 tester boxstyle slds-listbox__item slds-align_absolute-center  tester boxstyle slds-listbox__item";
       
        }
      });
    });

  }

  handleModalClose() {
    this.isShowModal = false; // Close the first modal
    this.showPopUp1 = false; //FOUK-12389 
    this.isDateChange = true; // Open the second modal
}

  hideModalBox() {
    this.isShowModal = false;
    this.showPopUp1 = false; //FOUK-12389 
  }


  /*This method will be called after clicking on slot value */
  handleSlot(event) {
    this.slotValue = event.target.dataset.id;
    this.startDate = event.target.dataset.startdate;
    this.endDate = event.target.dataset.enddate;
  }

  convertDate(actualDate) {
    const options = {
      year: "numeric",
      month: "long",
      day: "numeric",
    };
    let convertedDate = actualDate.toLocaleDateString("en-US", options);
    return convertedDate;
  }

  /*Re-book code */
  @wire(getRecord, {
    recordId: "$appointmentId", // newly created SA id 
    fields
  })

  handleRebookReason(event){
      if( event.detail ){
        this.rebookReasonValue = event.detail.rebookReasonValue;
        this.rebookSubReasonOptionValue = event.detail.rebookSubReasonOptionValue;
      }
     
     this.isDateChange = false;
      this.showPopUp1 = true; //FOUK-12389 once the 2nd pop up is closed we need to show 1st pop up again.
  }

  onCloseRebook(){
   this.isDateChange = false;
   this.showPopUp1 = true; //FOUK-12389
  }

  /*If slot value is present then slot data will be send to parent component */

  extractDateTime(dateTimeString){
    const dateTimeRegex = /^(.+?) (\d{1,2}:\d{2}-\d{1,2}:\d{2})$/;
    const match = dateTimeString.match(dateTimeRegex);

    if(match){
        this.datePart = match[1].trim();
        this.timeRange = match[2].trim();
    
    }
  }
  /*Re-book code END*/

  splitTimeRange(timeRange){
    const[start, end] = timeRange.split('-').map(time => time.trim());
    this.startTime = start;
    this.endTime = end;
  }

  /*If slot value is present then slot data will be send to parent component */
  handleConfirm(event) {
    let slotSelectedDate = this.convertDate(new Date(this.selectSlotDate));
    //FOUK-7148
    if(this.startSelectedTime!=null && this.startSelectedTime!=undefined && this.startSelectedTime!='' && this.endSelectedTime!= null && this.endSelectedTime!= undefined && this.endSelectedTime!= ''){
      this.slotValue = this.startSelectedTime+'-'+this.endSelectedTime;
      let startSlotDate= this.selectSlotDate.split('T');
      let newSlotDate= new Date(startSlotDate[0]+'T'+this.startSelectedTime+':00.000Z').toISOString();
      this.startDate= newSlotDate;
      let newEndSlotDate =new Date(startSlotDate[0]+'T'+this.endSelectedTime+':00.000Z').toISOString();
      this.endDate= newEndSlotDate;
      this.isDropoff = false;
     }

    /*Re-book code*/
    if((this.isRebooking == true && this.oldSlotDetails!='') || (this.isChangeProduct == true && this.rebookSubReasonOptionValue == '' && this.rebookReasonValue == '')){
      const dateTimeString = this.oldSlotDetails;
      this.extractDateTime(dateTimeString);
      let oldDate = new Date(this.datePart);
      let newDate = new Date(slotSelectedDate);
   
       //trial Code Start
      let timeRange1 = this.slotValue
      let timeRange2 = this.timeRange
       let[start1,end1] = timeRange1.split('-').map(time => {
           const [hours, minutes] = time.split(':');
           return parseInt(hours) * 60 + parseInt(minutes);
       });
   
       let[start2,end2] =  timeRange2.split('-').map(time => {
           const [hours, minutes] = time.split(':');
           return parseInt(hours) * 60 + parseInt(minutes);
       });
       //trial Code End
   
      //if(((oldDate != newDate || start1 != start2) && this.isRebooking == true && this.rebookSubReasonOptionValue == '' && this.rebookReasonValue == '')|| (this.oldAppointmentId != '' && this.rebookSubReasonOptionValue == '' && this.rebookReasonValue == '') || (this.isChangeProduct != '' && this.rebookSubReasonOptionValue == '' && this.rebookReasonValue == '')) { 
    if(this.selectedSlotApp.isExistingAppointment && this.rebookSubReasonOptionValue == '' && this.rebookReasonValue == '') {  
        this.isDateChange = true;
        this.isRebookingRequestModel = true;
        this.isShowModal = true;
      	this.showPopUp1 = false; //FOUK-12389 Disabling the first popup when 2nd popup is set to true
       }else{
         this.isDateChange = false;
         this.isRebookingRequestModel = false;
         this.isShowModal = false;
         this.showPopUp1 = false; //FOUK-12389 after confirm for 1st popup closing both popup.
       }
       
       getAfterHour({
        saList : JSON.stringify(this.appointmentId),
        jsonProductData : this.getQuotePayload,
        selectedProductJson : JSON.stringify(this.selectedProductList),
        isCashJourney: this.isCashJourney,
        caseId:this.caseId,
      slotdate:JSON.stringify(this.productDataList),

    })
    .then( result => {
          if (result != undefined && result != null && result != '' && result.netPriceIncludingTax > 0  && result.netPriceIncludingTax !=undefined){
            this.showModal = true;
          LightningAlert.open({
            message: 'After Hrs Charges will be applicable',
            theme: 'warning', // a red theme intended for error states
            label: 'warning!', // this is the header text
          });
        }else{
          this.showModal = false;
        }
    })
    .catch( err => {
        this.currentError = err;
      })
      .finally( () => {
          this.isLoading = false;
          this.showModal = false;
      });
    }
    
    /*Re-book code end*/ 
    if (this.slotValue != undefined && this.isDateChange == false) {
      this.isDisable = false;
      
      if(this.isMobileLocation == true){
        const[start, end] = this.slotValue.split('-').map(time => time.trim());
        let startTime = start;
        let endTime = end;

     if(this.startDate.includes('Z')){
          this.startDate = this.startDate.split('T');
          this.startDate = new Date(this.startDate[0]+'T'+startTime+':00.000Z').toISOString();
        }else{
           this.startDate = new Date(this.startDate+'T'+startTime+':00.000Z').toISOString();
        }

        if(this.endDate.includes('Z')){
          this.endDate = this.endDate.split('T');
          this.endDate = new Date(this.endDate[0]+'T'+endTime+':00.000Z').toISOString();
        }else{
          this.endDate = new Date(this.endDate+'T'+endTime+':00.000Z').toISOString();
        }
       // this.startDate = this.startDate.split('T');
       // this.startDate = new Date(this.startDate[0]+'T'+startTime+':00.000Z').toISOString();
       // this.endDate = this.endDate.split('T');
      //  this.endDate = new Date(this.endDate[0]+'T'+endTime+':00.000Z').toISOString();
      }
       
      
      const selectedDateEvent = new CustomEvent('selecteddata', {
        detail: {
          date: slotSelectedDate, slot: this.slotValue, isDropOff: this.isDropOff,
          startDate: this.startDate, endDate: this.endDate,rebookReasonValue : this.rebookReasonValue, 
          rebookSubReasonOptionValue : this.rebookSubReasonOptionValue, isForceAppointment: this.subSection
        }
      });
      this.dispatchEvent(selectedDateEvent);//this dispatch event will send slot details back to Schedule Appointment 
        getAfterHour({
          saList : JSON.stringify(this.appointmentId),
          jsonProductData : this.currentPayload,
          selectedProductJson : JSON.stringify(this.selectedProductList),
          isCashJourney: this.isCashJourney,
          caseId:this.caseId,
            slotdate:JSON.stringify(this.productDataList),
        })
        .then( result => {
          
            if (result != undefined && result != null && result != '' && result.netPriceIncludingTax > 0 && this.isCashJourney==true && result.netPriceIncludingTax !=undefined){
              this.showModal = true;
            LightningAlert.open({
              message: 'After Hrs Charges will be applicable',
              theme: 'warning', // a red theme intended for error states
              label: 'warning!', // this is the header text
            });
            }
            else{
            this.showModal = false;
          }
      })
      .catch( err => {
          this.currentError = err;
        })
        .finally( () => {
            this.isLoading = false;
            this.showModal = false;
        });
    }
  }
  
  closeModal() {
    //this.showModal = false;
    this.showModalBk = false;

  }

  markTrue(event){
    this.subSection = event.target.checked;
  }

  generateTimeSlots(){
    let times = [];
    let start = new Date();
    start.setHours(0,0,0,0);

    for(let num=0; num<48; num++){
      let hourCal = start.getHours();
      let texthourcal = hourCal.toString();
      let minutes = start.getMinutes();
      let textminutes = minutes.toString();
      let timeString = `${texthourcal.padStart(2,"0")}:${textminutes.padStart(2,"0")}`;
      times.push(timeString);
      start.setMinutes(start.getMinutes()+30);
    }
    this.timeOptions = times.map(time=>{
      return{label:time, value:time};
      
    });
  }
  handleStartTime(event){
    this.startSelectedTime =event.target.value
  }

  
  handleEndTime(event){
    this.endSelectedTime = event.target.value

  }
}