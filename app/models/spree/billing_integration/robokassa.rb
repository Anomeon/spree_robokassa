module Spree
  class BillingIntegration::Robokassa < Spree::BillingIntegration
    preference :password1, :string
    preference :password2, :string
    preference :mrch_login, :string

    # attr_accessible :preferred_password1, :preferred_password2, :preferred_mrch_login

    def provider_class
      ActiveMerchant::Billing::Base.integration_mode = self.mode
      ActiveMerchant::Billing::Integrations::Robokassa
    end

    def source_required?
      false
    end

    def method_type
      "robokassa"
    end

    def test?
      options[:test_mode] == true
    end

    def mode
      self.test? ? :test : :production
    end

    def service_url
      self.provider_class.service_url
    end

    def self.current
      robokassa_payment_methods = self.find_all_by_type(self.to_s)
      available_payment_methods = (PaymentMethod.available(:front_end) + PaymentMethod.available(:both)).uniq
      robokassa_payment_methods.each do |robokassa_payment_method|
        @payment_method ||= available_payment_methods.detect { |x| x.id == robokassa_payment_method.id }
      end
      @payment_method
    end

    #def desc
    #  "<p>
    #    <label> #{I18n.t('robokassa.success_url')}: </label> http://[domain]/gateway/robokassa/success<br />
    #    <label> #{I18n.t('robokassa.result_url')}: </label> http://[domain]/gateway/robokassa/result<br />
    #    <label> #{I18n.t('robokassa.fail_url')}: </label> http://[domain]/gateway/robokassa/fail<br />
    #  </p>"
    #end

  end
end
