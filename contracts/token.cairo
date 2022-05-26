# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address


@storage_var
func get_token_amount (address : felt) -> (amount : felt):
end

@storage_var
func get_token_address_from_name (name : felt) -> (address : felt):
end

@storage_var
func token_name () -> (name : felt):
end

@external
func create_token{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(name : felt):
    let (res) = token_name.read()
    token_name.write(name)
    return()
end

@external
func map_token_name_to_address {syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(name : felt, address : felt): 
    let (res) = get_token_address_from_name.read(name)
    get_token_address_from_name.write(name, address)
    return ()
end

@view
func get_token_addr {syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(name : felt) -> (address : felt):
    let (res) = get_token_address_from_name.read(name)
    return (res)
end

