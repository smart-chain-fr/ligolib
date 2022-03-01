module Utils = struct 

    let power (x, y : nat * nat) : nat = 
        let rec multiply(acc, elt, last: nat * nat * nat ) : nat = if last = 0n then acc else multiply(acc * elt, elt, abs(last - 1n)) in
        multiply(1n, x, y)

    let hexa_to_nat(hexa : bytes) : nat =
        let _check_size : unit = assert_with_error (Bytes.length hexa = 1n) "Should be a single hexa" in
        //match hexa with
        //| "0x00" -> 0n
        //| 0x01 -> 1n
        //| _ -> (failwith("Wrong hexa") : nat)        
        if hexa = 0x00 then 0n
        else if hexa = 0x01 then 1n
        else if hexa = 0x02 then 2n
        else if hexa = 0x03 then 3n
        else if hexa = 0x04 then 4n
        else if hexa = 0x05 then 5n
        else if hexa = 0x06 then 6n
        else if hexa = 0x07 then 7n
        else if hexa = 0x08 then 8n
        else if hexa = 0x09 then 9n
        else if hexa = 0x0A then 10n
        else if hexa = 0x0B then 11n
        else if hexa = 0x0C then 12n
        else if hexa = 0x0D then 13n
        else if hexa = 0x0E then 14n
        else if hexa = 0x0F then 15n
        else if hexa = 0x10 then 0n + 16n
        else if hexa = 0x11 then 1n + 16n
        else if hexa = 0x12 then 2n + 16n
        else if hexa = 0x13 then 3n + 16n
        else if hexa = 0x14 then 4n + 16n
        else if hexa = 0x15 then 5n + 16n
        else if hexa = 0x16 then 6n + 16n
        else if hexa = 0x17 then 7n + 16n
        else if hexa = 0x18 then 8n + 16n
        else if hexa = 0x19 then 9n + 16n
        else if hexa = 0x1A then 10n + 16n
        else if hexa = 0x1B then 11n + 16n
        else if hexa = 0x1C then 12n + 16n
        else if hexa = 0x1D then 13n + 16n
        else if hexa = 0x1E then 14n + 16n
        else if hexa = 0x1F then 15n + 16n
        else if hexa = 0x20 then 0n + 16n * 2n
        else if hexa = 0x21 then 1n + 16n * 2n
        else if hexa = 0x22 then 2n + 16n * 2n
        else if hexa = 0x23 then 3n + 16n * 2n
        else if hexa = 0x24 then 4n + 16n * 2n
        else if hexa = 0x25 then 5n + 16n * 2n
        else if hexa = 0x26 then 6n + 16n * 2n
        else if hexa = 0x27 then 7n + 16n * 2n
        else if hexa = 0x28 then 8n + 16n * 2n
        else if hexa = 0x29 then 9n + 16n * 2n
        else if hexa = 0x2A then 10n + 16n * 2n
        else if hexa = 0x2B then 11n + 16n * 2n
        else if hexa = 0x2C then 12n + 16n * 2n
        else if hexa = 0x2D then 13n + 16n * 2n
        else if hexa = 0x2E then 14n + 16n * 2n
        else if hexa = 0x2F then 15n + 16n * 2n
        else if hexa = 0x30 then 0n  + 16n * 3n
        else if hexa = 0x31 then 1n  + 16n * 3n
        else if hexa = 0x32 then 2n  + 16n * 3n
        else if hexa = 0x33 then 3n  + 16n * 3n
        else if hexa = 0x34 then 4n  + 16n * 3n
        else if hexa = 0x35 then 5n  + 16n * 3n
        else if hexa = 0x36 then 6n  + 16n * 3n
        else if hexa = 0x37 then 7n  + 16n * 3n
        else if hexa = 0x38 then 8n  + 16n * 3n
        else if hexa = 0x39 then 9n  + 16n * 3n
        else if hexa = 0x3A then 10n + 16n * 3n
        else if hexa = 0x3B then 11n + 16n * 3n
        else if hexa = 0x3C then 12n + 16n * 3n
        else if hexa = 0x3D then 13n + 16n * 3n
        else if hexa = 0x3E then 14n + 16n * 3n
        else if hexa = 0x3F then 15n + 16n * 3n
        else if hexa = 0x40 then 0n  + 16n * 4n
        else if hexa = 0x41 then 1n  + 16n * 4n
        else if hexa = 0x42 then 2n  + 16n * 4n
        else if hexa = 0x43 then 3n  + 16n * 4n
        else if hexa = 0x44 then 4n  + 16n * 4n
        else if hexa = 0x45 then 5n  + 16n * 4n
        else if hexa = 0x46 then 6n  + 16n * 4n
        else if hexa = 0x47 then 7n  + 16n * 4n
        else if hexa = 0x48 then 8n  + 16n * 4n
        else if hexa = 0x49 then 9n  + 16n * 4n
        else if hexa = 0x4A then 10n + 16n * 4n
        else if hexa = 0x4B then 11n + 16n * 4n
        else if hexa = 0x4C then 12n + 16n * 4n
        else if hexa = 0x4D then 13n + 16n * 4n
        else if hexa = 0x4E then 14n + 16n * 4n
        else if hexa = 0x4F then 15n + 16n * 4n
        else if hexa = 0x50 then 0n  + 16n * 5n
        else if hexa = 0x51 then 1n  + 16n * 5n
        else if hexa = 0x52 then 2n  + 16n * 5n
        else if hexa = 0x53 then 3n  + 16n * 5n
        else if hexa = 0x54 then 4n  + 16n * 5n
        else if hexa = 0x55 then 5n  + 16n * 5n
        else if hexa = 0x56 then 6n  + 16n * 5n
        else if hexa = 0x57 then 7n  + 16n * 5n
        else if hexa = 0x58 then 8n  + 16n * 5n
        else if hexa = 0x59 then 9n  + 16n * 5n
        else if hexa = 0x5A then 10n + 16n * 5n
        else if hexa = 0x5B then 11n + 16n * 5n
        else if hexa = 0x5C then 12n + 16n * 5n
        else if hexa = 0x5D then 13n + 16n * 5n
        else if hexa = 0x5E then 14n + 16n * 5n
        else if hexa = 0x5F then 15n + 16n * 5n
        else if hexa = 0x60 then 0n  + 16n * 6n
        else if hexa = 0x61 then 1n  + 16n * 6n
        else if hexa = 0x62 then 2n  + 16n * 6n
        else if hexa = 0x63 then 3n  + 16n * 6n
        else if hexa = 0x64 then 4n  + 16n * 6n
        else if hexa = 0x65 then 5n  + 16n * 6n
        else if hexa = 0x66 then 6n  + 16n * 6n
        else if hexa = 0x67 then 7n  + 16n * 6n
        else if hexa = 0x68 then 8n  + 16n * 6n
        else if hexa = 0x69 then 9n  + 16n * 6n
        else if hexa = 0x6A then 10n + 16n * 6n
        else if hexa = 0x6B then 11n + 16n * 6n
        else if hexa = 0x6C then 12n + 16n * 6n
        else if hexa = 0x6D then 13n + 16n * 6n
        else if hexa = 0x6E then 14n + 16n * 6n
        else if hexa = 0x6F then 15n + 16n * 6n
        else if hexa = 0x70 then 0n  + 16n * 7n
        else if hexa = 0x71 then 1n  + 16n * 7n
        else if hexa = 0x72 then 2n  + 16n * 7n
        else if hexa = 0x73 then 3n  + 16n * 7n
        else if hexa = 0x74 then 4n  + 16n * 7n
        else if hexa = 0x75 then 5n  + 16n * 7n
        else if hexa = 0x76 then 6n  + 16n * 7n
        else if hexa = 0x77 then 7n  + 16n * 7n
        else if hexa = 0x78 then 8n  + 16n * 7n
        else if hexa = 0x79 then 9n  + 16n * 7n
        else if hexa = 0x7A then 10n + 16n * 7n
        else if hexa = 0x7B then 11n + 16n * 7n
        else if hexa = 0x7C then 12n + 16n * 7n
        else if hexa = 0x7D then 13n + 16n * 7n
        else if hexa = 0x7E then 14n + 16n * 7n
        else if hexa = 0x7F then 15n + 16n * 7n
        else if hexa = 0x80 then 0n  + 16n * 8n
        else if hexa = 0x81 then 1n  + 16n * 8n
        else if hexa = 0x82 then 2n  + 16n * 8n
        else if hexa = 0x83 then 3n  + 16n * 8n
        else if hexa = 0x84 then 4n  + 16n * 8n
        else if hexa = 0x85 then 5n  + 16n * 8n
        else if hexa = 0x86 then 6n  + 16n * 8n
        else if hexa = 0x87 then 7n  + 16n * 8n
        else if hexa = 0x88 then 8n  + 16n * 8n
        else if hexa = 0x89 then 9n  + 16n * 8n
        else if hexa = 0x8A then 10n + 16n * 8n
        else if hexa = 0x8B then 11n + 16n * 8n
        else if hexa = 0x8C then 12n + 16n * 8n
        else if hexa = 0x8D then 13n + 16n * 8n
        else if hexa = 0x8E then 14n + 16n * 8n
        else if hexa = 0x8F then 15n + 16n * 8n
        else if hexa = 0x90 then 0n  + 16n * 9n
        else if hexa = 0x91 then 1n  + 16n * 9n
        else if hexa = 0x92 then 2n  + 16n * 9n
        else if hexa = 0x93 then 3n  + 16n * 9n
        else if hexa = 0x94 then 4n  + 16n * 9n
        else if hexa = 0x95 then 5n  + 16n * 9n
        else if hexa = 0x96 then 6n  + 16n * 9n
        else if hexa = 0x97 then 7n  + 16n * 9n
        else if hexa = 0x98 then 8n  + 16n * 9n
        else if hexa = 0x99 then 9n  + 16n * 9n
        else if hexa = 0x9A then 10n + 16n * 9n
        else if hexa = 0x9B then 11n + 16n * 9n
        else if hexa = 0x9C then 12n + 16n * 9n
        else if hexa = 0x9D then 13n + 16n * 9n
        else if hexa = 0x9E then 14n + 16n * 9n
        else if hexa = 0x9F then 15n + 16n * 9n
        else if hexa = 0xA0 then 0n  + 16n * 10n
        else if hexa = 0xA1 then 1n  + 16n * 10n
        else if hexa = 0xA2 then 2n  + 16n * 10n
        else if hexa = 0xA3 then 3n  + 16n * 10n
        else if hexa = 0xA4 then 4n  + 16n * 10n
        else if hexa = 0xA5 then 5n  + 16n * 10n
        else if hexa = 0xA6 then 6n  + 16n * 10n
        else if hexa = 0xA7 then 7n  + 16n * 10n
        else if hexa = 0xA8 then 8n  + 16n * 10n
        else if hexa = 0xA9 then 9n  + 16n * 10n
        else if hexa = 0xAA then 10n + 16n * 10n
        else if hexa = 0xAB then 11n + 16n * 10n
        else if hexa = 0xAC then 12n + 16n * 10n
        else if hexa = 0xAD then 13n + 16n * 10n
        else if hexa = 0xAE then 14n + 16n * 10n
        else if hexa = 0xAF then 15n + 16n * 10n
        else if hexa = 0xB0 then 0n  + 16n * 11n
        else if hexa = 0xB1 then 1n  + 16n * 11n
        else if hexa = 0xB2 then 2n  + 16n * 11n
        else if hexa = 0xB3 then 3n  + 16n * 11n
        else if hexa = 0xB4 then 4n  + 16n * 11n
        else if hexa = 0xB5 then 5n  + 16n * 11n
        else if hexa = 0xB6 then 6n  + 16n * 11n
        else if hexa = 0xB7 then 7n  + 16n * 11n
        else if hexa = 0xB8 then 8n  + 16n * 11n
        else if hexa = 0xB9 then 9n  + 16n * 11n
        else if hexa = 0xBA then 10n + 16n * 11n
        else if hexa = 0xBB then 11n + 16n * 11n
        else if hexa = 0xBC then 12n + 16n * 11n
        else if hexa = 0xBD then 189n
        else if hexa = 0xBE then 190n
        else if hexa = 0xBF then 191n
        else if hexa = 0xC0 then 192n
        else if hexa = 0xC1 then 193n
        else if hexa = 0xC2 then 194n
        else if hexa = 0xC3 then 195n
        else if hexa = 0xC4 then 196n
        else if hexa = 0xC5 then 197n
        else if hexa = 0xC6 then 198n
        else if hexa = 0xC7 then 199n
        else if hexa = 0xC8 then 200n
        else if hexa = 0xC9 then 201n
        else if hexa = 0xCA then 202n
        else if hexa = 0xCB then 203n
        else if hexa = 0xCC then 204n
        else if hexa = 0xCD then 205n
        else if hexa = 0xCE then 206n
        else if hexa = 0xCF then 207n
        else if hexa = 0xD0 then 208n
        else if hexa = 0xD1 then 209n
        else if hexa = 0xD2 then 210n
        else if hexa = 0xD3 then 211n
        else if hexa = 0xD4 then 212n
        else if hexa = 0xD5 then 213n
        else if hexa = 0xD6 then 214n
        else if hexa = 0xD7 then 215n
        else if hexa = 0xD8 then 216n
        else if hexa = 0xD9 then 217n
        else if hexa = 0xDA then 218n
        else if hexa = 0xDB then 219n
        else if hexa = 0xDC then 220n
        else if hexa = 0xDD then 221n
        else if hexa = 0xDE then 222n
        else if hexa = 0xDF then 223n
        else if hexa = 0xE0 then 224n
        else if hexa = 0xE1 then 225n
        else if hexa = 0xE2 then 226n
        else if hexa = 0xE3 then 227n
        else if hexa = 0xE4 then 228n
        else if hexa = 0xE5 then 229n
        else if hexa = 0xE6 then 230n
        else if hexa = 0xE7 then 231n
        else if hexa = 0xE8 then 232n
        else if hexa = 0xE9 then 233n
        else if hexa = 0xEA then 234n
        else if hexa = 0xEB then 235n
        else if hexa = 0xEC then 236n
        else if hexa = 0xED then 237n
        else if hexa = 0xEE then 238n
        else if hexa = 0xEF then 239n
        else if hexa = 0xF0 then 240n
        else if hexa = 0xF1 then 241n
        else if hexa = 0xF2 then 242n
        else if hexa = 0xF3 then 243n
        else if hexa = 0xF4 then 244n
        else if hexa = 0xF5 then 245n
        else if hexa = 0xF6 then 246n
        else if hexa = 0xF7 then 247n
        else if hexa = 0xF8 then 248n
        else if hexa = 0xF9 then 249n
        else if hexa = 0xFA then 250n
        else if hexa = 0xFB then 251n
        else if hexa = 0xFC then 252n
        else if hexa = 0xFD then 253n
        else if hexa = 0xFE then 254n
        else if hexa = 0xFF then 255n
        else
            (failwith("Wrong hexa") : nat)



    let bytes_to_nat(payload : bytes) : nat =
        let rec convert_to_nat(acc, indice, payload : nat * nat * bytes) : nat =
            if indice = 1n then
                acc + hexa_to_nat(payload)
            else
                let size : nat = (Bytes.length payload) in
                let one_left_bytes = Bytes.sub 0n 1n payload in
                let right_bytes = Bytes.sub 1n (abs(size - 1n)) payload in 
                let one_left_nat = hexa_to_nat(one_left_bytes) * power(256n, abs(indice - 1n)) in 
                convert_to_nat(acc + one_left_nat, abs(indice - 1n), right_bytes)
        in
        convert_to_nat(0n, Bytes.length payload, payload)

end