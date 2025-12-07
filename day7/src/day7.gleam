import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(content) = simplifile.read(from: "src/input.txt")

  content
  |> string.trim
  |> string.split("\n")
  |> solution_1
  |> int.to_string
  |> io.println

  content
  |> string.trim
  |> string.split("\n")
  |> solution_2
  |> int.to_string
  |> io.println

  Nil
}

fn solution_1(lines: List(String)) -> Int {
  let #(grid, start_col) = parse_input(lines)
  search_grid(grid, [#(0, start_col)], 0, set.new())
}

fn solution_2(lines: List(String)) -> Int {
  let #(grid, start_col) = parse_input(lines)
  let #(result, _) = quantum_search(grid, 0, start_col, dict.new())
  result
}

fn quantum_search(
  grid: dict.Dict(#(Int, Int), String),
  row: Int,
  col: Int,
  cache: dict.Dict(#(Int, Int), Int),
) -> #(Int, dict.Dict(#(Int, Int), Int)) {
  case dict.get(cache, #(row, col)) {
    Ok(result) -> #(result, cache)
    Error(_) -> {
      let #(result, new_cache) = case dict.get(grid, #(row, col)) {
        Error(_) -> #(1, cache)
        Ok("S") -> quantum_search(grid, row + 1, col, cache)
        Ok(".") -> quantum_search(grid, row + 1, col, cache)
        Ok("^") -> {
          let #(left_result, cache1) = quantum_search(grid, row, col - 1, cache)
          let #(right_result, cache2) =
            quantum_search(grid, row, col + 1, cache1)
          #(left_result + right_result, cache2)
        }
        Ok(_) -> quantum_search(grid, row + 1, col, cache)
      }
      let new_cache = dict.insert(new_cache, #(row, col), result)
      #(result, new_cache)
    }
  }
}

fn search_grid(
  grid: dict.Dict(#(Int, Int), String),
  queue: List(#(Int, Int)),
  split_count: Int,
  visited: set.Set(#(Int, Int)),
) -> Int {
  case queue {
    [] -> split_count
    [first, ..rest] -> {
      let #(row, col) = first
      let new_row = row + 1
      let char = dict.get(grid, #(new_row, col))
      case char {
        Ok(".") ->
          search_grid(
            grid,
            list.append(rest, [#(new_row, col)]),
            split_count,
            visited,
          )
        Ok("^") -> {
          let left_beam = #(new_row, col - 1)
          let right_beam = #(new_row, col + 1)

          let left_visited = set.contains(visited, left_beam)
          let right_visited = set.contains(visited, right_beam)

          let new_beams =
            []
            |> fn(l) {
              case left_visited {
                False -> [left_beam, ..l]
                True -> l
              }
            }
            |> fn(l) {
              case right_visited {
                False -> [right_beam, ..l]
                True -> l
              }
            }

          let new_visited =
            visited
            |> set.insert(left_beam)
            |> set.insert(right_beam)

          let new_count = case new_beams {
            [] -> split_count
            _ -> split_count + 1
          }

          search_grid(
            grid,
            list.append(rest, new_beams),
            new_count,
            new_visited,
          )
        }
        _ -> search_grid(grid, rest, split_count, visited)
      }
    }
  }
}

fn parse_input(lines: List(String)) -> #(dict.Dict(#(Int, Int), String), Int) {
  let assert Ok(first) = list.first(lines)
  let assert Ok(start_col) =
    first
    |> string.split("")
    |> list.index_map(fn(char, index) { #(char, index) })
    |> list.key_find("S")

  let grid =
    lines
    |> list.index_map(fn(line, row) {
      line
      |> string.split("")
      |> list.index_map(fn(char, col) { #(#(row, col), char) })
    })
    |> list.flatten
    |> dict.from_list

  #(grid, start_col)
}
