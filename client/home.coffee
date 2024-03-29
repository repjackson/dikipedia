@selected_tags = new ReactiveArray []
@selected_emotions = new ReactiveArray []

Template.admin.helpers
    doc_count: ->
        Docs.find().count()


Template.agg_tag.onCreated ->
    # console.log @
    @autorun => @subscribe 'term', @data.title

Template.home.onCreated ->
    Session.setDefault('current_query', '')
    Session.setDefault('dummy', true)
    @autorun => @subscribe 'terms',
        selected_tags.array()
    @autorun => @subscribe 'tag_results',
        selected_tags.array()
        selected_emotions.array()
        Session.get('current_query')
        Session.get('dummy')
    @autorun => @subscribe 'doc_results',
        selected_tags.array()
        selected_emotions.array()

Template.tone.events
    # 'click .upvote_sentence': ->
    'click .tone_item': ->
        # console.log @
        doc_id = Docs.findOne()._id
        if @weight is 3
            Meteor.call 'reset_sentence', doc_id, @, ->
        else
            Meteor.call 'upvote_sentence', doc_id, @, ->

Template.agg_tag.helpers
    term: ->
        # console.log @
        Terms.findOne
            title:@title
    tag_result_class: ->
        # console.log 'active_term class', @
        term =
            Terms.findOne title:@title
        if term
            # console.log 'found term emotion', term
            if term.max_emotion_name
                if term.max_emotion_name is 'anger'
                    'red'
                else if term.max_emotion_name is 'sadness'
                    'blue'
                else if term.max_emotion_name is 'joy'
                    'green'
                else if term.max_emotion_name is 'disgust'
                    'orange'
                else if term.max_emotion_name is 'fear'
                    'grey'


Template.agg_tag.events
    'click .result': (e,t)->
        Meteor.call 'log_term', @title, ->
        selected_tags.push @title

        $('#search').val('')
        Meteor.call 'call_wiki', @title, ->
        Meteor.call 'calc_term', @title, ->
        Meteor.call 'omega', @title, ->
        Session.set('current_query', '')
        Session.set('searching', false)

    # 'click .call_visual': ->
    #     Meteor.call 'call_visual', @_id, (err,res)->
    #         console.log res

    'click .select_query': ->
        selected_tags.push @title
        $('#search').val('')
        Session.set('current_query', '')
        Session.set('searching', false)

Template.home.events
    'click .set_today': -> Session.set('date_setting','today')
    'click .set_yesterday': -> Session.set('date_setting','yesterday')
    'click .set_this_month': -> Session.set('date_setting','set_this_month')
    'click .set_all_time': -> Session.set('date_setting','all_time')
    'click .unselect_tag': ->
        selected_tags.remove @valueOf()
        console.log selected_tags.array()
        if selected_tags.array().length is 1
            Meteor.call 'call_wiki', selected_tags.array(), ->
            Meteor.call 'calc_term', @title, ->


    'click .select_emotion': ->
        selected_emotions.push @title
    'click .unselect_emotion': ->
        selected_emotions.remove @valueOf()
        # console.log selected_tags.array()

    # 'click .refresh_tags': ->

    'click .clear_selected_tags': ->
        Session.set('current_query','')
        selected_tags.clear()
    # 'keyup #search': _.throttle((e,t)->
    'keyup #search': (e,t)->
        query = $('#search').val()
        # Session.set('current_query', query)
        # if query.length > 0
        # console.log Session.get('current_query')
        if e.which is 13
            search = $('#search').val().trim().toLowerCase()
            if search.length > 0
                selected_tags.push search
                console.log 'search', search

                Meteor.call 'call_wiki', search, =>
                    Meteor.call 'calc_term', @title, ->
                    Meteor.call 'omega', @title, ->

                Meteor.call 'log_term', search, ->

                $('#search').val('')
                Session.set('current_query', '')
                # Meteor.setTimeout ->
                #     Session.set('dummy', !Session.get('dummy'))
                # , 6000
    # , 200)

    # 'keydown #search': _.throttle((e,t)->
    #     if e.which is 8
    #         search = $('#search').val()
    #         if search.length is 0
    #             last_val = selected_tags.array().slice(-1)
    #             console.log last_val
    #             $('#search').val(last_val)
    #             selected_tags.pop()
    #             Meteor.call 'search_reddit', selected_tags.array(), ->
    # , 1000)

    'click .reconnect': -> Meteor.reconnect()

    'click .toggle_tag': (e,t)-> selected_tags.push @valueOf()

    'keyup .add_tag': (e,t)->
        # Session.set('current_query', query)
        # console.log Session.get('current_query')
        if e.which is 13
            tag = $(e.currentTarget).closest('.add_tag').val().trim().toLowerCase()
            console.log 'tag', tag
            # search = $('#search').val()
            if tag.length > 0
                # selected_tags.push search
                Docs.update @_id,
                    $addToSet:
                        tags:tag
                        user_tags:tag
                $(e.currentTarget).closest('.add_tag').val('')
                # # console.log 'search', search
                Meteor.call 'call_wiki', tag, =>
                    Meteor.call 'log_term', tag, ->

    'click .print_me': (e,t)->
        console.log @


    'click .call_watson': ->
        if @wiki_html
            dom = document.createElement('textarea')
            # dom.innerHTML = doc.body
            dom.innerHTML = @wiki_html.content
            console.log 'innner html', dom.value
            # return dom.value
            Docs.update @_id,
                $set:
                    parsed_wiki_html:dom.value
        Meteor.call 'call_watson', @_id, 'url', 'url', ->
        # Meteor.call 'agg_omega', ->





Template.home.helpers
    active_term_class: ->
        # console.log 'active_term class', @
        term =
            Terms.findOne title:@valueOf()
        if term
            # console.log 'found term emotion', term
            if term.max_emotion_name
                if term.max_emotion_name is 'anger'
                    'red'
                else if term.max_emotion_name is 'sadness'
                    'blue'
                else if term.max_emotion_name is 'joy'
                    'green'
                else if term.max_emotion_name is 'disgust'
                    'orange'
                else if term.max_emotion_name is 'fear'
                    'grey'


    curent_date_setting: -> Session.get('date_setting')

    background_style: ->
        "background-image:url(#{@image})"

    term_icon: ->
        console.log @
    doc_results: ->
        current_docs = Docs.find()
        # if Session.get('selected_doc_id') in current_docs.fetch()
        # console.log current_docs.fetch()
        # Docs.findOne Session.get('selected_doc_id')
        doc_count = Docs.find().count()
        # if doc_count is 1
        Docs.find({})


    is_loading: -> Session.get('is_loading')

    tag_result_class: ->
        # ec = omega.emotion_color
        # console.log @
        # console.log omega.total_doc_result_count
        total_doc_result_count = Docs.find({}).count()
        console.log total_doc_result_count
        percent = @count/total_doc_result_count
        # console.log 'percent', percent
        # console.log typeof parseFloat(@relevance)
        # console.log typeof (@relevance*100).toFixed()
        whole = parseInt(percent*10)+1
        # console.log 'whole', whole

        # if whole is 0 then "#{ec} f5"
        if whole is 0 then "f5"
        else if whole is 1 then "f11"
        else if whole is 2 then "f12"
        else if whole is 3 then "f13"
        else if whole is 4 then "f14"
        else if whole is 5 then "f15"
        else if whole is 6 then "f16"
        else if whole is 7 then "f17"
        else if whole is 8 then "f18"
        else if whole is 9 then "f19"
        else if whole is 10 then "f20"


    connection: ->
        # console.log Meteor.status()
        Meteor.status()
    connected: -> Meteor.status().connected

    emotion_results: ->
        Emotion_results.find({},
            limit:10
            sort:
                count:-1
        )
    selected_emotions: -> selected_emotions.array()

    agg_tags: ->
        # console.log Session.get('current_query')
        if Session.get('current_query').length > 0
            Terms.find({},
                limit:5
                sort:
                    count:-1
            )
        else
            # doc_count = Docs.find().count()
            # console.log 'doc count', doc_count
            # if doc_count < 3
            #     Tags.find({count: $lt: doc_count})
            # else
            Tags.find({})

    result_class: ->
        if Template.instance().subscriptionsReady()
            ''
        else
            'disabled'

    selected_tags: -> selected_tags.array()

    selected_tags_plural: -> selected_tags.array().length > 1

    searching: -> Session.get('searching')

    more_than_four: -> Docs.find().count() > 4
    one_result: ->
        Docs.find().count() is 1

    docs: ->
        # if selected_tags.array().length > 0
        cursor =
            Docs.find {
                model:'wikipedia'
            },
                sort:
                    points:-1
                    ups:-1
                # limit:10
        # console.log cursor.fetch()
        cursor

    term: ->
        # console.log @
        Terms.findOne
            title:@valueOf()

    home_subs_ready: ->
        Template.instance().subscriptionsReady()
    #
    # home_subs_ready: ->
    #     if Template.instance().subscriptionsReady()
    #         Session.set('global_subs_ready', true)
    #     else
    #         Session.set('global_subs_ready', false)
