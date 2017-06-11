# Preview all emails at http://localhost:3000/rails/mailers/mailer
class MailerPreview < ActionMailer::Preview
	def sample_mail_preview
    	Mailer.sample_email(User.first)
  	end
end
