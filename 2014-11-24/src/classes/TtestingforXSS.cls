public with sharing class TtestingforXSS {
	
	public String str {get; set;}
	
	public TtestingforXSS(){
		str = '<script>alert(1);</script>';
	}
}