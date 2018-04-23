# Service for the listing of Apps on the Markeplace
# MnoeMarketplace.getList()

# .getApps()
# => GET /mnoe/jpi/v1/marketplace
# Return the list off apps and categories
#   {categories: [], apps: []}
angular.module 'mnoEnterpriseAngular'
  .service 'MnoeMarketplace', ($log, MnoeApiSvc, MnoeOrganizations, MnoeFullApiSvc) ->
    _self = @

    # Using this syntax will not trigger the data extraction in MnoeApiSvc
    # as the /marketplace payload isn't encapsulated in "{ marketplace: categories {...}, apps {...} }"
    marketplacePromises = []
    @getMarketplace = ->
      params = {organization_id: MnoeOrganizations.selectedId}
      paramsKey = JSON.stringify(params)
      return marketplacePromises[paramsKey] if marketplacePromises[paramsKey]?
      marketplacePromises[paramsKey] = MnoeApiSvc.oneUrl('/marketplace').get(params)

    productsPromise = []
    @getProducts = ->
      params = {organization_id: MnoeOrganizations.selectedId}
      paramsKey = JSON.stringify(params)
      return productsPromise[paramsKey] if productsPromise[paramsKey]?
      productsPromise[paramsKey] = MnoeApiSvc.oneUrl('/products').get(params).then(
        (response) ->
          response.plain().products
      )

    # Find a product using its id or nid
    @findProduct = ({id = null, nid = null}) ->
      _self.getProducts().then(
        (response) ->
          _.find(response.products, (a) -> a.id == id || a.nid == nid)
      )

    @getProduct = (productId) ->
      MnoeApiSvc.one('/products', productId).get()

    @getReview = (appId, reviewId) ->
      MnoeApiSvc.one('marketplace', appId).one('app_reviews', parseInt(reviewId)).get()

    @getReviews = (appId, limit, offset, sort) ->
      params = ({order_by: sort, limit: limit, offset: offset})
      MnoeFullApiSvc.one('marketplace', appId).all('app_feedbacks').getList(params)

    @getQuestions = (appId, limit, offset, search) ->
      params = ({limit: limit, offset: offset, search: search})
      MnoeFullApiSvc.one('marketplace', appId).all('app_questions').getList(params)

    @addAppReview = (appId, data) ->
      payload = {app_feedback: data}
      MnoeFullApiSvc.one('marketplace', appId).post('/app_feedbacks', payload).then(
        (response) ->
          app_review = response.data.plain()
          app_review
      ).finally(-> marketplacePromise = null)

    @editReview = (appId, feedback_id, feedback) ->
      payload = feedback
      MnoeFullApiSvc.one('marketplace', appId).one('/app_feedbacks', feedback_id).patch(payload).then(
        (response) ->
          app_review = response.data.plain()
          app_review
      )

    @deleteReview = (appId, feedback_id) ->
      MnoeFullApiSvc.one('marketplace', appId).one('/app_feedbacks', feedback_id).remove().then(
        (response) ->
          app_review = response.data.plain()
          app_review
      ).finally(-> marketplacePromise = null)

    @addAppReviewComment = (appId, data) ->
      payload = {app_comment: data}
      MnoeFullApiSvc.one('marketplace', appId).post('/app_comments', payload).then(
        (response) ->
          app_comment = response.data.plain()
          app_comment
      )

    @editComment = (appId, comment_id, comment) ->
      payload = {app_comment: comment}
      MnoeFullApiSvc.one('marketplace', appId).one('/app_comments', comment_id).patch(payload).then(
        (response) ->
          app_comment = response.data.plain()
          app_comment
      )

    @deleteComment = (appId, comment_id) ->
      MnoeFullApiSvc.one('marketplace', appId).one('/app_comments', comment_id).remove().then(
        (response) ->
          app_comment = response.data.plain()
          app_comment
      )

    @addAppQuestion = (appId, data) ->
      payload = {app_question: data}
      MnoeFullApiSvc.one('marketplace', appId).post('/app_questions', payload).then(
        (response) ->
          app_question = response.data.plain()
          app_question
      )

    @editQuestion = (appId, question_id, question) ->
      payload = question
      MnoeFullApiSvc.one('marketplace', appId).one('/app_questions', question_id).patch(payload).then(
        (response) ->
          app_question = response.data.plain()
          app_question
      )

    @deleteQuestion = (appId, question_id) ->
      MnoeFullApiSvc.one('marketplace', appId).one('/app_questions', question_id).remove().then(
        (response) ->
          app_question = response.data.plain()
          app_question
      )

    @addAppQuestionAnswer = (appId, data) ->
      payload = {app_answer: data}
      MnoeFullApiSvc.one('marketplace', appId).post('/app_answers', payload).then(
        (response) ->
          app_answer = response.data.plain()
          app_answer
      )

    @editAnswer = (appId, answer_id, answer) ->
      payload = answer
      MnoeFullApiSvc.one('marketplace', appId).one('/app_answers', answer_id).patch(payload).then(
        (response) ->
          app_answer = response.data.plain()
          app_answer
      )

    @deleteAnswer = (appId, answer_id) ->
      MnoeFullApiSvc.one('marketplace', appId).one('/app_answers', answer_id).remove().then(
        (response) ->
          app_answer = response.data.plain()
          app_answer
      )

    return @
