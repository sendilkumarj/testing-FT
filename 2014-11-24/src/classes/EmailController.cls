/*  
 Created by:Shebin Mathew
 Last Modified by:Shebin Mathew
 Style: Force.com & Metro
 Description: This class is written to add/edit people to parent object - Plan or Decision
     
*/
Public with sharing class EmailController
{  

   
  
   Public String subject{get;set;} 
   Public String message{get;set;}
   Public String userName{get;set;}
   Public String userComany{get;set;}
   public String requestType{get;set;}
   Public String priority{get;set;}
   Public String domain{get;set;}
   Public String onPage{get;set;}
   Public String browser{get;set;}
   Public String operatingSys{get;set;}
   Public String viewPort{get;set;}
   Public String language{get;set;}
   Public String requestIp{get;set;}
   Public String userContext{get;set;}
   Public blob attachment{get;set;} 
   Public String attachmentName{get;set;}

   
   
   Public EmailController()
   {
   // Constructor initialize the fields used.
   Subject          =  '';
   requestType      = 'Ask a Question';
   priority         = 'Normal';
   message          = '';
   } 
   //Method called from VF to send email to support center
   public pagereference sendEmail()
   {   
        //Query the context user to get email,name and companyname,User company
        user currentUser  = [Select id,email,name,companyname from User where id =: Userinfo.getUserid()];
        //Query Organisation name to show inside email
        Organization Org = [Select  Name From Organization o limit 1];
        //Extra infor for User name,Email Address etc.
        String extraInfo  = '\n\nUser Name: '+ currentUser.name + '\nUser Email Address: '+   ((currentUser.email != null) ?currentUser.email:'') +  '\nUser Company: '+ ((currentUser.companyname!= null) ?currentUser.companyname:'')+  '\nRequest Type: '+requestType + '\nPriority: '+priority+  '\n\n'+'Organization : '+ ((Org.Name!= null) ?Org.Name:'') + '\n'+ userContext +'\nIP Address: '+   ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');   

        // Send email initialization  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'support@fingertip.fi'};  //
        mail.setToAddresses(toAddresses);
        mail.setSubject( subject +' ('+ domain +')' );
        //Body will be created from message from user and extraInfo  
        mail.setPlainTextBody( 'Message: '+message+ extraInfo  );
        // If attachement is there attach it
        if( attachment != null && attachmentName != null){
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attachmentName);
            efa.setBody(attachment);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});        
        }
        attachment = blob.valueOf('');
        //Finally send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return new pagereference('/apex/EmailThankYouForm');
   } 
   
}