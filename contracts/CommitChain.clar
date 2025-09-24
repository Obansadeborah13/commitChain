;; =============================================================
;; StackGuard  Emergency Fund Manager
;; - Funds with guardian approvals for emergency withdrawals
;; - Owner creates fund (with initial deposit), adds guardians,
;; owner requests emergency withdraw, guardians approve -> funds released
;; License: MIT
;; =============================================================

;; -----------------------------
;; Errors
;; -----------------------------
(define-constant ERR-ONLY-OWNER (err u100))
(define-constant ERR-PAUSED (err u101))
(define-constant ERR-BAD-ARGS (err u102))
(define-constant ERR_NOT_FOUND (err u103))
(define-constant ERR_ALREADY_CLOSED (err u104))
(define-constant ERR_INSUFFICIENT_BALANCE (err u105))
(define-constant ERR_NOT_GUARDIAN (err u106))
(define-constant ERR_ALREADY_APPROVED (err u107))
(define-constant ERR_NOT_PENDING (err u108))
(define-constant ERR_TRANSFER_FAIL (err u109))
(define-constant ERR_ZERO (err u110))

;; -----------------------------
;; Globals / state
;; -----------------------------
(define-data-var contract-owner principal tx-sender)
(define-data-var paused bool false)
(define-data-var next-fund-id uint u1)

;; -----------------------------
;; Fund struct (stored as map value)
;; Fields:
;; owner: principal
;; balance: uint
;; min-guardians: uint
;; pending: bool ;; emergency requested
;; created-block: uint
;; closed: bool
;; -----------------------------
(define-map funds uint {
  owner: principal,
  balance: uint,
  min_guardians: uint,
  pending: bool,
  created_block: uint,
  closed: bool
})

;; guardian registration: { fund-id, guardian } -> bool
(define-map guardians { fund_id: uint, guardian: principal } bool)

;; approvals: { fund-id, guardian } -> bool
(define-map approvals { fund_id: uint, guardian: principal } bool)

;; approvals-count: fund-id -> uint
(define-map approvals-count uint uint)

;; -----------------------------
;; Helpers / modifiers
;; -----------------------------
(define-private (only-owner)
  (begin 
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-ONLY-OWNER) 
    (ok true)))

(define-private (require-not-paused)
  (begin 
    (asserts! (not (var-get paused)) ERR-PAUSED) 
    (ok true)))

;; -----------------------------
;; Admin: pause/unpause
;; -----------------------------
(define-public (set-paused (p bool))
  (begin
    (try! (only-owner))
    (var-set paused p)
    (print { event: "PausedSet", paused: p, by: tx-sender })
    (ok true)))

;; -----------------------------
;; Create a fund (owner deposits initial amount)
;; - amount: initial STX to lock in fund (must be >0)
;; - min-guardians: number of guardian approvals required for emergency withdrawal
;; -----------------------------
(define-public (create-fund (amount uint) (min-guardians uint))
  (begin
    (try! (require-not-paused))
    (asserts! (> amount u0) ERR_ZERO)
    (asserts! (>= min-guardians u1) ERR-BAD-ARGS)
    ;; user must transfer STX to contract in same call
    (unwrap-panic (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (let ((fid (var-get next-fund-id))
          (now stacks-block-height))
      (map-set funds fid {
        owner: tx-sender,
        balance: amount,
        min_guardians: min-guardians,
        pending: false,
        created_block: now,
        closed: false
      })
      (var-set next-fund-id (+ fid u1))
      (print { event: "FundCreated", fund_id: fid, owner: tx-sender, amount: amount, min_guardians: min-guardians })
      (ok fid))))










(define-read-only (is-guardian (fund-id uint) (who principal))
  (ok (default-to false (map-get? guardians { fund_id: fund-id, guardian: who }))))

(define-read-only (has-approved (fund-id uint) (who principal))
  (ok (default-to false (map-get? approvals { fund_id: fund-id, guardian: who }))))

(define-read-only (get-approvals-count (fund-id uint))
  (ok (default-to u0 (map-get? approvals-count fund-id))))

(define-read-only (get-contract-balance) 
  (ok (stx-get-balance (as-contract tx-sender))))