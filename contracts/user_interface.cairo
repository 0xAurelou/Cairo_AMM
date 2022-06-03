%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_le, assert_nn_le, unsigned_div_rem

@contract_interface
namespace IUser:
    func assign_user_id() -> (id : felt):
    end

    func increase_token_balance(user_id : felt, token_address : felt, amount : felt) -> ():
    end

    func get_user_id() -> (user_id : felt):
    end

    func get_user_count() -> (user_count : felt):
    end

    func get_balance(user_id : felt, token_address : felt) -> (res: felt):
    end
end

@external
func call_assign_user_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(contract_address : felt) -> (id : felt):
    let (res) = IUser.assign_user_id(contract_address=contract_address)
    return (res)
end

@external
func call_increase_token_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(contract_address : felt,user_id : felt, token_address : felt, amount : felt) -> ():
    IUser.increase_token_balance(contract_address=contract_address, user_id=user_id, token_address=token_address,amount=amount)
    ret
end

@view
func call_get_user_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(contract_address : felt) -> (user_id : felt):
    let (res) = IUser.get_user_id(contract_address=contract_address)
    return(res)
end

@view
func call_get_user_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(contract_address : felt) -> (user_count : felt):
    let (res) = IUser.get_user_count(contract_address=contract_address)
    return (res)
end

@view
func get_balance {syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(contract_address, user_id : felt, token_address : felt) -> (res: felt):
    let (res) = IUser.get_balance(contract_address=contract_address,user_id=user_id, token_address=token_address)
    return (res)
en

