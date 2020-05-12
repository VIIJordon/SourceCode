class Api::ReportsController < ApiController
	def index
		reports = []
		if has_role :admin
			reports = [{
		    name: 'Customer Report', id: 'customer-report'
		  },{
		    name: 'Victorian Credit Report', id: 'victorian-credit-report'
		  },{
		    name: 'Ingredient Report', id: 'ingredient-report'
		  },{
		    name: 'Customer By Title', id: 'customer-title-report'
		  },{
		    name: 'Milams New Customers', id: 'milams-new-customers'
		  },{
		    name: 'Milams Order Report', id: 'milams-order-report'
		  },{
		    name: 'Customer Without Sponsor', id: 'customer-without-sponsor'
		  },{
		    name: 'Sales Report', id: 'sales-report'
		  },{
		    name: 'Order Transaction Victoria Report', id: 'order-transaction-victoria-report'
		  },{
		    name: 'CA Sales Report', id: 'california-sales-report'
		  },{
		    name: 'Non-Taxable Sales Report', id: 'non-taxable-sales-report'
		  },{
		    name: 'CA Resellers Sales Report', id: 'ca-resellers-report'
		  },{
		    name: 'Shipping Report', id: 'shipping-report'
		  },{
		    name: 'Void Report', id: 'void-report'
		  },{
		  	name: 'Void Payment Report', id: 'void-payment-report'
		  },{
		    name: 'Inventory Report', id: 'inventory-report'
		  },{
		    name: 'Milam COG Report', id: 'fda-report'
		  },{
		    name: 'FDA Report', id: 'faa-report'
		  },{
		    name: 'Sales Summary Report', id: 'sales-summary-report'
		  },{
		    name: 'Payment Report', id: 'payment-report'
		  },{
		    name: 'Order Transaction Report', id: 'order-transaction-report'
		  },{
		    name: 'No Shiping Option Report', id: 'no-ship-option-report'
		  },{
		    name: 'In Store Report', id: 'in-store-report'
		  },{
		    name: 'Customer Label Report', id: 'customer-label-report'
		  },{
		  	name: 'Customer Outreach Report', id: 'customer-outreach-report'
		  },{
			name: 'UK Order Transaction Report', id: 'uk-order-transaction-report'
		  },{
		    name: 'UK Payment Report', id: 'uk-payment-report'
		  },{
		    name: 'UK Inventory Report', id: 'uk-inventory-report'
		  },{
		    name: 'UK Customer Report', id: 'uk-customer-report'
		  }]
		  elsif has_role(:uk)
			reports = [{
		    name: 'UK Order Transaction Report', id: 'uk-order-transaction-report'
		  },{
		    name: 'UK Payment Report', id: 'uk-payment-report'
		  },{
		    name: 'UK Inventory Report', id: 'uk-inventory-report'
		  },{
		    name: 'UK Customer Report', id: 'uk-customer-report'
		  }]
		elsif has_role :portal 
			reports = [{
		    name: 'Customer Without Sponsor', id: 'customer-without-sponsor'
		  },{
		    name: 'Void Report', id: 'void-report'
		  },{
		    name: 'No Shiping Option Report', id: 'no-ship-option-report'
		  },{
		    name: 'Shipping Report', id: 'shipping-report'
		  },{
		    name: 'Payment Report', id: 'payment-report'
		  },{
		    name: 'Order Transaction Report', id: 'order-transaction-report'
		  },{
		    name: 'No Shiping Option Report', id: 'no-ship-option-report'
		  },{
		    name: 'In Store Report', id: 'in-store-report'
		  }]
		elsif has_role :accounting 
			reports = [{
		    name: 'Customer Without Sponsor', id: 'customer-without-sponsor'
		  },{
		    name: 'Shipping Report', id: 'shipping-report'
		  },{
		    name: 'Void Report', id: 'void-report'
		  },{
		    name: 'Payment Report', id: 'payment-report'
		  },{
		    name: 'Order Transaction Report', id: 'order-transaction-report'
		  },{
		    name: 'No Shiping Option Report', id: 'no-ship-option-report'
		  },{
		    name: 'In Store Report', id: 'in-store-report'
		  },{
		    name: 'CA Sales Report', id: 'california-sales-report'
		  },{
		    name: 'CA Resellers Sales Report', id: 'ca-resellers-report'
		  },{
		    name: 'Non-Taxable Sales Report', id: 'non-taxable-sales-report'
		  },{
		    name: 'Sales Report', id: 'sales-report'
		  },{
		  	name: 'Void Payment Report', id: 'void-payment-report'
		  }]
		end
    respond_to do |format|
      format.json do
       render json: reports
      end
    end

	end
end