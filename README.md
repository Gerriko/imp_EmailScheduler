# imp_EmailScheduler
Electric Imp Squirrel Code for the Agent which provides an html/javascript based UI to allow the user to schedule an email alert based on a calendar date and time of day. It also allows the user to select what sensor data to include in the email alert. [Mailgun API](http://www.mailgun.com/) is used to dispatch the email.

The diagram shown illustrates the process flow for this application.

![](https://lh5.googleusercontent.com/-mWb6JrRLZaw/VS1UxcfL_NI/AAAAAAAAACM/ts1lcFgKkws/w850-h600-no/imp_emailScheduler.png)

## Agent Code

The [Bootstrap](http://getbootstrap.com/) html, CSS and JS framework template is used to style the single html page. This enables the html page to automatically scale and adjust for small smartphone screen sizes through to larger desktop computer monitors. The page is also designed for touch screen use and hence checkboxes are modified to display as buttons. A further modification is added, using javascript, which adds a tick symbol to the text within a button to confirm that the button has been checked.

The sending of data from html page to Imp Agent is handled through jquery rather than using a submit button to post data. However, the agent code can be readily adapted to accomodate the normal form post method using a submit button and then allow for a second html confirmation page to be included.

Within the http.onrequest(httpHandler) routine, data received via post method is parsed. This code does not encrypt or hash the data when posting to imp. Within the agent simple comparison checks are made, based on data received. For example up to 20 email request schedules can be handled concurrently as the imp wakeup method is used.

If sensor data has been requested for a specified time period then this time period is adjusted using a constant DEVICE_PREP_TIME which is set at 2 seconds. This ensures that the imp device will wakeup 2 seconds before the email request time and take sensor readings and then send these to the agent.

## Device Code

Device Code included here does not actually take sensor readings. Placeholders are simply used and it will be up to the user to modify the device code to be able to take readings.

The device code has been set up to ensure that up to 20 readings can be handled.

## License
The example code in this library is licensed under the [MIT License](../master/LICENSE).
