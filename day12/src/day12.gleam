import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub type Coordinate {
  Coordinate(row: Int, col: Int)
}

pub type Region {
  Region(width: Int, height: Int, quantities: List(Int))
}

pub fn main() -> Nil {
  let assert Ok(content) = simplifile.read("src/input.txt")

  content
  |> string.trim
  |> string.split("\n\n")
  |> list.map(string.trim)
  |> list.filter(fn(group) { group != "" })
  |> solution_1
  |> int.to_string
  |> io.println
  Nil
}

fn solution_1(input: List(String)) -> Int {
  let length = list.length(input) - 1
  let shapes = list.take(input, length)
  let assert Ok(regions_str) = list.last(input)

  let cell_counts =
    shapes
    |> list.map(fn(shape) {
      shape
      |> string.split("\n")
      |> list.drop(1)
      |> list.map(fn(line) {
        line
        |> string.split("")
        |> list.filter(fn(char) { char == "#" })
        |> list.length
      })
      |> list.fold(0, fn(acc, curr) { acc + curr })
    })
    |> list.index_map(fn(count, index) { #(index, count) })
    |> dict.from_list

  let regions: List(Region) =
    regions_str
    |> string.split("\n")
    |> list.filter(fn(line) { line != "" })
    |> list.map(fn(line) {
      let assert [dimens_str, quantities_str] = string.split(line, ":")
      let assert [width_str, height_str] = string.split(dimens_str, "x")
      let assert Ok(width) = int.parse(string.trim(width_str))
      let assert Ok(height) = int.parse(string.trim(height_str))
      let quantities =
        quantities_str
        |> string.trim
        |> string.split(" ")
        |> list.map(fn(x) {
          let assert Ok(quantity) = int.parse(x)
          quantity
        })
      Region(width: width, height: height, quantities: quantities)
    })

  regions
  |> list.filter(fn(region) {
    let region_area = region.width * region.height
    let loose_bound =
      int.sum(region.quantities)
      |> int.multiply(9)

    loose_bound <= region_area
  })
  |> list.length
}
