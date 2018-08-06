do (ko, $=jQuery) ->

  ko.observableArray.fn.contains = (obj) ->
    @indexOf(obj) != -1

  ko.observableArray.fn.isEmpty = (obj) ->
    this().length == 0

  # Valid names: 'added', 'deleted', 'retained'
  ko.observableArray.fn.subscribeChange = (status, callback) ->
    previousValue = null

    beforeChange = (oldValue) ->
      previousValue = oldValue.slice(0)

    afterChange = (latestValue) ->
      for {status, value} in ko.utils.compareArrays(previousValue, latestValue)
        callback?(value) if status == 'name'
      previousValue = null

    @subscribe(beforeChange, undefined, 'beforeChange')
    @subscribe(afterChange)

  ko.observableArray.fn.subscribeAdd = (callback) ->
    @subscribeChange('added', callback)

  ko.observableArray.fn.subscribeRemove = (callback) ->
    @subscribeChange('deleted', callback)

  # http://www.knockmeout.net/2012/05/quick-tip-skip-binding.html
  ko.bindingHandlers.stopBinding =
    init: ->
      controlsDescendantBindings: true
  ko.virtualElements.allowedBindings.stopBinding = true

  # For observables that need to make an XHR or similar call to compute their value
  ko.asyncComputed = (initialValue, timeout, method, obj) ->
    value = ko.observable(initialValue)

    isSetup = ko.observable(false)

    isPendingRead = true

    callAsyncMethod = ->
      method.call obj, value.peek(), value, isPendingRead
      isPendingRead = true

    asyncComputed = ko.computed
      read: ->
        val = value.peek()
        callAsyncMethod()
        val
      write: value
      deferEvaluation: true

    result = ko.computed
      read: ->
        # Causes an evaluation of computed, thereby setting up dependencies correctly
        unless isSetup()
          asyncComputed.extend(throttle: timeout)
          isSetup(true)
        value()
      write: (newValue) ->
        isSetup(true) unless isSetup()
        value(newValue)
      deferEvaluation: true

    result.isSetup = isSetup

    result.readImmediate = ->
      callAsyncMethod()
      isPendingRead = false

    originalDispose = result.dispose
    result.dispose = ->
      originalDispose()
      asyncComputed.dispose()

    result


  ko.bindingHandlers.showModal =
    init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->

    update: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
      isShown = ko.unwrap(valueAccessor())
      if isShown
        method = 'show'
      else
        method = 'hide'
      $(element).modal(method)

  ko.bindingHandlers.loadDefaultForm =
    init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
    update: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
      $el = $(element)
      if $el.data('echoforms')
        $el.echoforms('destroy')
        $el.off('echoforms:modelchange')
      options = ko.unwrap(valueAccessor())
      options.hasBeenReset = true
      methodName = options.method()
      if methodName?
        method = null
        for available in options.availableMethods
          if available.name == methodName
            method = available
            break

        if method? && available?.form?
          form = available.form
          $el.echoforms(form: form, prepopulate: options.prepopulatedFields())
          syncModel = ->
            isValid = $(this).echoforms('isValid')
            options.isValid(isValid)

            options.model = $(this).echoforms('serialize')
            options.rawModel = $(this).echoforms('serialize', prune: false)

            null
          $el.on 'echoforms:modelchange', syncModel
          syncModel.call($el)
        else
          options.isValid(true)
        options.isReadFromDefaults = true

  ko.bindingHandlers.echoform =
    init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->

    update: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
      $el = $(element)
      if $el.data('echoforms')
        $el.echoforms('destroy')
        $el.off('echoforms:modelchange')

      options = ko.unwrap(valueAccessor())
      methodName = options.method()
      if methodName?
        method = null
        for available in options.availableMethods
          if available.name == methodName
            method = available
            break
        if method? && available?.form?
          # TODO this should be set in 'options' and be sent to echoforms using "prepopulate" param.
          # EDSC-975: If the form contains an empty email address field, prepopulate it with the user's email
          if edsc.page.account
            available.form = available.form.replace('<ecs:email/>', '<ecs:email>' + edsc.page.account.email() + '</ecs:email>')
          originalForm = form = available.form
          model = if options.hasBeenReset then options.rawModelInitialValue else options.rawModel

          if model? && !options.isReadFromDefaults
            shortNameRegex = /<ecs:SUBAGENT_ID>[\s\S]*<ecs:value>(.*)<\/ecs:value>[\s\S]*<\/ecs:SUBAGENT_ID>/
            shortName = shortNameRegex.exec(model)?[1]

            form = form.replace(/(?:<instance>)(?:.|\n)*(?:<\/instance>)/, "<instance>\n#{model}\n</instance>")

          # Handle problems if the underlying form has a breaking change
          try
            $el.echoforms(form: form, prepopulate: options.prepopulatedFields())

          catch error
            console.log("Error caught rendering saved model, retrying:", error)
            form = originalForm
            $el.echoforms(form: form, prepopulate: options.prepopulatedFields())

          syncModel = ->
            isValid = $(this).echoforms('isValid')
            options.isValid(isValid)

            options.model = if options.hasBeenReset then options.modelInitialValue else $(this).echoforms('serialize')
            options.rawModel = if options.hasBeenReset then options.rawModelInitialValue else $(this).echoforms('serialize', prune: false)

            null
          $el.on 'echoforms:modelchange', syncModel
          syncModel.call($el)
        else
          options.isValid(true)
        options.isReadFromDefaults = true
      null

  ko.bindingHandlers.mapdisplay =
    init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
    update: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
      element.removeChild(element.firstChild) while element.firstChild

      bounds = ko.unwrap(valueAccessor())
      if bounds
        [min_lat, min_lng, max_lat, max_lng] = bounds
        mbr = document.createElement('div')
        mbr.className = 'access-mbr'
        borderWidth = 2
        mbr.style.top = Math.round(-max_lat + 90 - borderWidth) + 'px'
        mbr.style.left = Math.round(min_lng + 180 - borderWidth) + 'px'
        mbr.style.height = Math.round(max_lat - min_lat + 2*borderWidth) + 'px'
        mbr.style.width = Math.round(max_lng - min_lng + 2*borderWidth) + 'px'
        element.appendChild(mbr)

  ko.bindingHandlers.fadeVisible =
    init: (element, valueAccessor) ->
      # Initially set the element to be instantly visible/hidden depending on the value
      value = valueAccessor()
      $(element).toggle(ko.unwrap(value)) # Use "unwrapObservable" so we can handle values that may or may not be observable
    update: (element, valueAccessor) ->
      # Whenever the value subsequently changes, slowly fade the element in or out
      value = valueAccessor()
      if ko.unwrap(value) then $(element).fadeIn() else $(element).fadeOut()

  # Truncate utility: http://jsfiddle.net/dima_k/bZEQM/1/
  ko.bindingHandlers.truncatedText = update: (element, valueAccessor, allBindingsAccessor) ->
    originalText = ko.utils.unwrapObservable(valueAccessor())
    length = ko.utils.unwrapObservable(allBindingsAccessor().maxLength) or 100
    truncatedText = if originalText.length > length then originalText.substring(0, length) + '...' else originalText
    # updating text binding handler to show truncatedText
    ko.bindingHandlers.text.update element, ->
      truncatedText
    return

  ko.bindingHandlers.descriptionLinks =
    init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
      description = $($.parseHTML(bindingContext.$data.description))
      for el, i in description
        if el.nodeName == 'A' && el.host != window.location.host
          $(el).attr('target', '_blank')
          $(el).addClass('ext')
          description[i] = el.outerHTML
        else if el.nodeName == 'A' && el.host == window.location.host
          description[i] = $(el.outerHTML).text()
        else
          description[i] = $(el).text()

      ko.applyBindingsToNode(element, { 'html': (el for el in description).join('')}, bindingContext)