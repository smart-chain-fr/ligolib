#import "../cameligo/contract.mligo" "Bigarray"

(**
 *  Beginning the tests
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

let test_insertion_with_int_should_work =
  //Given
  let lst1 : int list = [1; 3; 4] in
  let element : int = 2 in
  let position : nat = 2n in
  let intended_result : int list = [1 ; 2 ; 3 ; 4] in
  //when
  let result = Bigarray.insert element position lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"

let test_insertion_with_string_should_work =
  //Given
  let lst1 : string list = ["one"; "three"; "four"] in
  let element : string = "two" in
  let position : nat = 2n in
  let intended_result : string list = ["one"; "two"; "three"; "four"] in
  //when
  let result = Bigarray.insert element position lst1 in
  //Then
  let () = assert (result = intended_result) in "OK"









//  let () = Test.log ("result : ", result) in 