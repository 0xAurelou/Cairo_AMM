# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_le, assert_nn_le, unsigned_div_rem
from contracts.token_interface import IToken, Token

@storage_var
func user_id() -> (res : felt):
end

# This one is just for testing purpose
@storage_var
func user_count() -> (res : felt):
end

@storage_var
func token_address(name : felt) -> (address : felt):
end

@storage_var
func get_token_amount(user_id : felt, token_address : felt)-> (res : felt):
end

@storage_var
func user_balance(account_id : felt) -> (res : felt):
end

@event
func increase_balance_called(current_balance : felt, amount : felt):
end

@storage_var
func account_balance(account_id : felt, token_address : felt) -> (balance : felt):
end

@event
func new_user(count : felt):
end

namespace user:
    func assign_user_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        id : felt
    ):
        let (count) = user_count.read()
        user_id.write(count)
        user_count.write(count + 1)
        return (count)
    end

    func increase_token_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        user_id : felt, token_address : felt, amount : felt
    ):
        let (res) = get_token_amount.read(user_id, token_address)
        account_balance.write(user_id, res + amount)
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
        user_id : felt
    ) -> (res : felt):
        let (res) = user_balance.read(user_id)
        return (res)
    end
end
