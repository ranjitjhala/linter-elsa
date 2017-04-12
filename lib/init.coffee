{BufferedProcess, CompositeDisposable} = require "atom"
{Process}                              = require "process"

takeAfter = (str, needle) ->
  i = str.indexOf(needle)
  return str unless (0 <= i)
  str.substring(i + needle.length)

jsonErrors = (fp, message) ->
  console.log(message)
  return [] unless message?
  result = takeAfter(message, 'RESULT')
  console.log(result)
  errors = try JSON.parse result
  return [] unless errors?
  console.log("jsonErrors")
  console.log(errors)
  errors.map (err) ->
    type: 'Error',
    text: err.message,
    filePath: fp,
    range: [
      # Atom expects ranges to be 0-based
      [err.start.line - 1, err.start.column - 1],
      [err.stop.line  - 1, err.stop.column  - 1]
    ]

module.exports =
  config:
    elsaExecutablePath:
      title: "The elsa executable path."
      type: "string"
      default: "elsa"

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe "linter-elsa.elsaExecutablePath",
      (executablePath) =>
        @executablePath = executablePath

  deactivate: ->
    @subscriptions.dispose()

  provideLinter: ->
    provider =
      grammarScopes: ["source.haskell"]
      scope: "file" # or "project"
      lintOnFly: true # must be false for scope: "project"
      lint: (textEditor) =>
        return new Promise (resolve, reject) =>
          filePath = textEditor.getPath()
          message  = []
          # console.log ("filePath: " + filePath)
          command = @executablePath
          args    = [ "--json", filePath ]
          # console.warn(command, args)
          process = new BufferedProcess
            command: command
            args: args
            stderr: (data) ->
              message.push data
            stdout: (data) ->
              message.push data
            exit: (code) ->
              info = message.join("\n")
              errs = jsonErrors(filePath, info)
              console.log(errs)
              resolve errs

          process.onWillThrowError ({error,handle}) ->
            console.error("Failed to run", command, args, ":", message)
            reject "Failed to run #{command} with args #{args}: #{error.message}"
            handle()
