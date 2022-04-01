Intended usage of the module :

#import "../utils/bigarray.mligo" "Bigarray"


The first element (head of the list) is at position 0.

last
Return the last element
reverse
Reverse the elements
concat
Concatenate two lists
find
Return one element
set
Set one element at a given value
insert
Insert one element at a given position
drop
Drop one element at a given position
take
Take the number of item given as argument
slice
Return an extracted slice
Split
Split the list in two parts
rotate
Rotate a list n place to the left


Type list


Bigarray.last (list : kind list) : Kind

Get the last element of the list

Bigarray.reverse (list : kind list) : kind list

Return the bigarray with all the element reversed

Bigarray.concat (list1, list2 : kind list * kind list) : kind list

Concatenate two bigarrays into one

Bigarray.find (position, list : nat * kind list) : kind

Get one element of the Bigarray at a specific position

Bigarray.set (elem, position, list : kind * nat * kind list) : kind list

Set a value of one element at a specific position

Bigarray.insert (elem, position, list : kind * nat * kind list) : kind list

Insert a new element at a specific position

Bigarray.drop (position, list : nat * kind list) : kind list

Remove one element at a specific position 

Bigarray.take (i, list : nat * kind list) : kind list

Take the number of item given as argument

Bigarray.slice (i, k, list : nat * nat * kind list) : kind list

Given two indices, i and k, the slice is the list containing the elements between the i'th and k'th element of the original list (both limits included

Bigarray.rotate (i, list : nat * kind list) : kind list

Given one indice i, rotate every element of the list i times to the left



# Compile
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next run test bigarray/test/bigarray.test.mligo

# Launch tests
docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract bigarray/cameligo/contract.mligo -e main > bigarray/compiled/bigArray.tz
