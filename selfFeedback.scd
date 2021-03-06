(
SynthDef(\delaywfb,{
	arg obs,ibs, del=0.2, fbdel=0.0;
	var src, loc;
	var amp = \amp.kr(1.0, 0.03);
	var fbamp = \fbamp.kr(0.0, 0.03);
	src = In.ar(ibs);
	src = DelayN.ar(src, 2.2, del); //delay source
	loc = (LocalIn.ar()*fbamp) + src; // read feedback, add to source
	loc = DelayN.ar(loc, 2.2, fbdel); // delay feedback
	LocalOut.ar(loc* 0.8);
	Out.ar(obs,loc*amp);
}).add;
)
a = Synth(\delaywfb, [\ibs, 1, \obs, 0, \fbdel, 0.1, \amp, 0.5]);
a.set(\fbamp, 0.7, \fbdel, 0.03);
a.set(\fbamp, 1.20, \fbdel, 0.082);
a.set(\fbamp, 0.91, \fbdel, 0.012);
a.free;


//Map to some control busses and control with lfos

SynthDef(\line, 