app = angular.module 'SwApp'

app.factory 'AuthenticationService', [ '$http', '$cookies', '$rootScope', '$timeout', 'UserService', ($http, $cookies, $rootScope, $timeout, UserService) ->
		service = {}

		Login = (username, password, callback) ->

			setTimeout (->
				response = undefined
				UserService.GetByUsername(username).then (user) ->
					if user != undefined and user.password == password
						response = success: true
					else
						response =
							success: false
							message: 'Username or password is incorrect'

					callback response
			), 1000

		SetCredentials = (username, password) ->
			authdata = Base64.encode(username + ':' + password)

			$rootScope.globals = {
				currentUser: {
					username: username,
					authdata: authdata
				}
			}

			$http.defaults.headers.common['Authorization'] = 'Local ' + authdata

			cookieExp = new Date()

			cookieExp.setDate cookieExp.getDate() + 7
			$cookies.putObject 'globals', $rootScope.globals, { expires: cookieExp }

		ClearCredentials = ->
			$rootScope.globals = {}
			$cookies.remove 'globals'
			$http.defaults.headers.common.Authorization = 'Local'

		Base64 =

			keyStr: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='

			encode: (input) ->
				chr1 = chr2 = chr3 = enc1 = enc2 = enc3 = enc4 = output = ""
				i = 0

				while i < input.length
					chr1 = input.charCodeAt(i++)
					chr2 = input.charCodeAt(i++)
					chr3 = input.charCodeAt(i++)

					enc1 = chr1 >> 2
					enc2 = ((chr1 & 3) << 4) | (chr2 >> 4)
					enc3 = ((chr2 & 15) << 2) | (chr3 >> 6)
					enc4 = chr3 & 63

					if isNaN(chr2)
						enc3 = enc4 = 64
					else if (isNaN(chr3))
						enc4 = 64

					output = output +
						this.keyStr.charAt(enc1) +
						this.keyStr.charAt(enc2) +
						this.keyStr.charAt(enc3) +
						this.keyStr.charAt(enc4)
					chr1 = chr2 = chr3 = enc1 = enc2 = enc3 = enc4 = ""

				return output

			decode: (input) ->
				chr1 = chr2 = chr3 = enc1 = enc2 = enc3 = enc4 = output = ""
				i = 0

				base64test = /[^A-Za-z0-9\+\/\=]/g

				if base64test.exec(input)
					alert "There were invalid base64 characters in the input text.\n" +
						"Valid base64 characters are A-Z, a-z, 0-9, '+', '/',and '='\n" +
						"Expect errors in decoding."

				input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "")

				while i < input.length

					enc1 = this.keyStr.indexOf input.charAt(i++)
					enc2 = this.keyStr.indexOf input.charAt(i++)
					enc3 = this.keyStr.indexOf input.charAt(i++)
					enc4 = this.keyStr.indexOf input.charAt(i++)

					chr1 = (enc1 << 2) | (enc2 >> 4);
					chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
					chr3 = ((enc3 & 3) << 6) | enc4;

					output = output + String.fromCharCode chr1

					if enc3 != 64
						output = output + String.fromCharCode chr2
					if enc4 != 64
						output = output + String.fromCharCode chr3

					chr1 = chr2 = chr3 = enc1 = enc2 = enc3 = enc4 = ""

				return output


		service.Login = Login
		service.SetCredentials = SetCredentials
		service.ClearCredentials = ClearCredentials

		return service

	]


app.factory 'FlashService', [ '$rootScope', ($rootScope) ->

		service = {}

		(initService = ->
			console.log "here"
			$rootScope.$on '$locationChangeStart', () ->
				clearFlashMessage();

			clearFlashMessage = () ->
				flash = $rootScope.flash
				if flash
					if !flash.keepAfterLocationChange
						delete $rootScope.flash
					else
						flash.keepAfterLocationChange = false
		)()
		Success = (message, keepAfterLocationChange) ->
			$rootScope.flash = {
				message: message,
				type: 'success',
				keepAfterLocationChange: keepAfterLocationChange
			}

		Error = (message, keepAfterLocationChange) ->
			$rootScope.flash = {
				message: message,
				type: 'error',
				keepAfterLocationChange: keepAfterLocationChange
			}
		initService
		service.Success = Success
		service.Error = Error



		return service
	]


app.factory 'UserService', [ '$timeout', '$filter', '$q', ($timeout, $filter, $q) ->

		service = {}

		GetAll = () ->
			deferred = $q.defer()
			deferred.resolve(getUsers())
			return deferred.promise

		GetById = (id) ->
			deferred = $q.defer()
			filtered = $filter('filter')(getUsers(), { id: id })
			user = filtered[0] if filtered.length
			deferred.resolve(user)
			return deferred.promise

		GetByUsername = (username) ->
			deferred = $q.defer()
			filtered = $filter('filter')(getUsers(), { username: username })
			user = filtered[0] if filtered.length
			deferred.resolve(user)
			return deferred.promise

		Create = (user) ->
			deferred = $q.defer()

			$timeout (->
				GetByUsername(user.username).then (duplicateUser) ->
					if duplicateUser != undefined
						deferred.resolve
							success: false
							message: 'Username "' + user.username + '" is already taken'
					else
						users = getUsers()

						lastUser = users[users.length - 1] or id: 0
						user.id = lastUser.id + 1

						users.push user
						setUsers users
						deferred.resolve success: true
			), 1000

			return deferred.promise

		Update = (user) ->
			deferred = $q.defer()

			users = getUsers()

			i = 0
			while i < users.length
				if users[i].id == user.id
					users[i] = user
					break
				i++

			setUsers users
			deferred.resolve()

			return deferred.promise

		Delete = (id) ->
			deferred = $q.defer();

			users = getUsers();
			i = 0
			while i < users.length
				user = users[i]
				if user.id == id
					users.splice i, 1
					break
				i++

			setUsers users
			deferred.resolve()

			return deferred.promise

		getUsers = () ->
			if !localStorage.users
				localStorage.users = JSON.stringify([])

			return JSON.parse localStorage.users

		setUsers = (users) ->
			localStorage.users = JSON.stringify users

		service.GetAll = GetAll
		service.GetById = GetById
		service.GetByUsername = GetByUsername
		service.Create = Create
		service.Update = Update
		service.Delete = Delete

		return service

	]