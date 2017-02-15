SerialPort.listDevices

a = ArduinoSMS("/dev/ttyUSB0", 9600);
a.send(1,0,0);
a.send(1,1,0);
a.send(1,2,0);
a.send(1,3,0);
a.send(1,4,0);
a.send(1,5,0);

a.send(1,0,1);
a.send(1,1,1);
a.send(1,2,1);
a.send(1,3,1);
a.send(1,4,1);
a.send(1,5,1);
