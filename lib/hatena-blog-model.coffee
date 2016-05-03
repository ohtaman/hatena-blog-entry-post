blog = require 'hatena-blog-api'
fotolife = require 'hatena-fotolife-api'

module.exports = class HatenaBlogPost
  constructor: ->
    @isPublic = null
    @entryTitle = ""
    @entryBody = ""
    @categories = []

  getHatenaId: ->
    atom.config.get("hatena-blog.hatenaId")

  getBlogId: ->
    atom.config.get("hatena-blog.blogId")

  getApiKey: ->
    atom.config.get("hatena-blog.apiKey")

  uploadImage: (@image) ->
    client = fotolife(
      type: 'wsse'
      username: @getHatenaId()
      apikey: @getApiKey()
    )

    options =
      title: image
      file: image

    # insert loading text
    editor = atom.workspace.getActiveTextEditor()
    range = editor.insertText('Uploading...')

    client.create options, (err, res) ->
      if err
        markdown = "#{err.statusCode}"
        editor.setTextInBufferRange(range[0], markdown)
      else
        console.log res.entry
        imageurl = res.entry["hatena:imageurl"]._
        markdown = "![](#{imageurl})"
        editor.setTextInBufferRange(range[0], markdown)

  postEntry: (callback) ->
    client = blog(
      type: 'wsse'
      username: @getHatenaId()
      blogId:   @getBlogId()
      apikey:   @getApiKey()
    )

    client.create {
      title: @entryTitle
      content: @entryBody

      categories: @categories
      draft: !@isPublic
    }, (err, res) ->
      if err
        callback err
      else
        callback res
      return
