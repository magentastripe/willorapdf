#!/bin/sh
set -ex
ruby ensmallen_entities_json.rb entities.json | sed 's/},/},\n/g' > entities.min.json
