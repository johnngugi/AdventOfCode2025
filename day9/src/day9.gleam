import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

pub fn main() -> Nil {
  let assert Ok(content) = simplifile.read("src/input.txt")

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
  let coordinates =
    lines
    |> list.map(fn(line) {
      string.split(line, ",")
      |> list.map(fn(num_str) {
        let assert Ok(num) = int.parse(num_str)
        num
      })
    })
    |> list.map(fn(nums) {
      let assert [x, y] = nums
      Coordinate(x:, y:)
    })

  get_max_area(coordinates, 0)
}

fn solution_2(lines: List(String)) -> Int {
  let coordinates =
    lines
    |> list.map(fn(line) {
      string.split(line, ",")
      |> list.map(fn(num_str) {
        let assert Ok(num) = int.parse(num_str)
        num
      })
    })
    |> list.map(fn(nums) {
      let assert [x, y] = nums
      Coordinate(x:, y:)
    })

  let poly_sides = get_consecutive_pairs(coordinates)

  let rectangles = get_all_rectangles(coordinates)
  let sorted = rectangles |> list.sort(fn(a, b) { int.compare(b.area, a.area) })

  find_first_valid(sorted, poly_sides)
}

fn find_first_valid(
  rectangles: List(Rectangle),
  poly_sides: List(#(Coordinate, Coordinate)),
) -> Int {
  case rectangles {
    [] -> 0
    [rect, ..rest] -> {
      case rectangle_intersects(rect, poly_sides) {
        False -> rect.area
        True -> find_first_valid(rest, poly_sides)
      }
    }
  }
}

fn rectangle_intersects(
  rect: Rectangle,
  poly_sides: List(#(Coordinate, Coordinate)),
) -> Bool {
  let rect_min_x = int.min(rect.a.x, rect.b.x)
  let rect_max_x = int.max(rect.a.x, rect.b.x)
  let rect_min_y = int.min(rect.a.y, rect.b.y)
  let rect_max_y = int.max(rect.a.y, rect.b.y)

  poly_sides
  |> list.any(fn(side) {
    let #(p1, p2) = side
    let side_min_x = int.min(p1.x, p2.x)
    let side_max_x = int.max(p1.x, p2.x)
    let side_min_y = int.min(p1.y, p2.y)
    let side_max_y = int.max(p1.y, p2.y)

    let no_intersection =
      side_max_x <= rect_min_x
      || side_min_x >= rect_max_x
      || side_max_y <= rect_min_y
      || side_min_y >= rect_max_y

    !no_intersection
  })
}

pub type Rectangle {
  Rectangle(a: Coordinate, b: Coordinate, area: Int)
}

fn get_all_rectangles(coordinates: List(Coordinate)) -> List(Rectangle) {
  case coordinates {
    [] -> []
    [first, ..rest] -> {
      let pairs_with_first =
        rest
        |> list.map(fn(other) {
          let x_diff = int.absolute_value(first.x - other.x) + 1
          let y_diff = int.absolute_value(first.y - other.y) + 1
          Rectangle(a: first, b: other, area: x_diff * y_diff)
        })

      list.append(pairs_with_first, get_all_rectangles(rest))
    }
  }
}

fn get_consecutive_pairs(
  coordinates: List(Coordinate),
) -> List(#(Coordinate, Coordinate)) {
  let assert [first, ..] = coordinates
  let assert Ok(last) = list.last(coordinates)

  let pairs = list.window_by_2(coordinates)
  let wrap_around = #(last, first)

  list.append(pairs, [wrap_around])
}

fn get_max_area(coordinates: List(Coordinate), current_max: Int) -> Int {
  case coordinates {
    [] -> current_max
    [first, ..rest] -> {
      let max =
        rest
        |> list.fold(0, fn(acc, curr) {
          let x_diff = int.subtract(first.x, curr.x) + 1 |> int.absolute_value
          let y_diff = int.subtract(first.y, curr.y) + 1 |> int.absolute_value
          let area = int.multiply(x_diff, y_diff)

          int.max(acc, area)
        })
        |> int.max(current_max)

      get_max_area(rest, max)
    }
  }
}
