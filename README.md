# BitStack Analytics Protocol (BAP)

A decentralized analytics protocol built on Stacks L2 that enables token staking, tiered governance participation, and dynamic reward distribution.

## Overview

BAP introduces a novel approach to decentralized analytics by combining multi-tiered staking, governance mechanisms, and flexible lock periods with multiplier benefits. The protocol implements sophisticated reward calculations based on stake duration and amount.

## Key Features

- **Multi-Tiered Staking System**

  - Three tier levels with increasing benefits
  - Dynamic reward multipliers
  - Flexible lock periods (1 month, 2 months)
  - Automated reward calculations

- **Governance Mechanism**

  - Proposal creation and voting
  - Voting power based on stake amount
  - Cooldown periods for stability
  - Minimum voting thresholds

- **Security Controls**
  - Emergency mode
  - Contract pause functionality
  - Authorization checks
  - Cooldown periods for unstaking

## Protocol Architecture

### 1. Staking System

#### Tier Levels

- **Tier 1**

  - Minimum Stake: 1M uSTX
  - Reward Multiplier: 1x
  - Basic features enabled

- **Tier 2**

  - Minimum Stake: 5M uSTX
  - Reward Multiplier: 1.5x
  - Additional governance features

- **Tier 3**
  - Minimum Stake: 10M uSTX
  - Reward Multiplier: 2x
  - Full feature access

#### Lock Periods

- No Lock: 1x multiplier
- 1 Month (4,320 blocks): 1.25x multiplier
- 2 Months (8,640 blocks): 1.5x multiplier

### 2. Governance

#### Proposal System

- Minimum voting power requirement: 1M tokens
- Description length: 10-256 characters
- Voting period: 100-2,880 blocks (approximately 1 day)
- Vote tracking for both support and opposition

### 3. Reward Distribution

- Base reward rate: 5%
- Bonus rate: 1% for extended staking
- Rewards calculated based on:
  - Stake amount
  - Tier level
  - Lock period multiplier
  - Duration of stake

## Smart Contract Functions

### Public Functions

#### Staking Operations

- `stake-stx(amount, lock-period)`: Stake STX tokens with optional lock period
- `initiate-unstake(amount)`: Begin unstaking process with cooldown
- `complete-unstake()`: Finalize unstaking after cooldown period

#### Governance

- `create-proposal(description, voting-period)`: Create new governance proposal
- `vote-on-proposal(proposal-id, vote-for)`: Cast vote on active proposal

#### Contract Management

- `initialize-contract()`: Set up initial contract configuration
- `pause-contract()`: Pause contract operations
- `resume-contract()`: Resume contract operations

### Read-Only Functions

- `get-contract-owner()`: Retrieve contract owner address
- `get-stx-pool()`: Get current STX pool balance
- `get-proposal-count()`: Get total number of proposals

## Error Codes

| Code | Description                     |
| ---- | ------------------------------- |
| 1000 | Not authorized                  |
| 1001 | Invalid protocol parameters     |
| 1002 | Invalid amount                  |
| 1003 | Insufficient STX balance        |
| 1004 | Cooldown period active          |
| 1005 | No stake found                  |
| 1006 | Below minimum stake requirement |
| 1007 | Contract paused                 |

## Security Considerations

1. **Authorization**

   - Contract owner privileges
   - Stake ownership verification
   - Voting power requirements

2. **Cooldown Periods**

   - 24-hour unstaking cooldown
   - Prevents rapid stake manipulation
   - Protects protocol stability

3. **Emergency Controls**
   - Contract pause mechanism
   - Emergency mode for critical situations
   - Owner-only administrative functions

## Protocol Parameters

| Parameter        | Value        | Description                          |
| ---------------- | ------------ | ------------------------------------ |
| Minimum Stake    | 1M uSTX      | Minimum required stake               |
| Cooldown Period  | 1,440 blocks | Unstaking cooldown (~24 hours)       |
| Base Reward Rate | 5%           | Base annual reward rate              |
| Bonus Rate       | 1%           | Additional rate for extended staking |
| Minimum Votes    | 1M tokens    | Minimum votes for proposal           |

## Data Structures

### UserPositions

- Total collateral
- Total debt
- Health factor
- Last updated block
- STX staked amount
- Analytics tokens
- Voting power
- Tier level
- Rewards multiplier

### StakingPositions

- Stake amount
- Start block
- Last claim block
- Lock period
- Cooldown start
- Accumulated rewards

### Proposals

- Creator address
- Description
- Start/end blocks
- Execution status
- Vote counts
- Minimum vote threshold

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.
