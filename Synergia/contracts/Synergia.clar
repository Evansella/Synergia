;; Synergia- Autonomous Blockchain Knowledge Investment Smart Contract

;; Constants
(define-constant PROTOCOL-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED-ACTION (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))
(define-constant ERR-RECORD-NOT-FOUND (err u102))
(define-constant ERR-INVALID-PARAMETER (err u103))

;; State enumerator
(define-constant STATE-ACTIVE u0)
(define-constant STATE-COMPLETE-FUNDED u1)
(define-constant STATE-FINISHED u2)

;; Study ledger
(define-map ledger
  { record-id: uint }
  {
    originator: principal,
    title: (string-utf8 100),
    description: (string-utf8 500),
    target-amount: uint,
    current-total: uint,
    status: uint
  }
)

;; Track next available record ID
(define-data-var next-record-id uint u1)

;; Submit new study proposal
(define-public (propose-study 
  (title (string-utf8 100)) 
  (description (string-utf8 500)) 
  (target-amount uint))
  (begin
    ;; Parameter validation
    (asserts! (>= (len title) u1) ERR-INVALID-PARAMETER)
    (asserts! (>= (len description) u1) ERR-INVALID-PARAMETER)
    (asserts! (> target-amount u0) ERR-INVALID-PARAMETER)
    
    ;; Create record
    (let ((current-record-id (var-get next-record-id)))
      (map-set ledger 
        { record-id: current-record-id }
        {
          originator: tx-sender,
          title: title,
          description: description,
          target-amount: target-amount,
          current-total: u0,
          status: STATE-ACTIVE
        }
      )
      (var-set next-record-id (+ current-record-id u1))
      (ok current-record-id)
    )
  )
)

;; Contribute to study funding
(define-public (fund-proposal (record-id uint) (contribution uint))
  (begin
    ;; Validate input parameters
    (asserts! (> record-id u0) ERR-INVALID-PARAMETER)
    (asserts! (< record-id (var-get next-record-id)) ERR-RECORD-NOT-FOUND)
    (asserts! (> contribution u0) ERR-INVALID-PARAMETER)
    
    (let ((proposal (unwrap! (map-get? ledger { record-id: record-id }) ERR-RECORD-NOT-FOUND)))
      (asserts! (is-eq (get status proposal) STATE-ACTIVE) ERR-UNAUTHORIZED-ACTION)
      (asserts! (<= (+ (get current-total proposal) contribution) (get target-amount proposal)) ERR-INSUFFICIENT-BALANCE)
      
      (try! (stx-transfer? contribution tx-sender (as-contract tx-sender)))
      
      (map-set ledger 
        { record-id: record-id }
        (merge proposal {
          current-total: (+ (get current-total proposal) contribution),
          status: (if (is-eq (+ (get current-total proposal) contribution) (get target-amount proposal))
                     STATE-COMPLETE-FUNDED
                     (get status proposal))
        })
      )
      (ok true)
    )
  )
)

;; Mark study as completed
(define-public (complete-study (record-id uint))
  (begin
    ;; Validate input parameters
    (asserts! (> record-id u0) ERR-INVALID-PARAMETER)
    (asserts! (< record-id (var-get next-record-id)) ERR-RECORD-NOT-FOUND)
    
    (let ((proposal (unwrap! (map-get? ledger { record-id: record-id }) ERR-RECORD-NOT-FOUND)))
      (asserts! (is-eq tx-sender (get originator proposal)) ERR-UNAUTHORIZED-ACTION)
      (asserts! (is-eq (get status proposal) STATE-COMPLETE-FUNDED) ERR-UNAUTHORIZED-ACTION)
      
      (map-set ledger 
        { record-id: record-id }
        (merge proposal { status: STATE-FINISHED })
      )
      (ok true)
    )
  )
)