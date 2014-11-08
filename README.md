# Test::Unit::Runner::Tap

https://github.com/test-unit/test-unit-runner-tap


## DESCRIPTION

Test::Unit::Runner::Tap is a console UI for Test::Unit supporting TAP and TAP-Y/J
formats.

See [Tes::tUnit](http://test-unit.github.io/) for more information about Test::Unit.

See [TAP](http://testanything.org) for more information about TAP format.

See [TAPOUT](http://rubyworks.github.com/tapout) for more information about
TAP-Y/J format.


## INSTALL

Using Bundler add to your Gemfile:

    gem 'test-unit-runner-tap'

Or install globally:

    $ sudo gem install test-unit-runner-tap


## USAGE

In your test helper script use:

    require 'test/unit/runner/tap'

Then you can select the runner via the `--runner` command line option.

    $ ruby test/run_tests.rb --runner yaml

Available runners are `tap`, `tapy`/`yaml` or `tapj`/`json`.

The runner can also be specified in code, if need be. See API documentation
for more information on how to do this.

To use TAP-Y/J formats with TAPOUT, just pipe results to tapout utility.

    $ ruby test/run_tests.rb --runner yaml | tapout

See TAPOUT poject for more information on that.


## CONTRIBUTING

This project uses [Mast](http://github.com/rubyworks/mast) and [Indexer](https://github.com/rubyworks/indexer) tools. To perform a release, run `rake prep`. This will invoke the `mast` and `index` commands as needed. Then check in any changes to `Manifest.txt`, `.index` and `.gemspec` that may have occured. After that run `rake gem` to build the gem package. Be sure to bump the verion in `lib/test/unit/runner/tap-version.rb` and add an entry to `History.md` first!


## LICENSE

(LGPL v3.0 License)

Copyright (c) 2012 Trans & Kouhei Sutou

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

(See COPYING file for more details.)
