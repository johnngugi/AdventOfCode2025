import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

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

pub type Machine {
  Machine(lights: List(Int), buttons: List(Int))
}

fn solution_1(lines: List(String)) -> Int {
  lines
  |> list.map(fn(line) { string.split(line, " ") })
  |> list.map(fn(machine) {
    let assert [indicator_lights, ..rest] = machine
    let buttons = list.take(rest, list.length(rest) - 1)

    let lights = get_lights_bits(indicator_lights)
    let button_bits = get_buttons_bits(buttons, list.length(lights))

    Machine(lights:, buttons: button_bits)
  })
  |> list.fold(0, fn(acc, machine) {
    machine
    |> fewest_button_presses
    |> int.add(acc)
  })
}

fn get_buttons_bits(buttons: List(String), width: Int) -> List(Int) {
  buttons
  |> list.map(fn(button) {
    button
    |> string.replace("(", "")
    |> string.replace(")", "")
    |> string.split(",")
    |> list.map(fn(num_str) {
      let assert Ok(num) = int.parse(num_str)
      num
    })
  })
  |> list.map(fn(button) { bits_to_int(button, width) })
}

fn bits_to_int(bits: List(Int), width: Int) -> Int {
  list.fold(bits, 0, fn(acc, bit) {
    acc + int.bitwise_shift_left(1, width - 1 - bit)
  })
}

fn binary_list_to_int(nums: List(Int)) -> Int {
  bin_to_int(list.reverse(nums), 0, 0)
}

fn bin_to_int(nums: List(Int), power: Int, acc: Int) -> Int {
  case nums {
    [] -> acc
    [first, ..rest] -> {
      let assert Ok(pow) = int.power(2, int.to_float(power))
      let result = acc + int.multiply(first, float.round(pow))

      bin_to_int(rest, power + 1, result)
    }
  }
}

fn fewest_button_presses(machine: Machine) -> Int {
  let num_of_buttons = list.length(machine.buttons)
  let assert Ok(masks) = int.power(2, int.to_float(num_of_buttons))
  let goal = binary_list_to_int(machine.lights)

  list.range(0, float.round(masks) - 1)
  |> list.filter_map(fn(mask) {
    let pressed_indices = get_set_bits(mask, num_of_buttons)

    let result =
      pressed_indices
      |> list.filter_map(fn(i) {
        machine.buttons
        |> list.drop(i)
        |> list.first
      })
      |> list.fold(0, int.bitwise_exclusive_or)

    case result == goal {
      True -> Ok(list.length(pressed_indices))
      False -> Error(Nil)
    }
  })
  |> list.fold(999_999, int.min)
}

fn get_set_bits(mask: Int, num_bits: Int) -> List(Int) {
  list.range(0, num_bits - 1)
  |> list.filter(fn(i) {
    int.bitwise_and(mask, int.bitwise_shift_left(1, i)) != 0
  })
}

fn get_lights_bits(lights_part: String) -> List(Int) {
  string.split(lights_part, "")
  |> list.filter(fn(char) { char != "[" && char != "]" })
  |> list.map(fn(char) {
    case char {
      "#" -> 1
      "." -> 0
      _ -> 0
    }
  })
}
