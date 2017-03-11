(
//Adjust Server Options before boot
s.options.numInputBusChannels = 2;
s.options.numOutputBusChannels = 1;
s.options.memSize = 163840;
s.waitForBoot{ fork{

	//Make Groups
	//1999 for monitoring incomming signals
	//2000-2010 for dsp
	//2999 for monitoring out signals
	s.sendMsg(\g_new, 1999); s.sendMsg(\g_new, 2000);
	10.do{|ix| s.sendMsg(\g_new, 2001+ix, 3, 2000+ix)};
	s.sendMsg(\g_new, 2999, 3, 2010);

	0.1.wait;

	~filtermode = 0;

	//// ARDUINO

	~ino = ArduinoSMS("/dev/ttyUSB0", 9600);

	//////Arduino Action /////////////////////
	~ino.action = {
		arg msg;
		var serialmsg = msg.split($:);
		var header = serialmsg[0];
		var val = serialmsg[1].asFloat;

		//Pots
		switch(header,

			//POTS

			//// p0 - Delay Time
			"p0", {
				s.sendMsg(\c_set, 0, val.linexp(0, 1023, 0.01, 1.5));
				s.sendMsg(\c_get, 0);
			},

			//// p1 - Filter, Center Frequency
			"p1", {
				s.sendMsg(\c_set, 1, val.linexp(0, 1023, 70.0, 10000.0));
				s.sendMsg(\c_get, 1);
			},

			//// p2 - Q
			"p2", {
				s.sendMsg(\c_set, 2, val.linlin(0.0, 1023.0, 0.0, 0.999));
				s.sendMsg(\c_get, 2);
			},

			//// p3 - Comb, Delay Time
			"p3", {
				s.sendMsg(\c_set, 3, val.linexp(0.0, 1023.0, 0.0001, 0.8));
				s.sendMsg(\c_get, 3);
			},

			//// p4 - Comb, Decay Time
			"p4", {
				s.sendMsg(\c_set, 4, val.linlin(0.0, 1023.0, -2.0, 2.0));
				s.sendMsg(\c_get, 4);
			},

			//// p5 - Bitcrush
			"p5", {
				//control bus 5 is bitrate
				s.sendMsg(\c_set, 5, val.linlin(0.0, 1023.0, 16.0, 1.0));
				//control bus 5 is sample rate
				s.sendMsg(\c_set, 6, val.linlin(0.0, 1023.0, 44100.0, 300.0));
				s.sendMsg(\c_get, 5);
				s.sendMsg(\c_get, 6);
			},

			//// p6 - Contact Mic Volume
			"p6", {
				s.sendMsg(\c_set, 7, val.explin(0.001, 1023.0, -300.0, 48.0));
				s.sendMsg(\c_get, 7);
			},

			//// p7 - Master Volume
			"p7", {
				s.sendMsg(\c_set, 8, val.explin(0.001, 1023.0, -400.0, 18.0));
				s.sendMsg(\c_get, 8);
			},

			//SWITCHES

			//// b0 - Delay on/off
			"b0", {

				switch( val.asInteger,

					//Turn Delay On
					1, {
						//Start the DelayLine, node 3000, group 2002
						s.sendMsg(\s_new, \delay, 3000, 0, 2002, \ibs, 1, \gate, 1, \amp, 1.0, \obs, 0);
						0.05.wait;
						//Map Delay Time to Pot0/Control Bus 0
						s.sendMsg(\n_map, 3000, \delay, 0);
						//Print Message to console
						"Delay On".postln;
						//Turn On LED
						~ino.send(1,0,1);
					},

					//Turn Delay Off
					0, {
						//Stop delay by closing the envelope
						s.sendMsg(\n_set, 3000, \gate, 0);
						"Delay Off".postln;
						//Turn Off LED
						~ino.send(1,0,0);
					}

				); //end switch

			}, //end b0

			//// b1 - Filter
			"b1", {

				switch( val.asInteger,

					//Turn Filter On
					1, {
						//Start the Filter, node 3001, group 2003
						s.sendMsg(\s_new, \filter, 3001, 0, 2003, \ibs, 0, \gate, 1, \amp, 1.0, \obs, 0, \mode, 0);
						0.05.wait;
						//Map Filter frequency to Pot1/Control Bus 1
						s.sendMsg(\n_map, 3001, \freq, 1, \q, 2);
						//set ~filtermode var to 0
						~filtermode = 0;
						//Print Message to console
						"Filter On".postln;
						//Turn On LED
						~ino.send(1,1,1);
					},

					//Turn Filter Off
					0, {
						//Stop filter by closing the envelope
						s.sendMsg(\n_set, 3001, \gate, 0);
						0.05.wait;
						~ino.send(1,1,0);
						~ino.send(1,5,0);
						"Filter Off".postln;
					}

				); //end switch

			}, //end b1

			//// b2 - Comb
			"b2", {

				switch( val.asInteger,

					//Turn Comb Filter On
					1, {
						//Start the Filter, node 3002, group 2004
						s.sendMsg(\s_new, \comb, 3002, 0, 2004, \ibs, 0, \gate, 1, \amp, 1.0, \obs, 0);
						0.05.wait;
						//Map comb to control bus/pot 3 decay to 4
						s.sendMsg(\n_map, 3002, \delay, 3, \decay, 4);
						//Print Message to console
						"Comb On".postln;
						//Turn On LED
						~ino.send(1,2,1);
					},

					//Turn Comb Off
					0, {
						//Stop comb by closing the envelope
						s.sendMsg(\n_set, 3002, \gate, 0);
						0.05.wait;
						~ino.send(1,2,0);
						"Comb Off".postln;
					}

				); //end switch

			}, //end b2

			//// b3 - BitCrush
			"b3", {

				switch( val.asInteger,

					//Turn Bitcrush On
					1, {
						//Start the Crush, node 3003, group 2005
						s.sendMsg(\s_new, \crush, 3003, 0, 2005, \ibs, 0, \gate, 1, \amp, 1.0, \obs, 0);
						0.05.wait;
						//Map crush to control bus/pot 5 bitrate, sample rate6
						s.sendMsg(\n_map, 3003, \bitrate, 5, \samprate, 6);
						//Print Message to console
						"Bitcrush On".postln;
						//Turn On LED
						~ino.send(1,3,1);
					},

					//Turn Bitcrush Off
					0, {
						//Stop Bitcrush by closing the envelope
						s.sendMsg(\n_set, 3003, \gate, 0);
						0.05.wait;
						~ino.send(1,3,0);
						"Bitcrush Off".postln;
					}

				); //end switch

			}, //end b3

			//// b4 - Contact Mic
			"b4", {

				switch( val.asInteger,

					//Turn Contact Mic On
					1, {
						//Start the ContactMic, node 3004, group 2006
						s.sendMsg(\s_new, \gain, 3004, 0, 2006, \ibs, 2, \gate, 1, \vol, 0.0, \obs, 0);
						0.05.wait;
						//Map contact mic volume to control bus 7, pot 6
						s.sendMsg(\n_map, 3004, \vol, 7);
						//Print Message to console
						"Contact Mic On".postln;
						//Turn On LED
						~ino.send(1,4,1);
					},

					//Turn Contact Mic Off
					0, {
						//Stop contact mic by closing the envelope
						s.sendMsg(\n_set, 3004, \gate, 0);
						0.05.wait;
						~ino.send(1,4,0);
						"Contact Mic Off".postln;
					}

				); //end switch

			}, //end b4

			//Filter Mode
			"b5", { if(val.asInteger == 1,{
				//Advance ~filtermode var
				~filtermode = (~filtermode+1)%3;
				//set mode of filter
				s.sendMsg(\n_set, 3001, \mode, ~filtermode);
				//post filtermode
				switch(~filtermode,
					0, {"Filter Mode:".post; ~filtermode.post; "-LoPass".postln; 0.05.wait; ~ino.send(1,1,1); 0.05.wait; ~ino.send(1,5,0)},
					1, {"Filter Mode:".post; ~filtermode.post; "-HiPass".postln; 0.05.wait; ~ino.send(1,5,1); 0.05.wait; ~ino.send(1,1,0)},
					2, {"Filter Mode:".post; ~filtermode.post; "-BandPass".postln; 0.05.wait; ~ino.send(1,5,1);0.05.wait;  ~ino.send(1,1,1)}
				); //end switch
			})/*end if*/ }, //end b5


		);//end switch


	}; //end ino.action

	////DSP
	SynthDef( \delay, {
		arg ibs=0, obs=0, gate;
		var in, sig;
		var del = \delay.kr(0.5, 0.01);
		var amp = \amp.kr(0.85, 0.01);
		var env = EnvGen.ar(Env.asr(0.1,1,0.1,0),gate, doneAction:2);
		in = In.ar(ibs);
		sig = DelayC.ar(in, 5.0, del);
		ReplaceOut.ar(obs, sig*amp*env);
	}).add;

	SynthDef( \filter, {
		arg ibs=0, obs=0, mode=0, gate;
		var in, sig;
		var amp = \amp.kr(1.0, 0.01);
		var freq = \freq.kr(10000.0, 0.01);
		var q = \q.kr(0.5,0.01);
		var env = EnvGen.ar(Env.asr(0.03,1,0.03,0),gate, doneAction:2);
		in = In.ar(ibs);
		sig = BMoog.ar(in, freq, q, mode);
		ReplaceOut.ar(obs, sig*amp*env);
	}).add;

	SynthDef( \comb, {
		arg ibs=0, obs=0, gate;
		var in, sig;
		var amp = \amp.kr(0.85, 0.01);
		var del = \delay.kr(0.03, 0.01);
		var dec = \decay.kr(1.3,0.01);
		var env = EnvGen.ar(Env.asr(0.03,1,0.03,0),gate, doneAction:2);
		in = In.ar(ibs);
		sig = CombC.ar(in,3.0, del, dec);
		ReplaceOut.ar(obs, sig*amp*env);
	}).add;

	SynthDef( \crush, {
		arg ibs=0, obs=0, gate;
		var in, sig;
		var amp = \amp.kr(0.85, 0.01);
		var rate = \samprate.kr(44100, 0.01);
		var bits = \bitrate.kr(24,0.01);
		var env = EnvGen.ar(Env.asr(0.03,1,0.03,0),gate, doneAction:2);
		in = In.ar(ibs);
		sig = Decimator.ar(in, rate, bits);
		ReplaceOut.ar(obs, sig*amp*env);
	}).add;

	SynthDef( \mastervolume,{
		var amp = \vol.kr(0.0, 0.03).dbamp;
		var in = In.ar(0);
		ReplaceOut.ar(0, in*amp);
	}).add;


	SynthDef( \gain,{
		arg ibs, obs=0, gate;
		var amp = \vol.kr(0.0, 0.03).dbamp;
		var in = In.ar(ibs);
		var env = EnvGen.ar(Env.asr(0.03,1,0.03,0),gate, doneAction:2);
		Out.ar(obs, in*amp*env);
	}).add;

	0.1.wait;


	////This posts to console when pots are moved
	OSCdef( \kdat, {arg msg; msg.postln;}, \c_set);

	///MasterVolume - node 5000, group 2010
	s.sendMsg(\s_new, \mastervolume, 5000, 0, 2010);
	0.05.wait;
	////map master volume to pot 7, control bus 8
	s.sendMsg(\n_map, 5000, \vol, 8);

0.1.wait;

	{s.meter}.defer;
}} //end fork & s.waitForBoot
)


