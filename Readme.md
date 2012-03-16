# Automatic Foursquare Check-ins

I like [Foursquare](http://4sq.com), but I keep forgetting the check-in at the office.  This repsitory allows for automatic check-is to a venue, based on MAC addresses.

### Registration interface

![Logged in user dashboard](http://cl.ly/1a3Z2b2l2b0t2f1H293j/Screen%20Shot%202012-03-16%20at%2017.08.32.png)


![Logged out user default screen](http://cl.ly/143Z3r412P2e2C1b0t2f/Screen%20Shot%202012-03-16%20at%2017.10.06.png)

### How to use

There are two components, the registration interface and the networking scanner.

In order to get your users in the system, you'll need to launch the sinatra based registration interface found in the `bin/` folder.

Once your users are registered, run the `scan_network` script, also in the `bin/` folder in a `screen` or similar.  It'll keep looping and searching for new devices on your network, and check users into the venue on Foursquare at most once a day.

### Configuration

Configurations options can be found in `etc/config.yml.sample`.  You'll need to copy that file to `etc/config.yml`.  The database schema should be created automatically for you by [DataMapper](http://datamapper.org/).

    
### License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
