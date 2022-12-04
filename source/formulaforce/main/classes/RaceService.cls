public with sharing class RaceService {

    public static String driverCheckin(Id raceId, Id driverId) {
		return null;
		/**
		// Build request for Driver Checkin Salesforce Function 
		DriverCheckinRequest request = new DriverCheckinRequest();
		request.raceId = raceId;
		request.driverId = driverId;
		// Sync invoke the Function (blocking invoke, subject to 2 min Apex timeout)
		functions.Function driverCheckinFunction = 
			functions.Function.get('formulaforce.drivercheckin');
		functions.FunctionInvocation invocation = 
			driverCheckinFunction.invoke(JSON.serialize(request));
		// Convert failed invocations into catchable exceptions
		if (invocation.getStatus() == functions.FunctionInvocationStatus.ERROR) {
			functions.FunctionInvocationError resultError = invocation.getError();
			if (resultError != null) {
				throw new DriverCheckinException(resultError.getMessage() + ' [' + resultError.getType() + ']');
			} else {
				throw new DriverCheckinException('Unknown');
			}
		}				
		// Deserialize the response
		DriverCheckinResponse response = 
			(DriverCheckinResponse) JSON.deserialize(invocation.getResponse(), DriverCheckinResponse.class);
		return response.qrCodeBase64;
		 */
	}

	public static String driverCheckIn(Id raceId, Id driverId, DriverCheckinCompleteCallaback callback) {
		return null;
		/**
		// Build request for Driver Checkin Salesforce Function 
		DriverCheckinRequest request = new DriverCheckinRequest();
		request.raceId = raceId;
		request.driverId = driverId;
		// aSync invoke the Function (non-blocking invoke, unlimited async invokes)
		functions.Function driverCheckinFunction = 
			functions.Function.get('formulaforce.drivercheckin');
		functions.FunctionInvocation invocation = 
			driverCheckinFunction.invoke(JSON.serialize(request), callback);
		return invocation.getInvocationId();			
		 */
	}

	public virtual class DriverCheckinCompleteCallaback {}
	/**	
	public virtual class DriverCheckinCompleteCallaback implements functions.FunctionCallback {

		// Implement standard Function callback and convert into a more specialized form for the caller
		public void handleResponse(functions.FunctionInvocation result) {
			DriverCheckinException callbackException = null;
			String qrCodeBase64 = null;
			// Errors?
			if (result.getStatus() == functions.FunctionInvocationStatus.ERROR) {
				functions.FunctionInvocationError resultError = result.getError();
				if (resultError != null) {
					callbackException = new DriverCheckinException(resultError.getMessage() + ' [' + resultError.getType() + ']');
				} else {
					callbackException = new DriverCheckinException('Unknown');
				}
			} else { // Success
				DriverCheckinResponse response = 
					(DriverCheckinResponse) JSON.deserialize(result.getResponse(), DriverCheckinResponse.class);
				qrCodeBase64 = response.qrCodeBase64;
			}
			// Pass to Service caller logic
			handleResponse(callbackException, qrCodeBase64);
		} 

		public virtual void handleResponse(DriverCheckinException callbackException, String qrCodeBase64) {
		}
	} 

	public class DriverCheckinCompleteCallabckExample extends DriverCheckinCompleteCallaback {
		public override void handleResponse(DriverCheckinException callbackException, String qrCodeBase64) {
			if(callbackException!=null) {
				// Send User Notification, or Platform Event?
				// ... 
			} else  {
				// Store qrCodeBase64, or send Plaform Event to an LWC?
				// ...
			}
		}
	}
 	*/

	public static Map<Id, List<ProvisionalResult>> calculateProvisionResults(Set<Id> raceIds) {
		return service().calculateProvisionResults(raceIds);
	}

	public static void applyRaceResults(Map<Id, List<ProvisionalResult>> provisionalResultsByRaceId) {
		service().applyRaceResults(provisionalResultsByRaceId);
	}

	public static void awardChampionshipPoints(Set<Id> raceIds) {
		service().awardChampionshipPoints(raceIds);
	}

	private static IRaceService service() {
		return (IRaceService) Application.Service.newInstance(IRaceService.class);
	}

	public class RaceServiceException extends Exception {} 	

	public class ProvisionalResult {
		public Integer racePosition {get; set;}
		public Id contestantId {get; set;}
		public String contestantName {get; set;}		
	}

	// Inner classes used to invoke the Driver Checkin Function

	private class DriverCheckinRequest {
		public String raceId;
		public String driverId;
	}
	private class DriverCheckinResponse {
		public String qrCodeBase64;
	}
	public class DriverCheckinException extends Exception {}
}