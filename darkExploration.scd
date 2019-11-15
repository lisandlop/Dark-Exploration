// DARK EXPLORATION
// Lisa Andersson López & Thelma Svenns

(
o = Server.local.options;
o.numOutputBusChannels = 8;
s.boot; //or reboot if you have already booted the server
)
s.meter

thisProcess.openUDPPort(8000);
thisProcess.openPorts; // this will returns all open ports

OSCFunc.trace(true);
OSCFunc.trace(false);

(
a = OSCFunc(
	{|msg| msg.postln}, //function --> takes in msg = message as an Array
	'/RigidBody', // path
	recvPort:8000); //port on which messages will be received
)
a.free;

OSCFunc({|msg| msg.postln}, '/RigidBody', recvPort:8000).oneShot; // once only
OSCFunc({|msg| msg[2].postln}, '/RigidBody', recvPort:8000).oneShot;
s.plotTree; // see all the synths declared
s.freeAll; // free the server from synths

// Buffer array inserting an entire folder of sound files
(
~bufArr = PathName("/Users/op_csc-studio/Documents/LISA&THELMA/MIX/").files.collect{|file|
	Buffer.read(s, file.fullPath);
};
)

(
SynthDef(\play, {
	arg amp = 1, buf = 0, rate = 1, loop = 1;
	var sig;
	sig = PlayBuf.ar(8, buf, rate, loop:loop);
	Out.ar([0,1,2,3,4,5,6,7], sig*amp);
}).add;
)

(
~synths = ~bufArr.collect{|buffer|
	Synth(\play, [\buf, buffer]);
};
~osc = OSCFunc({|msg|
	~synths[0].set(\amp, msg[4].linlin(-200, 1000, 0.1, 1.1)); // drums z+
	~synths[1].set(\amp, msg[2].linlin(-1000, 200, 2, 0.1)); // guitar x+ (-)
	~synths[2].set(\amp, msg[4].linlin(-1000, 200, 2, 0.1)); // trombone z-
	~synths[3].set(\amp, msg[2].linlin(-200, 1000, 0.1, 2.5)); // base x- (+)
},
'/RigidBody',
recvPort:8000);
)

(
~synths.do{|synth|
	synth.free;
};
)