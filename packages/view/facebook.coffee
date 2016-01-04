limiter = Npm.require 'limiter'
request = Npm.require 'request'
async = Npm.require 'async'
util = Npm.require 'util'
urlModule = Npm.require 'url'

class FacebookApiRequest
  @FACEBOOK_THROTTLE_REQUESTS: 600
  @FACEBOOK_THROTTLE_INTERVAL: 600 * 1000 # ms
  @CONCURRENCY: 50

  @_instances: {}

  # Warn only once per 10 s.
  @queueWarning: _.throttle _.bind(->
    console.warn "Queue has grown to #{@_queue.length()} elements."
  , @), 10 * 1000 # ms

  @_worker: ({instance, url, options}, callback) ->
    # Queue is really long.
    @queueWarning() if @_queue.length() > 1000

    options ?= {}
    instance._facebookRequest url, options, callback

  @_queue: async.queue _.bind(@_worker, @), @CONCURRENCY

  constructor: (@instanceId, @accessToken) ->
    return @constructor._instances[@accessToken] if @accessToken of @constructor._instances

    @constructor._instances[@accessToken] = @

    @_limiter = new (limiter.RateLimiter)(@constructor.FACEBOOK_THROTTLE_REQUESTS, @constructor.FACEBOOK_THROTTLE_INTERVAL)

    # Warn only once per 10 s.
    @purgeWarning = _.throttle @purgeWarning, 10 * 1000 # ms
    @purgedWarning = _.throttle @purgedWarning, 10 * 1000 # ms
    @limiterWarning = _.throttle @limiterWarning, 10 * 1000 # ms

  purgeWarning: (requestsCount) ->
    console.warn "[#{@instanceId}] Rate limit hit, purging #{requestsCount} requests, #{@constructor._queue.length()} in the queue."

  purgedWarning: (remainingRequestsCount) ->
    console.warn "[#{@instanceId}] Purged requests, #{remainingRequestsCount} remaining, #{@constructor._queue.length()} in the queue."

  limiterWarning: (remainingRequestsCount) ->
    console.warn "[#{@instanceId}] Limiter has only #{remainingRequestsCount} requests left, #{@constructor._queue.length()} in the queue."

  checkRemainingRequests: (remainingRequests) ->
    @limiterWarning remainingRequests if remainingRequests < 10 and @constructor._queue.length() > 0

  _facebookRequest: (url, {qs, limit, payload}, callback) ->
    qs =  _.extend {}, (qs or {}),
      access_token: @accessToken

    if 'limit' not of qs and _.isFinite limit
      # If limit === 0 we want to fetch multiple pages, everything, so we go for 5000 per page.
      qs.limit = limit or 5000

    url = urlModule.resolve 'https://graph.facebook.com', url

    page = (currentUrl, callback) =>
      @_limiter.removeTokens 1, (error, remainingRequests) =>
        # We are requesting just one token, and 1 < FACEBOOK_THROTTLE_REQUESTS. So an error should never happen.
        assert not error, error

        @checkRemainingRequests remainingRequests

        request
          url: currentUrl
          method: if payload then 'POST' else 'GET'
          form: payload
          qs: qs
        ,
          (error, res, body) =>
            if error or res?.statusCode isnt 200
              try
                body = JSON.parse body

              if body?.error?.code is 613
                # We have to purge requests, we hit rate limit. We purge half each time (to allow faster recovery).
                tokensToPurge = parseInt(@_limiter.tokenBucket.content / 2) or 1
                @purgeWarning tokensToPurge

                @_limiter.removeTokens tokensToPurge, (error, remainingRequests) =>
                  # We are requesting less than FACEBOOK_THROTTLE_REQUESTS tokens. So an error should never happen.
                  assert not error, error

                  @purgedWarning remainingRequests

                  # Retry.
                  page currentUrl, callback
                  return

                return

              return callback "Facebook API request (#{currentUrl}) error, error: #{error}, status: #{res?.statusCode}, body: #{util.inspect body, depth: 10}"

            try
              body = JSON.parse body
            catch error
              return callback "Facebook API request (#{currentUrl}) parse error: #{error}, body: #{util.inspect body, depth: 10}"

            # If limit === 0 we want to fetch multiple pages, everything, so we go for next page, if available.
            if limit is 0 and body.data and body.data.length isnt 0 and body.paging and body.paging.next
              page body.paging.next, (error, nextBody) =>
                return callback error if error

                # We take only body.data from next pages.
                body.data.push.apply body.data, nextBody.data

                callback null, body
                return

            else
              callback null, body
              return

    page url, callback
    return

  requestAsync: (url, options, callback) ->
    @constructor._queue.push
      instance: @
      url: url
      options: options
    ,
      callback
    return

  request: (url, options) ->
    blocking(@, @requestAsync) url, options
