#import "../jsligo/contract.jsligo" "Bigarray"

type 'a big_array = 'a list

// We need to create a generic entrypoint main that do nothing for compilation purpose
let main (_action, store : bytes * bytes) : operation big_array * bytes = ([] : operation big_array), store


(**
 *  Basic Constructor
 *)
let test_construct_basic_array_should_work =
  //Given
  let size : nat = 3n in
  let intended_result : nat option list = [(None: nat option) ; (None: nat option) ; (None: nat option) ] in
  //when
  let result = Bigarray.construct (size, 0n) in
  //Then
  let () = Test.log ("result : ", result) in "OK"

(**
 *  Get the last element
 *)
let test_last_element_with_string_should_work =
  //Given
  let lst1 : string big_array = ["one"; "two"; "three"; "four"] in
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
  let lst1 : int big_array = [1; 2; 3] in
  let intended_result : int big_array = [3; 2; 1] in
  //when
  let result = Bigarray.reverse lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_reversing_with_string_should_work =
  //Given
  let lst1 : string big_array = ["one"; "two"; "three"] in
  let intended_result : string big_array = ["three"; "two"; "one"] in
  //when
  let result = Bigarray.reverse lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Concatenation
 *)
let test_concatenation_with_int_should_work =
  //Given
  let lst1 : int big_array = [1; 2; 3] in
  let lst2 : int big_array = [4; 5] in
  let intended_result : int big_array = [1 ; 2 ; 3 ; 4 ; 5] in
  //when
  let result = Bigarray.concat (lst1, lst2) in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_concatenation_with_string_should_work =
  //Given
  let lst1 : string big_array = ["one"; "two"; "three"] in
  let lst2 : string big_array = ["four"; "five"] in
  let intended_result : string big_array = ["one"; "two"; "three"; "four"; "five"] in
  //when
  let result = Bigarray.concat (lst1, lst2) in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Get one element
 *)
let test_get_element_with_int_should_work =
  //Given
  let lst1 : int big_array = [1; 2; 3; 4] in
  let position : nat = 1n in
  let intended_result : int = 2 in
  //when
  let result = Bigarray.find (position, lst1) in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_get_element_with_string_should_work =
  //Given
  let lst1 : string big_array = ["one"; "two"; "three"; "four"] in
  let position : nat = 1n in
  let intended_result : string = "two" in
  //when
  let result = Bigarray.find (position, lst1) in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Set one element
 *)
let test_set_element_with_int_should_work =
  //Given
  let lst1 : int big_array = [1; 2; 3; 4; 5] in
  let element : int = 7 in
  let position : nat = 2n in
  let intended_result : int big_array = [1; 2; 7; 4; 5] in
  //when
  let result = Bigarray.set (element, position, lst1) in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_set_element_with_string_should_work =
  //Given
  let lst1 : string big_array = ["one"; "two"; "three"; "four"; "five"] in
  let element : string = "seven" in
  let position : nat = 1n in
  let intended_result : string big_array = ["one"; "seven"; "three"; "four"; "five"] in
  //when
  let result = Bigarray.set (element, position, lst1) in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Insert one element
 *)
let test_insertion_with_int_should_work =
  //Given
  let lst1 : int big_array = [1; 3; 4] in
  let element : int = 2 in
  let position : nat = 1n in
  let intended_result : int big_array = [1 ; 2 ; 3 ; 4] in
  //when
  let result = Bigarray.insert (element, position, lst1) in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_insertion_with_string_should_work =
  //Given
  let lst1 : string big_array = ["one"; "three"; "four"] in
  let element : string = "two" in
  let position : nat = 1n in
  let intended_result : string big_array = ["one"; "two"; "three"; "four"] in
  //when
  let result = Bigarray.insert (element, position, lst1) in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Drop one element
 *)
let test_drop_with_int_should_work =
  //Given
  let lst1 : int big_array = [1; 2; 3; 4] in
  let position : nat = 2n in
  let intended_result : int big_array = [1 ; 2 ; 4] in
  //when
  let result = Bigarray.drop (position, lst1) in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_drop_with_string_should_work =
  //Given
  let lst1 : string big_array = ["one"; "two"; "three"; "four"] in
  let position : nat = 3n in
  let intended_result : string big_array = ["one"; "two"; "three"] in
  //when
  let result = Bigarray.drop (position, lst1) in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Slice
 *)
let test_slice_with_int_should_work =
  //Given
  let lst1 : int big_array = [1; 2; 3; 4] in
  let i : nat = 1n in
  let j : nat = 2n in
  let intended_result : int big_array = [2 ; 3] in
  //when
  let result = Bigarray.slice (i, j, lst1) in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_slice_with_string_should_work =
  //Given
  let lst1 : string big_array = ["one"; "two"; "three"; "four"] in
  let i : nat = 0n in
  let j : nat = 6n in
  let intended_result : string big_array = ["one"; "two"; "three"; "four"] in
  //when
  let result = Bigarray.slice (i, j, lst1) in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Split
 *)
let test_split_with_int_should_work =
  //Given
  let lst : int big_array = [1; 2; 3; 4] in
  let i : nat = 1n in
  let intended_result1 : int big_array = [1] in
  let intended_result2 : int big_array = [2; 3; 4] in
  //when
  let result = Bigarray.split (i, lst) in
  //Then
  let () = assert (result = (intended_result1, intended_result2)) in "OK"

(**
 *  Rotate
 *)
let test_rotate_with_int_should_work =
  //Given
  let lst1 : int big_array = [1; 2; 3; 4] in
  let i : nat = 1n in
  let intended_result : int big_array = [2; 3; 4; 1] in
  //when
  let result = Bigarray.rotate (i, lst1) in
  //Then
  let () = assert (result = intended_result) in "OK"

(**
 *  Remove
 *)
let test_remove_with_int_should_work =
  //Given
  let lst1 : int big_array = [1; 2; 3; 2] in
  let elem : int = 2 in
  let intended_result : int big_array = [1; 3] in
  //when
  let result = Bigarray.remove (elem, lst1) in
  //Then
  let () = assert (result = intended_result) in "OK"



// //  let () = Test.log ("result : ", result) in 