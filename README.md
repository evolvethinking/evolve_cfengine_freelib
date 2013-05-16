Copyright Evolve Thinking ( www.evolvethinking.com ).
For fresh updates visit:
https://github.com/evolvethinking/evolve_cfengine_freelib

License

Evolve_freelib.cf is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.

Introduction

The bundles contained in this library primarily focus on content driven
policy.  Each such bundle takes csv type delimited parameter file as shown in
the common bundle efl_c. A record consists of a single line and the required
fields.

A skeleton bundle is provided for those that wish to create new bundles.

Requirements

Cfengine Core 3.4.x or higher
cfengine_stdlib.cf ( https://raw.github.com/cfengine/core/master/masterfiles/libraries/cfengine_stdlib.cf )

Known issues

Parameter data files cannot contain variables at this time due to Cfengine bug 2333. (https://cfengine.com/dev/issues/2333)
