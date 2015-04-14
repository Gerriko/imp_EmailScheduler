// Copyright (c) 2015 Colin Gerrish (Gerriko IOT)
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

imp.setpowersave(true);

function simulateStatusUpdate(data4Sensor) {
    // This is an object containing an array and a tokem
    server.log("Token Hex: " + BlobToHexString(data4Sensor.tToken));
    local tHandle = imp.wakeup(data4Sensor.tWake*1.0, function() { 
        server.log("Sensor Data Requested: " + data4Sensor.tDS[0] + " | " + data4Sensor.tDS[1] + " | " + data4Sensor.tDS[2]);
        local tDSvals = [null, null, null];
        // Simulate values as no sensors attached to demo device
        // Uses logic of if there is a value to return then also change tDS code to 2 to show value update
        if (data4Sensor.tDS[0]) {
            tDSvals[0] = 17.9;
            data4Sensor.tDS[0] = 2;
        }
        if (data4Sensor.tDS[1]) {
            tDSvals[1] = 70.0;
            data4Sensor.tDS[1] = 2;
        }
        if (data4Sensor.tDS[2]) {
            tDSvals[2] = 1;
            data4Sensor.tDS[2] = 2;
        }
        agent.send("updatSensors", {"tH":data4Sensor.tToken, "tDS":data4Sensor.tDS, "tDSvals":tDSvals});
    });
}

function BlobToHexString(data) {
  local str = "0x";
  foreach (b in data) str += format("%02X", b);
  return str;
}

agent.on("prepSensors", simulateStatusUpdate);
