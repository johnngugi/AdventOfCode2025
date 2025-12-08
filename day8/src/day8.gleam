import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub type Coordinate {
  Coordinate(x: Int, y: Int, z: Int)
}

pub type DistancePair {
  DistancePair(distance: Float, box_a: Coordinate, box_b: Coordinate)
}

pub fn main() -> Nil {
  let assert Ok(content) = simplifile.read("src/input.txt")

  content
  |> string.trim
  |> string.split("\n")
  |> solution_1
  |> int.to_string
  |> io.println

  Nil
}

fn solution_1(lines: List(String)) -> Int {
  let coordinates =
    lines
    |> list.map(fn(line) { string.split(line, ",") })
    |> list.map(fn(line) {
      list.map(line, fn(num_str) {
        let assert Ok(num) = int.parse(num_str)
        num
      })
    })
    |> list.map(fn(coordinates) {
      let assert [x, y, z] = coordinates
      Coordinate(x:, y:, z:)
    })

  let circuits =
    coordinates
    |> list.index_map(fn(coordinate, index) { #(coordinate, index) })
    |> dict.from_list

  let distances =
    get_distances(coordinates, [])
    |> list.sort(fn(a, b) { float.compare(a.distance, b.distance) })

  let circuits = make_connections(distances, circuits, 0)

  list.group(dict.values(circuits), fn(circuit) { circuit })
  |> dict.map_values(fn(_circuit_id, values) { list.length(values) })
  |> dict.to_list
  |> list.sort(fn(a, b) { int.compare(b.1, a.1) })
  |> list.take(3)
  |> list.fold(1, fn(acc, curr) { acc * curr.1 })
}

fn make_connections(
  distances: List(DistancePair),
  circuits: dict.Dict(Coordinate, Int),
  pairs_processed: Int,
) -> dict.Dict(Coordinate, Int) {
  case pairs_processed == 1000 {
    True -> circuits
    False ->
      case distances {
        [] -> circuits
        [first, ..rest] -> {
          let assert Ok(id_a) = dict.get(circuits, first.box_a)
          let assert Ok(id_b) = dict.get(circuits, first.box_b)
          case id_a == id_b {
            True -> make_connections(rest, circuits, pairs_processed + 1)
            False -> {
              let new_circuit =
                dict.map_values(circuits, fn(_coordinate, circuit_id) {
                  case circuit_id == id_b {
                    True -> id_a
                    False -> circuit_id
                  }
                })
              make_connections(rest, new_circuit, pairs_processed + 1)
            }
          }
        }
      }
  }
}

fn get_distances(
  coordinates: List(Coordinate),
  store: List(DistancePair),
) -> List(DistancePair) {
  case coordinates {
    [first, ..rest] -> {
      let distances =
        list.map(rest, fn(c) {
          let x_difference = int.subtract(first.x, c.x)
          let y_difference = int.subtract(first.y, c.y)
          let z_difference = int.subtract(first.z, c.z)

          let assert Ok(x_pow) = int.power(x_difference, 2.0)
          let assert Ok(y_pow) = int.power(y_difference, 2.0)
          let assert Ok(z_pow) = int.power(z_difference, 2.0)

          let add = float.add(x_pow, y_pow) |> float.add(z_pow)
          let assert Ok(distance) = float.square_root(add)

          DistancePair(distance:, box_a: first, box_b: c)
        })

      get_distances(rest, list.append(store, distances))
    }
    [] -> store
  }
}
