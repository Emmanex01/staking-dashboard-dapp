#[starknet::interface]
pub trait IStake<TcontractState> {
    fn stake (ref self: TcontractState, amount:u256, timestamp: u64);
    fn unstake (ref self: TcontractState, amount:u256);
    fn get_staked_amount (self:@TcontractState) -> u256;
}


#[starknet::contract]
pub mod Stake {
    use super::IStake;
    use core::starknet::{ContractAddress, get_caller_address, storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess}};

    #[storage]
    pub struct Storage{
        stake_token: ByteArray,
        total_stake: u256,
        reward_balance: felt252,
        reward_rate: felt252,
        cooldown_period: u64,
        owner: ContractAddress
    }

    #[constructor]
    fn constructor (ref self: ContractState, user: ContractAddress) {
        self.owner.write(user)
    }

    #[abi(embed_v0)]
    impl stakeImpl of IStake<ContractState>{
        fn stake (ref self: ContractState, amount:u256, timestamp: u64) {
            // get the address of caller of the function
            let caller = get_caller_address();

            // check whether the caller is the owner of the address
            assert(self.owner.read() == caller, 'OWNER NOT RECOGNIZED');

            // set timestamp
            self.cooldown_period.write(timestamp);

            // get the prevstake and add with current state
            let prevStake = self.total_stake.read();
            let currentStake = prevStake + amount;
            self.total_stake.write(currentStake);
        }
        fn unstake (ref self: ContractState, amount:u256) {
            // get the address of caller of the function
            let caller = get_caller_address();

            // check whether the caller is the owner of the address
            assert(self.owner.read() == caller, 'OWNER NOT RECOGNIZED');

            // get the prevstake and add with current state
            let prevStake = self.total_stake.read();

            // check whether user balance is empty
            assert(self.total_stake.read() > 0, 'NOTHING TO UNSTAKE');

            // check whether user has prev stake
            assert(self.total_stake.read() >= amount, 'BALANCE LESS THAN AMOUNT');

            let currentStake = prevStake - amount;
            self.total_stake.write(currentStake);
        }
        fn get_staked_amount (self:@ContractState) -> u256 {
            self.total_stake.read()
        }
    }

    // #[generate_trait]
    // impl InternalFunction of InternalFunctionTraits {
    //     fn calculate_reward (self: @ContractState) -> u128 {
            
    //     }
    // }
}