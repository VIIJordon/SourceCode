angular.module('NewspiritAdmin').factory('OrdersService', ['Order', 'OrderDetail', 'OrderType', 'State', 'Country', 'ShipType', 'ShipOption', 'Product', 'OrderPayment', 'UkProduct', 'PaymentDetail', 'PaymentType', 'UkPaymentType', '$http',  'Customer', 'UkCustomer', 'Country', 'UkShipType','UkShipOption', function(Order, OrderDetail, OrderType, State, Country, ShipType, ShipOption, Product, OrderPayment, UkProduct, PaymentDetail, PaymentType, UkPaymentType, $http, Customer, UkCustomer, Country, UkShipType, UkShipOption) {
  var service = {}
  service.alerts = [];
  service.order;
  service.country;
  service.orders=[];
  service.orderTypes=[];
  service.orderDetails = [];
  service.paymentDetails=[];
  service.payments=[];
  service.paymentTypes=[];
  service.ukPaymentTypes=[];
  service.loggedBy;
  service.availablePayments=[];
  service.appliedPayments=[]
  service.products = [];
  service.displayShipOptions = true;
  service.states;
  service.countries;
  service.shipTypes;
  service.ukShipTypes;
  service.ukShipOptions
  service.paymentTypes;
  service.shipOptions;
  service.isLoading = false;
  service.totalRetail=0, service.totalAmount=0, service.totalTax=0, service.totalWeight=0, service.totalBonusValue=0, service.totalOrderAmount=0, service.balance=0;
  service.paymentApplied = 0;




    PaymentType.query().then(function(results) {
      service.paymentTypes = results;
    }, function(result) {
      service.alerts.push({type:'error', msg:'There was a problem loading the payment types. Please refresh the page and try again.'});
    });
  
  
    UkPaymentType.query().then(function(results) {
      service.ukPaymentTypes = results;
    }, function(result) {
      service.alerts.push({type:'error', msg:'There was a problem loading the payment types. Please refresh the page and try again.'});
    });





  OrderType.query().then(function(results) {
    service.orderTypes = results;
  }, function(result) {
    service.alerts.push({type:'error', msg:'There was a problem loading the order types. Please refresh the page and try again.'});
  });
  State.query().then(function(results) {
    service.states = results;
  }, function(result) {
    service.alerts.push({type:'error', msg:'There was a problem loading the states. Please refresh the page and try again.'});
  });
  Country.query().then(function(results) {
    service.countries = results;
  }, function(result) {
    service.alerts.push({type:'error', msg:'There was a problem loading the countries. Please refresh the page and try again.'});
  });

  ShipType.query().then(function(results) {
    service.shipTypes = results;
  }, function(result) {
    service.alerts.push({type:'error', msg:'There was a problem loading the ship types. Please refresh the page and try again.'});
  });
  
  service.loadUkTypes = function(){
    UkShipType.query().then(function(results) {
      service.ukShipTypes = results;
    }, function(result) {
      service.alerts.push({type:'error', msg:'There was a problem loading the order types. Please refresh the page and try again.'});
    });
  };


  service.updateTotals = function(){
    service.totalRetail=0;
    service.totalTax=0;
    service.totalAmount=0;
    service.totalWeight=0;
    service.totalBonusValue=0;
    service.orderDetails.forEach(function(detail){
      service.totalRetail = service.totalRetail+detail.retailAmountCents;
      service.totalAmount = service.totalAmount+detail.amountCents;
      service.totalWeight = service.totalWeight+detail.weight;
      service.totalTax = service.totalTax+detail.taxAmountCents;
      service.totalBonusValue += detail.bonusValueCents;
    });

    if (service.totalAmount>=10000) {
      service.order.handlingCents=0;
    }
    service.updateOrderTotal();

  };
  service.loadPaymentDetails = function(orderId, callback) {
    PaymentDetail.query({order_id: orderId}).then(function(results) {
      service.paymentDetails = results;
      if (callback) {
        callback();
      };
    });

  };

  service.updateOrderTotal = function() {
    service.totalOrderAmount=0
    if (service.order){
      service.totalShipAmount=service.order.shipAmountCents+service.order.handlingCents;
      if(service.order.ukCustomerId) {
        Country.get(service.order.countryId).then(function(result) {
          service.country = result;
        }, function(result) {
         
        });

        if (service.country && service.country.taxable == true){
          shippingVat = 0;
          shippingVat = service.order.shipAmountCents+service.order.handlingCents;
          shippingVat = shippingVat/1.2*0.2
          service.totalTax = service.totalTax+shippingVat;


          service.totalOrderAmount=service.totalAmount+service.totalShipAmount;


        }else{



          service.totalTax = 0;
          shippingVat = 0;




          service.totalOrderAmount=service.totalAmount+service.totalTax+service.totalShipAmount;


        };
      }else{
        service.totalOrderAmount=service.totalAmount+service.totalTax+service.totalShipAmount;
      }
    }    
    paymentValue = 0;
    service.paymentDetails.forEach(function(item) {
      paymentValue = paymentValue+item.amountCents;
    });
    service.balance = service.totalOrderAmount-paymentValue;    
  }
  service.newOrder = function() {
    service.order = new Order({customerId: service.customer.id, orderTypeId: ORDER_TYPE_ORDER, shipTypeId: SHIP_TYPE_IN_STORE, orderDate: moment().format('L'), accountingDate: moment().format('L'), void: 0, locked: 0, useCustomer: 0, status: "New Order Started"});
    service.orderDetails=[];
    service.updateTotals()
    return service.order;
  }; 
    service.newUkOrder = function() {
    service.order = new Order({ukCustomerId: service.ukCustomer.id, orderTypeId: ORDER_TYPE_ORDER, shipTypeId: SHIP_TYPE_IN_STORE, orderDate: moment().format('L'), accountingDate: moment().format('L'), void: 0, locked: 0, useCustomer: 0, status: "New Order Started"});
    service.orderDetails=[];
    service.loadUkTypes();
    service.updateTotals()
    return service.order;
  }; 
  service.newPayment = function() {
    if (service.customer){
      today = new Date();
      service.payment = new OrderPayment({
        void:false,
        customerId: service.customer.id, 
        paymentTypeId: PAYMENT_TYPE_CREDIT_CARD, 
        paymentDate: moment().format('L'), accountingDate: moment().format('L'),
        amountCents: service.balance,
        balance: service.balance
      });
      service.paymentApplied = service.balance;

      // toDo: set up the payment detail and assign the order
      service.paymentDetail=[];
      return service.payment;
    }
    else{
      today = new Date();
      service.payment = new OrderPayment({
        void:false,
        ukCustomerId: service.ukCustomer.id, 
        ukPaymentTypeId: UK_PAYMENT_TYPE_CREDIT_CARD, 
        paymentDate: moment().format('DD/MM/YYYY'), accountingDate: moment().format('DD/MM/YYYY'),
        amountCents: service.balance,
        balance: service.balance
      });
      service.paymentApplied = service.balance;

      // toDo: set up the payment detail and assign the order
      service.paymentDetail=[];
      return service.payment;
    }

  };
  // It is assumed the payment has already been saved and existing paymentDetails have been loaded
  // This will add a payment detail if one does not exist for the payment and update totals
  service.savePaymentDetail = function(payment) {
    if (service.balance > 0) {
      if (service.paymentDetails.length == 0) {
        newPayment = true;
      } else {
        // we have some payment details lets see if this order is already associated with this payment, if not then create a new one and save
        newPayment = true
        service.paymentDetails.forEach(function(detail) {
          if (detail.orderId == service.order.id && detail.paymentId == payment.id) {
            newPayment = false;
          }
        });
      }
      if (newPayment) {
        paymentDetail = new PaymentDetail({paymentId: payment.id, orderId: service.order.id, amountCents: service.paymentApplied});
        paymentDetail.save().then(function(result) {
          service.paymentDetails.push(result);
          if(service.customer){
            service.loadAppliedPayments(service.order.id);
            service.loadAvailablePayments(service.customer.id);
          };
          service.updateOrderTotal();
        }, function(errors){
          
        });
      }
    }
  };
  service.searchProduct = function(q){
    if (service.order.ukCustomerId){
      UkProduct.query({q: q}).then(function(results){
        service.products =  results;
      }, function(result) {
        service.alerts.push({type:'error', msg: 'There was a problem loading products'});
      });
    }else{
      Product.query({q: q}).then(function(results){
        service.products =  results;
      }, function(result) {
        service.alerts.push({type:'error', msg: 'There was a problem loading products'});
      });
    };

  };
  service.loadOrder = function(orderId, callback) {
    if (!service.isLoading) {
      service.payment=undefined;
      service.paymentApplied = 0;
      service.orderDetails = [];
      service.paymentDetails =[];
      service.availablePayments = [];
      service.appliedPayments = [];
      service.isLoading=true;


      OrderDetail.query({order_id: orderId}).then(function(results) {
        service.orderDetails = results;
        service.orderDetails.forEach(function(detail){
          if(detail.shipDate){
            detail.shipDate = moment(detail.shipDate).format('MM/DD/YYYY')
          }
        });
        service.updateTotals();
      });

      Order.get(orderId).then(function(item){
        Customer.get({id: item.loggedById}).then(function(result) {
          service.loggedBy = result;
        });
        
        if(item.ukCustomerId){
        UkCustomer.get({id: item.ukCustomerId}).then(function(result) {
          service.ukCustomer = result;
        });
        }
        service.isLoading=false;
        if(item.customer){
          service.customer = item.customer;
        }else
        {
          service.loadUkTypes();
        }
        service.order = item;

          Country.get(service.order.countryId).then(function(result) {
            service.country = result;
          }, function(result) {
           
          });
        if(service.customer){
          service.loadAvailablePayments(service.customer.id);
        }
        service.loadPaymentDetails(service.order.id, function() {
          service.updateOrderTotal();
        });
        service.loadAppliedPayments(service.order.id);
        service.loadShipOptions();
        service.loadUkShipOptions();
        callback(true);
        if(service.order.locked ==true){
          service.locked = true
        };
      });
    };
  };
  service.loadPayment = function(paymentId) {
    if (!service.isLoading) {
      service.isLoading=true;
      OrderPayment.get(paymentId).then(function(item){
        service.isLoading=false;
        service.payment = item;
        service.loadPaymentTypes();
      });
    }
  };
  service.loadAvailablePayments = function(customerId) {
    OrderPayment.query({available:true,customer_id:customerId, void:false}).then(function(results) {
      service.availablePayments = results;
    }, function(failure) {
      service.alerts.push({type:'warning',msg:'There was a problem loading available payments. If this is needed right now, please refresh the page and try again.'});
    });
  };
  service.loadAppliedPayments = function(orderId) {
    OrderPayment.query({order_id:orderId, void:false}).then(function(results) {
      service.appliedPayments = results;
    }, function(failure) {
      service.alerts.push({type:'warning',msg:'There was a problem loading applied payments. If this is needed right now, please refresh the page and try again.'});
    });
  }
  service.newOrderDetail = function() {
    newOrderDetail = new OrderDetail({order_id: service.order.id, useCase:false, shipped: 0});
    return newOrderDetail;
  };
  service.newPaymentDetail = function() {
    newPaymentDetail = new PaymentDetail({order_id: service.order.id, useCase:false});
    return newPaymentDetail;
  };
  service.loadOrders = function(customerId) {
    if (customerId) {
      Order.query({customer_id: customerId}).then(function(results) {
        service.orders = results;
      }, function(result) {
        service.alerts.push({type:'error', msg:'There was a problem loading the list of orders'});
      });

    } else {
      service.alerts.push({type:'error', msg:'Customer Id not set'});
    }
  };

  service.loadShipOptions = function() {
    ShipOption.query({order_id: service.order.id, weight: service.totalWeight}).then(function(results) {
      service.shipOptions = results;
      service.displayShipOptions = false;
    }, function(result) {

    });
  };
  service.loadUkShipOptions = function() {
    UkShipOption.query({uk_ship_type_id: service.order.ukShipTypeId}).then(function(results) {
      service.ukShipOptions = results;
      service.displayShipOptions = true;
    }, function(result) {
      service.alerts.push({type: 'error', msg: 'There was a problem loading the ship options'})
    });
  };
  return service;
}]);