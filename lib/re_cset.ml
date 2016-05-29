(*
   RE - A regular expression library

   Copyright (C) 2001 Jerome Vouillon
   email: Jerome.Vouillon@pps.jussieu.fr

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation, with
   linking exception; either version 2.1 of the License, or (at
   your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*)

type c = int
type t = (c * c) list

let rec union l l' =
  match l, l' with
    _, [] -> l
  | [], _ -> l'
  | (c1, c2)::r, (c1', c2')::r' ->
      if c2 + 1 < c1' then
        (c1, c2)::union r l'
      else if c2' + 1 < c1 then
        (c1', c2')::union l r'
      else if c2 < c2' then
        union r ((min c1 c1', c2')::r')
      else
        union ((min c1 c1', c2)::r) r'

let rec inter l l' =
  match l, l' with
    _, [] -> []
  | [], _ -> []
  | (c1, c2)::r, (c1', c2')::r' ->
      if c2 < c1' then
        inter r l'
      else if c2' < c1 then
        inter l r'
      else if c2 < c2' then
        (max c1 c1', c2)::inter r l'
      else
        (max c1 c1', c2')::inter l r'

let rec diff l l' =
  match l, l' with
    _, [] -> l
  | [], _ -> []
  | (c1, c2)::r, (c1', c2')::r' ->
      if c2 < c1' then
        (c1, c2)::diff r l'
      else if c2' < c1 then
        diff l r'
      else
        let r'' = if c2' < c2 then (c2' + 1, c2) :: r else r in
        if c1 < c1' then
          (c1, c1' - 1)::diff r'' r'
        else
          diff r'' r'

let single c = [c, c]

let add c l = union (single c) l

let seq c c' = if c <= c' then [c, c'] else [c', c]

let rec offset o l =
  match l with
    []            -> []
  | (c1, c2) :: r -> (c1 + o, c2 + o) :: offset o r

let empty = []

let rec mem (c : int) s =
  match s with
    []              -> false
  | (c1, c2) :: rem -> if c <= c2 then c >= c1 else mem c rem

(****)

type hash = int

let rec hash_rec l =
  match l with
    []        -> 0
  | (i, j)::r -> i + 13 * j + 257 * hash_rec r
let hash l = (hash_rec l) land 0x3FFFFFFF

(****)

let print_one ch c1 c2 =
  if c1 = c2 then
    Format.fprintf ch "@ %d" c1
  else
    Format.fprintf ch "@ %d-%d" c1 c2

let pp ch l =
  match l with
    [] ->
      ()
  | (c1, c2) :: rem ->
      print_one ch c1 c2;
      List.iter
        (fun (c1, c2) -> Format.fprintf ch "@ "; print_one ch c1 c2) rem

let print = pp
