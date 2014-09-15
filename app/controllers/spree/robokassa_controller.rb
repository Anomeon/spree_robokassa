module Spree
  class RobokassaController < Spree::StoreController

    before_filter :load_order

    skip_before_filter :verify_authenticity_token
    # ssl_required :result

    helper 'spree/orders'

    def result
      if @order && @order.completed?
        render :text => "Order already completed!" and return
      end
      @payment.amount = @notification.amount
      @payment.save
      if @notification.amount >= @order.total && @payment_method && @notification.acknowledge
        @order.next
        @payment.complete
        @order.update!
        render :text => @notification.success_response
      else
        @payment.pend
        render :text => "Invalid signature"
      end
    end

    def success
      if @order && @payment_method && @notification.acknowledge && @order.completed?
        session[:order_id] = nil
        redirect_to order_path(@order), :notice => I18n.t("payment_success")
      else
        flash[:error] = t("payment_success_fail")
        redirect_to @order.blank? ? root_url : checkout_state_path("payment")
      end
    end

    def fail
      if @order
        @payment.save
        @payment.void
        flash[:error] = t("payment_void")
        redirect_to @order.blank? ? root_url : cart_path
      end
    end

    private

    def load_order
      if params[:InvId]
        begin
          @order = Order.find params[:InvId]
        rescue ActiveRecord::RecordNotFound
          render :text => "Order not found"
        else
          find_robokassa_payment_method
          create_payment
          create_notification
          return @order
        end
      else
        render :text => "Incorrect request"
      end
    end

    def create_payment
      @payment = @order.payments.build
      @payment.payment_method_id = @payment_method.id
    end

    def find_robokassa_payment_method
      @payment_method = Spree::BillingIntegration::Robokassa.current
    end

    def create_notification
      @notification = @payment_method.provider_class::Notification.new(request.raw_post, :secret => @payment_method.preferred_password2)
    end

    def params
      params.require(Spree::BillingIntegration::Robokassa).permit(:preferred_password1, :preferred_password2, :preferred_mrch_login)
    end
  end
end
