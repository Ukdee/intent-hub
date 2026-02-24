;; ============================================================
;; Contract: intent-hub.clar
;; Purpose : Intent declaration and execution routing layer
;; ============================================================

;; -------------------------
;; CONSTANTS
;; -------------------------
(define-constant CONTRACT-OWNER (as-contract tx-sender))

;; -------------------------
;; ERRORS
;; -------------------------
(define-constant ERR-NOT-OWNER        (err u20001))
(define-constant ERR-NOT-EXECUTOR     (err u20002))
(define-constant ERR-INTENT-NOT-FOUND (err u20003))
(define-constant ERR-ALREADY-DONE     (err u20004))

;; -------------------------
;; STORAGE
;; -------------------------

;; Approved executors (bots / relayers)
(define-map executors
  principal
  bool
)

;; Intents
(define-map intents
  uint
  {
    owner: principal,
    target: principal,
    function: (string-ascii 32),
    params-hash: (buff 32),
    executed: bool,
    created-at: uint
  }
)

(define-data-var intent-nonce uint u0)

;; -------------------------
;; READ-ONLY HELPERS
;; -------------------------

(define-read-only (is-owner?)
  (is-eq tx-sender CONTRACT-OWNER)
)

(define-read-only (is-executor? (who principal))
  (default-to false (map-get? executors who))
)

;; -------------------------
;; OWNER CONTROLS
;; -------------------------

(define-public (add-executor (executor principal))
  (begin
    (asserts! (is-owner?) ERR-NOT-OWNER)
    (map-set executors executor true)
    (ok true)
  )
)

(define-public (remove-executor (executor principal))
  (begin
    (asserts! (is-owner?) ERR-NOT-OWNER)
    (map-delete executors executor)
    (ok true)
  )
)

;; -------------------------
;; INTENT CREATION
;; -------------------------

(define-public (create-intent
  (target principal)
  (function-name (string-ascii 32))
  (params-hash (buff 32))
)
  (let ((id (+ (var-get intent-nonce) u1)))
    (begin
      (var-set intent-nonce id)
      (map-set intents id {
        owner: tx-sender,
        target: target,
        function: function-name,
        params-hash: params-hash,
        executed: false,
        created-at: u0
      })
      (ok id)
    )
  )
)

;; -------------------------
;; INTENT EXECUTION MARKER
;; -------------------------

(define-public (mark-executed (intent-id uint))
  (begin
    (asserts! (is-executor? tx-sender) ERR-NOT-EXECUTOR)

    (let ((intent (map-get? intents intent-id)))
      (begin
        (asserts! (is-some intent) ERR-INTENT-NOT-FOUND)
        (asserts!
          (not (get executed (unwrap! intent ERR-INTENT-NOT-FOUND)))
          ERR-ALREADY-DONE
        )

        (map-set intents intent-id
          (merge (unwrap! intent ERR-INTENT-NOT-FOUND)
                 { executed: true })
        )

        (ok true)
      )
    )
  )
)

;; -------------------------
;; READ INTERFACE
;; -------------------------

(define-read-only (get-intent (intent-id uint))
  (map-get? intents intent-id)
)
