(
//Adjust Server Options before boot
s.options.numInputBusChannels = 1;
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




	////DSP
	SynthDef( \delay, {
		arg ibs=0, obs=0, gate;
		var in, sig;
		var del = \del.kr(0.5, 0.01);
		var amp = \amp.kr(0.85, 0.01);
		var env = EnvGen.ar(Env.asr(0.03,1,0.03,0),gate);
		in = In.ar(ibs);
		sig = DelayC.ar(in, 5.0, del);
		Out.ar(obs, sig*amp*env);
	}).add;

	SynthDef( \filter, {
		arg ibs=0, obs=0, mode=0, gate;
		var in, sig;
		var amp = \amp.kr(1.0, 0.01);
		var freq = \freq.kr(10000.0, 0.01);
		var q = \q.kr(0.5,0.01);
		var env = EnvGen.ar(Env.asr(0.03,1,0.03,0),gate);
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
		var env = EnvGen.ar(Env.asr(0.03,1,0.03,0),gate);
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
		var env = EnvGen.ar(Env.asr(0.03,1,0.03,0),gate);
		in = In.ar(ibs);
		sig = Decimator.ar(in, rate, bits);
		ReplaceOut.ar(obs, sig*amp*env);
	}).add;

	SynthDef( \ringmod, {
		arg ibs=0, obs=0, gate;
		var in, sig;
		var amp = \amp.kr(0.85, 0.01);
		var rate = \lforate.kr(0.08,0.01);
		var modamp = \modlevel.kr(0.5,0.01);
		var env = EnvGen.ar(Env.asr(0.03,1,0.03,0),gate);
		in = In.ar(ibs);
		sig = DiodeRingMod.ar( in, SinOsc.ar( SinOsc.kr(rate).range(50.0, 100.0).midicps )*modamp );
		ReplaceOut.ar(obs, sig*amp*env);
	}).add;

	//TRIGGERED SOUNDS

	SynthDef(\drumline, {
		arg obs=0,rate1=11.0, rate2=10.0, rate3=12.0, gdur=0.03, ffreq=5000, frez=0.5, fr1=300, fr2=12000, gate=0, dur=0.01, crv=0, pan=0;
		var noise, grainrate1, grainrate2, grainrate3, grainenv1, grainenv2, grainenv3, filterednoise1, filterednoise2, filterednoise3, freqchgrate1, freqchgrate2, freqchgrate3, s1, s2, s3, output, oenv, envtrig, atk;
		var amp = \amp.kr(1.0, 0.01);
		atk = PinkNoise.ar()*EnvGen.ar(Env.perc(attackTime:0.005, releaseTime:0.01));
		envtrig = \t_tr.kr(0,0);
		oenv = EnvGen.ar( Env.perc(attackTime:0.005, releaseTime:dur, curve:crv), envtrig, doneAction:2);
		grainrate1 = Impulse.kr(rate1);
		grainrate2 = Impulse.kr(rate2);
		grainrate3 = Impulse.kr(rate3);
		freqchgrate1 = Impulse.kr(rate1*2);
		freqchgrate2 = Impulse.kr(rate2*3);
		freqchgrate3 = Impulse.kr(rate3*4);
		grainenv1 = EnvGen.ar( Env.perc(attackTime:0.003, releaseTime:gdur), gate:grainrate1 );
		grainenv2 = EnvGen.ar( Env.perc(attackTime:0.003, releaseTime:gdur), gate:grainrate2 );
		grainenv3 = EnvGen.ar( Env.perc(attackTime:0.003, releaseTime:gdur), gate:grainrate3 );
		noise = Crackle.ar(chaosParam:1.95);
		filterednoise1 = MoogLadder.ar( in:noise, ffreq:TRand.kr(fr1, fr2, freqchgrate1), res:frez, mul:7);
		filterednoise2 = MoogLadder.ar( in:noise, ffreq:TRand.kr(fr1, fr2, freqchgrate2), res:frez, mul:7 );
		filterednoise3 = MoogLadder.ar( in:noise, ffreq:TRand.kr(fr1, fr2, freqchgrate3), res:frez, mul:7 );
		s1 = filterednoise1*grainenv1;
		s2 = filterednoise2*grainenv2;
		s3 = filterednoise3*grainenv3;
		output = Mix.ar( [s1, s2, s3, atk] );
		//output = Pan2.ar(output, pan);
		Out.ar(obs, output*amp*oenv);
	}).add;

	0.1.wait;

	s.sendMsg(\s_new, \delay, 5000, 0, 2003, \ibs, 1, \obs, 0, \del, 0.5, \gate, 1);


	0.1.wait;

	{s.meter}.defer;


}})

//Delay
s.sendMsg(\n_set, 5000, \del, 0.2);

//Filter
s.sendMsg(\s_new, \filter, 5001, 0, 2004, \ibs, 0, \obs, 0, \mode, 2, \freq, 120, \q, 0.9, \gate, 1);
s.sendMsg(\n_free, 5001);
s.sendMsg(\n_set, 5001, \mode, 0, \freq, 500, \q, 0.9);
s.sendMsg(\n_free, 5001);


//comb
s.sendMsg(\s_new, \comb, 5002, 0, 2005, \ibs, 0, \obs, 0, \delay, 0.05, \decay, 0.5, \gate, 1);
s.sendMsg(\n_set, 5002,\delay, 0.85, \decay, 2.5);
s.sendMsg(\n_free, 5002);


//triggered
s.sendMsg(\s_new, \drumline, 6000, 0, 2002, \obs, 0, \t_tr, 1, \dur, 1.5, \amp, 0.02);

s.queryAllNodes