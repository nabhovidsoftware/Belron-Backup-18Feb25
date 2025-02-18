/** @description :  Mock Data for lad_associatedProductsList component.
*   @Story :        FOUK-7848; FOUK-7866; FOUK-7867; FOUK-7868; FOUK-8518
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   26-06-2024
*/
const mockProductData = [
    {
        id: '01tIS000000J90jYAC',
        name: 'Windscreen',
        isEssential: true,
        sku: 'WISC1',
        code: 'W-001',
        isAvailable: true,
        avlStatus: 'Available',
        deliveryDate: '2024-06-13',
        description: 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Cupiditate, mollitia dolores inventore numquam eveniet optio, distinctio consectetur asperiores repellat laborum dicta laboriosam nostrum odio excepturi. Velit delectus illo exercitationem odit!',
        currencyIsoCode: 'INR',
        unitPrice: 120,
        quantitySuggested: 10,
        purchaseQuantityRule: {
            "increment": 10,
            "maximum": 1000,
            "minimum": 10
        },
    },
    {
        id: '000000000002',
        name: 'Windscreen 2',
        isEssential: false,
        sku: 'WISC2',
        code: 'W-002',
        isAvailable: false,
        avlStatus: 'Not Available',
        deliveryDate: '2024-06-21',
        description: 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Cupiditate, mollitia dolores inventore numquam eveniet optio, distinctio consectetur asperiores repellat laborum dicta laboriosam nostrum odio excepturi. Velit delectus illo exercitationem odit!',
        currencyIsoCode: 'GBP',
        unitPrice: 120,
        quantitySuggested: 5,
        purchaseQuantityRule: null,/* {
            "increment": 5,
            "maximum": 1000,
            "minimum": 5
        }, */
    },
];

export {
    mockProductData
};