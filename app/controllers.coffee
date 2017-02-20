app = angular.module 'SwApp'

app.controller 'RegisterController', [ 'UserService', '$location', '$rootScope', 'FlashService', (UserService, $location, $rootScope, FlashService) ->

		vm = this

		register = ->
			vm.dataLoading = true
			UserService.Create vm.user
				.then (response) ->
					if response.success
						FlashService.Success('Registration successful', true)
						$location.path '/login'
					else
						FlashService.Error(response.message)
						vm.dataLoading = false
		vm.register = register

		return vm
	]

app.controller 'LoginController', [ '$location', 'AuthenticationService', 'FlashService', ($location, AuthenticationService, FlashService) ->

		vm = this

		(initController = ->
			AuthenticationService.ClearCredentials
		)()

		login = ->

			vm.dataLoading = true
			AuthenticationService.Login(vm.username, vm.password, (response) ->
				if response.success
					AuthenticationService.SetCredentials vm.username, vm.password

					$location.path 'peoples'
				else
					FlashService.Error response.message
					vm.dataLoading = false
			)

		vm.login = login

		return vm
	]

app.controller 'LogoutController', [ '$rootScope', '$cookies', '$location', '$http', 'AuthenticationService', ($rootScope, $cookies, $location, $http, AuthenticationService) ->

		vm = this

		logout = ->
			$rootScope.globals = {}
			$cookies.remove 'globals'
			$http.defaults.headers.common.Authorization = 'Local'
			$location.path('/login')

		vm.logout = logout()

	]

app.controller 'PlanetsController', [ '$scope', '$http', '$stateParams', ($scope, $http, $stateParams) ->

		if $stateParams.id

			$http {
					url: 'http://swapi.co/api/planets/'+$stateParams.id+'/',
					method: 'GET'
				}
				.then (resp) ->
					$scope.planet = resp.data

		else

			$scope.currentUrl = 'http://swapi.co/api/planets/'
			$scope.planets = []

			$scope.getResults = (url) ->
				$('#loading').fadeIn()
				if typeof url == undefined
					url = $scope.currentUrl
				$http {
						url: url,
						method: 'GET',
						headers: {
							'Content-Type': 'text/plain'
						}
					}
					.then (resp) ->
						Object.keys(resp.data.results).map (key, value) ->
							resp.data.results[key].id = parseInt(resp.data.results[key].url.split('/')[5])
						$scope.planets = resp.data

						$('#loading').fadeOut()

						if !$stateParams.id
							$('.prev').prop 'disabled', (resp.data.previous == null)
							$('.next').prop 'disabled', (resp.data.next == null)

			$scope.getResults $scope.currentUrl

			$scope.prevPage = () ->
				if !$('.prev').prop('disabled')
					$scope.getResults($scope.planets.previous)
			$scope.nextPage = () ->
				if !$('.next').prop('disabled')
					$scope.getResults($scope.planets.next)

	]


app.controller 'PeoplesController', [ '$scope', '$http', '$stateParams', ($scope, $http, $stateParams) ->

		$scope.currentUrl = 'http://swapi.co/api/people/'
		$scope.peoples = []
		$scope.getResults = (url) ->
			$('#loading').fadeIn()
			if $('.next, .prev').length
				$('.next, .prev').prop('disabled', true)
			if typeof url == undefined
				url = $scope.currentUrl
			$http {
					url: url,
					method: 'GET'
				}, {}
				.then (resp) ->
					Object.keys(resp.data.results).map (key, value) ->
						resp.data.results[key].id = parseInt(resp.data.results[key].url.split('/')[5])
					$scope.peoples = resp.data

					$('#loading').fadeOut()
					if $('.next, .prev').length
						$('.next, .prev').prop('disabled', false)

		$scope.getResults $scope.currentUrl

		$scope.prevPage = () ->
			if !$('.prev').prop('disabled')
				$scope.getResults($scope.peoples.previous)
		$scope.nextPage = () ->
			if !$('.next').prop('disabled')
				$scope.getResults($scope.peoples.next)

		$scope.openModal = (id) ->
			$http {
					url: 'http://swapi.co/api/people/'+id+'/',
					method: 'GET'
				}
				.then (resp) ->
					$scope.people = resp.data
					$('#peopleModal').modal 'toggle'

	]
