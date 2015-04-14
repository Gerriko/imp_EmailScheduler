// Copyright (c) 2015 Colin Gerrish (Gerriko IOT)
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

// Mailgun API Keys
const MAILGUN_API_KEY = " --- INSERT YOUR MAILGUN API KEY HERE ---";
const MAILGUN_URL = " ----- CHECK MAILGUN DOCUMENTATION FOR CORRECT URL TO USE ------";
const MAILGUN_SENDER = " ----- PLACE EMAIL SENDER ADDRESS HERE ---------";

const DEVICE_PREP_TIME = 2;                 // This is an offset (in seconds) to allow device to get sensor data prior to sending email

glDT <- {
    tMail = [],
    tTime = [],
    tHash = [],
    tDelay = [],
    tDS = [],
    tGetTemp = [],
    tGetHumid = [],
    tGetDoorStat = [],
    tHandle = []
}


// ================================================================
// Web Page Functions
// ================================================================
function SignInPage(message)
{
    local html = @"
        <!DOCTYPE html>
        <html lang='en'>
            <head>
                <meta charset='utf-8'>
                <meta http-equiv='Cache-Control' content='no-cache, no-store, must-revalidate' />
                <meta http-equiv='Pragma' content='no-cache' />
                <meta http-equiv='Expires' content='0' />
                <meta name='viewport' content='width=device-width, initial-scale=1'>
                <title>Imp IoT Scheduling Controller -- Setup</title>
                <link href='https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.1/themes/ui-darkness/jquery-ui.min.css' rel='stylesheet'>
                <script src='https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js'></script>
                <script src='https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.3/jquery-ui.min.js'></script>
                <script src='https://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js'></script>
                <script src='https://maps.googleapis.com/maps/api/js?key=AIzaSyA53EEzZLp_QUy8aSBD7obW0qBn9an5KoU'></script>
                <link rel='stylesheet' href='https://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css'>
                <style>
                    body {
                      padding-top: 40px;
                      padding-bottom: 40px;
                    }
                    
                    .full {
                        background: url('https://lh5.googleusercontent.com/-yvNgECacOL0/VSZd-6zOSlI/AAAAAAAABfs/hARrm6DL_9w/w1358-h763-no/electricimpteam.jpg') no-repeat center center fixed;
                        -webkit-background-size: cover;
                        -moz-background-size: cover;
                        background-size: cover;
                        -o-background-size: cover;
                    }
                    
                    .full h1 {
                        color: white;
                    }
                    
                    .form-signin {
                      max-width: 420px;
                      padding: 15px;
                      margin: 0 auto;
                    }
                    .form-signin .form-signin-heading,
                    .form-signin .checkbox {
                      margin-bottom: 10px;
                    }
                    .form-signin .checkbox {
                      font-weight: normal;
                    }
                    .form-signin .form-control {
                      position: relative;
                      height: auto;
                      -webkit-box-sizing: border-box;
                         -moz-box-sizing: border-box;
                              box-sizing: border-box;
                      padding: 10px;
                      font-size: 16px;
                    }
                    .form-signin .form-control:focus {
                      z-index: 2;
                    }
                    .form-signin input[type='email'] {
                      margin-bottom: -1px;
                      border-bottom-right-radius: 0;
                      border-bottom-left-radius: 0;
                    }
                </style>
                <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
                <!--[if lt IE 9]>
                  <script src='https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js'></script>
                  <script src='https://oss.maxcdn.com/respond/1.4.2/respond.min.js'></script>
                <![endif]-->
            </head>
            <body class='full'>
                <div class='container col-xs-12 col-md-5 col-md-offset-4 text-center'>
                    <h1>Imp Scheduling Panel</h1>
                    <div class='well'>
                        <p><span id='stat_msg'>" + message + @"</span></p>
                        <form class='form-signin'>
                            <div class='form-group'>
                                <label for='ST1'>Schedule an email at THIS Time (hh:mm)</label>
                                <div id='schS1'></div>
                                <input type='time' class='form-control' id='ST1' required autofocus>
                            </div>
                            <div class='form-group'>
                                <br />
                                <label for='SD1'>ON THIS Date (dd/mm/yyyy)</label>
                                <input type='text' class='form-control' id='SD1' required>
                            </div>
                            <br>
                            <label for='inputEmail'>to THIS email address</label>
                            <input type='email' id='inputEmail' class='form-control' name='inputEmail' placeholder='Email address' required>
                            <hr>
                            <fieldset>
                            <legend>With the following data:</legend>
                            <div class='row btn-group' data-toggle='buttons'>
                                <label class='btn btn-default btn-block' id='DS0'><input type='checkbox' autocomplete='off'>Temperature</label>
                                <label class='btn btn-default btn-block' id='DS1'><input type='checkbox' autocomplete='off'>Humidity</label>
                                <label class='btn btn-default btn-block' id='DS2'><input type='checkbox' autocomplete='off'>Door Status</label>
                            </div>
                            </fieldset>
                            <hr>
                            <button type='button' class='btn btn-lg btn-primary btn-block' onclick='updateSchedule();'>Schedule Alert Now</button>
                        </form>
                    </div>
                </div> <!-- /container -->

                <script>
                    $(function() {
                        $('#SD1').datepicker({dateFormat: 'dd/mm/yy', minDate: 0, maxDate: 4});
                        
                    });

                    $('#DS0').on('click', function(event) {
                        if ($('#DS0').hasClass('active')) $('#DS0').text('Temperature');
                        else $('#DS0').text('Include Temperature');
                    });
                    
                    $('#DS1').on('click', function(event) {
                        if ($('#DS1').hasClass('active')) $('#DS1').text('Humidity');
                        else $('#DS1').text('Include Humidity');
                    });
                    
                    $('#DS2').on('click', function(event) {
                        if ($('#DS2').hasClass('active')) $('#DS2').text('Door Status');
                        else $('#DS2').text('Include Door Status');
                    });

                    function updateSchedule() {
                        
                        var err_msg = 'Input error:';
                        var err_flag = false;
        
                        var schtm = $('#ST1').val();
                        if (!schtm.length) {
                            err_msg += ' NO Time ';
                            err_flag = true;
                        }
        
                        var schdt = $('#SD1').val();
                        if (!schdt.length) {
                            err_msg += ' NO Date ';
                            err_flag = true;
                        }
                        else {
                            if (schdt.length != 10) {
                                err_msg += ' Date WRONG LENGTH ';
                                err_flag = true;
                            }
                            else {
                                if (schtm.length && !validateTime(schtm,schdt)) {
                                    err_msg += ' Time TOO EARLY ';
                                    err_flag = true;
                                }
                            }
                        }
                        
                        var eml = $('#inputEmail').val();
                        if (!eml.length) {
                            err_msg += ' NO email ';
                            err_flag = true;
                        } else {
                            if (!validateEmail(eml)) {
                                err_msg += ' INCORRECT email ';
                                err_flag = true;
                            }
                        }
                        
                        if (err_flag)
                            $('#stat_msg').html(err_msg);
                        else {
                            var schUTC = 0;
                            if (schdt.length == 10) {
                                var schdtCreate = new Date(schdt.substring(6), parseInt(schdt.substring(3,5))-1, schdt.substring(0,2));
                                var nToffset = schdtCreate.getTimezoneOffset();
                                schUTC = schdtCreate.getTime() * 0.001 + (parseInt(schtm.substring(0,2),10) * 60 + parseInt(schtm.substring(3),10))*60;
                            }
                            var DS0 = 0;
                            var DS1 = 0;
                            var DS2 = 0;
                            
                            if ($('#DS0').hasClass('active')) DS0=1;
                            if ($('#DS1').hasClass('active')) DS1=1;
                            if ($('#DS2').hasClass('active')) DS2=1;
                            
                            var DSdat = [DS0, DS1, DS2];

                            $.post(document.URL, {utc:schUTC, tz:nToffset, em:eml, ds:JSON.stringify(DSdat)}, (function(dataRec) {
                                var data = $.parseJSON(dataRec);
                                email1 = data.EM;
                                t2wait = data.TM;
                                emsg = data.ER;
                                if (emsg.length) $('#stat_msg').html(emsg);
                                else $('#stat_msg').html('An email to ' + email1 + ' is scheduled to be sent in ' + t2wait + ' seconds time');
                            }))
                            .fail(function(data) {alert('ERROR: ' + data.responseText);});
                        }                            
                    }

                    function validateEmail(Nemail) { 
                        var re = /^(([^<>()[\]\\.,;:\s@\']+(\.[^<>()[\]\\.,;:\s@\']+)*)|(\'.+\'))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                        return re.test(Nemail);
                    }
                    
                    function validateTime(Ntime, Ndate) { 
                        var cDate = new Date();
                        var toyear = cDate.getFullYear();
                        if (toyear == parseInt(Ndate.substring(6))) {
                            var tomonth = cDate.getMonth();
                            if (tomonth == (parseInt(Ndate.substring(3,5))-1)) {
                                var today = cDate.getDate();
                                if (today == parseInt(Ndate.substring(0,2))) {                         
                                    var hours = cDate.getHours();
                                    if (hours > parseInt(Ntime.substring(0,2))) return 0;
                                    else if (hours == parseInt(Ntime.substring(0,2))) {
                                        var minutes = cDate.getMinutes();
                                        if (minutes > parseInt(Ntime.substring(3))) return 0;
                                    }
                                }
                            }
                        }
                        return 1;
                    }
                    
                </script>
            </body>
        </html>
    
    ";
    
    return html;
}

// ================================================================
// Imp Functions
// ================================================================

function httpHandler(request,response) {
    try 
    {
        local method = request.method.toupper();
        local DeviceConnected = true;

        response.header("Access-Control-Allow-Origin", "*");

        if (method == "POST") 
        {
            local data = http.urldecode(request.body);
            if ("utc" in data && "em" in data && "ds" in data) {
                //check array size as limited to 20 timer events
                if (glDT.tMail.len() < 20) {
                    glDT.tMail.append(data.em);
                    glDT.tTime.append(data.utc.tointeger());
                    glDT.tDelay.append(-1);
                    
                    local sData = split(data.ds, "[,]");
                    glDT.tDS.append([sData[0].tointeger(), sData[1].tointeger(), sData[2].tointeger()]);
                    glDT.tGetTemp.append(null);
                    glDT.tGetHumid.append(null);
                    glDT.tGetDoorStat.append(null);

                    glDT.tHandle.append(null);
                    
                    local schTime = setAutoSchedules(glDT.tMail.len()-1);
                    
                    if (schTime >=0) {
                        local htmlTable = {EM=data.em, TM=schTime, ER=""};
                        local jvars = http.jsonencode(htmlTable);
                        response.send(200, jvars);
                    }
                    else {
                        local htmlTable = {EM="", TM=-1, ER=" Sorry, there was an error processing your email scheduled request"};
                        local jvars = http.jsonencode(htmlTable);
                        response.send(200, jvars);
                    }
                    
                } else {
                    local htmlTable = {EM="", TM=-1, ER=" Sorry, cannot schedule your request as maximum number of timer events already scheduled"};
                    local jvars = http.jsonencode(htmlTable);
                    response.send(200, jvars);
                }
            }
        }
        else
        {
            response.send(200, SignInPage(""));
        }
    }
    catch(error)
    {
        response.send(500, "Internal Server Error: " + error);
    }
}


function setAutoSchedules(index) {
    local sErrMsg = "";
    local nTime = time();
    local compTime = glDT.tTime[index] - nTime;
    glDT.tDelay[index] = compTime;
    
    server.log(format("Setting up new email schedule in %d seconds time for row index %d", compTime, index));
    
    if (glDT.tDS[index][0] || glDT.tDS[index][1] || glDT.tDS[index][2]) {
        server.log(format("Sensor Data Requested for: Temp %d | Humidity %d | Door Status %d", glDT.tDS[index][0], glDT.tDS[index][1], glDT.tDS[index][2]));
        // Send request to Imp Device
        local deviceTime = compTime - DEVICE_PREP_TIME;
        if (deviceTime >= 0) {
            // MODIFY CODE HERE TO HANDLE SENDING REQUEST TO IMP DEVICE
            local tHash = http.hash.md5(glDT.tMail[index]+glDT.tTime[index]);
            device.send("prepSensors", {"tToken":tHash, "tWake":deviceTime, "tDS":glDT.tDS[index]});
            
        }
        else sErrMsg = "Error: Sched Request too early. Not enough time to get sensor data";
    }
    
    if (glDT.tHandle[index] == null) {
        local tMail = glDT.tMail[index]; 
        local tTime = glDT.tTime[index]; 
        glDT.tHandle[index] = imp.wakeup(compTime*1.0, function() { 
            server.log("Sending email to " + tMail);
            local subj = "Imp IoT Scheduled Message";
            local emsg = "This is your scheduled email Alert, which was set up via web-browser.\r\n";

            for (local i = 0; i<glDT.tTime.len(); i++) {
                if ((tMail == glDT.tMail[i]) && (tTime == glDT.tTime[i])) {
                    // Check to see if any sensor data was requested
                    if (glDT.tDS[i][0] || glDT.tDS[i][1] || glDT.tDS[i][2]) {
                        if (glDT.tDS[i][0] == 2)
                            emsg += "Temperature: " + glDT.tGetTemp[i] + "°C\r\n";
                        else if (glDT.tDS[i][0] == 1)
                            emsg += "Temperature: No Sensor Data Received\r\n";
                        if (glDT.tDS[i][1] == 2)
                            emsg += "Humidity: " + glDT.tGetHumid[i] + "%\r\n";
                        else if (glDT.tDS[i][1] == 1)
                            emsg += "Humidity: No Sensor Data Received\r\n";
                        if (glDT.tDS[i][2] == 2)
                            emsg += "Door Status: " + (glDT.tGetDoorStat[i] ? "OPEN" : "CLOSED") + "\r\n";
                        else if (glDT.tDS[i][2] == 1)
                            emsg += "Door Status: No Sensor Data Received\r\n";
                    }
                    else emsg += "No sensor data was requested with this alert.\r\n";
                    
                    // Can now remove the array item
                    glDT.tMail.remove(i); 
                    glDT.tTime.remove(i);
                    glDT.tDelay.remove(i);
                    glDT.tDS.remove(i);
                    glDT.tGetTemp.remove(i);
                    glDT.tGetHumid.remove(i);
                    glDT.tGetDoorStat.remove(i);
                    glDT.tHandle.remove(i);
                    break;
                }
            }

            emsg += "\r\nThis email was automatically generated via the Imp Agent using MailGun API.";
            local datapost = HttpMailGunPostWrapper(subj, emsg, tMail);
            server.log("MailGun HTTPResponse: " + datapost.statuscode + " - " + datapost.body);
            
        });
        if (glDT.tHandle[index] == null) {
            server.log("ERROR setting up new timer handle");
            return -1;
        }
        else {
            server.log(format("New Timer Handle is set"));
            return compTime;
        }
    }
}

function get_fDate() {
    local aDate = date();
    local d_days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    local dow = d_days[aDate.wday];
    local fDate = "";
    //server.log(format("[%s] %04d/%02d/%02d at %02d:%02d:%02d", dow, aDate.year, aDate.month + 1, aDate.day, aDate.hour, aDate.min, aDate.sec));
    fDate = format("[%s] %04d/%02d/%02d %02d:%02d", dow, aDate.year, aDate.month + 1, aDate.day, aDate.hour, aDate.min);
    return fDate;
}

function Sensor_Handler(sData) {
    server.log("sensor data received: Temp - " + sData.tDSvals[0] + " | Humidity - " +  sData.tDSvals[1] + " | Door Stat - " +  sData.tDSvals[2]);
    for (local i = 0; i<glDT.tTime.len(); i++) {
        local tHash = http.hash.md5(glDT.tMail[i]+glDT.tTime[i]);
        server.log("Hash: " + BlobToHexString(tHash));
        if (BlobToHexString(tHash) == BlobToHexString(sData.tH)) {
            if (sData.tDS[0] == 2) {
                glDT.tGetTemp[i] = sData.tDSvals[0];
                glDT.tDS[i][0] = 2;
            }
            if (sData.tDS[1] == 2) {
                glDT.tGetHumid[i] = sData.tDSvals[1];
                glDT.tDS[i][1] = 2;
            }
            if (sData.tDS[2] == 2) {
                glDT.tGetDoorStat[i] = sData.tDSvals[2];
                glDT.tDS[i][2] = 2;
            }
            break;
        }
    }
}

function BlobToHexString(data) {
  local str = "0x";
  foreach (b in data) str += format("%02X", b);
  return str;
}

// Basic wrapper to create an execute an HTTP POST
function HttpMailGunPostWrapper (subject, message, emailAddr) {
    local from = MAILGUN_SENDER;
    local to   = emailAddr;
    
    local request = http.post("https://api:" + MAILGUN_API_KEY + "@api.mailgun.net/v2/" + MAILGUN_URL + 
        "/messages", {"Content-Type": "application/x-www-form-urlencoded"}, "from=" + from + "&to=" + to + "&subject=" + subject + "&text=" + message);
    
    local response = request.sendsync();
    return response;
}


/* REGISTER HTTP HANDLER -----------------------------------------------------*/
http.onrequest(httpHandler);

/* REGISTER DEVICE HANDLERS -----------------------------------------------------*/
device.on("updatSensors", Sensor_Handler);
