require 'net/smtp'
require 'rubygems'
require 'json' # sudo gem install json

class EpeptSMTP

def initialize()
  @HOST = 'http://cornea.systemsbiology.net:9080'
  @metaJsonInput = ''
  @annotationsPermHash = Hash.new
  @annotationsWarningHash = Hash.new
  @xlsInFile = ''
  @xlsOutFile = ''
end

def send_email(status, from, from_alias, to, to_alias, subject, message)

   IO.foreach("./inputs/inputs.json"){ |dterm|
      #right now all the json inputs comes in one line
      @metaJsonInput = @metaJsonInput + dterm
   }   
   jsonObj = JSON.parse(@metaJsonInput)
   email = jsonObj["mail_address"]
   uri = jsonObj["uri-uuid"]
   if (status == "success") then
        message = "Hello,\n\nYour EPEPT job has finished processing, you can access the results at:\n\n http://informatics.systemsbiology.net/EPEPT/index.html?URI=" + uri + "\n\n This job's results and logs will stay in our system for 30 days; if you need a different arrangement, please check with us. \n\nFeel free to contact us with any questions and comments.\n\nThanks,\nComputation - Shmulevich Lab@ISB"
   else
         if (email == nil || email.length < 1) then
              email = "codefor@systemsbiology.org"
         end 
         message = "Hello,\nThere was an error with your EPEPT job. You can access the error details at:\n\n http://informatics.systemsbiology.net/EPEPT/index.html?URI=" + uri + "\n\nPlease check the input parameters, data file(s) and logs and then try again.\nFeel free to contact us with any further questions and comments.\n\nThanks,\nComputation - Shmulevich Lab@ISB\n\nProgram inputs:" + @metaJsonInput 
   end

   if (email != nil && (email.length > 1)) then
   	to = email
   	to_alias = email.split("@")[0]
   	uri = uri[0, uri.rindex("/")]
   end

msg = <<END_OF_MESSAGE
From: #{from_alias} <#{from}>
To: #{to_alias} <#{to}>
Subject: #{subject}

#{message}
END_OF_MESSAGE

        Net::SMTP.start('mailhost.systemsbiology.net', 25) do |smtp|
                smtp.send_message msg, from, to
 		smtp.finish
        end
         rescue Exception => e:
         	msg = "EPEPT completed but there was an SMTP error, could be network or invalid email:" + e.to_s + "\n\nJob:" + uri + "\ninputs:" + @metaJsonInput
         	Net::SMTP.start('mailhost.systemsbiology.net', 25) do |innersmtp|
        		innersmtp.send_message msg, from, "jlin@systemsbiology.org"
        		innersmtp.finish
        	#print "exception on smtp:" + msg
			exit(0)
   end
end

end

epept = EpeptSMTP.new
epeptStatus = ARGV[0]
epept.send_email(epeptStatus, "jlin@systemsbiology.org", "Jake Lin", "jlin212@gmail.com", "jlin212" ,"EPEPT Notification", "Message")
