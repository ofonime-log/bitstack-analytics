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