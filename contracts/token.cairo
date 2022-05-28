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
    assert_not_zero
)


struct Token:
    member name : felt
    member address : felt
    member price : felt
end

@storage_var
func create_token(name : felt , address : felt, slot : felt) -> (token: Token):
end

@storage_var
func slot(address : felt) -> (slot : felt):
end

@storage_var
func token_from_address(address : felt, slot : felt) -> (token: Token):
end

@storage_var
func token(slot : felt) -> (token : Token):
end

@storage_var
func nb_slot () -> (nb_slot : felt):
end

@external
func add_token_to_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(token_name : felt, token_address: felt, token_price : felt):
    let (address) = get_caller_address()
    let (slot_token) = slot.read(address)
    let res : Token = Token(token_name,token_address, token_price)
    create_token.write(token_name, token_address,slot_token,res) 
    slot.write(address, slot_token + 1)
    nb_slot.write(slot_token + 1)
    return ()
end

@view 
func get_token_from_address_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address : felt, slot_token : felt) -> (token: Token):
    let (slot_tkn) = slot.read(address)
    let (res) = token.read(slot_tkn)
    return (res)
end

@view
func get_nb_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (nb_slot : felt):
    let (res) = nb_slot.read()
    return (res)
end

@view
func get_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (address : felt):
    let (address) = get_caller_address()
    return (address)
end

@view
func get_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (slot : felt):
    let (address) = get_caller_address()
    let (res) = slot.read(address)
    return (res)
end

@view
func get_token_from_name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(name : felt, slot : felt, slot_len : felt) -> (token: Token):
    alloc_locals
    let tkn : Token = token.read(slot)
    if tkn.name == name:
        tempvar syscall_ptr = syscall_ptr
        return (tkn)
    end
    let (local n_1) = get_token_from_name(name=name,slot=slot+1,slot_len=slot_len)
    return(n_1)
end
