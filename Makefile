
.PHONY: format lint config

format:
	@find . -type f -name '*.swift' -print0 | \
	jq -Rrs 'split("\u0000") | map(select(length>0)) | map("--input-files " + @sh) | join(" ")' | \
	xargs swift package plugin --allow-writing-to-package-directory format-source-code

lint:
	@find . -type f -name '*.swift' -print0 | \
	jq -Rrs 'split("\u0000") | map(select(length>0)) | map("--input-files " + @sh) | join(" ")' | \
	xargs swift package plugin format-source-code --lint-only

config:
	@swift format dump-configuration | jq --slurpfile override swift-format.json '\
	  def deepmerge(a; b): \
	    reduce (b | keys_unsorted[]) as $$k \
	      (a; \
	       .[$$k] = if (a[$$k]|type)=="object" and (b[$$k]|type)=="object" \
	                then deepmerge(a[$$k]; b[$$k]) \
	                else b[$$k] \
	                end); \
	  deepmerge(.; $$override[0]) \
	' > .swift-format
