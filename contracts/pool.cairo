%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import assert_le, assert_nn_le, unsigned_div_rem
from starkware.starknet.common.syscalls import storage_read, storage_write
from contracts.user_interface import IUser
from contracts.token import Token

# The maximum amount of each token that belongs to the AMM.
const BALANCE_UPPER_BOUND = 2 ** 64

const POOL_UPPER_BOUND = 2 ** 30

# Correspond to the total liquidity in the pool (ideally 50% token_a and 50% token_b)
# 
@storage_var
func AMM_balance(token_a_addr : felt, token_b_addr : felt) -> (balance : felt):
end

@storage_var
func pool_balance(token_address : felt) -> (balance : felt):
end

@storage_var
func total_account_value (account_id : felt) -> (value : felt):
end

func set_pool_token_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_address : felt, balance : felt
):
    assert_nn_le(balance, BALANCE_UPPER_BOUND - 1)
    pool_balance.write(token_address, balance)
    return ()
end

@view
func get_pool_token_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_address : felt
) -> (balance : felt):
    return pool_balance.read(token_address)
end

@view
func get_AMM_balance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_a_address : felt, token_b_address : felt
) -> (balance : felt):
    return AMM_balance.read(token_a_address,token_b_address)
end

# Swaps tokens between the given account and the pool.
func do_swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    contract_address : felt,
    account_id : felt, token_from : felt, token_to : felt, amount_from : felt
) -> (amount_to : felt):
    alloc_locals

    # Get pool balance.
    let (local amm_from_balance) = get_pool_token_balance(token_address=token_from)
    let (local amm_to_balance) = get_pool_token_balance(token_address=token_to)

    # Calculate swap amount.
    let (local amount_to, _) = unsigned_div_rem(
        amm_to_balance * amount_from, amm_from_balance + amount_from
    )

    # Update token_from balances.
    IUser.delegate_increase_token_balance(contract_address=contract_address, user_id=account_id, token_address=token_from, amount=-amount_from)
    set_pool_token_balance(token_address=token_from, balance=amm_from_balance + amount_from)

    # Update token_to balances.
    IUser.delegate_increase_token_balance(contract_address=contract_address, user_id=account_id, token_address=token_to, amount=amount_to)
    set_pool_token_balance(token_address=token_to, balance=amm_to_balance - amount_to)
    return (amount_to=amount_to)
end

@external
func swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
contract_address : felt, account_id : felt, token_from : felt, amount_from : felt, token_to : felt
) -> (amount_to : felt):

    # Check requested amount_from is valid.
    assert_nn_le(amount_from, BALANCE_UPPER_BOUND - 1)
    # Check user has enough funds.
    let (account_from_balance) = IUser.delegate_get_token_amount(contract_address=contract_address,
        user_id=account_id, token_address=token_from
    )
    assert_le(amount_from, account_from_balance)

    let (amount_to) = do_swap(contract_address=contract_address,
        account_id=account_id, token_from=token_from, token_to=token_to, amount_from=amount_from
    )

    return (amount_to=amount_to)
end

@external
func add_demo_token{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    contract_address : felt, account_id : felt, token_a_amount : felt,token_a_address : felt,  token_b_amount : felt,
    token_b_address : felt
):
    # Make sure the account's balance is much smaller then pool init balance.
    assert_nn_le(token_a_amount, 2**30 - 1)
    assert_nn_le(token_b_amount, 2**30 - 1)

    IUser.delegate_increase_token_balance(contract_address=contract_address, user_id=account_id, token_address=token_a_address, 
    amount=token_a_amount)

    IUser.delegate_increase_token_balance(contract_address=contract_address, user_id=account_id, token_address=token_b_address, 
    amount=token_b_amount)
    return ()
end

# Until we have LPs, for testing, we'll need to initialize the AMM somehow.
@external
func init_pool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_a_address : felt, token_a_amount : felt, token_b_address : felt ,token_b_amount : felt
):
    assert_nn_le(token_a_amount, POOL_UPPER_BOUND - 1)
    assert_nn_le(token_b_amount, POOL_UPPER_BOUND - 1)

    set_pool_token_balance(token_address=token_a_address, balance=token_a_amount)
    set_pool_token_balance(token_address=token_b_address, balance=token_b_amount)

    return ()
end
