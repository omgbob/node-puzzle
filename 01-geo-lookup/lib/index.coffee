fs = require 'fs'


GEO_FIELD_MIN = 0
GEO_FIELD_MAX = 1
GEO_FIELD_COUNTRY = 2


exports.ip2long = (ip) ->
  ip = ip.split '.', 4
  return +ip[0] * 16777216 + +ip[1] * 65536 + +ip[2] * 256 + +ip[3]


gindex = []
exports.load = ->
  data = fs.readFileSync "#{__dirname}/../data/geo.txt", 'utf8'
  data = data.toString().split '\n'

  for line in data when line
    line = line.split '\t'
    # GEO_FIELD_MIN, GEO_FIELD_MAX, GEO_FIELD_COUNTRY
    gindex.push [+line[0], +line[1], line[3]]

  # sort the list by GEO_FIELD_MIN
  gindex.sort (a, b) ->
    return a[GEO_FIELD_MIN] - b[GEO_FIELD_MIN]

normalize = (row) -> country: row[GEO_FIELD_COUNTRY]


exports.lookup = (ip) ->
  return -1 unless ip

  find = this.ip2long ip

  # run a binary search on gindex using the long format of the search ip
  result = binarySearch find

  # search returns an array index of the result if found, or -1 if not
  if result > -1
    return normalize gindex[result]

  return null

# binary search function that checks if the search value falls within the
# range of each eleemnt in gindex
binarySearch = (search) ->

  minIndex = 0
  maxIndex = gindex.length - 1

  while minIndex <= maxIndex
    currIndex = Math.floor (minIndex + maxIndex) / 2
    currEl = gindex[currIndex]

    if currEl[GEO_FIELD_MAX] < search
      minIndex = currIndex + 1
    else if currEl[GEO_FIELD_MIN] > search
      maxIndex = currIndex - 1
    else
      return currIndex

  return -1
