Meteor.methods
    call_wiki: (query)->
        console.log 'calling wiki', query
        # term = query.split(' ').join('_')
        # term = query[0]
        term = query
        HTTP.get "https://en.wikipedia.org/api/rest_v1/page/html/#{term}",(err,response)=>
            # console.log response.data
            if err
                console.log 'error finding wiki article for ', query
                # console.log err
            else
                console.log response
                # console.log 'response'
                found_doc =
                    Docs.findOne
                        url: "https://en.wikipedia.org/wiki/#{term}"
                if found_doc
                    console.log 'found wiki doc for term', term
                    # console.log 'found wiki doc for term', term, found_doc
                    Docs.update found_doc._id,
                        $set:
                            wiki_html:response
                    # console.log 'found wiki doc', found_doc
                    # Meteor.call 'call_watson', found_doc._id, 'url','url', ->
                else
                    new_wiki_id = Docs.insert
                        title: query
                        tags:[query]
                        wiki_html:response
                        source: 'wikipedia'
                        model:'wikipedia'
                        url:"https://en.wikipedia.org/wiki/#{term}"
                    Meteor.call 'call_watson', new_wiki_id, 'url','url', ->
