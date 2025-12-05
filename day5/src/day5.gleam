import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(content) = simplifile.read(from: "src/input.txt")

  content
  |> read_parts
  |> solution_1
  |> int.to_string
  |> io.println

  content
  |> read_parts
  |> solution_2
  |> int.to_string
  |> io.println

  Nil
}

fn solution_1(strings: List(String)) -> Int {
  let assert [ranges_part, ids_part] = strings

  let sorted_ranges = sort_ranges(ranges_part)

  ids_part
  |> string.split("\n")
  |> list.map(fn(num_str) { int.parse(num_str) |> result.unwrap(0) })
  |> list.fold(0, fn(acc, curr) {
    case is_in_range(sorted_ranges, curr) {
      True -> acc + 1
      False -> acc
    }
  })
}

fn solution_2(strings: List(String)) -> Int {
  let assert [ranges_part, _] = strings

  ranges_part
  |> sort_ranges
  |> merge_ranges
  |> list.fold(0, fn(acc, curr) {
    let assert [start, end] = curr

    end - start + 1
    |> int.add(acc)
  })
}

fn merge_ranges(ranges: List(List(Int))) -> List(List(Int)) {
  ranges
  |> list.fold([], fn(acc, curr) {
    case acc {
      [] -> [curr]
      [most_recent, ..rest] -> {
        let assert [recent_start, recent_end] = most_recent
        let assert [start, end] = curr

        case recent_end >= start - 1 {
          True -> {
            [[recent_start, int.max(recent_end, end)], ..rest]
          }
          False -> [curr, ..acc]
        }
      }
    }
  })
}

fn is_in_range(sorted_ranges: List(List(Int)), curr: Int) -> Bool {
  case sorted_ranges {
    [] -> False
    [first, ..rest] -> {
      let assert [begin, end] = first
      case curr <= end && curr >= begin {
        True -> True
        False -> is_in_range(rest, curr)
      }
    }
  }
}

fn sort_ranges(ranges_part: String) -> List(List(Int)) {
  ranges_part
  |> string.split("\n")
  |> list.map(fn(range) {
    string.split(range, "-")
    |> list.map(fn(num_str) { int.parse(num_str) |> result.unwrap(0) })
  })
  |> list.sort(fn(a, b) {
    let assert Ok(first) = list.first(a)
    let assert Ok(second) = list.first(b)

    int.compare(first, second)
  })
}

fn read_parts(content: String) -> List(String) {
  content
  |> string.trim
  |> string.split("\n\n")
}
