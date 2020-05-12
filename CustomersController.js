angular.module('NewspiritAdmin').controller('UkCustomersController', ['$scope', 'FormService', '$location', '$timeout', '$routeParams', '$http', 'UkCustomer', 'CustomersService', 'CreditCard', 'CustomerTitle', 'OrdersService', '$modal', 'CustomerCheckType', 'UkAddress', function($scope, FormService, $location, $timeout, $routeParams, $http, UkCustomer, CustomersService, CreditCard, CustomerTitle, OrdersService, $modal, CustomerCheckType, UkAddress) {
	$scope.selected;
	$scope.ukCustomers = [];
	$scope.customersService = CustomersService;
	$scope.alerts =[];
	$scope.customerTitles = [];
	$scope.customerCheckTypes = [];
	$scope.creditCards =  [];
	$scope.ordersService = OrdersService;
	$scope.sponsor;

	CustomerTitle.query().then(function(results) {
		$scope.customerTitles = results;
	}, function(result) {
		$scope.alerts.push({type:'error', msg: 'There was a problem loading the customer titles. Please refresh the page and try again.'});
	});

	CustomerCheckType.query().then(function(results) {
		$scope.customerCheckTypes = results;
	}, function(result) {
		$scope.alerts.push({type:'error', msg: 'There was a problem loading the customer check types. Please refresh the page and try again.'});
	});

	if ($routeParams.id == 'new') {
		$scope.selected = new UkCustomer();
		$scope.customersService.ukCustomerComments = [];
	} else if ($routeParams.id == undefined) {
		UkCustomer.query().then(function(results) {
			$scope.ukCustomers=results;
		});
	} else {
		UkCustomer.get($routeParams.id).then(function(result) {
			$scope.selected = result;
			$scope.customersService.setUkCustomer(result)
			OrdersService.ukCustomer = result;
		}, function(result) {
			$scope.alerts.push({type:'error',msg:'Customer Not Found'})
		});
	};

  $timeout(function(){
		if ($scope.selected.sponsor){
			UkCustomer.get($scope.selected.sponsor).then(function(result) {

				$scope.sponsor = result.firstName + ' ' + result.lastName;
			}, function(result) {
				$scope.alerts.push({type:'error',msg:'sponsor Not Found'})
			});
		} else{
			$scope.sponsor = ' '
		}
  }, 1000);
	$scope.update = function(item){
		if (item.id) {
			item.update().then(function(result) {
							$scope.alerts.push({type:'success',msg:'Customer Saved!'});
				$timeout(function(){
								$scope.alerts = [];
				}, 1000);
			}, function(result) {
				$scope.alerts.push({type:'error',msg:'Error saving Customer'});
				$timeout(function(){
								$scope.alerts = [];
				}, 1000);
			});
		} else {
			item.customerDate = moment().format('YYYY-MM-DD');
			item.save().then(function(result) {
				$timeout(function(){
								$location.path('uk_customers/'+ result.id)
							}, 1000);
			}, function(result) {
				$scope.alerts.push({type:'error',msg:'Error saving Customer'});
				$timeout(function(){
								$scope.alerts = [];
				}, 1000);
			});
		}    
	};
	$scope.showOrders = function(ukCustomer) {
		var modal = $modal.open({
			templateUrl: '/admin/orders',
			controller: 'OrdersSelectUkController',
			resolve: {
				ukCustomer: function () {
					return ukCustomer;
				}
			}

		});
		modal.result.then(function (item) {
			$location.path('/orders/'+item.id);
		}, function () {
			console.log('Modal dismissed at: ' + new Date());
		});     
	}
	$scope.newOrder = function() {
		$location.path('/orders/new');
	};
	$scope.setSponsor = function(searchText) {
		$scope.ukCustomers.forEach(function(item) {
			var sponsorResult;
			sponsorResult = 'Id: ' + item.id + ' ' + item.lastName +', ' + item.firstName;

				if (sponsorResult==searchText) {
				 $scope.selected.sponsor = item.id;
				 $scope.sponsor = item.lastName +', ' + item.firstName
				}
		}); 
	};
	$scope.closeAlert = function(index) {
			$scope.alerts.splice(index, 1);
	};
	$scope.returnToMenu = function() {
		console.log('return to menu');
		$location.path('/');
	};

	$scope.returnToList = function() {
		$location.path('/uk_customers');
	};


  $scope.search = function(options) {
    // TODO: validate params
    //searchText, showAll, page, perPage
    if (!options.page){
      options.page = 1;
    };
    if (!options.perPage){
      options.perPage= 20;
    };
      UkCustomer.query({q:options.query, show_all:options.showAll, page:options.page,per_page:options.perPage}).then(function(results) {
        if(!options.callback){
          $scope.results = results;
        }
        UkCustomer.query({q:options.query, show_all:options.showAll,total_count:true}).then(function(count) {
          if(!options.callback){
            totalCount = count['count']
          } else{
            options.callback({results: results, totalCount: count['count']});
          };
          return {results:results, totalCount:count['count']}
        });  
      });
  };

	$scope.searchUkCustomers = function(searchText) {
		UkCustomer.query({q: searchText}).then(function(results){
			$scope.ukCustomers = results;
		});    
	} 
	$scope.loadSelected = function(searchText) {
	 $location.path('/uk_customers/'+searchText.id);
	};
	$scope.delete = function(item){
		$scope.alerts = [];
		item.active = false;
			forms.update(item, function() {
				$scope.alerts.push({type:'success',msg:'Customer Marked Inactive, Redirecting to Customer List'});
					$timeout(function(){
					 $location.path('/uk_customers') 
					}, 2000);
			}, function(errors) {
				$scope.alerts = errors;
			}); 
	};
	// $scope.delete = function(item) {
	// 	$scope.ukCustomers.splice($scope.ukCustomers.indexOf(item), 1);
	// 	item.delete();
	// };
	$scope.edit = function(row) {
		$scope.selected=row;
		$location.path('/uk_customers/' + row.id)
	};

	$scope.pagingOptions = {
		pageSizes: [20, 50, 100],
		pageSize: 20,
		currentPage: 1
	};

	$scope.$watch('pagingOptions', function (newVal, oldVal) {
		if (newVal !== oldVal && (newVal.currentPage !== oldVal.currentPage || newVal.pageSize != oldVal.pageSize)) {
			_items = UkCustomer.query({'q':$scope.searchText, page: $scope.pagingOptions.currentPage, per_page: $scope.pagingOptions.pageSize});
			_items.then(function(results) {
				$scope.ukCustomers=results;
			});

		}
	}, true);

	$scope.gridOptions = {
	data: 'ukCustomers',
		enableCellSelection: false,
		rowHeight: 35,
		enablePaging:true,
		pagingOptions: $scope.pagingOptions,
		showFooter: true,
		columnDefs: [
					{field: 'id', width: 75, displayName: 'ID'},
					{field: 'firstName', displayName: 'First Name'},
					{field: 'lastName', displayName: 'Last Name'},
					{field: 'companyName', displayName: 'Company'},
			{displayName: '', width:125, cellTemplate: '<button class="btn btn-info" ng-click="edit(row.entity)">Edit</button>&nbsp;<button class="btn btn-danger" ng-confirm-click ng-click="delete(row.entity)">Delete</button>'}
		]
	};
}]);