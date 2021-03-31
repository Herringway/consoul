module consoul.common;

private auto luminosity(RGBA32 colour) {
	return 0.2126 * (cast(float)colour.red / ubyte.max) +
		0.7152 * (cast(float)colour.green / ubyte.max) +
		0.0722 * (cast(float)colour.blue / ubyte.max);
}

struct RGBA32 {
	ubyte red;
	ubyte green;
	ubyte blue;
	ubyte alpha;
	static auto randomColour() @safe {
		import std.random : uniform;
		return RGBA32(uniform!(typeof(red))(),uniform!(typeof(green))(),uniform!(typeof(blue))(),0);
	}
	auto randomComplementaryColour() const @safe {
		import std.random : uniform;
		static immutable gamma = 2.2;
		return (this.luminosity > 0.5) ?
			RGBA32(cast(ubyte)uniform(0,127),cast(ubyte)uniform(0,127),cast(ubyte)uniform(0,127),0) :
			RGBA32(cast(ubyte)uniform(127, 255),cast(ubyte)uniform(127, 255),cast(ubyte)uniform(127, 255),0);
	}
	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		sink.formattedWrite!"#%02X%02X%02X"(red,green,blue);
	}
}
@safe unittest {
	import std.conv : text;
	import std.math : abs;
	import std.random : rndGen, unpredictableSeed;
	auto seed = unpredictableSeed;
	rndGen.seed = seed;
	auto c1 = RGBA32.randomColour;
	auto c2 = c1.randomComplementaryColour;
	auto luminosityDifference = abs(c1.luminosity - c2.luminosity);
	assert(luminosityDifference > 0.1, "Illegible random complementary colour generated - seed "~seed.text);

	// Ensure both dark/light paths are covered
	rndGen.seed = 2_927_724_004;
	with (RGBA32.randomColour) {
		randomComplementaryColour();
	}
	rndGen.seed = 4_288_425_729;
	with (RGBA32.randomColour) {
		randomComplementaryColour();
	}
}
