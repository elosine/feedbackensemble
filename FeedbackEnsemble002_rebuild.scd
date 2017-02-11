(
//Adjust Server Options before boot
s.options.numAudioBusChannels = 512;
s.options.memSize = 163840;
s.waitForBoot{ fork{
	//SynthDefs
	SynthDef( \delaylive, {
		arg ibs=0, obs=0, gate;
		var in, sig;
		var del = \del.kr(0.5, 0.01);
		var amp = \amp.kr(0.85, 0.01);
		var env = EnvGen.ar(Env.asr(0.03,1,0.03,0),gate);
		in = SoundIn.ar(ibs);
		sig = DelayC.ar(in, 5.0, del);
		Out.ar(obs, sig*amp*env);
	}).add;
}} //end fork & s.waitForBoot
)




(
s.options.numAudioBusChannels = 300;
s.waitForBoot{ fork{

	//Groups
	s.sendMsg(\g_new, 2000);
	s.sendMsg(\g_new, 2001, 3, 2000);
	s.sendMsg(\g_new, 2002, 3, 2001);
	s.sendMsg(\g_new, 2003, 3, 2002);
	//SynthDefs
	SynthDef( \delaylive, {
		arg ibs=0, obs=0;
		var in, sig;
		var del = \del.kr(0.5, 0.01);
		var amp = \amp.kr(0.85, 0.01);
		in = SoundIn.ar(ibs);
		sig = DelayC.ar(in, 2.0, del);
		Out.ar(obs, sig*amp);
	}).add;
	SynthDef( \filter, {
		arg ibs=0, obs=0, freq=10000, q=0.5, mode=0;
		var in, sig;
		var amp = \amp.kr(0.85, 0.01);
		in = In.ar(ibs);
		sig = BMoog.ar(in, freq, q, mode);
		Out.ar(obs, sig*amp);
	}).add;
	SynthDef( \crush, {
		arg ibs=0, obs=0, rate=44100, bits=24;
		var in, sig;
		var amp = \amp.kr(0.85, 0.01);
		in = In.ar(ibs);
		sig = Decimator.ar(in, rate, bits);
		Out.ar(obs, sig*amp);
	}).add;
	SynthDef( \ringmod, {
		arg ibs=0, obs=0, rate=0.08, modamp=0.5;
		var in, sig;
		var amp = \amp.kr(0.85, 0.01);
		in = In.ar(ibs);
		sig = DiodeRingMod.ar(in, SinOsc.ar( SinOsc.kr(rate).range(20.0, 90.0).midicps )*modamp);
		Out.ar(obs, sig*amp);
	}).add;
	SynthDef( \comb, {
		arg ibs=0, obs=0, del=0.03, dec=1.3;
		var in, sig;
		var amp = \amp.kr(0.85, 0.01);
		in = In.ar(ibs);
		sig = CombC.ar(in,3.0, del, dec);
		Out.ar(obs, sig*amp);
	}).add;
	//Triggered Sounds
	SynthDef(\ashes, {
		arg obs=0, den=50, rel=0.3, t_tr=0;
		var sig, env;
		var amp = \amp.kr(0.85, 0.01);
		env = EnvGen.ar(Env.perc(0.001, rel), t_tr);
		sig = Dust.ar(den);
		Out.ar(obs, sig*env*amp);
	}).add;
	SynthDef( \puffdaddy, {
		//add a freq arg
		arg obs=0, t_tr=0, ivc = #[3,10,14,23,28,31,32], il1=0.27,d1=0.17, il2=0.2,d2=0.14, il3=0.3,d3=0.22, il4=0.12,d4=0.11, il5=0.24,d5=0.25, il6=0.14,d6=0.19, il7=0.3,d7=0.22, pos=0, wd=2, rq=0.08, rt=0.1, dp=0.5;
		var iv1 = [3,10,14,23,28,31,32], iv2= [1,4,5,6,7,10,11], iv3= [1,6,11,17,19, 24,30], iv4= [4,6,8,10,11,14,17];
		var imp, p1,p2,p3,p4,p5,p6,p7, ivs, iv, pd1,pd2,pd3,pd4,pd5,pd6,pd7, c1,c1d, c2,c2d, c3,c3d, c4,c4d, c5,c5d, c6,c6d, c7,c7d, sig;
		var st2,st3,st4,st5,st6,st7;
		var lfo1;
		var hp;
		var pd1b;
		var amp = \amp.kr(4.0, 0.01);
		imp = T2A.ar(t_tr);
		p1 = TIRand.kr(43, 79, imp);
		ivs = [iv1, iv2, iv3, iv4];
		iv = TChoose.kr(imp, ivs);
		p2 = p1+iv[0];
		p3 = p1+iv[1];
		p4 = p1+iv[2];
		p5 = p1+iv[3];
		p6 = p1+iv[4];
		p7 = p1+iv[5];
		pd1 = 1.0/p1.midicps;
		pd2 = 1.0/p2.midicps;
		pd3 = 1.0/p3.midicps;
		pd4 = 1.0/p4.midicps;
		pd5 = 1.0/p5.midicps;
		pd6 = 1.0/p6.midicps;
		pd7 = 1.0/p7.midicps;
		c1 = CombC.ar(imp, 0.2, pd1, il1); //il1 is going to control the length of the initial impulse
		lfo1 = SinOsc.kr( 0.07 ).range(0.3, 2.7);
		c1d = CombC.ar(c1, 0.2, TRand.kr(0.08, 0.15, imp), lfo1); //d1, controls delay time, the last argument controls length of ping pong tail
		c2 = CombC.ar(imp, 0.2, pd2, il2);
		st2 = TRand.kr(0.7, 0.1);
		c2 = DelayC.ar(c2, 0.2, st2);
		c2d = CombC.ar(c2, 0.2, TRand.kr(0.1, 0.33, imp), SinOsc.kr( 0.06 ).range(0.8, 2.9));
		c3 = CombC.ar(imp, 0.2, pd3, il3);
		st3 = TRand.kr(0.7, 0.1);
		c3 = DelayC.ar(c3, 0.2, st2+st3);
		c3d = CombC.ar(c3, 0.2, TRand.kr(0.09, 0.1, imp), SinOsc.kr( 0.09 ).range(1.5, 1.8));
		c4 = CombC.ar(imp, 0.2, pd4, il4);
		st4 = TRand.kr(0.7, 0.1);
		c4 = DelayC.ar(c4, 0.4, st2+st3+st4);
		c4d = CombC.ar(c4, 0.2, TRand.kr(0.11, 0.5, imp), SinOsc.kr( 0.05 ).range(1.6, 2.1));
		c5 = CombC.ar(imp, 0.2, pd5, il5);
		st5 = TRand.kr(0.7, 0.1);
		c5 = DelayC.ar(c5, 0.4, st2+st3+st4+st5);
		c5d = CombC.ar(c5, 0.2, TRand.kr(0.08, 0.12, imp), SinOsc.kr( 0.02 ).range(0.7, 3.1));
		c6 = CombC.ar(imp, 0.2, pd6, il6);
		st6 = TRand.kr(0.7, 0.1);
		c6 = DelayC.ar(c6, 0.4, st2+st3+st4+st5+st6);
		c6d = CombC.ar(c6, 0.2, TRand.kr(0.098, 0.2, imp), SinOsc.kr( 0.07 ).range(1.1, 1.8));
		c7 = CombC.ar(imp, 0.2, pd7, il7);
		st7 = TRand.kr(0.7, 0.1);
		c7 = DelayC.ar(c7, 0.6, st2+st3+st4+st5+st7);
		c7d = CombC.ar(c7, 0.2, TRand.kr(0.12, 0.3, imp), SinOsc.kr( 0.03 ).range(0.75, 2.5));
		sig = Mix.ar([ c1*(1.0/3.0), c1d*(1.0/3.0),  c2*(1.0/3.0),c2d*(1.0/3.0), c3*(1.0/3.0),c3d*(1.0/3.0), c4*(1.0/4.0),c4d*(1.0/3.0), c5*(1.0/3.0),c5d*(1.0/3.0), c6*(1.0/3.0),c6d*(1.0/3.0), c7*(1.0/3.0),c7d*(1.0/3.0) ]);

		hp = RHPF.ar(sig, SinOsc.kr(0.03).range(3000, 12000), rq);
		hp = JPverb.ar(hp, rt, dp);

		sig = RLPF.ar(sig, SinOsc.kr(0.03).range(1200, 12000), rq);
		sig = Mix.ar([sig, hp*0.33]);

		Out.ar(obs, sig*amp);
	}).add;
	SynthDef( \janus, {
		arg obs=0, t_tr=0, amp=0.5;
		var imp = T2A.ar(t_tr);
		var o1 = SinOsc.kr(0.311).range(0.0, 0.25);
		var o2 = SinOsc.kr(0.07).range(0.0, 0.25);
		var o3 = SinOsc.kr(0.11).range(0.0, 0.25);
		var o4 = SinOsc.kr(0.085).range(0.0, 0.25);
		var o5 = SinOsc.kr(0.23).range(0.0, 0.25);
		var dur = TRand.kr(3.0, 9.0,imp);
		var p1 = TIRand.kr(40, 80, imp);
		var p2 = p1 + TIRand.kr(1, 10, imp);
		var p3 = p1 + TIRand.kr(1, 10, imp);
		var f1 = p1.midicps;
		var f2 = p2.midicps;
		var f3 = p3.midicps;
		var h = [2,3,4,5,6,7,8,9,10,11,12,13,14];
		var j1 = TIRand.kr(0,10,imp);
		var j2 = TIRand.kr(0,10,imp);
		var j3 = TIRand.kr(0,10,imp);
		var h1 = h.scramble.copyRange(3,5).addFirst(1);
		var h2 = h.scramble.copyRange(7,9).addFirst(1);
		var h3 = h.scramble.copyRange(0,2).addFirst(1);
		var s1 = Ringz.ar( imp, f1*h1, dur,[o5, o1, o2, o3] );
		var s2 = Ringz.ar( imp, f2*h2, dur,[o3, o5, o4, o2]);
		var s3 = Ringz.ar( imp, f3*h3, dur,[o2, o1, o5, o3]);
		var fe = EnvGen.ar(Env.perc(0.002, dur+(dur*0.7), 1, 0),imp,doneAction:0);
		var f1b = (p1+1).midicps;
		var s1b = Ringz.ar( imp, f1b, dur,[o5, o1, o2, o3]);
		var f2b = (p2+1).midicps;
		var s2b = Ringz.ar( imp, f2b, dur,[o3, o5, o4, o2]);
		var f3b = (p3+1).midicps;
		var s3b = Ringz.ar( imp, f3b, dur,[o2, o1, o5, o3]);
		s1 = Mix.ar(s1);
		s2 = Mix.ar(s2);
		s3 = Mix.ar(s3);
		//Out.ar(och, Mix.ar([s1*(1.0/6.0), s2*(1.0/6.0), s3*(1.0/6.0), s1b*(1.0/6.0), s2b*(1.0/6.0), s3b*(1.0/6.0)])*fe);
		Out.ar(obs, (Mix.ar([s1*0.3, s2*0.3, s3*0.3])*fe) * amp);
		//Out.ar(0, Mix.ar([s1*(1.0/6.0), s1b*(1.0/6.0)])*fe);
	}).add;
	SynthDef(\stochsynth, {
		arg obs=0,ampdist = 4.5, durdist = 1.5, adparam = 1, ddparam = 1, minfreq = 50, maxfreq = 6580, ampscale = 1.0, durscale = 0.5, initCPs = 12, knum, mul = 0.5, add = 0, envdur = 2, envdens = 7, atk=0.001, amp = 4.1, rel = 0.5;
		//'one-slider' variables
		//var dur = \dur.kr(0.0).linexp(0.0, 1.0, 0.02, 3.02);
		//var dens = \dens.kr(0.0).linlin(0.0, 1.0, 37.0, 9.02);
		//var crv = \crv.kr(0.0).linexp(0.0, 1.0, 6.0, 4.0);
		//var res = \res.kr(0.0).linlin(0.0, 1.0, 0.0, 0.6);
		//'one-slider' variables
		var lfo = LFTri.kr(0.1).range(0.0, 1.0);
		var dur = lfo.linexp(0.0, 1.0, 0.02, 3.02);
		var dens = lfo.linlin(0.0, 1.0, 37.0, 9.02);
		var crv = lfo.linexp(0.0, 1.0, 6.0, 4.0);
		var res = lfo.linlin(0.0, 1.0, 0.0, 0.6);

		var env = Env.perc(0.0001, dur, 0.25, -32);
		var gate = Dust.kr(dens);
		var env_gen = EnvGen.kr(env, gate, doneAction: 0);
		var envgate = Dust.kr(envdens);
		//var ampenv = EnvGen.kr(Env.perc(0.001, envdur, curve: crv), envgate);
		//var ampenv = EnvGen.kr(Env.perc(atk, TRand.kr(0.08, 1.2, Dust.kr(1)), curve: crv), envgate);
		var ampenv = EnvGen.kr(Env.perc(atk, rel, curve: crv), \t_tr.kr(0, 0.0));
		var gd = Gendy1.ar( ampdist, durdist, adparam, ddparam, minfreq, maxfreq, ampscale, durscale, initCPs, knum, env_gen, add );
		var moog = MoogLadder.ar(gd, TIRand.kr(200, 10000, envgate),res);
		var ring = Ringz.ar(gd, TRand.kr(80, 1500, Dust.kr(1.4)), TRand.kr(0.2, 3, Dust.kr(1.4)));
		var mix = Mix.ar([gd, ring*0.01]);
		var rmod = SinOsc.ar(SinOsc.kr(0.03, 0, 400, 600));
		var pan = Pan2.ar([moog, DelayC.ar(moog, delaytime:0.008)], SinOsc.kr(TIRand.kr(0.5, 2.5,Dust.kr(1.0) )));//spatialize
		Out.ar(obs, moog*ampenv*amp);
	}).add;
	SynthDef(\drumline, {
		arg rate1=11.0, rate2=10.0, rate3=12.0, gdur=0.03, ffreq=5000, frez=0.5, fr1=300, fr2=12000, amp=1.5, gate=0, dur=0.01, crv=0, pan=0;
		var noise, grainrate1, grainrate2, grainrate3, grainenv1, grainenv2, grainenv3, filterednoise1, filterednoise2, filterednoise3, freqchgrate1, freqchgrate2, freqchgrate3, s1, s2, s3, output, oenv, envtrig, atk;
		atk = PinkNoise.ar()*EnvGen.ar(Env.perc(attackTime:0.005, releaseTime:0.01));
		envtrig = \t_tr.kr(0,0);
		oenv = EnvGen.ar( Env.perc(attackTime:0.005, releaseTime:dur, curve:crv), envtrig, doneAction:0);
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
		filterednoise1 = MoogLadder.ar( in:noise, ffreq:TRand.kr(fr1, fr2, freqchgrate1), res:frez, mul:3 );
		filterednoise2 = MoogLadder.ar( in:noise, ffreq:TRand.kr(fr1, fr2, freqchgrate2), res:frez, mul:3 );
		filterednoise3 = MoogLadder.ar( in:noise, ffreq:TRand.kr(fr1, fr2, freqchgrate3), res:frez, mul:3 );
		s1 = filterednoise1*grainenv1;
		s2 = filterednoise2*grainenv2;
		s3 = filterednoise3*grainenv3;
		output = Mix.ar( [s1, s2, s3, atk] );
		//output = Pan2.ar(output, pan);
		Out.ar(0, output*amp*oenv);
	}).add;
	SynthDef(\krunkd, {
		arg obs=0, rate=0.7, res=9.8, igain=0.01, type=0, nl=0.33, f1=200, f2=210, decay=0.9, amp=0.5, rq=0.006, atk=0.001, rel=0.5, crv = -4, pan=0;
		var filter, impulse, ftrig, filter2, output, f1b, f2b, freq, oenv;
		oenv = EnvGen.ar(Env.perc(atk, rel, crv), \t_tr.kr(0, 0.0001), doneAction:0);
		f1b = (f1.cpsmidi-1).midicps;
		f2b = (f2.cpsmidi-1).midicps;
		ftrig = Impulse.kr(rate);
		freq = TRand.kr(f1, f2, ftrig);
		impulse = K2A.ar(1);
		filter = DFM1.ar( impulse, TRand.kr(f1, f2, ftrig), res, igain, type, nl );
		filter2 = DFM1.ar( impulse, TRand.kr(f1b, f2b, ftrig), res, igain, type, nl );
		output = Mix.ar([filter, filter2]) * 0.2;
		output = Decay2.ar(output, 0.001, decay, output);
		output = output*0.06;
		//output = Pan2.ar(output, pan);
		Out.ar(obs, output*amp*oenv);
	}).add;

	SynthDef(\krunkd, {
		arg obs=0, rate=0.7, res=9.8, igain=0.01, type=0, nl=0.33, f1=200, f2=210, decay=0.9, amp=0.5, rq=0.006, atk=0.001, rel=0.5, crv = -4, pan=0;
		var filter, impulse, ftrig, filter2, output, f1b, f2b, freq, oenv;
		oenv = EnvGen.ar(Env.perc(atk, rel, crv), \t_tr.kr(0, 0.0001), doneAction:2);
		f1b = (f1.cpsmidi-1).midicps;
		f2b = (f2.cpsmidi-1).midicps;
		ftrig = Impulse.kr(rate);
		freq = TRand.kr(f1, f2, ftrig);
		impulse = K2A.ar(1);
		filter = DFM1.ar( impulse, TRand.kr(f1, f2, ftrig), res, igain, type, nl );
		filter2 = DFM1.ar( impulse, TRand.kr(f1b, f2b, ftrig), res, igain, type, nl );
		output = Mix.ar([filter, filter2]) * 0.2;
		output = Decay2.ar(output, 0.001, decay, output);
		output = output*0.06;
		//output = Pan2.ar(output, pan);
		Out.ar(obs, output*amp*oenv);
	}).add;

	0.1.wait;
	//Initial Synths
	//DSP on nodes 5000+
	s.sendMsg(\s_new, \delaylive, 5000, 0, 2001, \del, 0.5);
	s.sendMsg(\s_new, \filter, 5001, 0, 2002, \ibs, 100, \obs, 0);
	s.sendMsg(\s_new, \crush, 5002, 0, 2002, \ibs, 101, \obs, 0);
	s.sendMsg(\s_new, \ringmod, 5003, 0, 2002, \ibs, 102, \obs, 0);
	s.sendMsg(\s_new, \comb, 5004, 0, 2002, \ibs, 103, \obs, 0);
	//hp lp bp filter (moogFF)
	//bit crush
	//pv?
	//Triggered Sounds on Node 6000+
	s.sendMsg(\s_new, \ashes, 6000, 0, 2000,\obs, 0);
	s.sendMsg(\s_new, \puffdaddy, 6001, 0, 2000,\obs, 0);
	s.sendMsg(\s_new, \janus, 6002, 0, 2000, \obs, 0, \amp, 1 );
	s.sendMsg(\s_new, \stochsynth, 6003, 0, 2000);
	s.sendMsg(\s_new, \drumline, 6004, 0, 2000);
	s.sendMsg(\s_new, \krunkd, 6005, 0, 2000);

	0.1.wait;
	{s.meter}.defer;
}}
)
//DSP
//delaylive
//reset to only delayed sig
s.sendMsg(\n_set, 5000, \obs, 0, \del, 0.5);
//filter
(
//send delayed sig to bus 100
s.sendMsg(\n_set, 5000, \obs, 100);
//filter delayed sig
s.sendMsg(\n_set, 5001, \ibs, 100, \obs, 0, \freq, 300, \q, 0.9, \mode, 0);
)
//crush
(
//send delayed sig to bus 101
s.sendMsg(\n_set, 5000, \obs, 101);
//crush delayed sig
s.sendMsg(\n_set, 5002, \ibs, 101, \obs, 0, \rate, 2000, \bits, 2);
)
//ringmod
(
//send delayed sig to bus 102
s.sendMsg(\n_set, 5000, \obs, 102);
//ringmod delayed sig
s.sendMsg(\n_set, 5003, \ibs, 102, \obs, 0, \rate, 0.2, \modamp, 1.5);
)
//comb
(
//send delayed sig to bus 103
s.sendMsg(\n_set, 5000, \obs, 103);
//ringmod delayed sig
s.sendMsg(\n_set, 5004, \ibs, 103, \obs, 0);
)


//Trigger Sounds
//ashes
s.sendMsg(\n_set, 6000, \t_tr, 1, \rel, 0.9, \den, 100, \amp, 1.0);
//puffdaddy
s.sendMsg(\n_set, 6001, \t_tr, 1);
//janus
s.sendMsg(\n_set, 6002, \t_tr, 1, \obs, 102);
//stochsynth
s.sendMsg(\n_set, 6003, \t_tr, 1, \rel, 1.2);
//drumline
s.sendMsg(\n_set, 6004, \t_tr, 1, \dur, 0.8, \amp, 3);
//krunkd
(
var freq, dur; freq = rrand(30, 80); dur = rrand(0.2, 1.2); s.sendMsg(\n_set, 6005, \t_tr, 1, \f1, freq.midicps, \f2, (freq+1).midicps, \decay, dur, \rel, dur, \amp, 0.5);
)


SynthDef(\ns, {Out.ar(\obs.kr(102, 0), WhiteNoise.ar())}).add;
SynthDef(\ns, {|del=0.01, dec=0.1| Out.ar(\obs.kr(0, 0),
	CombC.ar( WhiteNoise.ar(), 2.0, del, dec)
)}).add;
s.sendMsg(\s_new, \ns, 7000, 0, 2000, \obs, 0);
s.sendMsg(\n_set, 7000, \del, 0.039, \dec, 3.5)
s.queryAllNodes

s.sendMsg(\n_free, 5003);
s.sendMsg(\n_free, 7000);

