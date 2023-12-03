class_name AddonManifestConfig extends RefCounted

var file: String
var git: String
var branch: String
var tag: String
var commit: String

func to_json():
	var result = {}
	
	if file: result.file = file
	if git: result.git = git
	if branch: result.branch = branch
	if tag: result.tag = tag
	if commit: result.commit = commit
	
	return result
