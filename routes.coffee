Wikiviews = require 'wikiviews'
Sanitize = require "sanitize-filename"
Helpers = require './helpers'

# Holds all the jobs in progress
jobs = {}

# A function that takes an express app object and adds routes to it
module.exports = (app) ->
  # Renders the landing page
  app.get '/', (req, res) ->
    res.render 'landing'

  # Adds a new background job for a given article, start and end month.
  # If everything goes well, it will return (in JSON) the job ID
  # of the job created, to be later checked with GET /job/:jobid
  app.post '/', (req, res) ->
    article = req.body.article
    start = Helpers.getMonthObject(req.body.start)
    end = Helpers.getMonthObject(req.body.end)

    # Change the start and end dates if required to be
    # after wikipedia's creation date, and make sure that
    # the end month is not before the start month
    start.year = Helpers.getInRange(start.year, 2001, 2015)
    end.year = Helpers.getInRange(end.year, start.year, 2015)
    if end.year == start.year
      Helpers.getInRange(end.month, start.month, 2015)

    startStr = "#{start.year}#{Helpers.padNumber(start.month, 2)}"
    endStr = "#{end.year}#{Helpers.padNumber(end.month, 2)}"

    # Create the job with a random job id
    job =
      id: Helpers.randomString(5)
      status: 'pending'
      article: article
      start: [start.year, start.month].join("-")
      end: [end.year, end.month].join("-")

    jobs[job.id] = job

    try 
      Wikiviews(article, startStr, "#{end.year}#{end.month}", (data) ->
        # Write the result to a CSV
        filename = Sanitize "#{article}-#{startStr}-#{endStr}.csv"
        filepath = "./public/data/#{filename}"
        Helpers.writeCSV(data, filepath)

        # Update the job
        job.status = 'completed'
        job.result = {filepath: "/data/#{filename}"}

        console.log "Job #{job.id} finished, CSV saved at #{filepath}"
      )
    catch err # Something went wrong, assume the worst
      console.log "Job #{job.id} failed: #{err}"
      job.status = 'failed'
      job.result = {err: toString err}

    # Return the job object
    res.send JSON.stringify(job)

  # Gets a job object
  app.get '/jobs/:jobid', (req, res) ->
    jobID = req.params.jobid
    res.send jobs[jobID]

