angular.module 'mnoEnterpriseAngular'
  .controller('ProvisioningDetailsCtrl', ($state, MnoeMarketplace, MnoeProvisioning, schemaForm) ->

    vm = this

    vm.form = [ "*" ]

    vm.subscription = MnoeProvisioning.getSubscription()
    vm.isEditMode = !_.isEmpty(vm.subscription.custom_data)
    vm.activeTab = vm.subscription.available_edit_actions[0]

    # The schema is contained in field vm.product.custom_schema
    #
    # jsonref is used to resolve $ref references
    # jsonref is not cyclic at this stage hence the need to make a
    # reasonable number of passes (2 below + 1 in the sf-schema directive)
    # to resolve cyclic references
    #

    vm.getSubscription = () ->
      vm.isLoading = true

      # Must pass in the active tab, as this dictates which json-schema we will receive.
      MnoeMarketplace.getProduct(vm.subscription.product.id, { editAction: vm.activeTab })
        .then((response) -> JSON.parse(response.custom_schema))
        .then((schema) -> schemaForm.jsonref(schema))
        .then((schema) -> schemaForm.jsonref(schema))
        .then((schema) ->
          vm.schema = schema
          vm.isLoading = false
          )

    vm.submit = (form) ->
      return if form.$invalid
      MnoeProvisioning.setSubscription(vm.subscription)
      $state.go('home.provisioning.confirm')

    vm.suspendable = if vm.subscription.status == 'suspended'
      'mno_enterprise.templates.dashboard.provisioning.subscription.reactivate'
    else
      'mno_enterprise.templates.dashboard.provisioning.subscription.suspend'

    vm.editButtonVisable = (editAction) ->
      _.includes(vm.subscription.available_edit_actions, editAction)


    vm.getSubscription()
    return
  )
