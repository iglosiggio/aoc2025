#let small(body) = context {
  text(size: text.size * 0.8, body)
}
#set page(
  paper: "a4",
  numbering: "1",
)
#set text(lang: "es")
#set par(justify: true)

#let enumerate(arr) = range(arr.len()).zip(arr)

#let log-id = counter("log-id")
#let dbg(..args) = {
  let named = args.named().pairs().map(((k, v)) => [#k = #v])
  let positional = args.pos().map(v => [#v])
  [[#log-id.display()] ]
  log-id.step()
  (named + positional).join(", ")
  linebreak()
}
#let code(body) = raw(lang: "typc", body)

#let globals = state("globals", (dbg: dbg, enumerate: enumerate))

#let label-options = (
  fill: gradient.linear(dir: ttb, luma(225), luma(245)),
  inset: 8pt,
  below: 0pt,
  radius: (top: 6pt),
)
#let body-options = (
  fill: luma(245),
  inset: 8pt,
  width: 100%,
  radius: (bottom: 6pt, top-right: 6pt),
)

#show raw.where(lang: "definition"): it => box({
  log-id.update(0)
  block(..label-options, [*Code*])
  block(..body-options, raw(lang: "typc", it.text))
  globals.update(currentGlobals => {
    (: ..currentGlobals, ..eval(scope: currentGlobals, it.text))
  })
})

#show raw.where(lang: "repl"): it => context {
  log-id.update(0)
  box({
    block(..label-options, [*Code*])
    block(..body-options, raw(lang: "typc", it.text))
  })
  box({
    block(..label-options, [*Result*])
    block(..body-options, [#eval(scope: globals.get(), it.text)])
  })
}

#show raw.where(lang: "data"): it => {
  raw(it.text)
  globals.update(currentGlobals => {
    let data = it.text
    let datas = currentGlobals.at("datas", default: ())
    (: ..currentGlobals, data: data, datas: (data, ..datas))
  })
}

#show heading: it => {
  if it.body == [Part One] or it.body == [Part Two] {
    globals.update(v => (: ..v, data: none, datas: ()))
  }
  it
}
= Advent of Code 2024

== Pruebas iniciales

Una cosa que necesito es una forma de escribir código que se muestre
highlighteada y al mismo tiempo se evalúe. Tengo una solución medio bestia que
me permite escribir definiciones por un lado:

```definition
let x = 0
let y = 1
(x: x, y: y)
```

E invocaciones al REPL por otro:

```repl
[El valor de $X$ es #x. El valor de $Y$ es #y]
```

El problema de esta técnica es que hay que listar de forma explícita los
símbolos que se exportan en cada bloque.

```definition
x = x + 1
y = y + 1
(x: x, y: y)
```

Y que las llamadas al repl no tienen side-effects:

```repl
x = x + 1
y = y + 1
(x, y)
```

```repl
x = x + 1
y = y + 1
(x, y)
```

== Primer ejercicio del año pasado

=== Day 1: Trebuchet?!

Something is wrong with global snow production, and you've been selected to
take a look. The Elves have even given you a map; on it, they've used stars to
mark the top fifty locations that are likely to be having problems.

You've been doing this long enough to know that to restore snow operations, you
need to check all fifty stars by December 25th.

Collect stars by solving puzzles. Two puzzles will be made available on each
day in the Advent calendar; the second puzzle is unlocked when you complete the
first. Each puzzle grants one star. Good luck!

You try to ask why they can't just use a weather machine ("not powerful
enough") and where they're even sending you ("the sky") and why your map looks
mostly blank ("you sure ask a lot of questions") and hang on did you just say
the sky ("of course, where do you think snow comes from") when you realize that
the Elves are already loading you into a trebuchet ("please hold still, we need
to strap you in").

As they're making the final adjustments, they discover that their calibration
document (your puzzle input) has been *amended* by a very young Elf who was
apparently just excited to show off her art skills. Consequently, the Elves are
having trouble reading the values on the document.

The newly-improved calibration document consists of lines of text; each line
originally contained a specific *calibration value* that the Elves now need to
recover. On each line, the calibration value can be found by combining the
*first digit* and the *last digit* (in that order) to form a single *two-digit
number*.

For example:

```data
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
```

In this example, the calibration values of these four lines are `12`, `38`,
`15`, and `77`. Adding these together produces `142`.

Consider your entire calibration document. *What is the sum of all of the
calibration values?*

=== Resolución

Tengo un macro que pone el último input como global:
```repl
data
```

Intento la resolución:

```definition
let ejercicio(data) = {
  let result = 0
  let lines = data.split()
  for line in lines {
    let matches = line.matches(regex("\d"))
    result = result + int(matches.first().text + matches.last().text)
  }
  result
}
(ejercicio: ejercicio)
```

```repl
ejercicio(data)
```

=== Data posta

```repl
let data = read("2023-example.data")
ejercicio(data)
```

== Part Two

Your calculation isn't quite right. It looks like some of the digits are
actually *spelled out with letters*: `one`, `two`, `three`, `four`, `five`,
`six`, `seven`, `eight`, and `nine` also count as valid "digits".

Equipped with this new information, you now need to find the real first and
last digit on each line. For example:

```data
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
```

In this example, the calibration values are `29`, `83`, `13`, `24`, `42`, `14`,
and `76`. Adding these together produces `281`.

*What is the sum of all of the calibration values?*

```definition
let ejercicio-2(data) = {
  let text2num = (
    zero: 0,
    one: 1,
    two: 2,
    three: 3,
    four: 4,
    five: 5,
    six: 6,
    seven: 7,
    eight: 8,
    nine: 9,
  )
  let lines = data.split()
  let result = 0
  for line in lines {
    let matches = (
        line.matches(regex("\d"))
      + line.matches(regex("zero"))
      + line.matches(regex("one"))
      + line.matches(regex("two"))
      + line.matches(regex("three"))
      + line.matches(regex("four"))
      + line.matches(regex("five"))
      + line.matches(regex("six"))
      + line.matches(regex("seven"))
      + line.matches(regex("eight"))
      + line.matches(regex("nine"))).sorted(key: v => v.start)
    let a = matches.first().text
    let b = matches.last().text
    if a.len() != 1 {
      a = text2num.at(a)
    } else {
      a = int(a)
    }
    if b.len() != 1 {
      b = text2num.at(b)
    } else {
      b = int(b)
    }
    let n = a * 10 + b
    result = result + n
  }
  result
}

(ejercicio-2: ejercicio-2)
```

```repl
ejercicio-2(data)
```

=== Data posta

```repl
let data = read("2023-example.data")
ejercicio-2(data)
```

=== Hola fran

```data
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
```

```repl
let lines = data.split()
for line in lines {
  let matches = (
      line.matches(regex("\d"))
    + line.matches(regex("zero"))
    + line.matches(regex("one"))
    + line.matches(regex("two"))
    + line.matches(regex("three"))
    + line.matches(regex("four"))
    + line.matches(regex("five"))
    + line.matches(regex("six"))
    + line.matches(regex("seven"))
    + line.matches(regex("eight"))
    + line.matches(regex("nine"))).sorted(key: v => v.start)
  dbg(count: matches.len(), matches.first().text, matches.last().text)
}
dbg(a: 123, b: 321, arr: (1, 2, 3), "pos1", [*pos2*], $"pos"^3$)
```

```repl
dbg(1, 2, 3)
```

== Day 10: Pipe Maze

=== Part One

You use the hang glider to ride the hot air from Desert Island all the way up
to the floating metal island. This island is surprisingly cold and there
definitely aren't any thermals to glide on, so you leave your hang glider
behind.

You wander around for a while, but you don't find any people or animals.
However, you do occasionally find signposts labeled "Hot Springs" pointing in a
seemingly consistent direction; maybe you can find someone at the hot springs
and ask them where the desert-machine parts are made.

The landscape here is alien; even the flowers and trees are made of metal. As
you stop to admire some metal grass, you notice something metallic scurry away
in your peripheral vision and jump into a big pipe! It didn't look like any
animal you've ever seen; if you want a better look, you'll need to get ahead of
it.

Scanning the area, you discover that the entire field you're standing on is
densely packed with pipes; it was hard to tell at first because they're the
same metallic silver color as the "ground". You make a quick sketch of all of
the surface pipes you can see (your puzzle input).

The pipes are arranged in a two-dimensional grid of *tiles*:
- | is a *vertical pipe* connecting north and south.
- - is a *horizontal pipe* connecting east and west.
- L is a *90-degree bend* connecting north and east.
- J is a *90-degree bend* connecting north and west.
- 7 is a *90-degree bend* connecting south and west.
- F is a *90-degree bend* connecting south and east.
- . is *ground*; there is no pipe in this tile.
- S is the *starting position* of the animal; there is a pipe on this tile, but
  your sketch doesn't show what shape the pipe has.

Based on the acoustics of the animal's scurrying, you're confident the pipe
that contains the animal is *one large, continuous loop*.

For example, here is a square loop of pipe:

```data
.....
.F-7.
.|.|.
.L-J.
.....
```

If the animal had entered this loop in the northwest corner, the sketch would
instead look like this:

```data
.....
.S-7.
.|.|.
.L-J.
.....
```

In the above diagram, the S tile is still a 90-degree F bend: you can tell
because of how the adjacent pipes connect to it.

Unfortunately, there are also many pipes that *aren't connected to the loop*!
This sketch shows the same loop as above:

```data
-L|F7
7S-7|
L|7||
-L-J|
L|-JF
```

In the above diagram, you can still figure out which pipes form the main loop:
they're the ones connected to S, pipes those pipes connect to, pipes *those*
pipes connect to, and so on. Every pipe in the main loop connects to its two
neighbors (including S, which will have exactly two pipes connecting to it, and
which is assumed to connect back to those two pipes).

Here is a sketch that contains a slightly more complex main loop:

```data
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
```

Here's the same example sketch with the extra, non-main-loop pipe tiles also
shown:

```
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
```

If you want to get out *ahead of the animal*, you should find the tile in the
loop that is *farthest* from the starting position. Because the animal is in
the pipe, it doesn't make sense to measure this by direct distance. Instead,
you need to find the tile that would take the longest number of steps *along
the loop* to reach from the starting point - regardless of which way around the
loop the animal went.

In the first example with the square loop:

```data
.....
.S-7.
.|.|.
.L-J.
.....
```

You can count the distance each tile in the loop is from the starting point
like this:

```data
.....
.012.
.1.3.
.234.
.....
```

In this example, the farthest point from the start is *4* steps away.

Here's the more complex loop again:

```data
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
```

Here are the distances for each tile on that loop:

```
..45.
.236.
01.78
14567
23...
```

Find the single giant loop starting at S. *How many steps along the loop does
it take to get from the starting position to the point farthest from the
starting position?*

== Resolución

Lo primero que me gustaría es poder dibujar los cosos estos...

```repl
let i = 0
enum(..datas.map(data => {
    let lines = data.split()

    grid(
      columns: (1em,) * lines.first().len(),
      rows: 1em,
      ..lines.map(l => {
        l.codepoints().map(c => {
          if (c == "S") {
            circle(width: 100%)
          } else if (c == "F") {
            line(start: (50%, 100%), end: (100%, 50%))
          } else if (c == "-") {
            line(start: (0%, 50%), end: (100%, 50%))
          } else if (c == "7") {
            line(start: (0%, 50%), end: (50%, 100%))
          } else if (c == "|") {
            line(start: (50%, 0%), end: (50%, 100%))
          } else if (c == "J") {
            line(start: (0%, 50%), end: (50%, 0%))
          } else if (c == "L") {
            line(start: (50%, 0%), end: (100%, 50%))
          }
        })
      }).flatten()
    )
  })
)
```

Vamos a meterlo en una función:
```definition
let draw(data) = {
  let lines = data.split()

  grid(
    columns: (1em,) * lines.first().len(),
    rows: 1em,
    ..lines.map(l => {
      l.codepoints().map(c => {
        if (c == "S") {
          circle(width: 100%)
        } else if (c == "F") {
          line(start: (50%, 100%), end: (100%, 50%))
        } else if (c == "-") {
          line(start: (0%, 50%), end: (100%, 50%))
        } else if (c == "7") {
          line(start: (0%, 50%), end: (50%, 100%))
        } else if (c == "|") {
          line(start: (50%, 0%), end: (50%, 100%))
        } else if (c == "J") {
          line(start: (0%, 50%), end: (50%, 0%))
        } else if (c == "L") {
          line(start: (50%, 0%), end: (100%, 50%))
        }
      })
    }).flatten()
  )
}
(draw-map: draw)
```

Ahora me pongo a pensar la resolución:
```repl
dbg(draw-map(data))

let map = data.split().map(v => v.codepoints())
dbg(map)

let start 
for (y, row) in enumerate(map) {
  for (x, col) in enumerate(row) {
    if col == "S" {
      start = (x, y)
    }
  }
}
dbg(start: start)
```

=== Part Two

You quickly reach the farthest point of the loop, but the animal never emerges.
Maybe its nest is *within the area enclosed by the loop*?

To determine whether it's even worth taking the time to search for such a nest,
you should calculate how many tiles are contained within the loop. For example:

```data
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........
```

The above loop encloses merely *four tiles* - the two pairs of `.` in the
southwest and southeast (marked `I` below). The middle `.` tiles (marked `O`
below) are *not* in the loop. Here is the same loop again with those regions
marked:

```data
...........
.S-------7.
.|F-----7|.
.||OOOOO||.
.||OOOOO||.
.|L-7OF-J|.
.|II|O|II|.
.L--JOL--J.
.....O.....
```

In fact, there doesn't even need to be a full tile path to the outside for
tiles to count as outside the loop - squeezing between pipes is also allowed!
Here, `I` is still within the loop and `O` is still outside the loop:

```data
..........
.S------7.
.|F----7|.
.||OOOO||.
.||OOOO||.
.|L-7F-J|.
.|II||II|.
.L--JL--J.
..........
```

In both of the above examples, *4* tiles are enclosed by the loop.

Here's a larger example:

```data
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
```

The above sketch has many random bits of ground, some of which are in the loop
(`I`) and some of which are outside it (`O`):

```data
OF----7F7F7F7F-7OOOO
O|F--7||||||||FJOOOO
O||OFJ||||||||L7OOOO
FJL7L7LJLJ||LJIL-7OO
L--JOL7IIILJS7F-7L7O
OOOOF-JIIF7FJ|L7L7L7
OOOOL7IF7||L7|IL7L7|
OOOOO|FJLJ|FJ|F7|OLJ
OOOOFJL-7O||O||||OOO
OOOOL---JOLJOLJLJOOO
```

In this larger example, *8* tiles are enclosed by the loop.

Any tile that isn't part of the main loop can count as being enclosed by the
loop. Here's another example with many bits of junk pipe lying around that
aren't connected to the main loop at all:

```data
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
```

Here are just the tiles that are *enclosed by the loop* marked with `I`:

```data
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJIF7FJ-
L---JF-JLJIIIIFJLJJ7
|F|F-JF---7IIIL7L|7|
|FFJF7L7F-JF7IIL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
```

In this last example, *10* tiles are enclosed by the loop.

Figure out whether you have time to search for the nest by calculating the area
within the loop. *How many tiles are enclosed by the loop*?

=== Resolución

Primero que todo quiero dibujarlo:
```repl
enum(..datas.map(v => draw-map(v)))
```

=== Boludeces

Dibujo la data posta:
```repl
draw-map(read("2023-example2.data"))
```

Es un poco grande.
