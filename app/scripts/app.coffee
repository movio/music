'use strict'

angular.module 'app', ['mediaPlayer', 'ngCookies']

.config ($httpProvider)->
  $httpProvider.defaults.useXDomain = true
  delete $httpProvider.defaults.headers.common['X-Requested-With']

.directive 'mvMusic', ($http, $interval, $q, $cookies)->
  restrict: 'A'
  templateUrl: 'views/player.html'
  link: (scope, element, attrs)->

    initCookies = ->
      if not $cookies.queueIp
        scope.queueIp = 'http://10.10.0.10:3000'
        $cookies.queueIp = scope.queueIp
      else
        scope.queueIp = $cookies.queueIp

      if not $cookies.streamIp
        scope.streamIp = 'http://10.10.0.10:8888'
        $cookies.streamIp = scope.streamIp
      else
        scope.streamIp = $cookies.streamIp

    scope.updateCookies = ->
      $cookies.queueIp = scope.queueIp
      $cookies.streamIp = scope.streamIp

    stop = $interval ->
      #console.table [
        #['network', 'loadPercent', 'playing']
        #[scope.mediaPlayer.network, scope.mediaPlayer.loadPercent, scope.mediaPlayer.playing]
      #]
      network = scope.mediaPlayer.network
      return if scope.mediaPlayer.playing or network is 'progress' or network is 'stalled'

      $http.jsonp(scope.queueIp + '/queue/pop?callback=JSON_CALLBACK')

        .then (data)->
          if data.data.data
            console.log 'queue data', data.data.data
            $http.get(scope.streamIp + '/info/' + data.data.data)
          else
            console.log 'empty data'
            null

        .then (data)->
          if data
            console.log 'stream data: ' + data.data.id
            scope.mediaPlayer.load({src: scope.streamIp + '/stream/' + data.data.id, type: 'audio/mpeg'}, true)

    , 8000

    scope.$on '$destroy', (event)->
      stop()

    init = ->
      initCookies()

    init()
