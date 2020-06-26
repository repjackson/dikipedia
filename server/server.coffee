Docs.allow
    insert: (user_id, doc) -> true
    update: (user_id, doc) -> true
    # user_id is doc._author_id
    remove: (user_id, doc) -> false
        # user = Meteor.users.findOne user_id
        # if user.roles and 'admin' in user.roles
        #     true
        # else
        #     user_id is doc._author_id
# Facts.setUserIdFilter(()->true);

Meteor.publish 'doc', (doc_id)->
    Docs.find
        _id:doc_id

Meteor.publish 'term', (title)->
    Terms.find
        title:title

Meteor.publish 'terms', (selected_tags, searching, query)->
    # console.log 'selected tags looking for terms', selected_tags
    # console.log 'looking for tags', Tags.find().fetch()
    Terms.find
        image:$exists:true
        title:$in:selected_tags



Meteor.publish 'tag_results', (
    selected_tags
    selected_emotions
    query
    dummy
    )->
    # console.log 'dummy', dummy
    console.log 'selected tags', selected_tags
    console.log 'query', query

    self = @
    match = {}

    match.model = 'wikipedia'
    # console.log 'query length', query.length
    # if query
    if query and query.length > 1
        console.log 'searching query', query
        #     # match.tags = {$regex:"#{query}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
        #
        Terms.find {
            title: {$regex:"#{query}"}
            # title: {$regex:"#{query}", $options: 'i'}
        },
            sort:
                count: -1
            limit: 5
        # tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "tags": 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: "$tags", count: $sum: 1 }
        #     { $match: _id: $nin: selected_tags }
        #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 42 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]

    else
        # unless query and query.length > 2
        # if selected_tags.length > 0 then match.tags = $all: selected_tags

        if selected_tags.length > 0
            match.tags = $all: selected_tags
        # else
        #     # unless selected_domains.length > 0
        #     #     unless selected_subreddits.length > 0
        #     #         unless selected_subreddits.length > 0
        #     #             unless selected_emotions.length > 0
        #     match.tags = $all: ['dao']
        # console.log 'match for tags', match
        if selected_emotions.length > 0
            match.max_emotion_name = $all: selected_emotions
        console.log 'match for tags', match


        agg_doc_count = Docs.find(match).count()
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $match: count: $lt: agg_doc_count }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        tag_cloud.forEach (tag, i) =>
            # console.log 'queried tag ', tag
            # console.log 'key', key
            self.added 'tags', Random.id(),
                title: tag.name
                count: tag.count
                # category:key
                # index: i
        # console.log doc_tag_cloud.count()


        emotion_cloud = Docs.aggregate [
            { $match: match }
            { $project: "max_emotion_name": 1 }
            # { $unwind: "$max_emotion_name" }
            { $group: _id: "$max_emotion_name", count: $sum: 1 }
            { $match: _id: $nin: selected_emotions }
            # { $match: count: $lt: agg_doc_count }
            # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 5 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        emotion_cloud.forEach (emotion, i) =>
            # console.log 'queried emotion ', emotion
            # console.log 'key', key
            self.added 'emotion_results', Random.id(),
                title: emotion.name
                count: emotion.count
                # category:key
                # index: i
        # console.log doc_tag_cloud.count()

        self.ready()

Meteor.publish 'doc_results', (
    selected_tags
    selected_emotions
    )->
    # console.log 'got selected tags', selected_tags
    # else
    self = @
    match = {model:'wikipedia'}
    # if selected_tags.length > 0
    # console.log date_setting

    if selected_tags.length > 0
        # if selected_tags.length is 1
        #     console.log 'looking single doc', selected_tags[0]
        #     found_doc = Docs.findOne(title:selected_tags[0])
        #
        #     match.title = selected_tags[0]
        # else
        match.tags = $all: selected_tags
    # else
        # unless selected_domains.length > 0
        #     unless selected_subreddits.length > 0
        #         unless selected_subreddits.length > 0
        #             unless selected_emotions.length > 0
        # match.tags = $all: ['dao']
    if selected_emotions.length > 0
        match.max_emotion_name = $all: selected_emotions

    # else
    #     match.tags = $nin: ['wikipedia']
    #     sort = '_timestamp'
    #     # match. = $ne:'wikipedia'
    # console.log 'doc match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:
            points:-1
            ups:-1
        limit:10
