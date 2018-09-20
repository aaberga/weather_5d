**Weather 5d**

To operate, run the project on any simulator (or a device) and simply add a city name in the relevant field, then hit return on the keyboard.

A 5d forecast JSON structure will show in the textview.

This is, as of the first commit, just fake data, that only pretends to be pulled from the OpenWeatherMap API, will be brutally copied in the text view under the input field.
That is for elaborate UI/UX!

More work is needed to actually hook the general purpose pluggable API to the app logic, that is already present in the repo. 

_Stay tuned._

The current, single UIViewController is one of the shortest ever written. It does not contain any logic, network or other code more than simply the methods needed to trigger the network/API call and -asynchronously- the presentation of results.


MVC bye, bye!

Inspiration is taken from the cool Coordinator patten presentation at NSSpain 2015, as well as the nice Coordinator tutorial on the Wenderlich site.

a) Presenting Coordinators - Soroush Khanlou
[https://vimeo.com/144116310]()

b) Coordinator Tutorial for iOS: Getting Started
[https://www.raywenderlich.com/158-coordinator-tutorial-for-ios-getting-started]()


The idea about confining any API call logic *out* of the coordinators, in its own layer, is an improvement on a pure coordinators based architecture.

