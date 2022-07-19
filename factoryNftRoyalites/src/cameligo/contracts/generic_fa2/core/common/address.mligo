(** 
   This file implement the TZIP-12 protocol (a.k.a FA2) for NFT on Tezos
   copyright Wulfman Corporation 2021
*)

type t = address

[@no_mutation] let equal (a : t) (b : t) = a = b