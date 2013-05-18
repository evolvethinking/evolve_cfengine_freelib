Requirements

Cfengine Core 3.4.x or higher

Create a libraries directory 

Download in libraries directory cfengine_stdlib.cf ( https://raw.github.com/cfengine/core/master/masterfiles/libraries/cfengine_stdlib.cf )

Copy or link modules/return_index.pl in ~/.cfagent/modules (user) or /var/cfengine/modules (root)

Copy or link masterfiles/libraries/evolve_freelib.cf in the libraries directory

Action: cf-agent -K -f ./promises.cf

Result: This example creates the file /tmp/orig and one or several links /tmp/dest? -> /tmp/orig.
