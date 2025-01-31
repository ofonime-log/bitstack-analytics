;; Title: BitStack Analytics Protocol (BAP)
;; 
;; Summary:
;; A decentralized analytics protocol built on Stacks L2 that enables token staking,
;; tiered governance participation, and dynamic reward distribution. The protocol 
;; implements a sophisticated staking mechanism with tier-based rewards and voting power.
;;
;; Description:
;; BAP introduces a novel approach to decentralized analytics by combining:
;; - Multi-tiered staking system with dynamic rewards
;; - Governance mechanism with cooldown periods and voting power
;; - Flexible lock periods with multiplier benefits
;; - Emergency controls and contract management
;; - Automated reward calculations based on stake duration and amount
;;
;; Architecture:
;; 1. Staking System: Implements tiered staking with multipliers
;; 2. Governance: Proposal creation and voting mechanisms
;; 3. Reward Distribution: Dynamic calculation based on stake and duration
;; 4. Security Controls: Emergency modes and authorization checks

;; Token Definition
(define-fungible-token ANALYTICS-TOKEN u0)

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INVALID-PROTOCOL (err u1001))
(define-constant ERR-INVALID-AMOUNT (err u1002))
(define-constant ERR-INSUFFICIENT-STX (err u1003))
(define-constant ERR-COOLDOWN-ACTIVE (err u1004))
(define-constant ERR-NO-STAKE (err u1005))
(define-constant ERR-BELOW-MINIMUM (err u1006))
(define-constant ERR-PAUSED (err u1007))

;; Protocol Configuration
(define-data-var contract-paused bool false)
(define-data-var emergency-mode bool false)
(define-data-var stx-pool uint u0)
(define-data-var base-reward-rate uint u500) ;; 5% base rate (100 = 1%)
(define-data-var bonus-rate uint u100) ;; 1% bonus for longer staking
(define-data-var minimum-stake uint u1000000) ;; Minimum stake amount
(define-data-var cooldown-period uint u1440) ;; 24 hour cooldown in blocks
(define-data-var proposal-count uint u0)

;; Data Structures
(define-map Proposals
    { proposal-id: uint }
    {
        creator: principal,
        description: (string-utf8 256),
        start-block: uint,
        end-block: uint,
        executed: bool,
        votes-for: uint,
        votes-against: uint,
        minimum-votes: uint
    }
)

(define-map UserPositions
    principal
    {
        total-collateral: uint,
        total-debt: uint,
        health-factor: uint,
        last-updated: uint,
        stx-staked: uint,
        analytics-tokens: uint,
        voting-power: uint,
        tier-level: uint,
        rewards-multiplier: uint
    }
)

(define-map StakingPositions
    principal
    {
        amount: uint,
        start-block: uint,
        last-claim: uint,
        lock-period: uint,
        cooldown-start: (optional uint),
        accumulated-rewards: uint
    }
)

(define-map TierLevels
    uint
    {
        minimum-stake: uint,
        reward-multiplier: uint,
        features-enabled: (list 10 bool)
    }
)

;; Private Functions

;; desc Determines user tier based on stake amount
;; param stake-amount (uint) - Amount of STX staked
;; returns {tier-level: uint, reward-multiplier: uint}
(define-private (get-tier-info (stake-amount uint))
    (if (>= stake-amount u10000000)
        {tier-level: u3, reward-multiplier: u200}
        (if (>= stake-amount u5000000)
            {tier-level: u2, reward-multiplier: u150}
            {tier-level: u1, reward-multiplier: u100}
        )
    )
)

;; desc Calculates reward multiplier based on lock duration
;; param lock-period (uint) - Duration of stake lock in blocks
;; returns uint - Multiplier value
(define-private (calculate-lock-multiplier (lock-period uint))
    (if (>= lock-period u8640)     ;; 2 months
        u150                       ;; 1.5x multiplier
        (if (>= lock-period u4320) ;; 1 month
            u125                   ;; 1.25x multiplier
            u100                   ;; 1x multiplier (no lock)
        )
    )
)

;; desc Computes rewards for a user based on stake and duration
;; param user (principal) - User address
;; param blocks (uint) - Number of blocks to calculate rewards for
;; returns uint - Calculated reward amount
(define-private (calculate-rewards (user principal) (blocks uint))
    (let
        (
            (staking-position (unwrap! (map-get? StakingPositions user) u0))
            (user-position (unwrap! (map-get? UserPositions user) u0))
            (stake-amount (get amount staking-position))
            (base-rate (var-get base-reward-rate))
            (multiplier (get rewards-multiplier user-position))
        )
        (/ (* (* (* stake-amount base-rate) multiplier) blocks) u14400000)
    )
)

;; desc Validates proposal description length
;; param desc (string-utf8 256) - Proposal description
;; returns bool - Validation result
(define-private (is-valid-description (desc (string-utf8 256)))
    (and 
        (>= (len desc) u10)   ;; Minimum description length
        (<= (len desc) u256)  ;; Maximum description length
    )
)

;; desc Validates lock period duration
;; param lock-period (uint) - Proposed lock period
;; returns bool - Validation result
(define-private (is-valid-lock-period (lock-period uint))
    (or 
        (is-eq lock-period u0)     ;; No lock
        (is-eq lock-period u4320)  ;; 1 month
        (is-eq lock-period u8640)  ;; 2 months
    )
)

;; desc Validates voting period duration
;; param period (uint) - Proposed voting period
;; returns bool - Validation result
(define-private (is-valid-voting-period (period uint))
    (and 
        (>= period u100)   ;; Minimum voting blocks
        (<= period u2880)  ;; Maximum voting blocks (approximately 1 day)
    )
)

;; Public Functions

;; desc Initializes protocol configuration and tier levels
;; returns (response bool uint)
(define-public (initialize-contract)
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        
        ;; Set up tier levels
        (map-set TierLevels u1 
            {
                minimum-stake: u1000000,  ;; 1M uSTX
                reward-multiplier: u100,  ;; 1x
                features-enabled: (list true false false false false false false false false false)
            })
        (map-set TierLevels u2
            {
                minimum-stake: u5000000,  ;; 5M uSTX
                reward-multiplier: u150,  ;; 1.5x
                features-enabled: (list true true true false false false false false false false)
            })
        (map-set TierLevels u3
            {
                minimum-stake: u10000000, ;; 10M uSTX
                reward-multiplier: u200,  ;; 2x
                features-enabled: (list true true true true true false false false false false)
            })
        (ok true)
    )
)

;; desc Stakes STX tokens with optional lock period
;; param amount (uint) - Amount of STX to stake
;; param lock-period (uint) - Duration to lock stake
;; returns (response bool uint)
(define-public (stake-stx (amount uint) (lock-period uint))
    (let
        (
            (current-position (default-to 
                {
                    total-collateral: u0,
                    total-debt: u0,
                    health-factor: u0,
                    last-updated: u0,
                    stx-staked: u0,
                    analytics-tokens: u0,
                    voting-power: u0,
                    tier-level: u0,
                    rewards-multiplier: u100
                }
                (map-get? UserPositions tx-sender)))
        )
        (asserts! (is-valid-lock-period lock-period) ERR-INVALID-PROTOCOL)
        (asserts! (not (var-get contract-paused)) ERR-PAUSED)
        (asserts! (>= amount (var-get minimum-stake)) ERR-BELOW-MINIMUM)
        
        ;; Transfer STX to contract
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        ;; Calculate tier level and multiplier
        (let
            (
                (new-total-stake (+ (get stx-staked current-position) amount))
                (tier-info (get-tier-info new-total-stake))
                (lock-multiplier (calculate-lock-multiplier lock-period))
            )
            
            ;; Update staking position
            (map-set StakingPositions
                tx-sender
                {
                    amount: amount,
                    start-block: block-height,
                    last-claim: block-height,
                    lock-period: lock-period,
                    cooldown-start: none,
                    accumulated-rewards: u0
                }
            )
            
            ;; Update user position with new tier info
            (map-set UserPositions
                tx-sender
                (merge current-position
                    {
                        stx-staked: new-total-stake,
                        tier-level: (get tier-level tier-info),
                        rewards-multiplier: (* (get reward-multiplier tier-info) lock-multiplier)
                    }
                )
            )
            
            ;; Update STX pool
            (var-set stx-pool (+ (var-get stx-pool) amount))
            (ok true)
        )
    )
)