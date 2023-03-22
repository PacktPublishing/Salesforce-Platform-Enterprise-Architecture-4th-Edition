/**
 * Simple Apex Action to expose the RaceService.driverCheckin method to Flow
 */
public with sharing class DriverCheckinAction {

    @InvocableMethod(label='Driver Checkin' description='Driver Checkin')
    public static List <Response> execute (List<Request> requestList) {
        // Call RaceService.driverCheckin
        Request request = requestList[0];
        String qrCodeBase64 = RaceService.driverCheckin(request.raceId, request.driverId);
        // Return QRCode base64 as dataURL
        Response response = new Response();
        response.qrCodeDataURL = 'data:image/png;base64,'+qrCodeBase64;
        return new List<Response> { response };
    }

    public class Request {
        @InvocableVariable
        public String driverId;
        @InvocableVariable
        public String raceId;
    }

    public class Response {
        @InvocableVariable
        public String qrCodeDataURL;
    }
}