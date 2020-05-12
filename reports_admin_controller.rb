class Admin::ReportsController < Admin::AdminController
	layout 'reports'


	def uk_order_transaction
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@orders = Order.includes([:uk_customer, :order_details, :order_type, :payment_details])
		.where("orders.void = ? AND orders.customer_id = ? AND accounting_date >= ? AND accounting_date < ?", false, 8675309, Time.zone.parse(@start_date).in_time_zone('UTC'), Time.zone.parse(@end_date).in_time_zone('UTC')).order('uk_customers.last_name ASC')
		@order_analytics = Order.includes([:uk_customer, :order_details, :order_type, :payment_details])
		.where("accounting_date >= ? AND accounting_date < ?", Time.zone.parse(@start_date).in_time_zone('UTC'), Time.zone.parse(@end_date).in_time_zone('UTC'))
		    respond_to do |format|
		      format.html # index.html.erb
		      format.json { render json: @order_analytics }
		    end
	end
	def uk_payment_report
		@start_date = params[:start_date] || Date.today.beginning_of_week.strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Date.today.end_of_week.strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s

		@payments = Payment.includes([:uk_customer, :uk_payment_type])
		.where("payment_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND  payment_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND (payments.void = 0 OR payments.void IS NULL)")
		.order('uk_payment_types.type_name, YEAR(payments.payment_date), MONTH(payments.payment_date), DAY(payments.payment_date), uk_customers.last_name, uk_customers.first_name')
	end


	def order_transaction
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@orders = Order.includes([:customer, :order_details, :order_type, :payment_details])
		.where("orders.void = ? AND orders.customer_id != ? AND accounting_date >= ? AND accounting_date < ?", false, 8675309, Time.zone.parse(@start_date).in_time_zone('UTC'), Time.zone.parse(@end_date).in_time_zone('UTC')).order('customers.last_name ASC')
		@order_analytics = Order.includes([:customer, :order_details, :order_type, :payment_details])
		.where("accounting_date >= ? AND accounting_date < ?", Time.zone.parse(@start_date).in_time_zone('UTC'), Time.zone.parse(@end_date).in_time_zone('UTC'))
		    respond_to do |format|
		      format.html # index.html.erb
		      format.json { render json: @order_analytics }
		    end
	end
	def order_transaction_victoria
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@orders = Order.includes([{:customer => [:customer_title]}, :order_details, :order_type, :payment_details, :ship_type])
		.where("orders.void = ? AND orders.customer_id != ? AND accounting_date >= ? AND accounting_date < ?", false, 8675309, Time.zone.parse(@start_date).in_time_zone('UTC'), Time.zone.parse(@end_date).in_time_zone('UTC')).order('customers.last_name ASC')
	end
	
	def ingredient_report
		@ingredients = Ingredient.includes([:products]).all
		@json_data = @ingredients.collect do |c| 
			{id: c.id, ingredient_name: c.ingredient_name}
		end
	end

	def milams_new_customers
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@customers = Customer.includes([{:orders => [:order_details, :state, :order_type, :payment_details, :ship_type, :ship_option]}, :customer_title, {:addresses => [:address_type]}])
		.where("customer_date >= ? AND customer_date < ?", Time.zone.parse(@start_date).in_time_zone('UTC'), Time.zone.parse(@end_date).in_time_zone('UTC')).order('customers.customer_date ASC')
	end

	def milams_order_report
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@orders = Order.includes([{:customer => [:customer_title]}, :order_details, :order_type, :payment_details, :ship_type, :state, :ship_option])
		.where("accounting_date >= ? AND orders.customer_id != ? AND accounting_date < ?", Time.zone.parse(@start_date).in_time_zone('UTC'), 8675309, Time.zone.parse(@end_date).in_time_zone('UTC')).order('customers.last_name ASC')
	end

	def payment_report
		@start_date = params[:start_date] || Date.today.beginning_of_week.strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Date.today.end_of_week.strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s

		@payments = Payment.includes([:customer, :payment_type])
		.where("payment_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND  payment_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND customers.id!=8675309 AND (payments.void = 0 OR payments.void IS NULL)")
		.order('payment_types.type_name, YEAR(payments.payment_date), MONTH(payments.payment_date), DAY(payments.payment_date), customers.last_name, customers.first_name')
	end
	def victorian_credit_report
		@start_date = params[:start_date] || Date.today.beginning_of_week.strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Date.today.end_of_week.strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s

		@payments = Payment.includes([:customer, :payment_type])
		.where("payment_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND  payment_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND customers.id!=8675309 AND payment_types.id = 5 AND (payments.void = 0 OR payments.void IS NULL)")
		.order('payment_types.type_name, YEAR(payments.payment_date), MONTH(payments.payment_date), DAY(payments.payment_date), customers.last_name, customers.first_name')
	end

	def customer_label_report
		@start_date = params[:start_date] || Date.today.beginning_of_week.strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Date.today.end_of_week.strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s

		@customers = Customer.includes([{:addresses => [:state]}, :orders, :customer_title])
		.where("orders.order_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.order_date <= '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND addresses.address_type_id = 1 AND addresses.is_default = 1 AND (orders.void = 0 OR orders.void IS NULL)").where(customer_title_id: params[:customer_title_id])
		.order('addresses.is_default DESC, addresses.zip_code  ASC')
		@customer_title = CustomerTitle.find(params[:customer_title_id])
		@customer_title_name = @customer_title.title_name
		@json_data = @customers.collect do |c| 
			@json_address =  c.addresses.first
			{id: c.id, full_name: c.full_name, customer_date: c.customer_date.strftime("%m/%d/%Y %H:%M"), customer_title: @customer_title_name, address_1: @json_address.address1, city: @json_address.city, state: @json_address.state.name, zip: @json_address.zip_code } 
		end
	end

	def customer_report
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@customers = Customer.includes(:sponsors)
		.where("customers.customer_date >= '#{Time.zone.parse(@start_date).to_s(:db)}' AND customers.customer_date < '#{Time.zone.parse(@end_date).to_s(:db)}'").order('customers.last_name ASC, customers.first_name ASC')
		@json_data = @customers.collect do |c| 
			sponsor = c.sponsors[0].nil? ? "MISSING SPONSOR" : c.sponsors[0].full_name
			{id: c.id, full_name: c.full_name, customer_date: c.customer_date.strftime("%m/%d/%Y %H:%M"), sponsor: sponsor } 
		end
	end
	def uk_customer_report
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@customers = UkCustomer.where("uk_customers.customer_date >= '#{Time.zone.parse(@start_date).to_s(:db)}' AND uk_customers.customer_date < '#{Time.zone.parse(@end_date).to_s(:db)}'").order('uk_customers.last_name ASC, uk_customers.first_name ASC')
		@json_data = @customers.collect do |c| 
			{id: c.id, full_name: c.full_name, customer_date: c.customer_date.strftime("%m/%d/%Y %H:%M") } 
		end
	end
	def bonus_report
		today = Date.today-1
		params[:start_date] ||= Time.new(today.year, today.mon,1)
		params[:end_date] ||= params[:start_date].advance(months: 1)    

		if params[:customer_id]
			@reports = DistributorBonusReport.where({start_date: params[:start_date], end_date: params[:end_date], customer_id: params[:customer_id]})
		else
			@reports = DistributorBonusReport.where({start_date: params[:start_date], end_date: params[:end_date], :personal_volume_cents.gte => 7500}).sort({last_name: 1, first_name: 1})
		end
	end
	def customer_by_title
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@customers = Customer.includes(:customer_title).where("customers.customer_date >= '#{Time.zone.parse(@start_date).to_s(:db)}' AND customers.customer_date < '#{Time.zone.parse(@end_date).to_s(:db)}'").where(customer_title_id: params[:customer_title_id]).order('customers.last_name ASC, customers.first_name ASC')
		@customer_title = CustomerTitle.find(params[:customer_title_id])
		@customer_title_name = @customer_title.title_name
		@json_data = @customers.collect do |c| 
			{id: c.id, full_name: c.full_name, customer_date: c.customer_date.strftime("%m/%d/%Y %H:%M"), customer_title: @customer_title_name } 
		end
		
		respond_to do |format|
			format.html
		end
	end 
	def customer_without_sponsor
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@customers = Customer.includes(:sponsors).where("customers.customer_date >= '#{Time.zone.parse(@start_date).to_s(:db)}' AND customers.customer_date < '#{Time.zone.parse(@end_date).to_s(:db)}' AND (sponsor_id is NULL OR sponsor_id = 0)").order('customers.last_name ASC, customers.first_name ASC')
		@json_data = @customers.collect do |c| 
			{id: c.id, full_name: c.full_name, customer_date: c.customer_date.strftime("%m/%d/%Y %H:%M")} 
		end
		
		respond_to do |format|
			format.html
		end
	end

	def sales_report

		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@orders = Order.includes([:order_type, :state, :customer, :order_details])
		.where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND orders.customer_id != 8675309 AND (orders.void = 0 OR orders.void IS NULL)")
		@grand_total = 0
		@tax_total= 0
		@ship_total = 0
		@sub_total = 0
		@orders.each do |order|
			@grand_total += order.grand_total_cents
			@sub_total += order.sub_total_cents
			@tax_total += order.tax_total_cents
			@ship_total += order.ship_total_cents
		end
		@json_data = @orders.collect do |o| 
			order_type_name = 'UNKNOWN'      
			order_type_name = o.order_type.type_name if o.order_type
			state = 'MISSING STATE'      
			state = o.state.abbreviation if o.state

			{id: o.id, accounting_date: o.accounting_date.strftime("%m/%d/%Y %H:%M"), full_name: o.customer.full_name, order_type: order_type_name, state: state, ship_total_cents: o.ship_total_cents/100.00, tax_total_cents: o.tax_total_cents/100.00, sub_total_cents: o.sub_total_cents/100.00, grand_total_cents: o.grand_total_cents/100.00} 
		end
		
		respond_to do |format|
			format.html
		end
	end

	def sales_summary_report

		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@orders = Order.includes([:order_type, :state, :order_details, :customer, {:order_details => :product}])
		.where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND (orders.void = 0 OR orders.void IS NULL)")
		@voided_orders = Order.includes([:order_type, :state, :order_details, :customer, {:order_details => :product}])
		.where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND orders.void = 1")
		@ca_orders = Order.includes([:order_type, :state, :customer, :order_details])
		.where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND orders.state_id = #{app_config.ca_state_id} AND (orders.void = 0 OR orders.void IS NULL)")
		@ca_reseller_orders = Order.includes([:order_type, :state, :customer, :order_details]).where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND orders.state_id = #{app_config.ca_state_id} AND (customers.resell_num IS NOT NULL AND customers.resell_num <> '') AND (orders.void = 0 OR orders.void IS NULL)")
		@non_taxable_orders = Order.includes([:order_type, :state, :order_details, :customer, {:order_details => :product}]).where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND products.taxable = 0 AND (orders.void = 0 OR orders.void IS NULL)")
		@grand_total = 0
		@tax_total= 0
		@ship_total = 0
		@sub_total = 0
		@orders.each do |order|
			@grand_total += order.grand_total_cents
			@sub_total += order.sub_total_cents
			@tax_total += order.tax_total_cents
			@ship_total += order.ship_total_cents
		end
		@grand_total_void = 0
		@tax_total_void= 0
		@ship_total_void = 0
		@sub_total_void = 0
		@voided_orders.each do |void|
			@grand_total_void += void.grand_total_cents
			@sub_total_void += void.sub_total_cents
			@tax_total_void += void.tax_total_cents
			@ship_total_void += void.ship_total_cents
		end
		@grand_total_ca = 0
		@tax_total_ca= 0
		@ship_total_ca = 0
		@sub_total_ca = 0
		@ca_orders.each do |ca|
			@grand_total_ca += ca.grand_total_cents
			@sub_total_ca += ca.sub_total_cents
			@tax_total_ca += ca.tax_total_cents
			@ship_total_ca += ca.ship_total_cents
		end
		@grand_total_reseller = 0
		@tax_total_reseller= 0
		@ship_total_reseller = 0
		@sub_total_reseller = 0
		@ca_reseller_orders.each do |reseller|
			@grand_total_reseller += reseller.grand_total_cents
			@sub_total_reseller += reseller.sub_total_cents
			@tax_total_reseller += reseller.tax_total_cents
			@ship_total_reseller += reseller.ship_total_cents
		end
		@grand_total_non_taxable = 0
		@tax_total_non_taxable= 0
		@ship_total_non_taxable = 0
		@sub_total_non_taxable = 0
		@non_taxable_orders.each do |non_taxable|
			@grand_total_non_taxable += non_taxable.grand_total_cents
			@sub_total_non_taxable += non_taxable.sub_total_cents
			@tax_total_non_taxable += non_taxable.tax_total_cents
			@ship_total_non_taxable += non_taxable.ship_total_cents
		end
		@json_data = [{title: "Total Sales", ship: @ship_total/100.0, tax: @tax_total/100.0, subtotal: @sub_total/100.0, total: @grand_total/100.0}, {title: "Voided Sales", ship: @ship_total_void/100.0, tax: @tax_total_void/100.0, subtotal: @sub_total_void/100.0, total: @grand_total_void/100.0}, {title: "California Sales", ship: @ship_total_ca/100.0, tax: @tax_total_ca/100.0, subtotal: @sub_total_ca/100.0, total: @grand_total_ca/100.0}, {title: "CA Reseller Sales", ship: @ship_total_reseller/100.0, tax: @tax_total_reseller/100.0, subtotal: @sub_total_reseller/100.0, total: @grand_total_reseller/100.0}, {title: "Non Taxable Sales", ship: @ship_total_non_taxable/100.0, tax: @tax_total_non_taxable/100.0, subtotal: @sub_total_non_taxable/100.0, total: @grand_total_non_taxable/100.0}]
		respond_to do |format|
			format.html
		end
	end

	def california_sales_report

		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@orders = Order.includes([:order_type, :state, :customer, :order_details])
		.where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND orders.state_id = #{app_config.ca_state_id} AND orders.customer_id != 8675309 AND (orders.void = 0 OR orders.void IS NULL)")
		@grand_total = 0
		@tax_total= 0
		@ship_total = 0
		@sub_total = 0
		@orders.each do |order|
			@grand_total += order.grand_total_cents
			@sub_total += order.sub_total_cents
			@tax_total += order.tax_total_cents
			@ship_total += order.ship_total_cents
		end
		@json_data = @orders.collect do |o| 
			order_type_name = 'UNKNOWN'      
			order_type_name = o.order_type.type_name if o.order_type
			{id: o.id, accounting_date: o.accounting_date.strftime("%m/%d/%Y %H:%M"), full_name: o.customer.full_name, order_type: order_type_name, ship_total_cents: o.ship_total_cents/100.00, tax_total_cents: o.tax_total_cents/100.00, sub_total_cents: o.sub_total_cents/100.00, grand_total_cents: o.grand_total_cents/100.00} 
		end
		
		respond_to do |format|
			format.html
		end
	end
	def non_taxable_sales_report

		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@orders = Order.includes([:order_type, :state, :order_details, :customer, {:order_details => :product}]).where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND products.taxable = 0 AND orders.customer_id != 8675309 AND (orders.void = 0 OR orders.void IS NULL)")
		@grand_total = 0
		@tax_total= 0
		@ship_total = 0
		@sub_total = 0
		@orders.each do |order|
			@grand_total += order.grand_total_cents
			@sub_total += order.sub_total_cents
			@tax_total += order.tax_total_cents
			@ship_total += order.ship_total_cents
		end
		@json_data = @orders.collect do |o| 
			order_type_name = 'UNKNOWN'      
			order_type_name = o.order_type.type_name if o.order_type
			{id: o.id, accounting_date: o.accounting_date.strftime("%m/%d/%Y %H:%M"), full_name: o.customer.full_name, order_type: order_type_name, state: o.state.abbreviation, ship_total_cents: o.ship_total_cents/100.00, tax_total_cents: o.tax_total_cents/100.00, sub_total_cents: o.sub_total_cents/100.00, grand_total_cents: o.grand_total_cents/100.00} 
		end
		
		respond_to do |format|
			format.html
		end

	end
	def ca_resellers_report

		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@orders = Order.includes([:order_type, :state, :customer, :order_details]).where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND orders.state_id = #{app_config.ca_state_id} AND (customers.resell_num IS NOT NULL AND customers.resell_num <> '') AND (orders.void = 0 OR orders.void IS NULL)")
		@grand_total = 0
		@tax_total= 0
		@ship_total = 0
		@sub_total = 0
		@orders.each do |order|
			@grand_total += order.grand_total_cents
			@sub_total += order.sub_total_cents
			@ship_total += order.ship_total_cents
		end
		@json_data = @orders.collect do |o| 
			order_type_name = 'UNKNOWN'      
			order_type_name = o.order_type.type_name if o.order_type
			{id: o.id, accounting_date: o.accounting_date.strftime("%m/%d/%Y %H:%M"), full_name: o.customer.full_name, order_type: order_type_name, ship_total_cents: o.ship_total_cents/100.00, sub_total_cents: o.sub_total_cents/100.00, grand_total_cents: o.grand_total_cents/100.00} 
		end
		
		respond_to do |format|
			format.html
		end
	end
	def shipping_report
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s

		where = "orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND orders.ship_type_id <> 5 AND order_details.shipped <> 1"
		where << " AND orders.void <> 1"
		@ship_options = ShipOption.includes([:orders, {:orders => [:customer, :order_type, :ship_type, :order_details, {:order_details => :product}]}])
		.where(where).order("ship_types.type_name, orders.accounting_date")

	end
	def no_ship_option_report
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s

		where = "orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND orders.ship_type_id <> 2 AND orders.ship_type_id <> 6 AND order_details.shipped <> 1 AND (orders.ship_option_id < 1 OR ship_option_id IS NULL)"
		where << " AND orders.void <> 1"
		@ship_types = ShipType.includes([:orders, {:orders => [:order_details]}])
		.where(where).order('ship_types.type_name ASC')

	end
	def in_store_report
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s

		where = "orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND orders.ship_type_id = 2 AND orders.customer_id != 8675309 "
		where << " AND orders.void <> 1 AND order_details.shipped <> 1"
		@ship_types = ShipType.includes([:orders, {:orders => [:order_details]}])
		.where(where).order('ship_types.type_name ASC')
	end
	def void_report
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@orders = Order.includes([:order_type, :state, :customer, :order_details])
		.where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND orders.void = 1")
		@grand_total = 0
		@tax_total= 0
		@ship_total = 0
		@sub_total = 0
		@orders.each do |order|
			@grand_total += order.grand_total_cents
			@sub_total += order.sub_total_cents
			@tax_total += order.tax_total_cents
			@ship_total += order.ship_total_cents
		end
		@json_data = @orders.collect do |o| 
			order_type_name = 'UNKNOWN'      
			order_type_name = o.order_type.type_name if o.order_type
			{id: o.id, accounting_date: o.accounting_date.strftime("%m/%d/%Y %H:%M"), full_name: o.customer.full_name, order_type: order_type_name, state: o.state.abbreviation, ship_total_cents: o.ship_total_cents/100.00, tax_total_cents: o.tax_total_cents/100.00, sub_total_cents: o.sub_total_cents/100.00, grand_total_cents: o.grand_total_cents/100.00} 
		end
		
		respond_to do |format|
			format.html
		end
	end
	def void_payment_report
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@payments = Payment.includes([:payment_details, :customer, :payment_type])
		.where("payments.payment_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND payments.payment_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND payments.void = 1")
		respond_to do |format|
			format.html
		end
	end
	def uk_inventory_report 
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@products = UkProduct.includes( [:order_details, { :order_details => [:order] }] )
		.where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND (orders.void = 0 OR orders.void IS NULL)").order('uk_products.product_name ASC')
		@products.collect do |product|
			quantity = 0
			wholesale = 0
			tax = 0
			product.order_details.collect.each do |detail|
				quantity += detail.qty * (detail.unit.nil? ? 1 : detail.unit)
				wholesale += detail.amount_cents/100.0
				tax += detail.tax_amount_cents/100.0
			end
			product[:quantity] = quantity
			product[:wholesale] = wholesale
			product[:tax] = tax
		end
		@json_data = @products.collect do |p| 
			quantity = 0
			wholesale = 0
			tax = 0
			p.order_details.collect.each do |detail|
				quantity += detail.qty * (detail.unit.nil? ? 1 : detail.unit)
				wholesale += detail.amount_cents/100.0
				tax += detail.tax_amount_cents/100.0
			end
			{id: p.id, product_name: p.product_name, item_num: p.item_num, quantity: quantity, tax: tax, wholesale: wholesale } 
		end
		
		respond_to do |format|
			format.html
		end

	end



	def inventory_report 
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@products = Product.includes( [:order_details, { :order_details => [:order] }] )
		.where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND (orders.void = 0 OR orders.void IS NULL)").order('products.product_name ASC')
		@products.collect do |product|
			quantity = 0
			wholesale = 0
			tax = 0
			product.order_details.collect.each do |detail|
				quantity += detail.qty * (detail.unit.nil? ? 1 : detail.unit)
				wholesale += detail.amount_cents/100.0
				tax += detail.tax_amount_cents/100.0
			end
			product[:quantity] = quantity
			product[:wholesale] = wholesale
			product[:tax] = tax
		end
		@json_data = @products.collect do |p| 
			quantity = 0
			wholesale = 0
			tax = 0
			p.order_details.collect.each do |detail|
				quantity += detail.qty * (detail.unit.nil? ? 1 : detail.unit)
				wholesale += detail.amount_cents/100.0
				tax += detail.tax_amount_cents/100.0
			end
			{id: p.id, product_name: p.product_name, item_num: p.item_num, quantity: quantity, tax: tax, wholesale: wholesale } 
		end
		
		respond_to do |format|
			format.html
		end

	end


	def organizational_report
		@sponsor = Customer.where(id: params[:customer_id]).first
		sponsor_tree = SponsorTree.where(customer_id: params[:customer_id]).first
		if sponsor_tree
			@customers = Customer.includes(:customer_title).where("id IN (?)", sponsor_tree[:direct_customers]).order("customers.last_name, customers.first_name")
		else
			@customers = []
		end
	end



	def fda_report 
		# render status: 400 and return unless params[:product_ids]
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s



		@products = Product.includes( [:order_details, { :order_details => {:order => [:customer]}}] )
		.where("orders.accounting_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.accounting_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND (orders.void = 0 OR orders.void IS NULL)").order('products.product_name ASC')
		@products.collect do |product|
			quantity = 0
			product.order_details.collect.each do |detail|
				quantity += detail.qty * (detail.unit.nil? ? 1 : detail.unit)
			end
			product[:quantity] = quantity
		end
		@json_data = @products.collect.each do |p| 
			quantity = 0
			wholesale_amount = 0
			p.order_details.collect.each do |detail|
				quantity += detail.qty * (detail.unit.nil? ? 1 : detail.unit)
				@customer_id = detail.order.customer.id
				@customer_name = detail.order.customer.full_name
				@order_id = detail.order.id
				@order_type = detail.order.order_type.type_name unless detail.order.order_type.nil?
				@order_date = detail.order.order_date
				wholesale_amount += detail.amount_cents/100.00
			end
			{id: p.id, product_name: p.product_name, customer_id: @customer_id, customer_name: @customer_name, order_id: @order_id, order_type: @order_type, order_date: @order_date, quantity: quantity, amount: wholesale_amount} 
		end

		respond_to do |format|
			format.html
		end
	end
	def faa_report 
		# render status: 400 and return unless params[:product_ids]
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s



		@products = Product.includes( [:order_details, { :order_details => {:order => [:customer]}}] )
		.where("products.id IN (#{params[:product_ids]}) AND orders.order_date >= '#{Time.zone.parse(@start_date).in_time_zone('UTC').to_s(:db)}' AND orders.order_date < '#{Time.zone.parse(@end_date).in_time_zone('UTC').to_s(:db)}' AND (orders.void = 0 OR orders.void IS NULL)").order('products.product_name ASC')
		@products.collect do |product|
			quantity = 0
			product.order_details.collect.each do |detail|
				quantity += detail.qty * (detail.unit.nil? ? 1 : detail.unit)
			end
			product[:quantity] = quantity
		end
		@json_data = @products.each do |p| 
			quantity = 0
			p.order_details.collect.each do |detail|
				quantity += detail.qty * (detail.unit.nil? ? 1 : detail.unit)
				@customer_id = detail.order.customer.id
				@customer_name = detail.order.customer.full_name
				@order_id = detail.order.id
				@order_type = detail.order.order_type.type_name unless detail.order.order_type.nil?
				@order_date = detail.order.order_date
				@wholesale_amount = detail.amount_cents/100.00
			end
			{id: p.id, product_name: p.product_name, customer_id: @customer_id, customer_name: @customer_name, order_id: @order_id, order_type: @order_type, order_date: @order_date, quantity: quantity, amount: @wholesale_amount} 
		end

		respond_to do |format|
			format.html
		end
	end
	def customer_outreach_report
		@start_date = params[:start_date] || Chronic.parse('Yesterday midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = params[:end_date] || Chronic.parse('Today midnight').strftime('%Y-%m-%d %H:%M')
		@end_date = (@end_date.to_date + 1).to_s
		@customers = Customer.includes(:orders)
		.where("orders.order_date >= '#{Time.zone.parse(@start_date).to_s(:db)}' AND orders.order_date < '#{Time.zone.parse(@end_date).to_s(:db)}' AND customers.email_me = 1").order('customers.last_name ASC, customers.first_name ASC')
		@json_data = @customers.collect do |c| 
			# @json_address =  c.addresses.first
			{id: c.id, full_name: c.full_name, email: c.email} 
		end
		respond_to do |format|
			format.html
		end
	end

	def index
		render layout: false
	end
end