type revoke_beneficiary_param = address

type t = 
      Start of unit 
    | Revoke of unit
    | RevokeBeneficiary of address
    | Release of unit

