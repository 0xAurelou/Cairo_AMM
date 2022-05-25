# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

# Define a storage variable.
@storage_var
func balance() -> (res : felt):
end

@storage_var
func pair_address(first_token : felt, second_token : felt) -> (address : felt):
end

@storage_var
func token_address(name : felt) -> (address : felt):
end

@storage_var
func get_token_amount(account_id : felt, token_type : felt) -> (res : felt):
end

@storage_var
func balance_account (account_id : felt) -> (res : felt):
end

@storage_var
func pool_balance(pool_address : felt, token_type :felt) -> (res : felt):
end

# Increases the balance by the given amount.
@external
func increase_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        token_address : felt , amount : felt):
    let (res) = balance.read()
    balance.write(res + amount)
    return ()
end

# Returns the current balance.
@view
func get_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        res : felt):
    let (res) = balance.read()
    return (res)
end
