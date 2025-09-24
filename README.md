StackGuard – Emergency Fund Manager

A Clarity smart contract on the Stacks blockchain that provides a guardian-approved emergency fund system.
Funds can only be withdrawn in emergencies after multiple guardians approve, protecting against unauthorized withdrawals and single-point failures.

✨ Features

Fund Creation

Owners create an emergency fund with an initial STX deposit.

Specify the minimum number of guardian approvals required for withdrawals.

Guardian System

Guardians can be registered to oversee each fund.

Guardians approve emergency withdrawal requests before funds are released.

Emergency Withdrawals (coming in next versions)

Withdrawals require sufficient guardian approvals.

Prevents single-user compromise.

Admin Controls

Contract owner can pause/unpause operations (set-paused).

Only contract owner has global management rights.

Read-Only Functions

is-guardian(fund-id, who) → Check if an address is a guardian.

has-approved(fund-id, who) → Verify if a guardian has approved.

get-approvals-count(fund-id) → View total approvals for a fund.

get-contract-balance() → View total STX held in the contract.

⚙️ Deployment

Deploy the contract on the Stacks blockchain using Clarinet or Stacks CLI.

Initialize by creating funds with the required number of guardians.

Register guardians for each fund.

Owners may later request withdrawals, subject to guardian approval (future feature).

📜 Example Usage
;; Create a fund with 1000 STX requiring 2 guardian approvals
(contract-call? .stackguard create-fund u1000 u2)

;; Check if an address is a guardian for fund 1
(contract-call? .stackguard is-guardian u1 'ST1234...XYZ)

;; Get the total approvals for fund 1
(contract-call? .stackguard get-approvals-count u1)

🚨 Error Codes

ERR-ONLY-OWNER (u100) → Unauthorized caller

ERR-PAUSED (u101) → Contract is paused

ERR-BAD-ARGS (u102) → Invalid arguments provided

ERR-NOT-FOUND (u103) → Fund not found

ERR-ALREADY-CLOSED (u104) → Fund already closed

ERR-INSUFFICIENT-BALANCE (u105) → Not enough balance

ERR-NOT-GUARDIAN (u106) → Caller is not a guardian

ERR-ALREADY-APPROVED (u107) → Guardian already approved

ERR-NOT-PENDING (u108) → No pending withdrawal

ERR-TRANSFER-FAIL (u109) → STX transfer failed

ERR-ZERO (u110) → Zero value not allowed

🔒 Security

Guardian approval prevents misuse of funds.

Owner-only controls for pausing the contract.

Strict checks on arguments and balances.
