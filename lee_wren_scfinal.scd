///wren lee
///#WhySoWhite

///artist statement
/*
#WhySoWhite
As a queer, Chinese American filmmaker, I am passionate about media representation because I don’t often see people like me in the media. My project #WhySoWhite highlights the issue of racial diversity within the Academy of Motion Picture Arts and Science’s Best Original Screenplay award since 2000. I’m focusing on the Best Original Screenplay because 1) I am a screenwriter by trade and 2) screenwriters are the ones who start the story. The begininng of the piece is clapping to highlight the irony of the Oscars supposedly being an award show rewarding the best and brightest filmmakers yet only actually rewards the white, straight, male filmmakers. The sounds of the writers will be sonified based on their birth place in longitudinal degrees, with the diverse writers (see notes) distinguished by lower values.

I imagine this piece to be an installation paired with video clips from the award ceremony, especially the 2015 Oscars that inspired the #OscarsSoWhite hashtag when all 20 actor nominees were white. The visuals and audio in conjunction highlight the lack of racial diversity in the past 20 years and emphasize the importance of creating more opportunities for BIPOC creators.
*/

///introduction
/*
It wasn’t until 2017 that a Black screenwriter won Best Original Screenplay. 89 Academy Awards had passed before that moment happened.
Guess Crash didn’t fix Hollywood’s diversity issue when it won Best Picture
¯\_(ツ)_/¯

also please note there are a lot of comments related to the data
*/

///instructions
/*
1. load the server
2. load clapping definition
3. play clapping all the way through
4. load writers
5. play writers all the way through
*/

///patch
s.boot; //1. load the server

//clapping
(
	SynthDef(\clap,{
		arg output=0, vari=0, acc = 1;
		var noiz, amp, filt1, filt2, aEnv, fEnv, tap;

		noiz = WhiteNoise.ar;
		aEnv = EnvGen.kr(Env.perc(0.01, 0.4, 1, -10).delay(Rand(0,0.02)), 1, doneAction:2);
		fEnv = EnvGen.kr(Env.perc(0, 0.2, 1, -8), 1, doneAction:0)*600
		+ ((1100 + Rand(-100,300)) - (vari*100));

		filt1 = BPF.ar(noiz, fEnv, 0.4 - (vari * 0.1) )*0.4;
		filt2 = BPF.ar(noiz, 1000+ Rand(-50,50), 0.2)*1;

		acc = clip2((acc + 0.5) ,1);
		amp = ( (filt1+filt2) ) ;
		amp = RLPF.ar( amp, 10000 , 0.9)*2;
		amp = amp.softclip * aEnv * acc;
		Out.ar(output, amp);
	}).add;

SynthDef(\reverb,{
		arg bus1, bus2; //bus = spatialization aspect
		var in1, in2, mix;
		in1 = In.ar(bus1);
		in2 = In.ar(bus2);
		mix = FreeVerb2.ar(in1, in2, 0.2, 0.7, 0.98);
		Out.ar(0, mix);
	}).add;
)//2. load the clapping definition

(
	var tempo, clapPattern, accPattern, performer1, performer2, numRepeates,
		effDef, bus1, bus2, group1, group2;

	tempo = 100/30; //slower clapping
	numRepeates = 10; //the claps cycle through pattern 10 times

    //clapping sounds all around to symbolize being in the center of the dolby theater where the awards are held
	bus1 = Bus.audio(s,1);
	bus2 = Bus.audio(s,1);
	group1 = Group.head(s);
	group2 = Group.after(group1);

    //generates continual clapping sounds with rests (0)
    clapPattern = [1,0,1,0,1,0,1,0];
    accPattern = [0,1,0,1,0,1,0,1];

	effDef = Synth.head(group2, \reverb, [\bus1, bus1.index, \bus2, bus2.index]);//creates a synth based on the synthdef above

	performer1 = Pbind(
		\instrument, \clap,
		\group, group1,
		\output, bus1.index,//output to left
		\vari, 1,
	    \degree,Pseq(clapPattern,numRepeates),
		\dur, 0.4
	);

	performer2 = Pbind(
		\instrument, \clap,
		\group, group1,
		\output, bus2.index,//output to right
		\vari, 0,
		\acc,Pseq(accPattern,numRepeates),
		\dur, 0.4 //shorter claps
	);

	performer1.play(TempoClock(tempo));
	performer2.play(TempoClock(tempo));
)//3. play clapping

(
//initializes array of data
o = o ?(); //o stands for oscars
o.diversewriters = ();
o.diversewriters.timestamps = (1 .. 12);

o.diversewriters.datatypes = (//the data here is determined by the longitude of the location of the birthplace of the writer
diverseWritersCount: [
		//diverse writers here are bipoc, female, lgbtq, or international (with some limitations)
		//diverse writers are within the 30-50 range
		63, //cameron crowe "almost famous" - palm springs, california, usa; i added 30 to make it audible, the original number is 33
		61, //julian fellowes "gosford park" - cairo, egypt; this is on the east of greenwich and i added 30 to make it audible, the original number is 31. although born in cairo and of british nationality, i don't count fellowes as diverse because he's a white anglo-saxon male
		63, //pedro almodóvar "talk to her" - calzada de calatrava, spain; admittedly i'm not sure whether or not almodóvar counts as white or not because he's an international director and intl directors don't have a lot of rep in the oscars, i don't count him as diverse because he's from a colonizing country spain; the original number is 3
		34, //sofia coppola "lost in translation" - new york city, new york, usa; the original value is 74
		74, //charlie kaufman "eternal sunshine of the spotless mind" - new york city, new york, usa
		81, //paul haggis "crash" - london, ontario, canada; although canada is international, haggis has lived in the us for a long time, and "crash" itself is a deeply us-focused movie, so i don't count him as diverse
		77, //michael arndt "little miss sunshine" - mclean, virginia, usa
		47, //diablo cody "juno" - lemont, illinois, usa; the original value is 87
		41, //dustin lance black "milk" - sacramento county, california, usa; the original value is 121
		74, //mark boal "the hurt locker" - new york city, new york, usa
		60, //david seidler "the king's speech" - london, england; this value should be 0 because of the location but is 60 because it needs to be audible; similar to fellowes, i count seidler as non-diverse even though he's born abroad
		74, //woody allen "midnight in paris" - new york city, new york, usa
		83, //quentin tarntino "django unchained" - knoxville, tennessee, usa
		74, //spike jonze "her" - new york city, new york, usa
		59, //alejandro gonzález iñárritu "birdman" - mexico city, mexico; the original value is 99
		75, //josh singer "spotlight" - philadelphia, pennsylvania, usa
		74, //kenneth lonergan "manchester by the sea" - new york city, new york, usa
		44, //jordan peele "get out" - new york city, new york, usa; the original value is 74
		74, //nick vallelonga "green book" - new york city, new york, usa
		48, //bong jong-ho "parasite" - daegu, south korea; the original value is 128
	]
);
o.getHData = { |o, datatype| o.diversewriters.datatypes[datatype]};
)//4. load writers

(Pbindef( //pushes all of the sound into one stream
\exec,
\note, Pseq(o.getHData(\diverseWritersCount)),
\octave, 0.5,
\dur,0.8
).play;
)//5. play writers

///notes
/*
-sources-
the clapping code is adapted from: https://gist.github.com/44kwm20/343761bb8fb4e82d6ce9
the array code is adapted from nikita and cassidy's group project

source for info from artist statement https://www.nytimes.com/2020/02/06/movies/oscarssowhite-history.html
source for screenwriter data https://en.wikipedia.org/wiki/Academy_Award_for_Best_Original_Screenplay#2000s

i used wikipedia for the longitude and birth place info. i used birth place because childhood upbringing is key for some writers in developing their voice and themes.
also, random note, but so many writers are from new york city

-diversity-
i struggled with identifying some writers as 'diverse' or not. does almodóvar count as diverse because he's from spain? it made me wonder who is white and not white. white itself is a difficult category because it is so binary. there are few people, if any, who are purely white. and even if you describe white as european, europe is so different.
this made me rethink my assumptions about race and ethnicity. who do we view as diverse? why do we view them as diverse? how does viewing people on a diverse-non-diverse binary spectrum complicate inclusion and equity? all interesting questions
*/

///erasure poem
//title -true diversity is hard to get
WhiteNoise
bus1, bus2;
mix;

    bi d
		e
time

d  ivers   it         y

diverseWritersCount
0