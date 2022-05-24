%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import assert_le, assert_nn_le, unsigned_div_rem
from starkware.starknet.common.syscalls import storage_read, storage_write

@storage_var
func pool_balance(token_type : felt) -> (balance : felt):
end

@storage_var
func account_balance(account_id : felt, token_type : felt) -> (
    balance : felt
):
end

@view
func get_account_token_balance{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(account_id : felt, token_type : felt) -> (balance : felt):
    return account_balance.read(account_id, token_type)
end


@view
func get_pool_token_balance{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(token_type : felt) -> (balance : felt):
    return pool_balance.read(token_type)
end

const MAX_BALANCE = 2**64 -1

const TOKEN_TYPE_A = 1
const TOKEN_TYPE_B = 2

const POOL_UPPER_BOUND = 2**30
const ACCOUNT_BALANCE_BOUND = 2**27

func modify_account_balance{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(account_id : felt, token_type : felt, amount : felt):
    let (current_balance) = account_balance.read(
        account_id, token_type
    )
    tempvar new_balance = current_balance + amount
    assert_nn_le(new_balance, MAX_BALANCE- 1)
    account_balance.write(
        account_id=account_id,
        token_type=token_type,
        value=new_balance,
    )
    return ()
end

func set_pool_token_balance{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(token_type : felt, balance : felt):
    assert_nn_le(balance, MAX_BALANCE- 1)
    pool_balance.write(token_type, balance)
    return ()
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


func get_opposite_token(token_type : felt) -> (t : felt):
    if token_type == TOKEN_TYPE_A:
        return (TOKEN_TYPE_B)
    else:
        return (TOKEN_TYPE_A)
    end
end

func swap{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(account_id : felt, token_from : felt, amount_from : felt) -> (
    amount_to : felt
):
    # Verify that token_from is either TOKEN_TYPE_A or TOKEN_TYPE_B.
    assert (token_from - TOKEN_TYPE_A) * (token_from - TOKEN_TYPE_B) = 0

    # Check requested amount_from is valid.
    assert_nn_le(amount_from, MAX_BALANCE - 1)

    # Check user has enough funds.
    let (account_from_balance) = get_account_token_balance(
        account_id=account_id, token_type=token_from
    )
    assert_le(amount_from, account_from_balance)

    # Execute the actual swap.
    let (token_to) = get_opposite_token(token_type=token_from)
    let (amount_to) = do_swap(
        account_id=account_id,
        token_from=token_from,
        token_to=token_to,
        amount_from=amount_from,
    )

    return (amount_to=amount_to)
end

@external
func init_pool{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(token_a : felt, token_b : felt):
    assert_nn_le(token_a, POOL_UPPER_BOUND - 1)
    assert_nn_le(token_b, POOL_UPPER_BOUND - 1)

    set_pool_token_balance(token_type=TOKEN_TYPE_A, balance=token_a)
    set_pool_token_balance(token_type=TOKEN_TYPE_B, balance=token_b)

    return ()
end

@external
func add_demo_token{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    account_id : felt, token_a_amount : felt, token_b_amount : felt
):
    # Make sure the account's balance is much smaller then pool init balance.
    assert_nn_le(token_a_amount, ACCOUNT_BALANCE_BOUND - 1)
    assert_nn_le(token_b_amount, ACCOUNT_BALANCE_BOUND - 1)

    modify_account_balance(account_id=account_id, token_type=TOKEN_TYPE_A, amount=token_a_amount)
    modify_account_balance(account_id=account_id, token_type=TOKEN_TYPE_B, amount=token_b_amount)
    return ()
end
