%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import assert_le, assert_nn_le, unsigned_div_rem
from starkware.starknet.common.syscalls import storage_read, storage_write

@storage_var
func pool_balance(token_type : felt) -> (balance : felt):
end

@external
func set_pool_token_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_type : felt, balance : felt
):
    assert_nn_le(balance, 2 ** 64 - 1)
    pool_balance.write(token_type, balance)
    return ()
end

@view
func get_pool_token_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_type : felt
) -> (balance : felt):
    return pool_balance.read(token_type)
end

# Swaps tokens between the given account and the pool.
func do_swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account_id : felt, token_from : felt, token_to : felt, amount_from : felt
) -> (amount_to : felt):
    alloc_locals

    # Get pool balance.
    let (local amm_from_balance) = get_pool_token_balance(token_type=token_from)
    let (local amm_to_balance) = get_pool_token_balance(token_type=token_to)

    # Calculate swap amount.
    let (local amount_to, _) = unsigned_div_rem(
        amm_to_balance * amount_from, amm_from_balance + amount_from
    )

    # Update token_from balances.
    modify_account_balance(account_id=account_id, token_type=token_from, amount=-amount_from)
    set_pool_token_balance(token_type=token_from, balance=amm_from_balance + amount_from)

    # Update token_to balances.
    modify_account_balance(account_id=account_id, token_type=token_to, amount=amount_to)
    set_pool_token_balance(token_type=token_to, balance=amm_to_balance - amount_to)
    return (amount_to=amount_to)
end
