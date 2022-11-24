public with sharing class RaceService {

    public static String driverCheckin(Id raceId, Id driverId) {
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
	}

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