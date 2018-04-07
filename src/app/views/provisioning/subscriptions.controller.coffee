angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningSubscriptionsCtrl', ($q, $state, $stateParams, $uibModal, toastr, MnoeOrganizations, MnoeProvisioning, MnoeConfig, MnoConfirm, PRICING_TYPES) ->

    vm = this
    vm.isLoading = true

    vm.goToSubscription = (subscription) ->
      $state.go('home.subscription', { id: subscription.id })

    vm.cancelSubscription = (subscription, i) ->
      modalOptions =
        headerText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.title'
        bodyText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.body'
        closeButtonText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.no'
        actionButtonText: 'mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_modal.yes'
        actionCb: -> MnoeProvisioning.cancelSubscription(subscription).then(
          (response) ->
            angular.copy(response.subscription, vm.subscriptions[i])
          ->
            toastr.error('mno_enterprise.templates.dashboard.provisioning.subscriptions.cancel_error')
        )
        type: 'danger'

      MnoConfirm.showModal(modalOptions)

    orgPromise = MnoeOrganizations.get()
    subPromise = MnoeProvisioning.getSubscriptions()

    $q.all({organization: orgPromise, subscriptions: subPromise}).then(
      (response) ->
        vm.orgCurrency = response.organization.organization?.billing_currency || MnoeConfig.marketplaceCurrency()

        # If a subscription doesn't contains a pricing for the org currency, a warning message is displayed
        vm.displayCurrencyWarning = not _.every(response.subscriptions, (subscription) ->
          currencies = _.map(subscription?.product_pricing?.prices, 'currency')
          _.includes(currencies, vm.orgCurrency) || (subscription?.product_pricing?.pricing_type in PRICING_TYPES['unpriced'])
        )
        vm.subscriptions = response.subscriptions
    ).finally(-> vm.isLoading = false)

    vm.displayInfoTooltip = (subscription) ->
      return subscription.status == 'aborted'

    vm.openEditModal = (subscription) ->
      MnoeProvisioning.setSubscription({})
      $uibModal.open(
        templateUrl: 'app/views/apps/modals/edit-subscription-modal.html'
        controller: 'EditSubscriptionController'
        controllerAs: 'vm'
        resolve:
          subscription: -> subscription
      )

    return
  )
