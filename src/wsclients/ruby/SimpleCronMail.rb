require 'net/smtp'

class SimpleCronMail

	def self.sendErrorMessage(jobid) 
		#jobid = ARGV[0]

message = <<MESSAGE_END
From: EPEPT Notifier <jlin@systemsbiology.org>
To: <epept_admins@systemsbiology.org>
Subject: EPEPT might be down, cron job failed

The weekly EPEPT cron job for EPEPT did not complete.
The job id is #{jobid}
Please take a look at
romulus - 
1. ps -ef | grep robot
2. check workspaces - /proj/ilyalab/jlin/epept/workspace
athena -
1. jms
2. jcr
3. tomcat
Might need to bounce robot if all services are up as jms connection might be staled
MESSAGE_END

		Net::SMTP.start('mailhost.systemsbiology.net') do |smtp|
  		smtp.send_message message, 'epept_admins@systemsbiology.org', 
                             'epept_admins@systemsbiology.org'
		end
	end
end

#SimpleCronMail.sendErrorMessage("someid")
