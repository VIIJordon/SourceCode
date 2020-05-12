require 'spec_helper'
describe 'customers api' do 
  context 'when listing customers' do 
    before(:each) do
      Customer.create!(first_name: 'Frank', last_name: 'Furters', phone: '555-1212', email: 'ffurter@fred.com', customer_check_type_id: 1, customer_title_id: 1)
      Customer.create!(first_name: 'Marisyle', last_name: 'Sholden', phone: '555-1212', customer_check_type_id: 1, customer_title_id: 1)
      Customer.create!(first_name: 'Mary', last_name: 'Furter', phone: '555-1212', customer_check_type_id: 1, customer_title_id: 1)
      Customer.create!(first_name: 'Fred', last_name: 'Show', phone: '555-1212', email: 'fred@jane.com', customer_check_type_id: 1, customer_title_id: 1)
      Customer.create!(first_name: 'Marilyn', last_name: 'Show', phone: '555-1212', email: 'mary@jane.com', customer_check_type_id: 1, customer_title_id: 1)
      
    end
    it 'searches email' do
      get '/api/customers.json?q=mary@jane.com'
      response.should be_ok
      data = JSON.parse(response.body)
      data.length.should == 1
      data[0]['first_name'].should == 'Marilyn'
    end

    it 'sorts by last_name, first_name' do 
      get '/api/customers.json'
      response.should be_ok
      data = JSON.parse(response.body, :symbolize_names => true)
      data.length.should == 5
      data[0][:last_name].should == 'Furter'
      data[1][:last_name].should == 'Furters'
      data[2][:last_name].should == 'Sholden'
      data[3][:last_name].should == 'Show'
      data[3][:first_name].should == 'Fred'
      data[4][:last_name].should == 'Show'
      data[4][:first_name].should == 'Marilyn'
    end
    it 'looks searches by first name' do
      get '/api/customers.json?q=ma'
      response.should be_ok
      data = JSON.parse(response.body)
      data.length.should == 3
      data[0]['first_name'].should == 'Mary'
      data[1]['first_name'].should == 'Marisyle'
      data[2]['first_name'].should == 'Marilyn'
    end
    it 'looks gets a count of search matches' do
      get '/api/customers.json?q=ma&total_count=true'
      response.should be_ok
      data = JSON.parse(response.body, :symbolize_names => true)
      data[:count].should == 3
    end
    it 'looks gets a total count' do
      get '/api/customers.json?total_count=true'
      response.should be_ok
      data = JSON.parse(response.body, :symbolize_names => true)
      data[:count].should == 5
    end

    it 'searches by last_name, first' do
      get '/api/customers.json?q=Show,F'
      response.should be_ok
      data = JSON.parse(response.body, :symbolize_names => true)
      data.length.should == 1
      data[0][:first_name].should == 'Fred'

    end
    it 'should page the results' do 
      get '/api/customers.json?page=2&per_page=3'
      response.should be_ok
      data = JSON.parse(response.body, :symbolize_names => true)
      data.length.should == 2
      data[0][:first_name].should == 'Fred'
      data[1][:first_name].should == 'Marilyn'
      get '/api/customers.json?page=2&per_page=2&q=Mar'
      response.should be_ok
      data = JSON.parse(response.body, :symbolize_names => true)
      data.length.should == 1
      data[0][:first_name].should == 'Marilyn'
    end
  end
  context 'when creating a customer' do
    title = CustomerTitle.create(title_name: 'Head Honcho', level: 7)
    before(:each) do
      @root_customer = Customer.create(first_name: 'Root', last_name: 'Customer', phone:'1234', customer_check_type_id: 1, customer_title_id: title.id)
      sponsors = []
      4.times do |i|
        sponsor = CustomerSponsor.create(customer_id: @root_customer.id, sponsor_id: @root_customer.id, customer_sponsor_type_id: i)
      end
      SponsorTree.create(customer_id: @root_customer.id, sponsor: @root_customer.id, sponsors: [], direct_customers: [], group_customers: [])

    end

    it 'should create a customer' do 
      post '/api/customers.json', :customer => {
        first_name: 'Bob',
        last_name: 'furbers'
      }
      response.status.should == 422

      post '/api/customers.json', :customer => {
        first_name: 'Bob',
        last_name: 'furbers',
        phone: '555-1212',
        customer_title_id: 1,
        customer_check_type_id: 1,
        sponsor_id: @root_customer.id
      }
      response.status.should == 201
      data = JSON.parse(response.body, :symbolize_names => true)
      data[:id].should_not be_nil

    end
    it 'set sponsors on create' do 
      post '/api/customers.json', :customer => {
        first_name: 'Bob',
        last_name: 'furbers',
        phone: '555-1212',
        customer_title_id: 1,
        customer_check_type_id: 1,
        sponsor_id: @root_customer.id
      }
      response.status.should == 201
      data = JSON.parse(response.body, :symbolize_names => true)
      data[:id].should_not be_nil
      sponsor_record = SponsorTree.where(customer_id: data[:id]).first
      sponsor_record.should_not be_nil
      sponsor_record.sponsor.should == @root_customer.id
      sponsor_record.sponsors.length.should == 1
      sponsor_record.sponsors[0].should == @root_customer.id
    
      sponsor_record = SponsorTree.where(customer_id: @root_customer.id).first
      sponsor_record.direct_customers.length.should == 1
      sponsor_record.direct_customers[0].should == data[:id]

    end
    it 'should validate check type id presence' do 
      post '/api/customers.json', :customer => {
        first_name: 'Bob',
        last_name: 'furbers',
        phone: '555-1212',
        customer_check_type_id: 0,
        customer_title_id: 1,
        sponsor_id: @root_customer.id

      }
      response.status.should == 422

      post '/api/customers.json', :customer => {
        first_name: 'Bob',
        last_name: 'furbers',
        phone: '555-1212',
        customer_title_id: 1,
        customer_check_type_id: 1,
        sponsor_id: @root_customer.id

      }
      response.status.should == 201
      data = JSON.parse(response.body, :symbolize_names => true)
      data[:id].should_not be_nil

    end
    it "creates a customer when customer_title is passed" do 
      post '/api/customers.json', :customer => {
        first_name: 'Bob',
        customer_title: {title_name: 'Distributor'},
        last_name: 'furbers',
        phone: '555-1212',
        customer_title_id: 1,
        customer_check_type_id: 1,
        sponsor_id: @root_customer.id

      }
      response.status.should == 201
      data = JSON.parse(response.body, :symbolize_names => true)
      data[:id].should_not be_nil

    end

  end
  context 'when dealing with an existing customer' do 
    before(:each) do 
      @customer =  Customer.create!(first_name: 'Fred', last_name: 'Show', phone: '555-1212', email: 'fred@jane.com', customer_check_type_id: 1, customer_title_id: 1)
    end
    it 'should update a customer' do 
      put "/api/customers/#{@customer.id}.json", :customer => {
        first_name: 'Bob',
        last_name: 'Franklin'
      }
      response.should be_ok
      customer = Customer.where(id: @customer.id).first 
      customer.first_name.should == 'Bob'
      customer.last_name.should == 'Franklin'
    end
    it "updates a customer when customer_title is passed" do 
      put "/api/customers/#{@customer.id}.json", :customer => {
        first_name: 'Fred',
        customer_title: {title_name: 'Distributor'},
        last_name: 'Furbers',
        phone: '555-1212',
        customer_title_id: 1,
        customer_check_type_id: 1
      }
      response.should be_ok
      customer = Customer.where(id: @customer.id).first 
      customer.first_name.should == 'Fred'
      customer.last_name.should == 'Furbers'

    end

    it 'should delete a customer' do
      delete "/api/customers/#{@customer.id}.json"
      customer = Customer.where(id:@customer.id).first
      customer.should be_nil
    end

    it "looks up a customer by id" do 
      get "/api/customers/#{@customer.id}.json"
      response.should be_ok
      data = JSON.parse(response.body, :symbolize_names => true)
      data[:first_name].should == 'Fred'

    end
    it "searches a customer by id" do 
      get "/api/customers.json?q=#{@customer.id}"
      response.should be_ok
      data = JSON.parse(response.body, :symbolize_names => true)
      data.length.should == 1
      data[0][:first_name].should == 'Fred'
    end
  end
end