/*****************************************
ClassName : BLN_ConnectWithGPS
Description : FOUK-2164 This controller class is used to call 'vehicle-schematics' & 'vehicle-bill-of-materials' request GPS API &
                Passed the data back to 'BLN_DamageAssessmentFlow'.
CreatedDate: 15-12-2023
CreatedBy : PWC-India
****************************************/

@isTest
public class BLN_ConnectWithGPSMock implements HttpCalloutMock {
    /* @description:In Http respond we send the request and get the GPS dummy data for test Class */
    Public HTTPResponse respond(HTTPRequest request) {


           String jsonF=       ''+
        '{'+
        '    "vehicleDamage": {'+
        '        "transactionId": "33690830-133d-4fe6-bd05-c9eab7f40290",'+
        '        "status": "HOLE_SELECTION",'+
        '        "vehicleId": 10540'+
        '    },'+
        '    "schematics": ['+
        '        ['+
        '           {'+
        '                "vehicleHoleId": null,'+
        '                "vehicleHoleTypeCode": null,'+
        '                "display": null'+
        '            },            '+
        '            {'+
        '                "vehicleHoleId": 217,'+
        '                "vehicleHoleTypeCode": "VN",'+
        '                "display": "FRONT_LEFT"'+
        '            },'+
        '            {'+
        '                "vehicleHoleId": 218,'+
        '                "vehicleHoleTypeCode": "WS",'+
        '                "display": "FRONT"'+
        '            },'+
        '            {'+
        '                "vehicleHoleId": 218,'+
        '                "vehicleHoleTypeCode": "WS",'+
        '                "display": "FRONT"'+
        '            },'+
        '            {'+
        '                "vehicleHoleId": 218,'+
        '                "vehicleHoleTypeCode": "WS",'+
        '                "display": "FRONT"'+
        '            },'+
        '            {'+
        '                "vehicleHoleId": 217,'+
        '                "vehicleHoleTypeCode": "VN",'+
        '                "display": "FRONT_RIGHT"'+
        '            },'+
        '            {'+
        '                "vehicleHoleId": null,'+
        '                "vehicleHoleTypeCode": null,'+
        '                "display": null'+
        '            }'+
        '        ],'+
        '        ['+
        '            {'+
        '                "vehicleHoleId": null,'+
        '                "vehicleHoleTypeCode": null,'+
        '                "display": null'+
        '            },'+
        '            {'+
        '                "vehicleHoleId": 215,'+
        '                "vehicleHoleTypeCode": "DR",'+
        '                "display": "LEFT"'+
        '            },'+
        '            {'+
        '                "vehicleHoleId": 215,'+
        '                "vehicleHoleTypeCode": "DR",'+
        '                "display": "RIGHT"'+
        '            }'+
        '        ],'+
        '        ['+
        '            {'+
        '                "vehicleHoleId": 215,'+
        '                "vehicleHoleTypeCode": "DR",'+
        '                "display": "LEFT"'+
        '            },'+
        '            {'+
        '                "vehicleHoleId": 215,'+
        '                "vehicleHoleTypeCode": "DR",'+
        '                "display": "RIGHT"'+
        '            }'+
        '        ],'+
        '        ['+
        '            {'+
        '                "vehicleHoleId": 215,'+
        '                "vehicleHoleTypeCode": "DR",'+
        '                "display": "LEFT"'+
        '            },'+
        '            {'+
        '                "vehicleHoleId": 215,'+
        '                "vehicleHoleTypeCode": "DR",'+
        '                "display": "RIGHT"'+
        '            }'+
        '        ],'+
        '        ['+
        '            {'+
        '                "vehicleHoleId": 214,'+
        '                "vehicleHoleTypeCode": "BK",'+
        '                "display": "BACK"'+
        '            }'+
        '        ]'+
        '    ],'+
        '    "digitalReferenceName": "https://belrongps-schematics-images-stg.s3.eu-west-1.amazonaws.com/images/Hatchback-5-Door.svg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=ASIARBM3HLEUKWAFXX7I%2F20240709%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20240709T095535Z&X-Amz-Expires=86400&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEGEaCWV1LXdlc3QtMSJHMEUCIQCJ6b563JVR1JKXcPQVY8wX0hDchitqtEzoKoMOPjJZmQIgBeXIGtzHY9ZZohnTONXZtRF6ICwjluhnLbXzSV3%2B%2FHQqlwMIKhAAGgwwNzE3MjkzNzE0MzIiDLlpzmoVr0Dls6WtMSr0AqIY8VXg%2FhmGmSGZWeWr8LRB0u%2F%2FIAW8GAhekwwLlTo8erSBmOpJqygXA4BJpfAPwO4vi2H%2FKGvra5V4O2IpHUkPg01hSlRunHTEMVayJGfSxpBdlwZRcdTrBxdmOyt0IbIkBM4%2F%2FIZlTNbNL20nZDmpUvBBJfRCH6rlNks944TRoEjfIZSh%2BhB29LDXqtWBSiPqEv%2Ba2un3rvNIALEUI6efGIr7SXdHHUPAZRrV8gr8V3U%2FaLAtfOyMbovSO6IdciJdARJXxjFuiTgXafLfxdYYvN54XER15VGSnCkTK3w3q%2Bz%2FTER9Tth59f2q80eUr7%2BHFzyNn%2B7KTDSW5MTfxvHew7s%2BZoqNec0OcmgxVOJU89MnHnp25So3mRY5WnpLG%2BQnj1yxd%2FgG32YEp5n0l9g8ioT%2F43nXHxqgXQ78uI5LBSPaJUzTt2Z5SOb%2BNpJiar1r0p5SoA147iRB7ZcFoyHqJIkniN0Bdct6NVK1LwIBxKfSPzDd77O0BjqdAVnpVdv0b4VTM%2BOlBrlVyw8glo8IDNgRmgrknCNTVkQmI5zcZcYUxPkwmzQ8KDHdHtAVSrZeM3wDOwzVOSsu9H%2F7SEXW79S7MxUIMXCwy3lpuv0FC3Z1tYFXjq%2FA%2F%2BDnwTx9h%2FYEOz8H7VsNv8ZjcfMf0SLUuYk6VMCyApkxlYFKVcW%2Bd941jjHc0CQn6hfMWYMPycpD%2FkB7MYOlBpI%3D&X-Amz-Signature=7f0e2ef9ce079a64bbc5b8b87a35f4086ba26c20cd75a0d3ace71bec8913461e&X-Amz-SignedHeaders=host&x-id=GetObject"'+      
        '}';

        
        String jsonR=		'{'+
		'    "vehicleDamage": {'+
		'        "transactionId": "32999054-b9ec-4b04-856e-3d862983fcb7",'+
		'        "status": "RESULT",'+
		'        "vehicleId": 24652'+
		'    },'+
		'    "results": ['+
		'        {'+
		'            "bomId": 105507,'+
		'            "partNumber": "4011AGABIMV2P"'+
		'        }'+
		'    ]'+
		'}';
        String jsonQ=		'{'+
		'    "vehicleDamage": {'+
		'        "transactionId": "6ae8f5b3-bebe-479c-9721-a1f0d198c7b4",'+
		'        "status": "QUESTIONS",'+
		'        "vehicleId": 102,'+
		'        "vehicleHoleId": 4671'+
		'    },'+
		'    '+
		'    "results": ['+
		'        {'+
		'            "bomId": 18459,'+
		'            "partNumber": "DT04588GTNN"'+
		'        }'+
		'    ],  '+
		'    "question": {'+
		'        "questionTypeName": "product-feature",'+
		'        "feature": "Aftermarket2",'+
		'        "question": "Does the product have the feature Aftermarket2?"'+
		'    }'+
		'}';
        string encoded = EncodingUtil.urlEncode('5 Door Hatchback', 'UTF-8');
            if(request.getEndpoint() == 'callout:BLN_OktaAuthToken'){
            HttpResponse response = new HttpResponse();
            response.setBody('{"token_type":"Bearer","expires_in":3600,"access_token":"MockAccessToken","scope":"read"}');
            response.setStatusCode(200);
            return response;     
        }else if(request.getEndpoint().endsWith(encoded)){
            HttpResponse response = new HttpResponse();
            response.setBody(jsonF);
            response.setStatusCode(200);
            return response;
        }else if(request.getEndpoint().endsWith('4500')){
            HttpResponse response = new HttpResponse();
            response.setBody(jsonQ);
            response.setStatusCode(200);
            return response;
        }else if(request.getEndpoint().endsWith('true')){
            HttpResponse response = new HttpResponse();
            response.setBody(jsonQ);
            response.setStatusCode(200);
            return response;
        }else if(request.getEndpoint().endsWith('32008')){
            HttpResponse response = new HttpResponse();
            response.setBody(jsonQ);
            response.setStatusCode(200);
            return response;
        }else if(request.getEndpoint().endsWith('5600')){
            HttpResponse response = new HttpResponse();
            response.setBody(jsonR);
            response.setStatusCode(200);
            return response;
        }else if(request.getEndpoint().endsWith('false')){
            HttpResponse response = new HttpResponse();
            response.setBody(jsonR);
            response.setStatusCode(200);
            return response;
        }else{
            return null;
        }

}
}