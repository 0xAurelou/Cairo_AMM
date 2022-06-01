%lang starknet

from starkware.cairo.common.uint256 import Uint256 
from starkware.cairo.common.cairo_builtins import HashBuiltin 
from starkware.starknet.common.syscalls import get_caller_address 
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import(assert_le, assert_lt, sqrt, sign, abs_value, signed_div_rem,
           unsigned_div_rem, assert_not_zero, )

    struct Token:
        member name: felt 
        member address : felt
        member price : felt
    end

@contract_interface 
namespace IToken: 
    func add_token_to_slot(token_name : felt, token_address : felt, token_price : felt)
        ->(token : Token):
    end

    func get_token_from_slot(slot_number : felt) ->(token : Token): 
    end

    func get_nb_slot() ->(nb_slot: felt):
    end

    func get_address() ->(address: felt):
    end
end

@external 
func call_add_token_to_slot{
syscall_ptr: felt *,
pedersen_ptr: HashBuiltin *,
range_check_ptr
}(contract_address: felt, token_name : felt, token_address : felt, token_price)
    -> (token : Token): 
    let(res) = IToken .add_token_to_slot(contract_address = contract_address,
                 token_name = token_name, token_address = token_address,
                 token_price = token_price)
    return (res)
end

@view
func call_get_nb_slot{
        syscall_ptr: felt *,
        pedersen_ptr: HashBuiltin *,
        range_check_ptr
    }(contract_address : felt)
        ->(nb_slot : felt):
    let(res) = IToken.get_nb_slot(contract_address = contract_address) 
    return (res)
end

@view
    func call_get_address{
        syscall_ptr: felt *,
        pedersen_ptr: HashBuiltin *,
        range_check_ptr
    }(contract_address)
        ->(address: felt): 
    let(res) = IToken.get_address(contract_address =contract_address) 
    return (res)
end
