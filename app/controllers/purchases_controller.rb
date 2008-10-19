class PurchasesController < ApplicationController
  before_filter :login_required
  before_filter :find_or_initialize
  
  def new
    @purchase = Purchase.new(:quantity => params[:quantity], :ticket_type_id => params[:ticket_type_id])
  end
  
  def create
    @purchase.attributes = params[:purchase]
    @purchase.buyer = current_user
    if @purchase.save
      redirect_to @purchase.free? ?
         purchase_path(@purchase) :
         @purchase.paypal_url(purchase_url(@purchase))
    else
      render :action => 'new'
    end
  end
  
  def show
    if (request.referer =~ /^https:\/\/(www\.)?paypal/ || @purchase.free?) && !@purchase.paid?
      @purchase.paid!
    end
    if !@purchase.paid?
      redirect_to dashboard_path
    else
      respond_to do |format|
        format.html
        format.pdf do
          send_data PurchasePDF.render(@purchase), :disposition => 'inline', :filename => "admiteer_tickets.pdf", :type => "application/pdf"
        end
      end
    end
  end
  
  protected
  
    def find_or_initialize
      @purchase = params[:id] ? current_user.purchases.find(params[:id]) : current_user.purchases.build
    end
end
