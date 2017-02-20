app = angular.module 'SwApp', [ 'ngResource', 'ngCookies', 'ui.router' ]

app.config ($stateProvider) ->

	$stateProvider
	.state('login', {
		url: '/login',
		templateUrl: '/app/views/login.html',
		controller: 'LoginController',
		controllerAs: 'vm'
	})
	.state('logout', {
		url: '/logout',
		controller: 'LogoutController',
		controllerAs: 'vm'
	})
	.state('register', {
		url: '/register',
		templateUrl: '/app/views/register.html',
		controller: 'RegisterController',
		controllerAs: 'vm'
	})
	.state('planet', {
		url: '/planets',
		controller: 'PlanetsController',
		templateUrl: '/app/views/planets.html'
	})
	.state('planet_detail', {
		url: '/planet/:id',
		controller: 'PlanetsController',
		templateUrl: '/app/views/planet.html'
	})
	.state('people', {
		url: '/peoples',
		controller: 'PeoplesController',
		templateUrl: '/app/views/peoples.html'
	})

app.run [ '$rootScope', '$location', '$cookies', '$http', ($rootScope, $location, $cookies, $http) ->

		$rootScope.globals = $cookies.getObject('globals') || {};

		$rootScope.$on '$locationChangeStart', (event, next, current) ->
			restrictedPage =  $location.path() == '/register'
			loggedIn = $rootScope.globals.currentUser

			if !restrictedPage && !loggedIn
				$location.path('/login')


		$rootScope.logged = () ->
			if $rootScope.globals.currentUser
				return true
			else
				return false

	]
