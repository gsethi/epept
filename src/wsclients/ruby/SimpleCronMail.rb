require 'net/smtp'

class SimpleCronMail

	def self.sendErrorMessage(jobid) 
		#jobid = ARGV[0]

message = <<MESSAGE_END
From: EPEPT Notifier <epept_admins@systemsbiology.org>
To: <epept_admins@systemsbiology.org>
Subject: EPEPT might be down, cron job failed

The weekly EPEPT cron job did not complete.
The job id is #{jobid}

MESSAGE_END

		Net::SMTP.start('mailhost.systemsbiology.net') do |smtp|
  		smtp.send_message message, 'epept_admins@systemsbiology.org', 
                             'epept_admins@systemsbiology.org'
		end
	end

	def self.sendSuccessMessage(jobid)

message = <<MESSAGE_END
From: EPEPT Notifier <epept_admins@systemsbiology.org>
To: <epept_admins@systemsbiology.org>
Subject: EPEPT is good - weekly cron job passed

The weekly EPEPT cron service test is successful.
The completed job id is #{jobid}
MESSAGE_END

                Net::SMTP.start('mailhost.systemsbiology.net') do |smtp|
                smtp.send_message message, 'epept_admins@systemsbiology.org',
                             'epept_admins@systemsbiology.org'
                end
        end

end

#SimpleCronMail.sendErrorMessage("someid")
