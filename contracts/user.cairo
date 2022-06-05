# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_le, assert_nn_le, unsigned_div_rem
from contracts.token_interface import IToken, Token

@storage_var
func user_id() -> (res : felt):
end

struct user:
    member account_id : felt
    member token : Token
end

# This one is just for testing purpose
@storage_var
func user_count() -> (res : felt):
end

@storage_var
func token_address(name : felt) -> (address : felt):
end

@storage_var
func token_amount(user_id : felt, token_address : felt)-> (res : felt):
end

@storage_var
func account_balance(account_id : felt, token_address : felt) -> (balance : felt):
end

@event
func new_user(count : felt):
end

@external
func assign_user_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    id : felt
):
    let (count) = user_count.read()
    user_id.write(count)
    user_count.write(count + 1)
    return (count)
end

@external
func increase_token_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_id : felt, token_address : felt, amount : felt
):
    let (res) = token_amount.read(user_id, token_address)
    account_balance.write(user_id,token_address , res + amount)
    return ()
end

@view
func get_user_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    user : felt
):
    let (user) = user_id.read()
    return (user)
end

@view
func get_user_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
    count : felt
):
    let (count) = user_count.read()
    return (count)
end

# Returns the current balance.
@view
func get_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_id : felt, token_address : felt
) -> (res : felt):
    let (res) = account_balance.read(user_id, token_address)
    return (res)
end

@view
func get_account_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(token_contract : felt , user_id : felt, token_slot : felt,sum : felt) -> (res : felt): 
    let (nb_token) = IToken.get_nb_slot(token_contract)
    if nb_token == token_slot:
        return (sum)
    end
    let (tkn) = IToken.delegate_get_token_from_slot(token_contract,token_slot)
    let (balance) = account_balance.read(user_id, tkn.address)
    let addition_sum = balance * tkn.price
    return get_account_balance(token_contract=token_contract, user_id=user_id, token_slot=token_slot + 1,sum = sum + addition_sum) 
end

@view
func get_token_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(user_id : felt, token_address : felt)-> (res : felt):
    return token_amount.read(user_id, token_address)
end
