$(document).ready ->
  localStorage["jobs"] = "" unless localStorage.jobs
  updateJobs()
  setTimeout renderJobs, 1000

  $("form").ajaxForm(
    dataType: "json"
    success: (job) ->
      console.log "Created job #{job.id}"
      addJob(job)
      renderJobs()
  )

jobs = {}

addJob = (job) ->
  localStorage["jobs"] += " #{job.id}"
  jobs[job.id] = job

renderJobs = ->
  return if Object.keys(jobs).length == 0

  $("div#jobs").fadeIn(500)

  tableBody = ""
  for id, job of jobs
    tableBody += "<tr>"
    tableBody += "<td>#{job.article}</td>"
    tableBody += "<td>#{job.start}</td>"
    tableBody += "<td>#{job.end}</td>"
    if job.status == "pending"
      tableBody += "<td>Processing...</td>"
    else
      tableBody += "<td><a href='#{job.result.filepath}'>Download CSV</a></td>"
    tableBody += "</tr>"

  $("table#jobs tbody").html tableBody

getJob = (id) ->
  $.get "/jobs/#{id}", (job) ->
    # Remove jobIDs that are not found
    if job == ""
      jobIDs = localStorage["jobs"].split(" ")
      badID = id
      newJobIDs = []
      for id in jobIDs
        newJobIDs.push id unless id == badID
      localStorage["jobs"] = newJobIDs

    jobs[id] = job

updateJobs = ->
  jobIDs = localStorage["jobs"].split(" ")
  for id in jobIDs
    getJob(id) if id.length > 1

setInterval updateJobs, 5000
setInterval renderJobs, 2500
