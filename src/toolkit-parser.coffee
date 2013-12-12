ramlParser = require 'raml-parser'
class ToolkitParser
  constructor: (data, @logger)->
    @logger.debug "[ToolkitParser.constructor] Building ToolkitParser instance"
    @raml = data
    @resources = {}
    @_generateResources()

  getResources: ->
    @logger.debug "[ToolkitParser.getResources]Getting Resources"
    @resources

  getResourcesList: ->
    @logger.debug "[ToolkitParser.getResourcesList]Getting Resources List"
    resourceList = []
    for key,resource of @resources
      @logger.debug "[ToolkitParser.getResourcesList]Building Resources Information for resource #{key}"
      resourceCopy = clone resource
      resourceCopy.uri = key.replace(/{(.*?)}/g,":$1")
      resourceList.push resourceCopy
    resourceList

  getProtocols: ->
    @raml.protocols

  getSecuritySchemes: ->
    @raml.securitySchemes

  getRaml: ->
    @raml

  _generateResources: ->
    @logger.debug '[ToolkitParser._generateResources]Getting Resources from RAML file'
    @_processResource x, @resources for x in @raml.resources

  _processResource: (resource, resourceMap, uri) ->
    if not uri?
      uri = resource.relativeUri

    @logger.debug "[ToolkitParser._processResource]Getting Resource Information from #{ uri }"

    if resource.resources?
      this._processResource x, resourceMap, uri + x.relativeUri for x in resource.resources

    resourceMap[uri] = clone resource
    delete resourceMap[uri].relativeUri
    delete resourceMap[uri]?.resources



clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  if obj instanceof Date
    return new Date(obj.getTime())

  if obj instanceof RegExp
    flags = ''
    flags += 'g' if obj.global?
    flags += 'i' if obj.ignoreCase?
    flags += 'm' if obj.multiline?
    flags += 'y' if obj.sticky?
    return new RegExp(obj.source, flags)

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone obj[key]

  return newInstance


exports.loadRaml = (filePath, loggerObj, callback) ->
  loggerObj.debug "[toolkit-parser.loadRaml]Parsing RAML file #{filePath}"
  ramlParser.loadFile(filePath).then(
    (data) ->
      loggerObj.debug "[toolkit-parser.loadRaml]RAML file parsed successful!!!!!"
      callback(new ToolkitParser data, loggerObj)
    ,(error) ->
      loggerObj.debug "[toolkit-parser.loadRaml]Error parsing: #{error}"
      new Error "Error parsing: #{error}"
  )
