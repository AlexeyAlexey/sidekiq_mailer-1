require 'test_helper'

class Issue
  attr_accessor :id, :name, :project_id
end

class User
  attr_accessor :id, :name, :email
  
  def initialize(id, email = nil)
    @id = id
    @email = email
  end
end

## Redmine Integration test
class Object::RedmineApp
end

#before write to queue convert to easy objects
class Sidekiq::Mailer::BeforeFilter::RedmineMailer
  def issue_add(args)
    #issue_add(issue, to_users)
    args.map{|a| a.is_a?(Array) ? (a.map(&:id))  : (a.id)}
  end
end

 #before send to method convert to objects 
class Sidekiq::Mailer::AfterFilter::RedmineMailer
  #issue_add(issue, to_users)
  def issue_add(params)
    issue_id, to_user_ids = *params
    issue = Issue.new
    issue.id = issue_id
    
    to_users = to_user_ids.map do |user_id| 
      user = User.new
      user.id = user_id
      user.email = "foo_#{user_id}@example.com"
    end

    params_ = []
    params_ << issue
    params_ << to_users
    return params_
  end
end

class RedmineMailer < ActionMailer::Base
  include Sidekiq::Mailer

  default :from => "from@example.org", :subject => "Subject"

  def issue_add(issue, to_users)
    to = to_users.map(&:email).join(", ")
    mail(to: to) do |format|
      format.text { render :text => "Hello Mikel!" }
      format.html { render :text => "<h1>Hello Mikel!</h1>" }
    end
  end
  
  def issue_edit(issue, to_users)
    to = to_users.map(&:email).join(", ")
    mail(to: to) do |format|
      format.text { render :text => "Hello Mikel!" }
      format.html { render :text => "<h1>Hello Mikel!</h1>" }
    end
  end
end


class PreventSomeEmails
  def self.delivering_email(message)
    if message.to.include?("foo@example.com")
      message.perform_deliveries = false
    end
  end
end

ActionMailer::Base.register_interceptor(PreventSomeEmails)

class RedmineSidekiqMailerTest < Test::Unit::TestCase
  def setup
    Sidekiq::Mailer.excluded_environments = []
    ActionMailer::Base.deliveries.clear
    Sidekiq::Mailer::Worker.jobs.clear
  end

  def test_redmine_integration_use_filters_of_params_asynchronously
    issue = Issue.new
    issue.id = 1
    to_users = [User.new(1), User.new(2), User.new(3)]

    RedmineMailer.issue_add(issue, to_users).deliver

    job_args = Sidekiq::Mailer::Worker.jobs.first['args']
    expected_args = ['RedmineMailer', 'issue_add', [1, [1, 2, 3]] ]
    
    assert_equal expected_args, job_args
  end

  def test_redmine_integration_without_filters_of_params_asynchronously
    issue = Issue.new
    issue.id = 1
    to_users = [User.new(1, "foo_1@example.com"), User.new(2, "foo_2@example.com"), User.new(3, "foo_3@example.com")]
    
    RedmineMailer.issue_edit(issue, to_users).deliver

    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end


