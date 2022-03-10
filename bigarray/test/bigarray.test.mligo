#import "../cameligo/contract.mligo" "Bigarray"


// We need to create a generic entrypoint main that do nothing for compilation purpose
let main (_action, store : bytes * bytes) : operation list * bytes = ([] : operation list), store



(**
 *  Get the last element
 *)
let test_last_element_with_string_should_work =
  //Given
  let lst1 : string list = ["one"; "two"; "three"; "four"] in
  let intended_result : string = "four" in
  //when
  let result = Bigarray.last lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"


(**
 *  Reverse
 *)
let test_reversing_with_int_should_work =
  //Given
  let lst1 : int list = [1; 2; 3] in
  let intended_result : int list = [3; 2; 1] in
  //when
  let result = Bigarray.reverse lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_reversing_with_string_should_work =
  //Given
  let lst1 : string list = ["one"; "two"; "three"] in
  let intended_result : string list = ["three"; "two"; "one"] in
  //when
  let result = Bigarray.reverse lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Concatenation
 *)
let test_concatenation_with_int_should_work =
  //Given
  let lst1 : int list = [1; 2; 3] in
  let lst2 : int list = [4; 5] in
  let intended_result : int list = [1 ; 2 ; 3 ; 4 ; 5] in
  //when
  let result = Bigarray.concat lst1 lst2 in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_concatenation_with_string_should_work =
  //Given
  let lst1 : string list = ["one"; "two"; "three"] in
  let lst2 : string list = ["four"; "five"] in
  let intended_result : string list = ["one"; "two"; "three"; "four"; "five"] in
  //when
  let result = Bigarray.concat lst1 lst2 in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Get one element
 *)
let test_get_element_with_int_should_work =
  //Given
  let lst1 : int list = [1; 2; 3; 4] in
  let position : nat = 1n in
  let intended_result : int = 2 in
  //when
  let result = Bigarray.find position lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_get_element_with_string_should_work =
  //Given
  let lst1 : string list = ["one"; "two"; "three"; "four"] in
  let position : nat = 1n in
  let intended_result : string = "two" in
  //when
  let result = Bigarray.find position lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Set one element
 *)
let test_set_element_with_int_should_work =
  //Given
  let lst1 : int list = [1; 2; 3; 4; 5] in
  let element : int = 7 in
  let position : nat = 2n in
  let intended_result : int list = [1; 2; 7; 4; 5] in
  //when
  let result = Bigarray.set element position lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_set_element_with_string_should_work =
  //Given
  let lst1 : string list = ["one"; "two"; "three"; "four"; "five"] in
  let element : string = "seven" in
  let position : nat = 1n in
  let intended_result : string list = ["one"; "seven"; "three"; "four"; "five"] in
  //when
  let result = Bigarray.set element position lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Insert one element
 *)
let test_insertion_with_int_should_work =
  //Given
  let lst1 : int list = [1; 3; 4] in
  let element : int = 2 in
  let position : nat = 1n in
  let intended_result : int list = [1 ; 2 ; 3 ; 4] in
  //when
  let result = Bigarray.insert element position lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_insertion_with_string_should_work =
  //Given
  let lst1 : string list = ["one"; "three"; "four"] in
  let element : string = "two" in
  let position : nat = 1n in
  let intended_result : string list = ["one"; "two"; "three"; "four"] in
  //when
  let result = Bigarray.insert element position lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Drop one element
 *)
let test_drop_with_int_should_work =
  //Given
  let lst1 : int list = [1; 2; 3; 4] in
  let position : nat = 2n in
  let intended_result : int list = [1 ; 2 ; 4] in
  //when
  let result = Bigarray.drop position lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_drop_with_string_should_work =
  //Given
  let lst1 : string list = ["one"; "two"; "three"; "four"] in
  let position : nat = 3n in
  let intended_result : string list = ["one"; "two"; "three"] in
  //when
  let result = Bigarray.drop position lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Slice
 *)
let test_slice_with_int_should_work =
  //Given
  let lst1 : int list = [1; 2; 3; 4] in
  let i : nat = 1n in
  let j : nat = 2n in
  let intended_result : int list = [2 ; 3] in
  //when
  let result = Bigarray.slice i j lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_slice_with_string_should_work =
  //Given
  let lst1 : string list = ["one"; "two"; "three"; "four"] in
  let i : nat = 0n in
  let j : nat = 6n in
  let intended_result : string list = ["one"; "two"; "three"; "four"] in
  //when
  let result = Bigarray.slice i j lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Split
 *)
let test_split_with_int_should_work =
  //Given
  let lst : int list = [1; 2; 3; 4] in
  let i : nat = 1n in
  let intended_result1 : int list = [1] in
  let intended_result2 : int list = [2; 3; 4] in
  //when
  let result = Bigarray.split i lst in
  //Then
  let () = assert (result = (intended_result1, intended_result2)) in "OK"

(**
 *  Rotate
 *)
let test_rotate_with_int_should_work =
  //Given
  let lst1 : int list = [1; 2; 3; 4] in
  let i : nat = 1n in
  let intended_result : int list = [2; 3; 4; 1] in
  //when
  let result = Bigarray.rotate i lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Remove
 *)
let test_remove_with_int_should_work =
  //Given
  let lst1 : int list = [1; 2; 3; 2] in
  let elem : int = 2 in
  let intended_result : int list = [1; 3] in
  //when
  let result = Bigarray.remove elem lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"



// //  let () = Test.log ("result : ", result) in 