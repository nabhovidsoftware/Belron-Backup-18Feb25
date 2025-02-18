/** @description :  This file holds and exports mock data for preview mode of the experience site.
*   @Story :        FOUK-9051; FOUK-8454; FOUK-8231; FOUK-8232; FOUK-8230; FOUK-7684; FOUK-8367
*   @author:        (binayak.debnath@pwc.com (IN))
*   @CreatedDate:   22-05-2024
*/
const mockLocationData = {
    primarylocations: [
        {
            avlStatus: "Available for <b>delivery</b> or <b>collection</b>",
            deliveryDate: "2024-06-06",
            location: "Bardon",
            locId: "0000000000000",
            isDisabled: false,
            dateIsToday: false,
            stockCount: 10
        }
    ],
    secondarylocations: [
        {
            avlStatus: "Available",
            deliveryDate: "1970-01-01",
            location: "Belfast",
            locId: "0000000000000",
            isDisabled: false,
            dateIsToday: false,
            stockCount: 10
        },
        {
            avlStatus: "Available",
            deliveryDate: "1970-01-01",
            location: "Bristol",
            isDisabled: false,
            locId: "0000000000000",
            dateIsToday: true,
            stockCount: 10
        }
    ]
};

export {
    mockLocationData
};