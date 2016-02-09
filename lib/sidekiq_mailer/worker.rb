class Sidekiq::Mailer::Worker
  include Sidekiq::Worker

  def perform(mailer_class, action, params)
    if defined?(RedmineApp)
      class_constant =  "Sidekiq::Mailer::AfterFilter::#{mailer_class}".constantize
      if class_constant.method_defined?(action.to_s)
        mailer_obj = class_constant.new
        params = mailer_obj.send(action, params)
        mailer_class.constantize.send(action, *params).deliver!
      end
    else
      mailer_class.constantize.send(action, *params).deliver!
    end
  end
end
