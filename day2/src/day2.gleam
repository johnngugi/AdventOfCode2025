import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(lines) = simplifile.read(from: "src/input.txt")

  let ranges =
    lines
    |> string.split(",")
    |> list.map(string.trim)
    |> list.filter(fn(r) { r != "" })

  // Uncomment for part 1
  // ranges
  // |> sum_invalid(is_invalid_1)
  // |> int.to_string
  // |> io.println

  ranges
  |> sum_invalid(is_invalid_2)
  |> int.to_string
  |> io.println

  Nil
}

fn sum_invalid(ranges: List(String), is_invalid: fn(Int) -> Bool) -> Int {
  ranges
  |> list.map(fn(range) { string.split(range, "-") })
  |> list.fold(0, fn(acc, curr) {
    let assert [first, last] = curr
    let first = int.parse(first) |> result.unwrap(0)
    let last = int.parse(last) |> result.unwrap(0)

    let range_sum =
      list.range(first, last)
      |> list.filter(is_invalid)
      |> int.sum

    acc + range_sum
  })
}

fn is_invalid_1(num: Int) -> Bool {
  let num_str = int.to_string(num)
  let len = string.length(num_str)

  case len % 2 == 0 {
    False -> False
    True -> {
      let mid = len / 2
      let first = string.slice(num_str, 0, mid)
      let last = string.slice(num_str, mid, len - mid)
      first == last
    }
  }
}

fn is_invalid_2(num: Int) -> Bool {
  let num_str = int.to_string(num)
  let len = string.length(num_str)

  case len < 2 {
    True -> False
    False -> {
      list.range(1, len / 2)
      |> list.filter(fn(i) { len % i == 0 })
      |> list.any(fn(i) {
        let chunk = string.slice(num_str, 0, i)

        let chunk_position_range = len / i
        let chunk_position_range = chunk_position_range - 1
        list.range(0, chunk_position_range)
        |> list.all(fn(k) { string.slice(num_str, k * i, i) == chunk })
      })
    }
  }
}
