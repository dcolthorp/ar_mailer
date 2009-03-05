require 'test/unit'
require 'action_mailer'
require 'action_mailer/ar_mailer'

##
# Pretend mailer

class Mailer < ActionMailer::ARMailer

  def mail
    @mail = Object.new
    def @mail.encoded() 'email' end
    def @mail.from() ['nobody@example.com'] end
    def @mail.destinations() %w[user1@example.com user2@example.com] end
    def @mail.[](header) nil end
  end

  def mail_with_return_path
    @mail = Object.new
    def @mail.encoded() 'email' end
    def @mail.from() ['nobody@example.com'] end
    def @mail.destinations() %w[user1@example.com user2@example.com] end
    def @mail.[](header) 
      {"return-path" => "return@path.com"}[header]
    end
  end

end

class TestARMailer < Test::Unit::TestCase

  def setup
    Mailer.email_class = Email

    Email.records.clear
    Mail.records.clear
  end

  def test_self_email_class_equals
    Mailer.email_class = Mail

    Mailer.deliver_mail

    assert_equal 2, Mail.records.length
  end

  def test_perform_delivery_activerecord
    Mailer.deliver_mail

    assert_equal 2, Email.records.length

    record = Email.records.first
    assert_equal 'email', record.mail
    assert_equal 'user1@example.com', record.to
    assert_equal 'nobody@example.com', record.from

    assert_equal 'user2@example.com', Email.records.last.to
  end

  def test_perform_delivery_activerecord_uses_return_path_if_present
    Mailer.deliver_mail_with_return_path

    assert_equal 2, Email.records.length

    record = Email.records.first
    assert_equal 'return@path.com', record.from
  end

end

