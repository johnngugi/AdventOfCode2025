import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(content) = simplifile.read(from: "src/input.txt")

  content
  |> read_lines
  |> solution_1
  |> int.to_string
  |> io.println

  content
  |> read_lines
  |> solution_2
  |> int.to_string
  |> io.println

  Nil
}

fn solution_1(lines: List(String)) -> Int {
  let grid = get_grid_from_lines(lines)

  find_accessible_rolls(grid)
  |> list.length
}

fn solution_2(lines: List(String)) -> Int {
  let grid = get_grid_from_lines(lines)

  remove_accessible(grid, 0)
}

fn get_grid_from_lines(lines: List(String)) -> dict.Dict(#(Int, Int), String) {
  lines
  |> list.index_map(fn(line, row) {
    string.to_graphemes(line)
    |> list.index_map(fn(char, col) { #(#(row, col), char) })
  })
  |> list.flatten
  |> dict.from_list
}

fn remove_accessible(
  grid: dict.Dict(#(Int, Int), String),
  total_removed: Int,
) -> Int {
  let accessible_rolls = find_accessible_rolls(grid)

  case list.length(accessible_rolls) {
    0 -> total_removed
    n -> {
      let new_grid =
        list.fold(accessible_rolls, grid, fn(g, curr) { dict.delete(g, curr) })

      remove_accessible(new_grid, total_removed + n)
    }
  }
}

fn find_accessible_rolls(
  grid: dict.Dict(#(Int, Int), String),
) -> List(#(Int, Int)) {
  let neighbours = [
    #(0, -1),
    #(-1, 0),
    #(0, 1),
    #(1, 0),
    #(-1, -1),
    #(-1, 1),
    #(1, -1),
    #(1, 1),
  ]

  grid
  |> dict.filter(fn(_key, value) { value == "@" })
  |> dict.filter(fn(position, _) {
    let #(row, col) = position

    let neighbour_count =
      neighbours
      |> list.count(fn(neighbour) {
        let dy = col + neighbour.1
        let dx = row + neighbour.0

        dict.get(grid, #(dx, dy)) == Ok("@")
      })
    neighbour_count < 4
  })
  |> dict.keys
}

fn read_lines(contents: String) -> List(String) {
  contents
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.filter(fn(r) { r != "" })
}
