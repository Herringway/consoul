module consoul.ansi;

import consoul.common;

import std.range : isOutputRange;

private enum escapeChar = '\x1B';

/++
+ Colourize some text.
+
+ Params:
+ 		fmt = Format string to use with the value.
+		f = Foreground (text) colour.
+		b = Background colour.
+		val = Value to print. Must be compatible with fmt.
+
+ Returns: A wrapper struct with toString() designed for console output with colour.
+/
auto colouredText(string fmt = "%s", T)(RGBA32 f, RGBA32 b, T val) {
	return ColouredText!(fmt, T)(f, b, val);
}
/// ditto
auto colouredText(string fmt = "%s", T)(RGBA32 f, T val) {
	return ColouredText!(fmt, T)(f, val);
}
template simpleColour(RGBA32 f) {
	auto simpleColour(T)(T val) {
		return ColouredText!("%s", T)(f, val);
	}
}
template simpleColour(RGBA32 f, RGBA32 b) {
	auto simpleColour(T)(T val) {
		return ColouredText!("%s", T)(f, b, val);
	}
}
alias black = simpleColour!(RGBA32(0, 0, 0));
alias red = simpleColour!(RGBA32(170, 0, 0));
alias green = simpleColour!(RGBA32(0, 170, 0));
alias yellow = simpleColour!(RGBA32(170, 85, 0));
alias blue = simpleColour!(RGBA32(0, 0, 170));
alias magenta = simpleColour!(RGBA32(170, 0, 170));
alias cyan = simpleColour!(RGBA32(0, 170, 170));
alias white = simpleColour!(RGBA32(170, 170, 170));
alias brightBlack = simpleColour!(RGBA32(85, 85, 85));
alias brightRed = simpleColour!(RGBA32(255, 85, 85));
alias brightGreen = simpleColour!(RGBA32(85, 255, 85));
alias brightYellow = simpleColour!(RGBA32(255, 255, 85));
alias brightBlue = simpleColour!(RGBA32(85, 85, 255));
alias brightMagenta = simpleColour!(RGBA32(255, 85, 255));
alias brightCyan = simpleColour!(RGBA32(85, 255, 255));
alias brightWhite = simpleColour!(RGBA32(255, 255, 255));

struct ColouredText(string fmt, T) {
	RGBA32 fg;
	RGBA32 bg;
	bool hasBG;
	bool hasFG;
	T thing;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		if (!hasFG & !hasBG) {
			sink.formattedWrite!fmt(thing);
		} else if (hasBG) {
			sink.formattedWrite!(escapeChar~"[38;2;%s;%s;%sm"~escapeChar~"[48;2;%s;%s;%sm"~fmt~escapeChar~"[0m")(fg.red, fg.green, fg.blue, bg.red, bg.green, bg.blue, thing);
		} else {
			sink.formattedWrite!(escapeChar~"[38;2;%s;%s;%sm"~fmt~escapeChar~"[0m")(fg.red, fg.green, fg.blue, thing);
		}
	}
	package this(RGBA32 f, RGBA32 b, T str) @safe pure nothrow @nogc {
		fg = f;
		bg = b;
		thing = str;
		hasBG = true;
		hasFG = true;
	}
	package this(RGBA32 f, T str) @safe pure nothrow @nogc {
		fg = f;
		thing = str;
		hasFG = true;
	}
}
///
@safe pure unittest {
	import std.conv : text;
	import std.outbuffer : OutBuffer;
	ColouredText!("%s", ulong)().toString(new OutBuffer);
	assert(colouredText!"Test %s"(RGBA32(128,128,128), RGBA32(128,128,128), 3).text == "\x1B[38;2;128;128;128m\x1B[48;2;128;128;128mTest 3\x1B[0m");
	assert(colouredText!"Test %s"(RGBA32(128,128,128), 3).text == "\x1B[38;2;128;128;128mTest 3\x1B[0m");
	assert(3.red.text == "\x1B[38;2;170;0;0m3\x1B[0m");
}

private struct StyledText(string fmt, string sequence, string endSequence = "0", T) {
	T thing;

	void toString(T)(T sink) const if (isOutputRange!(T, const(char))) {
		import std.format : formattedWrite;
		sink.formattedWrite(escapeChar~"["~sequence~"m"~fmt~escapeChar~"["~endSequence~"m", thing);
	}
}
///
@safe pure unittest {
	import std.outbuffer;
	StyledText!("%s", "1", "0", ulong)().toString(new OutBuffer);
}
alias underlined = underlinedText;
auto underlinedText(string fmt = "%s", T)(T val) {
	return StyledText!(fmt, "4", "24", T)(val);
}
///
@safe pure unittest {
	import std.conv : text;
	assert(underlinedText!"Test %s"(3).text == "\x1B[4mTest 3\x1B[24m");
}
alias italicized = italicText;
auto italicText(string fmt = "%s", T)(T val) {
	return StyledText!(fmt, "3", "23", T)(val);
}
///
@safe pure unittest {
	import std.conv : text;
	assert(italicText!"Test %s"(3).text == "\x1B[3mTest 3\x1B[23m");
}

alias bolded = boldText;
auto boldText(string fmt = "%s", T)(T val) {
	return StyledText!(fmt, "1", "0", T)(val);
}
///
@safe pure unittest {
	import std.conv : text;
	assert(boldText!"Test %s"(3).text == "\x1B[1mTest 3\x1B[0m");
}

auto strikethroughText(string fmt = "%s", T)(T val) {
	return StyledText!(fmt, "9", "0", T)(val);
}
///
@safe pure unittest {
	import std.conv : text;
	assert(strikethroughText!"Test %s"(3).text == "\x1B[9mTest 3\x1B[0m");
}
