public with sharing class MyAppController {

    public String getMessage()
    {
        String appName = 'Sales';

        // Get tab set describes for each app
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();

        // Iterate through each tab set describe for each app and display the info
        boolean selected = false;
        for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
            if (tsr.getLabel() == appName) {
                selected = tsr.isSelected();
                break;   
            }           
        }       

        // Selected?
        return selected ? 'Sales selected' : 'Sales not selected';
    }
}