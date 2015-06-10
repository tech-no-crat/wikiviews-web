fs = require 'fs'
# Helper methods
module.exports =
  # Brings x in range within min and max.
  # If x is within [min..max], it returns x.
  # If x < min returns min, otherwise returns max.
  getInRange: (x, min, max) ->
    Math.max(Math.min(x, max), min) 

  # Pads a number to a given number of leading zeroes
  # Hacky: Only works for up to 5 leading zeroes
  padNumber: (num, size) ->
    ('00000' + num).substr(-size)

  # Generates a string of a specific length from a certain set of characters
  # which defaults to all alphanumeric characters
  # Adapted version of http://stackoverflow.com/questions/1349404
  randomString: (length, chars) ->
    chars = chars || 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    result = ''
    i = length
    while i > 0
      result += chars[Math.round(Math.random() * (chars.length - 1))]
      --i
    result

  # Given a string in the default HTML format (YYYY-MM),
  # it returns an object with keys 'year' and 'month'
  # containing the year and month as integers
  getMonthObject: (str) ->
    parts = str.split('-')
    return null if parts.length != 2

    # Get the raw numbers
    year = parseInt parts[0]
    month = parseInt parts[1]

    # Return only positive years and month numbers in [1..12]
    return {
      year: this.getInRange(year, 0, 2015)
      month: this.getInRange(month, 1, 12)
    }

  # Writes an object in CSV format to a filename
  # i.e. the file will contain lines of the format <key>, <value>
  writeCSV: (obj, filename) ->
    lines = []
    for key, value of obj
      lines.push "#{key}, #{value}"

    fs.writeFileSync filename, lines.join("\n")
