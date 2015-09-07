###
Copyright 2013 Simon Lydell

This file is part of map-replace.

map-replace is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

map-replace is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along with map-replace. If not,
see <http://www.gnu.org/licenses/>.
###

fs          = require "fs"
escapeRegex = require "escape-regexp-component"


modify = (file, modifyFn, callback)->
	fs.readFile file, (error, contents)->
		return callback(error) if error

		try
			contents = modifyFn(contents.toString())
		catch error
			return callback(error)

		fs.writeFile file, contents, (error)->
			return callback(error) if error
			callback(null)


mapReplace = (string, map, options={})->
	if typeof map is "string"
		map = JSON.parse(map)

	if options.match
		regex = RegExp(options.match, "g" + (options.flags ? ""))

	for searchString, replacement of map
	    if options.prefix
	      replacement = replacement.replace(RegExp(escapeRegex(options.prefix), "g"), "")
		
		replace = (string)->
			string.replace(RegExp(escapeRegex(searchString), "g"), replacement)

		string =
			if regex
				string.replace(regex, replace)
			else
				replace(string)

	string


readStdin = (process, callback)->
	{stdin} = process
	stdin.resume()
	contents = ""
	stdin.on "data", (data)-> contents += data
	stdin.on "end", -> callback(contents)


module.exports = {
	modify
	mapReplace
	readStdin
	}
