/**
 * Applicaiton specific Domain base class, customise fflib_SObjectSelector and add common behaviour
 **/
public inherited sharing abstract class ApplicationSelector extends fflib_SObjectSelector {

    public ApplicationSelector() {
        this(false);
    }
    
    public ApplicationSelector(Boolean includeFieldSetFields) {
        // Application follows the pattern of least privileged execution, so user mode is defaulted on
        this(includeFieldSetFields, fflib_SObjectSelector.DataAccess.USER_MODE );
    }
    
    public ApplicationSelector(Boolean includeFieldSetFields, fflib_SObjectSelector.DataAccess dataAccessMode ) {
        // Allow override of default user mode enforcement
        super(includeFieldSetFields, dataAccessMode);
        // Disable sorting of select fields in the resulting SOQL improvements performance
        unsortedSelectFields();
    }
}