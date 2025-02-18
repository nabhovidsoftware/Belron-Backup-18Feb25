import { LightningElement,track} from 'lwc';
import getWebStoreId from '@salesforce/apex/LAD_WishlistHandler.getWebStoreId';
import removeWishlistItems from '@salesforce/apex/LAD_WishlistHandler.removeWishlistItems'
import removeWishlist from '@salesforce/label/c.LAD_removeWishlistItem'
import Id from '@salesforce/user/Id';
import Toast from 'lightning/toast';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath'
export default class LAD_Wishlist extends NavigationMixin(LightningElement) {
    userId=Id;
    @track wishlistitems;
    basePath=basePath;
    connectedCallback(){
        console.log('userId'+this.userId);
        getWebStoreId()
                .then(result => {
                    this.invokeCallout(result);
                })
                .catch(error => {
                    console.error('Error in finding Wishlist Items:', error);
                })

       
    }      
    
    extractStoreUrl(url){
          
        let index = url.indexOf('/', 8);

        if (index !== -1) {
            index = url.indexOf('/', index + 1); 
            
            if (index !== -1) {
                return url.substring(0, index);
            }
        }
        
        return url;
    }

 invokeCallout(webStoreId){
        console.log(30);
        let url=this.extractStoreUrl(window.location.href)+'/webruntime/api/services/data/v61.0/commerce/webstores/'+webStoreId+'/wishlists?includeDisplayedList=true&pageSize=500&productFields=CurrencyIsoCode,Description,DisplayUrl,Family,Name,ProductCode,QuantityUnitOfMeasure,StockKeepingUnit&language=en-US&asGuest=false&htmlEncode=false';
        fetch(url)
            .then(response => {
                if (!response.ok) {
                throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
               
                 this.wishlistitems= this.extractProductDetails(data);
                 console.log(42,this.wishlistitems);
                 console.log(43,this.extractProductDetails(data));
            })
            .catch(error => {
                console.error('There was a problem with the fetch operation:', error);
            });
    }


    extractProductDetails(jsonData) {
        if (!jsonData || !jsonData.displayedList || !jsonData.displayedList.page || !jsonData.displayedList.page.items) {
          throw new Error('Invalid JSON structure');
        }
        const items = jsonData.displayedList.page.items;
        return items.map(item => {
        let isError=false;
        let error=item.error;
            let label="Go to Product"
            let isnavigationDisabled=false;
            let style='margin-top: 30px';
        if(error){
            isError=true;
            label="Item Unavailable";
            style='margin-top: 74px';
            isnavigationDisabled=true;
        }

          const  productSummary  = item.productSummary;
          if (productSummary) {
            const { name, sku,productId } = productSummary;

            const url = productSummary.thumbnailImage ?  productSummary.thumbnailImage.url : null;
            return {url, name, sku ,productId,isError,label,isnavigationDisabled,style};
          }
          return null; 
        }).filter(item => item !== null); 
      }
      

    handleClick(event){
        let prodid = event.target.dataset.productId;
        console.log(prodid);
        const pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: prodid, 
                objectApiName: 'Product2', 
                actionName:'view'
            }
        };
        this[NavigationMixin.GenerateUrl](pageReference)
            .then(url => {
                console.log('Generated URL:', url);

                // Redirect to the generated URL
                window.open(url, "_self");
            })
            .catch(error => {
                console.error('Error generating URL:', error);
            });
    };

    handleRemove(event){
        let prodid = event.target.dataset.productId;
        removeWishlistItems({ prodId: prodid, userId: this.userId})
                .then( result => {
                    window.location.reload();
                })
                .catch(error => {
                    console.error('Error in finding Wishlist Items:', error);
                })
                Toast.show({
                    label: 'Success',
                    message: removeWishlist,
                    variant: 'success',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
    }
}