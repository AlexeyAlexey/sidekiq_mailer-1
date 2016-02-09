# Sidekiq::Mailer


## Integration with [Redmine](https://github.com/redmine/redmine) 
      (Alexey Kondratenko https://github.com/AlexeyAlexey  IAlexeyKondratenko@gmail.com)

Adds to gem the ability convert args of methods to easy objects before write to queue and back after read from guegue but before send to method


### Example Redmine


    ActionDispatch::Callbacks.to_prepare do
      Mailer.send(:include, Sidekiq::Mailer)
      
      #before write to queue convert to easy objects
      class Sidekiq::Mailer::BeforeFilter::Mailer
        def issue_add(args)
          #args - array of method args 
          args.map{|a| a.is_a?(Array) ? (a.map(&:id))  : (a.id)}
        end

        def document_added(args)
          [args.first.id, User.current.id]
        end
      end
      #before send to method convert easy objects from queue to back 
      class Sidekiq::Mailer::AfterFilter::Mailer
        def issue_add(params)
          #sleep 1
          i = 0
          issue_ = nil
          issue_id, to_users, cc_users = *params
          while issue_.nil? and i < 10
            (sleep 0.3) if i > 0
            i += 1
            issue_ = Issue.find_by_id(issue_id)
          end

          to_users_ = to_users.map{|user_id| User.find_by_id(user_id)}
          cc_users_ = cc_users.map{|user_id| User.find_by_id(user_id)}
          params_ = []
          params_ << issue_
          params_ << to_users_
          params_ << cc_users_
          params_
        end

        def document_added(params)
          document_id, user_current_id = *params
          document = Document.find_by_id(document_id)
          User.current = User.find_by_id(user_current_id)

          params = []
          params << document
        end
      end

      
    end

    #You cane override method use_sidekiq_mailer?
    #this method turn on/off Sidekiq::Mailer 
    class Sidekiq::Mailer::UseSidekiqMailer
      def use_sidekiq_mailer?
        true #true/false  defaulte true
      end
    end





Sidekiq::Mailer adds to your ActionMailer classes the ability to send mails asynchronously.

## Usage

If you want to make a specific mailer to work asynchronously just include Sidekiq::Mailer module:

    class MyMailer < ActionMailer::Base
      include Sidekiq::Mailer

      def welcome(to)
        ...
      end
    end

Now every deliver you make with MyMailer will be asynchronous.

    # Queues the mail to be sent asynchronously by sidekiq
    MyMailer.welcome('your@email.com').deliver

The default queue used by Sidekiq::Mailer is 'mailer'. So, in order to send mails with sidekiq you need to start a worker using:

    sidekiq -q mailer

If you want to skip sidekiq you should use the 'deliver!' method:

    # Mail will skip sidekiq and will be sent synchronously
    MyMailer.welcome('your@email.com').deliver!

By default Sidekiq::Mailer will retry to send an email if it failed. But you can [override sidekiq options](https://github.com/andersondias/sidekiq_mailer/wiki/Overriding-sidekiq-options) in your mailer.

## Installation

Add this line to your application's Gemfile:

    gem 'sidekiq_mailer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq_mailer

## Testing

Delayed e-mails is an awesome thing in production environments, but for e-mail specs/tests in testing environments it can be a mess causing specs/tests to fail because the e-mail haven't been sent directly. Therefore you can configure what environments that should be excluded like so:

    # config/initializers/sidekiq_mailer.rb
    Sidekiq::Mailer.excluded_environments = [:test, :cucumber]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
