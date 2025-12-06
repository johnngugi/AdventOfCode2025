import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(lines) = simplifile.read(from: "src/input.txt")

  lines
  |> string.trim
  |> string.split("\n")
  |> solution_1
  |> int.to_string
  |> io.println

  lines
  |> string.trim
  |> string.split("\n")
  |> solution_2
  |> int.to_string
  |> io.println

  Nil
}

fn solution_1(lines: List(String)) -> Int {
  let assert Ok(symbols) = list.last(lines)
  let symbols = string.split(symbols, " ") |> list.filter(fn(s) { s != "" })
  let m = list.length(lines)

  let nums =
    lines
    |> list.take(m - 1)
    |> list.map(fn(line) {
      string.split(line, " ") |> list.filter(fn(s) { s != "" })
    })
    |> list.map(fn(line) {
      line
      |> list.map(fn(num_str) {
        let assert Ok(result) = int.parse(num_str)
        result
      })
    })

  let columns =
    nums
    |> list.transpose

  list.zip(columns, symbols)
  |> list.fold(0, fn(acc, curr) {
    let #(numbers, operation) = curr
    let result = case operation {
      "+" -> list.fold(numbers, 0, int.add)
      "*" -> list.fold(numbers, 1, int.multiply)
      _ -> list.fold(numbers, 0, int.add)
    }

    acc + result
  })
}

fn solution_2(lines: List(String)) -> Int {
  let max_length =
    lines
    |> list.map(string.length)
    |> list.fold(0, int.max)

  let columns =
    lines
    |> list.map(fn(line) {
      line
      |> string.pad_end(to: max_length, with: " ")
      |> string.to_graphemes
    })
    |> list.transpose

  let chunked =
    columns
    |> list.chunk(fn(col) { !is_separator(col) })
    |> list.filter(fn(group) {
      case group {
        [first, ..] -> !is_separator(first)
        [] -> False
      }
    })

  chunked
  |> list.map(fn(group) {
    let op = get_operator(group)

    let cols =
      list.map(group, fn(col) {
        let str_col =
          col
          |> list.filter(fn(char) { char != " " && char != "+" && char != "*" })
          |> string.join("")

        let assert Ok(num) = int.parse(str_col)
        num
      })

    #(cols, op)
  })
  |> list.map(fn(group) {
    let #(nums, op) = group

    case op {
      "+" -> list.fold(nums, 0, int.add)
      "*" -> list.fold(nums, 1, int.multiply)
      _ -> list.fold(nums, 0, int.add)
    }
  })
  |> list.fold(0, int.add)
}

fn is_separator(column: List(String)) -> Bool {
  list.all(column, fn(char) { char == " " })
}

fn get_operator(group: List(List(String))) -> String {
  let assert [first_col, ..] = group
  let assert Ok(op) = list.last(first_col)
  op
}
