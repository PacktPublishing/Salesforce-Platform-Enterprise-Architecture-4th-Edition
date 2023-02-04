/**
 * Applicaiton specific Domain base class, customise fflib_SObjectSelector and add common behaviour
 **/
public inherited sharing abstract class ApplicationSelector extends fflib_SObjectSelector {

    public ApplicationSelector() {
        this(false);
    }
    
    public ApplicationSelector(Boolean includeFieldSetFields) {
        // Application follows the pattern of least privileged execution, so user mode is defaulted on
        this(includeFieldSetFields, true);
    }
    
    public ApplicationSelector(Boolean includeFieldSetFields, Boolean userMode) {
        // Allow override of default user mode enforcement to run all queries as system mode (default for Apex) 
        // - this can also be overriden within the selector methods themselves via fflib_QueryFactory.setEnforceFLS
        super(includeFieldSetFields, fflib_SObjectSelector.DataAccess.USER_MODE);
        // Disable sorting of select fields in the resulting SOQL improvements performance
        unsortedSelectFields();
    }
}