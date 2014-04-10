module Spree
  class BillingIntegration::Robokassa < Spree::BillingIntegration
    preference :password1, :string
    preference :password2, :string
    preference :mrch_login, :string

    attr_accessible :preferred_password1, :preferred_password2, :preferred_mrch_login

    def provider_class
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

    def service_url
      self.mode
      ActiveMerchant::Billing::Integrations::Robokassa.service_url
      # self.test? ? "http://test.robokassa.ru/Index.aspx" : "https://merchant.roboxchange.com/Index.aspx"
    end

    def mode
      ActiveMerchant::Billing::Base.integration_mode = self.test? ? :test : :production
    end

    #def self.current
    #  self.where(:type => self.to_s, :environment => Rails.env, :active => true).first
    #end

    #def desc
    #  "<p>
    #    <label> #{I18n.t('robokassa.success_url')}: </label> http://[domain]/gateway/robokassa/success<br />
    #    <label> #{I18n.t('robokassa.result_url')}: </label> http://[domain]/gateway/robokassa/result<br />
    #    <label> #{I18n.t('robokassa.fail_url')}: </label> http://[domain]/gateway/robokassa/fail<br />
    #  </p>"
    #end

  end
end