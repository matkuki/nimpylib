import strutils, math

type
  ## Python-like range object
  Range*[T] = object
    start, stop: T
    step, len: int

proc `$`*[T](rng: Range[T]): string = 
  if rng.step != 1:
    "range($1, $2, $3)".format(rng.start, rng.stop, rng.step)
  else:
    "range($1, $2)".format(rng.start, rng.stop)

proc range*[T: SomeInteger](start, stop: T, step: int): Range[T] = 
  ## Creates new range object with given *start* and *stop* of any integer type
  ## and *step* of int
  assert(step != 0, "Step must not be zero!")
  when compiles(stop > start):
    assert(stop > start xor step < 0, "Stop must be reachable from start with given step!")
  result.start = start
  result.stop = stop
  result.step = step
  result.len = int(math.ceil((stop - start) / step))

template range*[T: SomeInteger](start, stop: T): Range[T] = 
  ## Shortcut for range(start, stop, 1)
  range(start, stop, 1)

template range*[T: SomeInteger](stop: T): Range[T] = 
  ## Shortcut for range(0, stop, 1)
  range(0, stop)

iterator items*[T](rng: Range[T]): T = 
  var res = rng.start
  if rng.step > 0:
    while res <= (rng.stop - 1):
      yield res
      res += rng.step
  else:
    let opposite = -rng.step
    while res >= (rng.stop + 1):
      yield res
      res -= opposite

proc contains*[T](x: Range[T], y: T): bool = 
  ## Checks if given value is in range
  result =
    if x.step > 0:
      y >= x.start and y < x.stop
    else:
      y > x.stop and y <= x.start
  result = result and ((y - x.start) mod x.step == 0)

proc `[]`*[T](x: Range[T], y: int): T = 
  ## Get value from range by its index
  assert(y < x.len, "Index out of bounds")
  result = x.start + (x.step * y)

proc min*[T](x: Range[T]): T = 
  ## Get minimum value from range
  x[if x.step > 0: 0 else: x.len - 1]

proc max*[T](x: Range[T]): T = 
  ## Get maximum value from range
  x[if x.step > 0: x.len - 1 else: 0]

proc list*[T](x: Range[T]): seq[T] = 
  ## Generate sequence of numbers from given range
  result = newSeq[T](x.len)
  var i = 0
  for val in x:
    result[i] = val
    inc i