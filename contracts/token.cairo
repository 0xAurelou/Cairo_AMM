# Declare this file as a contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.math import (
    assert_le,
    assert_lt,
    sqrt,
    sign,
    abs_value,
    signed_div_rem,
    unsigned_div_rem,
    assert_not_zero,
)

struct Token:
    member name : felt
    member address : felt
    member price : felt
end

@storage_var
func slot() -> (slot : felt):
end

@storage_var
func token_from_address(address : felt, slot : felt) -> (token : Token):
end

@storage_var
func token(slot : felt) -> (token : Token):
end

# A revoir
@storage_var
func nb_slot() -> (nb_slot : felt):
end

@external
func add_token_to_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_name : felt, token_address : felt, token_price : felt
):
    let (slot_token) = slot.read()
    let res : Token = Token(token_name, token_address, token_price)
    token.write(slot_token, res)
    slot.write(slot_token + 1)
    return ()
end

@view
func get_token_from_address_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    slot_number : felt
) -> (token : Token):
    let (res) = token.read(slot_number)
    return (res)
end

@view
func get_nb_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    nb_slot : felt
):
    let (res) = slot.read()
    return (res)
end

@view
func get_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    address : felt
):
    let (address) = get_caller_address()
    return (address)
end
