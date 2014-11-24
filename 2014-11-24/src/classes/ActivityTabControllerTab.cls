public with sharing class ActivityTabControllerTab {
	 public boolean isdisplayCard {get;set;}
	 public boolean isdisplayList {get;set;}
	 
	 public ActivityTabControllerTab(){
	 	isdisplayCard=true;
	 	isdisplayList=false;
	 	
	 }
	 
	 public void isdisplayCardSet(){
	 	isdisplayCard=true;
	 	isdisplayList=false;
	 }
	 public void isdisplayListSet(){
	 	isdisplayCard=false;
	 	isdisplayList=true;
	 }
}